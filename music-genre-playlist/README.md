# Music Genre Playlist Generator (`musicgen`)

A command-line tool that creates M3U playlists from your local music collection based on a genre, by cross-referencing popular songs from the iTunes API with your locally available tracks.

## Features

- Indexes your music library once and caches metadata (artist, title, album, genre) in SQLite
- Only rescans changed files on subsequent runs (fast incremental updates)
- Fetches current popular songs for a given genre from iTunes Search API (no API key required)
- Fuzzy matches popular songs against your local collection (handles minor differences in artist/title formatting)
- Generates a standard M3U playlist that can be used with any music player
- Designed for large music collections (100k+ tracks) with batch commits to avoid memory issues

## Requirements

- Python 3.10+
- Access to your music library folder: `~/nfs/sm1-music`
- Virtual environment (recommended)

## Installation

1. Clone or copy this project to your machine:

   ```bash
   cd /home/cam/.openclaw/workspace/music-genre-playlist
   ```

2. Create a virtual environment and install dependencies:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

   On Windows use `.venv\Scripts\activate`.

## Usage

### Step 1: Index your music library

The first step is to scan your music folder and build the cache:

```bash
./.venv/bin/python musicgen.py scan
```

Or if virtualenv is active:

```bash
python musicgen.py scan
```

This will walk through `~/nfs/sm1-music`, read metadata from each audio file (FLAC, MP3, M4A, OGG, WAV, etc.), and store it in `~/.cache/musicgen/library.db`.

**Notes:**
- The initial scan can take several minutes for large libraries. Subsequent runs are incremental and very fast.
- You can force a full rescan with `--force`: `musicgen.py scan --force`
- To use a different music folder, add `--music-dir /path/to/music` to any command.

### Step 2: Generate a genre playlist

Once the index is built, generate a playlist for any genre:

```bash
musicgen.py popular "rock" --output rock.m3u
```

Options:
- `--limit N` – how many popular songs to fetch from iTunes (default: 100)
- `--fuzz THRESHOLD` – matching strictness (0.7–0.95). Lower for more relaxed matching.
- `--output FILE` – output path (default: `<genre>_playlist.m3u` in current directory)
- `--songs-file FILE` – use a custom list from a text file (one "Artist - Title" per line) instead of iTunes

The playlist will contain only those songs that are both popular (from iTunes) **and** present in your local collection.

### Using AI-generated song lists

You can also ask an AI assistant to browse the web for "top [genre] songs" and output the results in a file. Save it as `songs.txt` and then run:

```bash
musicgen.py popular "rock" --songs-file songs.txt --output rock.m3u
```

The file should contain one song per line in the format `Artist - Title`. This gives you flexibility to use any source (Last.fm, Wikipedia, your own list) without changing the tool.

## How it works

1. **Indexing (`scan`)**
   - Walks your music directory recursively
   - Reads tags via `mutagen`
   - Stores normalized artist/title for matching
   - Uses file mtime + size checksum to detect changes; unchanged files are skipped

2. **Fetching (`popular`)**
   - Queries iTunes Search API for the genre term
   - Returns up to `limit` songs, sorted by iTunes relevance/popularity
   - (No API key needed; rate limits are generous for light use)

3. **Matching**
   - Normalizes strings: lowercase, strip punctuation, ignore common words like "the" and "and"
   - First tries exact match on normalized `artist title`
   - Falls back to fuzzy ratio (`difflib.SequenceMatcher`) with configurable threshold
   - Returns best match if score exceeds threshold

4. **M3U generation**
   - Writes an extended M3U file with `#EXTINF` lines containing Artist - Title
   - Paths are absolute to work from any working directory

## Example output

```bash
$ musicgen.py popular "alternative" --limit 20
Ensuring library index is up-to-date...
Indexing complete: 0 new, 0 updated, 0 skipped.
Library loaded: 45623 unique tracks.
Fetching top 20 songs for genre 'alternative' from iTunes...
✓ Matched: Radiohead - Creep
✓ Matched: Nirvana - Smells Like Teen Spirit
✗ Not found: Cool Kids -自言
...
Playlist written to alternative_playlist.m3u (12 tracks).
```

The resulting playlist can be opened in VLC, mpv, Foobar2000, Plex, etc.

## Troubleshooting

- **No matches found?** Try lowering `--fuzz` to 0.75 or check that your files have proper artist/title tags.
- **Slow scanning?** The first scan reads metadata from every file. Subsequent scans are incremental.
- **Memory issues on huge libraries?** The matcher loads all track keys into memory (~ couple hundred MB for >100k tracks). If that's a problem, we can move to a SQLite-only matching approach.
- **Different music folder?** Edit `MUSIC_DIR` at the top of `musicgen.py`.
- **Unsupported file types?** Add your extension to `AUDIO_EXTENSIONS` set.

## Future improvements

- Cache iTunes results per genre to reduce API calls
- Support MusicBrainz or Last.fm as alternative sources
- Allow custom genre-to-common-subgenre mapping
- Option to use relative paths in M3U (portable playlists)
- Parallel metadata extraction for faster initial scan

## License

This tool is provided as-is for personal use. Modify as you like.
