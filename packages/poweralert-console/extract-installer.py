"""Extract the MSI from PowerAlert's InstallShield SetupStream v3 payload."""

import struct
import sys
import zlib
from pathlib import Path

data = Path(sys.argv[1]).read_bytes()
# The stream follows the PE sections; its signature also occurs in executable
# code, so locate the overlay through the PE header rather than a text search.
pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
section_count = struct.unpack_from("<H", data, pe_offset + 6)[0]
optional_header_size = struct.unpack_from("<H", data, pe_offset + 20)[0]
sections_offset = pe_offset + 24 + optional_header_size
offset = max(
    sum(struct.unpack_from("<II", data, sections_offset + i * 40 + 16))
    for i in range(section_count)
)
if data[offset : offset + 14] != b"ISSetupStream\0":
    raise ValueError("No InstallShield SetupStream found after PE sections")
file_count, stream_version = struct.unpack_from("<HI", data, offset + 14)
if stream_version != 3:
    raise ValueError(f"Unsupported InstallShield stream version: {stream_version}")
offset += 46

for _ in range(file_count):
    name_length, flags = struct.unpack_from("<II", data, offset)
    size = struct.unpack_from("<I", data, offset + 10)[0]
    compressed = struct.unpack_from("<H", data, offset + 22)[0]
    offset += 24
    name = data[offset : offset + name_length].decode("utf-16le").rstrip("\0")
    offset += name_length
    payload = data[offset : offset + size]
    offset += size
    if not name.endswith(".msi"):
        continue
    if flags != 6 or not compressed or len(payload) != size:
        raise ValueError("Unexpected MSI encoding in InstallShield payload")

    # SetupStream v3 uses a filename-derived key, restarted every 1024 bytes,
    # followed by a zlib-compressed stream.
    magic = b"\x13\x35\x86\x07"
    key = bytes(byte ^ magic[i % 4] for i, byte in enumerate(name.encode()))
    decoded = bytes(
        ~(key[(i % 1024) % len(key)] ^ ((byte << 4) | (byte >> 4))) & 255
        for i, byte in enumerate(payload)
    )
    msi = zlib.decompress(decoded)
    if not msi.startswith(b"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1"):
        raise ValueError("Decoded payload is not an MSI compound file")
    Path("launcher.msi").write_bytes(msi)
    break
else:
    raise ValueError("No MSI found in InstallShield payload")
