import os

def replace_in_files(directory, old_str, new_str):
    for root, _, files in os.walk(directory):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                new_content = content.replace(old_str, new_str)
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as file:
                        file.write(new_content)
                    print(f'Fixed {path}')

replace_in_files(r'C:\berlin\berlin_nukus\apps\student_app', 'package:berlin_nukus/', 'package:student_app/')
replace_in_files(r'C:\berlin\berlin_nukus\apps\admin_app', 'package:berlin_nukus/', 'package:admin_app/')
replace_in_files(r'C:\berlin\berlin_nukus\apps\teacher_app', 'package:berlin_nukus/', 'package:teacher_app/')
print('Done.')
