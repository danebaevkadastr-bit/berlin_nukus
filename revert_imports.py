import os
import re

apps_dir = r'C:\berlin\berlin_nukus\apps'
test_dir = r'C:\berlin\berlin_nukus\test'
core_lib_dir = r'C:\berlin\berlin_nukus\packages\core\lib'
core_dirs = ['services', 'core', 'utils', 'l10n', 'widgets', 'models', 'repositories', 'providers']

def revert_bad_imports(directory):
    for root, _, files in os.walk(directory):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                new_content = content
                
                # Find all package:core imports
                matches = re.finditer(r'import\s+[\'\"]package:core/(' + '|'.join(core_dirs) + r')/(.*?)[\'\"]', content)
                for match in matches:
                    d = match.group(1)
                    subpath = match.group(2)
                    
                    # Check if file actually exists in package:core
                    expected_path = os.path.join(core_lib_dir, d, os.path.normpath(subpath))
                    if not os.path.exists(expected_path):
                        print(f"File {expected_path} doesn't exist, reverting in {path}")
                        # Revert it to local import
                        new_content = new_content.replace(
                            f"import 'package:core/{d}/{subpath}'",
                            f"import '{d}/{subpath}'"
                        )
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as file:
                        file.write(new_content)
                    print(f'Reverted bad imports in {path}')

revert_bad_imports(apps_dir)
revert_bad_imports(test_dir)
print('Done.')
