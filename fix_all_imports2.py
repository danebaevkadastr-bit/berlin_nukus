import os
import re

apps_dir = r'C:\berlin\berlin_nukus\apps'
test_dir = r'C:\berlin\berlin_nukus\test'
core_dirs = ['services', 'core', 'utils', 'l10n', 'widgets', 'models', 'repositories', 'providers']

def process_dir(directory):
    for root, _, files in os.walk(directory):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                new_content = content
                for d in core_dirs:
                    # relative imports with multiple ../
                    new_content = re.sub(r'import\s+[\'\"](?:\.\./)+' + d + r'/(.*?)[\'\"]', r"import 'package:core/" + d + r"/\1'", new_content)
                    # local imports like 'services/...'
                    new_content = re.sub(r'import\s+[\'\"]' + d + r'/(.*?)[\'\"]', r"import 'package:core/" + d + r"/\1'", new_content)

                # fix 'package:berlin_nukus/...' to 'package:core/...' if it matches core_dirs
                for d in core_dirs:
                    new_content = re.sub(r'import\s+[\'\"]package:berlin_nukus/' + d + r'/(.*?)[\'\"]', r"import 'package:core/" + d + r"/\1'", new_content)
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as file:
                        file.write(new_content)
                    print(f'Fixed {path}')

process_dir(apps_dir)
process_dir(test_dir)
print('Done.')
