#!/usr/bin/env python3
"""
musicgen – Scan local music library and generate M3U playlists
based on genre, using popular songs from iTunes or Spotify APIs.
"""

import os
import sys
import sqlite3
import hashlib
import re
import time
import configparser
from pathlib import Path
from datetime import datetime
from typing import Optional, List, Tuple

import click
from mutagen import File
from mutagen.flac import FLAC
from mutagen.mp3 import MP3
import requests
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import os

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------
MUSIC_DIR = Path.home() / "nfs" / "sm1-music"
CACHE_DIR = Path.home() / ".cache" / "musicgen"
CACHE_DIR.mkdir(parents=True, exist_ok=True)
DB_PATH = CACHE_DIR / "library.db"

# Config file location
CONFIG_PATH = Path.home() / ".config" / "musicgen" / "config.ini"

def _load_spotify_credentials():
    """Load Spotify client_id and client_secret from env or config file."""
    client_id = os.getenv("SPOTIPY_CLIENT_ID")
    client_secret = os.getenv("SPOTIPY_CLIENT_SECRET")
    if client_id and client_secret:
        return client_id, client_secret
    if CONFIG_PATH.exists():
        cp = configparser.ConfigParser()
        cp.read(CONFIG_PATH)
        if 'spotify' in cp:
            section = cp['spotify']
            client_id = section.get('client_id') or client_id
            client_secret = section.get('client_secret') or client_secret
    if client_id and client_secret:
        return client_id, client_secret
    raise RuntimeError(
        "Spotify credentials not found.\n"
        "Set SPOTIPY_CLIENT_ID/SPOTIPY_CLIENT_SECRET env vars, or create a config file at "
        f"{CONFIG_PATH} with [spotify] section and client_id/client_secret keys."
    )

# Supported file extensions (case-insensitive)
AUDIO_EXTENSIONS = {'.flac', '.mp3', '.m4a', '.ogg', '.wav', '.ape', '.wv', '.mpc'}

# ----------------------------------------------------------------------
# Database functions
# ----------------------------------------------------------------------
def init_db():
    """Initialize SQLite database with required tables."""
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS tracks (
            filepath TEXT PRIMARY KEY,
            artist TEXT,
            title TEXT,
            album TEXT,
            genre TEXT,
            mtime REAL,
            checksum TEXT,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    # Index for lookups
    cur.execute('CREATE INDEX IF NOT EXISTS idx_artist_title ON tracks(artist, title)')
    cur.execute('CREATE INDEX IF NOT EXISTS idx_genre ON tracks(genre)')
    conn.commit()
    return conn

def compute_checksum(filepath: Path, size: int) -> str:
    """Quick checksum based on file size and mtime (cheap) or partial content hash."""
    stat = filepath.stat()
    # Use size + mtime as cheap fingerprint
    return hashlib.md5(f"{stat.st_size}_{stat.st_mtime}".encode()).hexdigest()

def normalize_text(s: Optional[str]) -> str:
    """Normalize a string for matching: lowercase, strip, remove punctuation."""
    if not s:
        return ""
    s = s.lower().strip()
    # Remove common punctuation and filler words
    s = re.sub(r'[^\w\s]', ' ', s)       # punctuation -> space
    s = re.sub(r'\b(the|and|a|an)\b', '', s)  # remove articles/conjunctions
    s = re.sub(r'\s+', ' ', s)           # collapse whitespace
    return s.strip()

def index_library(conn, force_rescan: bool = False):
    """Walk the music directory and update the cache with audio file metadata."""
    cur = conn.cursor()
    new_count = 0
    updated_count = 0
    skipped = 0
    batch = 0
    BATCH_SIZE = 1000

    for root, dirs, files in os.walk(MUSIC_DIR):
        for fname in files:
            ext = Path(fname).suffix.lower()
            if ext not in AUDIO_EXTENSIONS:
                continue
            filepath = Path(root) / fname
            abs_path = str(filepath.resolve())
            try:
                stat = filepath.stat()
                mtime = stat.st_mtime
                checksum = compute_checksum(filepath, stat.st_size)

                # Check existing record
                cur.execute("SELECT mtime, checksum FROM tracks WHERE filepath = ?", (abs_path,))
                row = cur.fetchone()
                if row and not force_rescan:
                    old_mtime, old_checksum = row
                    if old_mtime == mtime and old_checksum == checksum:
                        continue  # unchanged

                # Read metadata
                try:
                    audio = File(filepath, easy=True)
                    if audio is None:
                        raise ValueError("Unsupported or corrupt file")
                    artist = audio.get('artist', ['Unknown Artist'])[0]
                    title = audio.get('title', [filepath.stem])[0]
                    album = audio.get('album', ['Unknown Album'])[0]
                    genre = audio.get('genre', [''])[0]
                except Exception as e:
                    click.echo(f"Warning: {abs_path}: {e}", err=True)
                    artist = title = album = genre = ''
                # Upsert
                cur.execute('''
                    INSERT OR REPLACE INTO tracks
                    (filepath, artist, title, album, genre, mtime, checksum, last_updated)
                    VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                ''', (abs_path, artist, title, album, genre, mtime, checksum))
                if row:
                    updated_count += 1
                else:
                    new_count += 1
                batch += 1
                if batch >= BATCH_SIZE:
                    conn.commit()
                    batch = 0
                    click.echo(f"... indexed {new_count + updated_count} files so far")
            except Exception as e:
                skipped += 1
                click.echo(f"Error indexing {filepath}: {e}", err=True)

    conn.commit()
    click.echo(f"Indexing complete: {new_count} new, {updated_count} updated, {skipped} skipped.")

# ----------------------------------------------------------------------
# iTunes API fetch
# ----------------------------------------------------------------------
ITUNES_SEARCH_URL = "https://itunes.apple.com/search"

def fetch_popular_songs(genre: str, limit: int = 50, source: str = 'itunes') -> List[dict]:
    """Fetch popular songs for a genre from the specified source."""
    if source == 'itunes':
        return _fetch_itunes(genre, limit)
    elif source == 'spotify':
        return _fetch_spotify(genre, limit)
    else:
        raise ValueError(f"Unknown source: {source}")

# ----------------------------------------------------------------------
# iTunes backend
# ----------------------------------------------------------------------
ITUNES_SEARCH_URL = "https://itunes.apple.com/search"

def _fetch_itunes(genre: str, limit: int = 50) -> List[dict]:
    """Query iTunes API for popular songs in the given genre."""
    params = {
        "term": genre,
        "entity": "song",
        "limit": limit,
        "country": "US",
    }
    resp = requests.get(ITUNES_SEARCH_URL, params=params, timeout=15)
    resp.raise_for_status()
    data = resp.json()
    results = data.get("results", [])
    click.echo(f"Fetched {len(results)} songs from iTunes for genre '{genre}' (raw search results).")
    return results

# ----------------------------------------------------------------------
# Spotify backend
# ----------------------------------------------------------------------
def _fetch_spotify(genre: str, limit: int = 50) -> List[dict]:
    """Fetch top tracks for a genre from Spotify API, sorted by popularity."""
    client_id, client_secret = _load_spotify_credentials()

    auth_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
    sp = spotipy.Spotify(auth_manager=auth_manager)

    all_tracks = []
    per_page = min(50, limit)  # Spotify max per request
    pages = (limit + per_page - 1) // per_page

    for page in range(pages):
        offset = page * per_page
        try:
            results = sp.search(q=f'genre:"{genre}"', type='track', limit=per_page, offset=offset)
        except spotipy.SpotifyException as e:
            if e.http_status == 429:
                retry_after = int(e.headers.get('Retry-After', 5))
                click.echo(f"Rate limited. Waiting {retry_after}s...")
                time.sleep(retry_after)
                results = sp.search(q=f'genre:"{genre}"', type='track', limit=per_page, offset=offset)
            else:
                raise
        tracks = results.get('tracks', {}).get('items', [])
        if not tracks:
            break
        for t in tracks:
            artist = t['artists'][0]['name'] if t['artists'] else 'Unknown Artist'
            all_tracks.append({
                'artistName': artist,
                'trackName': t['name'],
                'popularity': t.get('popularity', 0)
            })
        if len(tracks) < per_page:
            break

    # Sort by popularity descending and take top 'limit'
    all_tracks.sort(key=lambda x: x['popularity'], reverse=True)
    click.echo(f"Fetched {len(all_tracks)} tracks from Spotify for genre '{genre}' (sorted by popularity).")
    return all_tracks[:limit]

# ----------------------------------------------------------------------
# Matching
# ----------------------------------------------------------------------
def load_library(conn) -> dict:
    """Load entire track cache into a dict keyed by normalized artist+title."""
    cur = conn.cursor()
    cur.execute("SELECT artist, title, filepath FROM tracks")
    rows = cur.fetchall()
    library = {}
    for artist, title, filepath in rows:
        key = normalize_text(f"{artist} {title}")
        library.setdefault(key, []).append({"artist": artist, "title": title, "filepath": filepath})
    return library

def match_local_track(library: dict, artist: str, title: str, fuzzy_threshold: float = 0.85):
    """Find best match in library for given artist+title."""
    from difflib import SequenceMatcher
    key = normalize_text(f"{artist} {title}")
    if key in library:
        return library[key][0]
    # Fuzzy fallback
    best_match = None
    best_score = 0.0
    for lib_key, tracks in library.items():
        score = SequenceMatcher(None, key, lib_key).ratio()
        if score > best_score and score >= fuzzy_threshold:
            best_score = score
            best_match = tracks[0]
    return best_match

# ----------------------------------------------------------------------
# M3U generation
# ----------------------------------------------------------------------
def write_m3u(matches: List[dict], output_path: Path):
    """Write matched tracks to an M3U playlist file."""
    lines = ["#EXTMUSIC"]
    for m in matches:
        # EXTINF line: duration is unknown -> -1
        # Format: #EXTINF:-1,Artist - Title
        line = f"#EXTINF:-1,{m['artist']} - {m['title']}"
        lines.append(line)
        lines.append(m['filepath'])
    output_path.write_text("\n".join(lines) + "\n")
    click.echo(f"Playlist written to {output_path} ({len(matches)} tracks).")

# ----------------------------------------------------------------------
# CLI
# ----------------------------------------------------------------------
@click.group()
@click.option('--music-dir', type=click.Path(exists=True, file_okay=False, dir_okay=True), help='Path to music library (default: ~/nfs/sm1-music)')
def cli(music_dir):
    """Music genre playlist generator."""
    if music_dir:
        global MUSIC_DIR
        MUSIC_DIR = Path(music_dir).expanduser().resolve()

@cli.command()
@click.option('--force', is_flag=True, help="Force rescan of all files")
def scan(force: bool = False):
    """Scan music directory and build/update the local cache."""
    conn = init_db()
    try:
        index_library(conn, force_rescan=force)
    finally:
        conn.close()

@cli.command()
@click.argument('genre')
@click.option('--limit', default=100, help="Number of popular songs to fetch")
@click.option('--output', '-o', type=click.Path(), help="Output M3U file path")
@click.option('--fuzzy', default=0.85, help="Fuzzy matching threshold (0-1)")
@click.option('--songs-file', type=click.File('r'), help="File with one 'Artist - Title' per line; overrides API fetch")
@click.option('--source', type=click.Choice(['itunes', 'spotify']), default='itunes', help='Source for popular songs (default: itunes)')
def popular(genre: str, limit: int, output: Optional[str], fuzzy: float, songs_file, source: str):
    """Fetch popular songs for a genre, match against local library, generate M3U."""
    conn = init_db()
    try:
        # Ensure library is indexed (quick check will skip unchanged files)
        click.echo("Ensuring library index is up-to-date...")
        index_library(conn, force_rescan=False)

        # Load library into memory for fast matching
        library = load_library(conn)
        click.echo(f"Library loaded: {len(library)} unique tracks.")

        if songs_file:
            click.echo(f"Reading songs from {songs_file.name}...")
            songs = []
            for line in songs_file:
                line = line.strip()
                if not line:
                    continue
                if ' - ' in line:
                    artist, title = line.split(' - ', 1)
                    songs.append({"artistName": artist, "trackName": title})
                else:
                    click.echo(f"Warning: skipping malformed line: {line}", err=True)
        else:
            click.echo(f"Fetching top {limit} songs for genre '{genre}' from {source}...")
            songs = fetch_popular_songs(genre, limit=limit, source=source)

        matches = []
        for song in songs:
            artist = song.get("artistName", "")
            title = song.get("trackName", "")
            match = match_local_track(library, artist, title, fuzzy_threshold=fuzzy)
            if match:
                matches.append(match)
                click.echo(f"✓ Matched: {artist} - {title}")
            else:
                click.echo(f"✗ Not found: {artist} - {title}")

        if not matches:
            click.echo("No matching songs found in your library.")
            return

        if not output:
            safe_genre = re.sub(r'[^\w-]', '_', genre).lower()
            output_path = Path.cwd() / f"{safe_genre}_playlist.m3u"
        else:
            output_path = Path(output)

        write_m3u(matches, output_path)
    finally:
        conn.close()

@cli.command()
@click.argument('genre')
@click.option('--limit', default=100, help="Number of popular songs to fetch")
@click.option('--source', type=click.Choice(['itunes', 'spotify']), default='itunes', help='Source for popular songs')
def playlist(genre: str, limit: int, source: str):
    """Shortcut: fetch and generate playlist with default name."""
    # Use popular command internally
    ctx = click.get_current_context()
    ctx.invoke(popular, genre=genre, limit=limit, output=None, fuzzy=0.85, source=source)

if __name__ == '__main__':
    cli()
