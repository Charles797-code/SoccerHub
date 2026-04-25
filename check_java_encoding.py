import os

# Use forward slashes
filepath = 'd:/soccer_community/backend/src/main/java/com/soccerhub/FixCircleNames.java'
with open(filepath, 'rb') as f:
    raw = f.read()
print(f'File size: {len(raw)} bytes')
print(f'First 20 hex: {raw[:20].hex()}')
if raw.startswith(b'\xef\xbb\xbf'):
    print('Has UTF-8 BOM')
    text = raw[3:].decode('utf-8')
    for i, line in enumerate(text.split('\n')):
        if any('\u4e00' <= c <= '\u9fff' for c in line):
            print(f'  Line {i}: {line[:80]}')
else:
    print('No BOM')
    for enc in ['utf-8', 'gbk', 'gb2312', 'latin-1']:
        try:
            text = raw.decode(enc)
            print(f'{enc} OK')
            for i, line in enumerate(text.split('\n')):
                if any('\u4e00' <= c <= '\u9fff' for c in line):
                    print(f'  Line {i}: {line[:80]}')
            break
        except Exception as e:
            print(f'{enc}: {e}')
