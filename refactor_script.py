import os
import re

ROOT_DIR = r"c:\berlin\berlin_nukus"
APPS_DIR = os.path.join(ROOT_DIR, "apps")
PACKAGES_DIR = os.path.join(ROOT_DIR, "packages")
CORE_LIB = os.path.join(PACKAGES_DIR, "core", "lib")

apps = ['student_app', 'teacher_app', 'admin_app']

# 1. Update imports in Core
def refactor_core_imports():
    for root, _, files in os.walk(CORE_LIB):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # In core, anything importing from berlin_nukus should now be package:core
                new_content = re.sub(r"import 'package:berlin_nukus/([^']+)';", r"import 'package:core/\1';", content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)

# 2. Update imports and pubspec in apps
def refactor_apps():
    for app in apps:
        app_dir = os.path.join(APPS_DIR, app)
        app_lib = os.path.join(app_dir, "lib")
        
        # Update pubspec.yaml
        pubspec_path = os.path.join(app_dir, "pubspec.yaml")
        if os.path.exists(pubspec_path):
            with open(pubspec_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Change name
            content = re.sub(r"^name:\s*berlin_nukus", f"name: {app}", content, flags=re.MULTILINE)
            
            # Add dependency to core
            if "core:" not in content:
                content = content.replace("dependencies:", "dependencies:\n  core:\n    path: ../../packages/core")
            
            with open(pubspec_path, 'w', encoding='utf-8') as f:
                f.write(content)

        # Update dart files
        for root, _, files in os.walk(app_lib):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file)
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    original_content = content
                    
                    # Convert berlin_nukus to core for shared folders
                    shared_folders = ['models', 'providers', 'services', 'widgets', 'utils', 'l10n', 'core', 'data']
                    for folder in shared_folders:
                        content = re.sub(r"import 'package:berlin_nukus/" + folder + r"/([^']+)';", r"import 'package:core/" + folder + r"/\1';", content)
                    
                    # Convert remaining berlin_nukus to app name
                    content = re.sub(r"import 'package:berlin_nukus/([^']+)';", f"import 'package:{app}/\\1';", content)
                    
                    if original_content != content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)

if __name__ == "__main__":
    refactor_core_imports()
    refactor_apps()
    print("Refactoring complete.")
