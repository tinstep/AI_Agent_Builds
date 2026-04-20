#!/usr/bin/env python3
"""Merge multiple M3U playlists, deduplicate, and filter exclusions."""
from pathlib import Path
import sys

def read_playlist(path):
    entries = []
    lines = path.read_text().splitlines()
    i = 0
    while i < len(lines):
        if lines[i].startswith('#EXTINF:'):
            title = lines[i].split(',',1)[1].strip()
            filepath = lines[i+1] if i+1 < len(lines) else ''
            entries.append({'title': title, 'filepath': filepath})
            i += 2
        else:
            i += 1
    return entries

def deduplicate(entries):
    seen = set()
    uniq = []
    for e in entries:
        key = e['title'].lower()
        if key not in seen:
            seen.add(key)
            uniq.append(e)
    return uniq

def main():
    base = Path.home()
    hr = base / "hard_rock_raw.m3u"
    cr = base / "classic_rock_raw.m3u"
    rr = base / "rock_raw.m3u"
    nu = base / "nu_metal_playlist.m3u"
    out = base / "rock_playlist_final.m3u"

    # Read
    hr_entries = read_playlist(hr)
    cr_entries = read_playlist(cr)
    rr_entries = read_playlist(rr)
    print(f"Hard Rock raw: {len(hr_entries)} tracks")
    print(f"Classic Rock raw: {len(cr_entries)} tracks")
    print(f"Rock raw: {len(rr_entries)} tracks")

    # Load exclusions from Nu Metal
    exclude = set()
    if nu.exists():
        for line in nu.read_text().splitlines():
            if line.startswith('#EXTINF:'):
                exclude.add(line.split(',',1)[1].strip().lower())
        print(f"Nu Metal exclusions: {len(exclude)} tracks")

    # Merge
    all_entries = hr_entries + cr_entries + rr_entries
    print(f"Combined before dedupe: {len(all_entries)} tracks")

    # Dedupe by title
    uniq = deduplicate(all_entries)
    print(f"After deduplication: {len(uniq)} tracks")

    # Filter Nu Metal
    filtered = [e for e in uniq if e['title'].lower() not in exclude]
    print(f"After Nu Metal filter: {len(filtered)} tracks")

    # Write M3U
    lines = ["#EXTMUSIC"]
    for e in filtered:
        lines.append(f"#EXTINF:-1,{e['title']}")
        lines.append(e['filepath'])
    out.write_text("\n".join(lines)+"\n")
    print(f"\nFinal playlist written to {out}")

if __name__ == '__main__':
    main()
