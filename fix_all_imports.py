import os
import re

apps = ['student_app', 'admin_app', 'teacher_app']
base_dir = 'apps'
core_dirs = ['services', 'core', 'utils', 'l10n', 'widgets', 'models', 'repositories', 'providers']

# Pattern to match: import 'dir/...'; where dir is in core_dirs
# Also handle import '../../dir/...'; which was supposed to be fixed but maybe some were missed
# Also handle import '../dir/...';

for app in apps:
    app_dir = os.path.join(base_dir, app, 'lib')
    if not os.path.exists(app_dir):
        continue
        
    for root, dirs, files in os.walk(app_dir):
        for file in files:
            if not file.endswith('.dart'):
                continue
                
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            
            # Fix imports like import 'services/...' or import '../services/...' or import '../../services/...'
            for c_dir in core_dirs:
                # Match: import 'services/...'
                content = re.sub(r"import\s+['\"]" + c_dir + r"/(.*?)['\"];", r"import 'package:core/" + c_dir + r"/\1';", content)
                # Match: import '../services/...'
                content = re.sub(r"import\s+['\"]\.\./" + c_dir + r"/(.*?)['\"];", r"import 'package:core/" + c_dir + r"/\1';", content)
                # Match: import '../../services/...'
                content = re.sub(r"import\s+['\"]\.\./\.\./" + c_dir + r"/(.*?)['\"];", r"import 'package:core/" + c_dir + r"/\1';", content)
                
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Fixed {file_path}")

print("Done.")
