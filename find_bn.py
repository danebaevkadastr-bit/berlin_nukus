import os

def find_berlin_nukus():
    for root, dirs, files in os.walk(r'C:\berlin\berlin_nukus'):
        if '.git' in root or '.old_' in root or 'build' in root: continue
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as file:
                        if 'package:berlin_nukus/' in file.read():
                            print('STILL HAS berlin_nukus:', path)
                except Exception as e:
                    pass

find_berlin_nukus()
