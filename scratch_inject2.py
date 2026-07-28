with open('c:/berlin/berlin_nukus/scratch_aufgaben.txt', 'r', encoding='utf-8') as f:
    new_content = f.read()

with open('c:/berlin/berlin_nukus/lib/screens/student/sprechen/sprechen_data.dart', 'r', encoding='utf-8') as f:
    dart_code = f.read()

target = """              'Aber ich finde, ein persönlicher Brief hat trotzdem seinen '
              'Wert. Und wie ist deine Meinung dazu?',
        ),
          ],
        ),"""

replacement = target + "\n" + new_content

if target in dart_code:
    dart_code = dart_code.replace(target, replacement, 1)
    with open('c:/berlin/berlin_nukus/lib/screens/student/sprechen/sprechen_data.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)
    print("Successfully replaced and updated!")
else:
    print("Target not found!")
