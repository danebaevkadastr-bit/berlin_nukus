import subprocess
import sys

def build(app):
    print(f"\n============================")
    print(f"Building {app} for web...")
    print(f"============================")
    res = subprocess.run(
        [r'C:\src\flutter\bin\flutter.bat', 'build', 'web', '--no-tree-shake-icons'],
        cwd=f'c:/berlin/berlin_nukus/apps/{app}',
        capture_output=True, text=True, encoding='utf-8', errors='replace'
    )
    sys.stdout.buffer.write(res.stdout.encode('utf-8', errors='replace'))
    sys.stderr.buffer.write(res.stderr.encode('utf-8', errors='replace'))
    if res.returncode != 0:
        print(f"Build failed for {app}")
    else:
        print(f"Build succeeded for {app}")

if __name__ == '__main__':
    build('student_app')
