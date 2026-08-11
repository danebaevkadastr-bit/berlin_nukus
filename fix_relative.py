import os
import re

ROOT_DIR = r"c:\berlin\berlin_nukus"
APPS_DIR = os.path.join(ROOT_DIR, "apps")
apps = ['student_app', 'teacher_app', 'admin_app']
shared_folders = ['models', 'providers', 'services', 'widgets', 'utils', 'l10n', 'core', 'data']

for app in apps:
    app_lib = os.path.join(APPS_DIR, app, "lib")
    for root, _, files in os.walk(app_lib):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                for folder in shared_folders:
                    # Match any number of ../ followed by the folder name
                    content = re.sub(r"import\s+'(?:\.\./)+" + folder + r"/([^']+)';", r"import 'package:core/" + folder + r"/\1';", content)
                
                if original_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                        
print("Relative imports fixed.")
