import subprocess
import sys
import os

apps = ['student_app', 'admin_app', 'teacher_app']

for app in apps:
    print(f"--- Building {app} ---")
    app_dir = os.path.join("apps", app)
    
    # pub get
    print("Running pub get...")
    subprocess.run(["flutter", "pub", "get"], cwd=app_dir, shell=True, check=True)
    
    # build web
    print("Running build web...")
    subprocess.run(["flutter", "build", "web"], cwd=app_dir, shell=True, check=True)
    
    # deploy
    target = app.replace("_app", "")
    print(f"Running deploy for {target}...")
    subprocess.run(["firebase", "deploy", "--only", f"hosting:{target}"], shell=True, check=True)

print("ALL DONE!")
