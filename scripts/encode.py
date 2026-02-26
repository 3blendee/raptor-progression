#!/usr/bin/env python3
"""Encode Lua tweakdefs/tweakunits files to base64url and generate lobby commands."""

import base64
import os
import sys

LUA_DIR = os.path.join(os.path.dirname(__file__), '..', 'lua')
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'base64url')
DOCS_DIR = os.path.join(os.path.dirname(__file__), '..', 'docs')

# Filename -> lobby slot name mapping
SLOT_MAP = {
    'tweakdefs.lua':  'tweakdefs',
    'tweakdefs1.lua': 'tweakdefs1',
    'tweakdefs2.lua': 'tweakdefs2',
    'tweakdefs3.lua': 'tweakdefs3',
    'tweakdefs4.lua': 'tweakdefs4',
    'tweakdefs5.lua': 'tweakdefs5',
    'tweakunits.lua':  'tweakunits',
    'tweakunits1.lua': 'tweakunits1',
}

CHAR_LIMIT = 50000

# Lobby setup commands (run before modoptions)
LOBBY_COMMANDS = [
    '!rename Raptor Unit Focused',
    '!map Full Metal Plate',
]

# Modoptions for raptor progression game mode
MODOPTIONS = [
    '!bset raptor_raptorstart alwaysbox',
    '!bset raptor_endless 0',
    '!bset raptor_queencount 1',
    '!bset raptor_queenhatchtimemult 0.7',
    '!bset raptor_graceperiodmult 0.8',
    '!bset raptor_wavefrequencymult 1.3',
    '!bset raptor_unitspawnmult 1.2',
    '!bset raptor_difficulty normal',
    '!bset startmetal 1500',
    '!bset startenergy 1500',
    '!bset startmetalstorage 1500',
    '!bset startenergystorage 1500',
    '!bset startoptions_startpos chooseinlobby',
]


def encode_base64url(data: bytes) -> str:
    """Encode bytes to base64url without padding."""
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode('ascii')


def decode_base64url(s: str) -> bytes:
    """Decode base64url string (add back padding)."""
    padding = 4 - len(s) % 4
    if padding != 4:
        s += '=' * padding
    return base64.urlsafe_b64decode(s)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(DOCS_DIR, exist_ok=True)

    commands = []
    errors = []

    # Process each Lua file
    for filename in sorted(SLOT_MAP.keys()):
        filepath = os.path.join(LUA_DIR, filename)
        if not os.path.exists(filepath):
            print(f"  SKIP  {filename} (not found)")
            continue

        with open(filepath, 'r', encoding='utf-8') as f:
            lua_source = f.read()

        encoded = encode_base64url(lua_source.encode('utf-8'))
        slot_name = SLOT_MAP[filename]

        # Write encoded file
        out_path = os.path.join(OUT_DIR, f'{slot_name}.b64')
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(encoded)

        # Verify round-trip
        decoded = decode_base64url(encoded).decode('utf-8')
        if decoded != lua_source:
            errors.append(f"  FAIL  {filename}: round-trip mismatch!")
            print(f"  FAIL  {filename}: round-trip mismatch!")
        else:
            command = f'!bset {slot_name} {encoded}'
            char_count = len(command)
            status = "OK" if char_count <= CHAR_LIMIT else "OVER LIMIT"
            print(f"  {status:>10}  {filename} -> {slot_name} ({char_count:,} chars)")
            if char_count > CHAR_LIMIT:
                errors.append(f"  OVER  {filename}: {char_count:,} chars > {CHAR_LIMIT:,} limit")
            commands.append(command)

    # Write lobby-commands.txt
    lobby_path = os.path.join(DOCS_DIR, 'lobby-commands.txt')
    with open(lobby_path, 'w', encoding='utf-8') as f:
        f.write("# Raptor Progression — Lobby Commands\n")
        f.write("# Paste these into BAR lobby chat after !boss\n")
        f.write("# ==========================================\n\n")

        f.write("# --- Lobby Setup ---\n")
        for cmd in LOBBY_COMMANDS:
            f.write(cmd + '\n')

        f.write("\n# --- Modoptions ---\n")
        for cmd in MODOPTIONS:
            f.write(cmd + '\n')

        f.write("\n# --- Tweakdefs & Tweakunits ---\n")
        for cmd in commands:
            f.write(cmd + '\n')

    print(f"\n  Generated {len(commands)} encoded commands -> docs/lobby-commands.txt")

    if errors:
        print("\n  ERRORS:")
        for e in errors:
            print(e)
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
