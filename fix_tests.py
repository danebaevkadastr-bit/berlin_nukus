import os
for root, _, files in os.walk(r'apps\student_app\test'):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                c = file.read()
            if 'package:berlin_nukus/' in c:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(c.replace('package:berlin_nukus/', 'package:student_app/'))
                print('Fixed', path)
