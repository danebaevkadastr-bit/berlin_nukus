with open('c:/berlin/berlin_nukus/scratch_aufgaben.txt', 'r', encoding='utf-8') as f:
    new_content = f.read()

with open('c:/berlin/berlin_nukus/lib/screens/student/sprechen/sprechen_data.dart', 'r', encoding='utf-8') as f:
    dart_code = f.read()

target = """        ),
      ],
    ),
    SprechenTeil(
      teilNumber: 3,"""

replacement = "        ),\n" + new_content + """      ],
    ),
    SprechenTeil(
      teilNumber: 3,"""

if target in dart_code:
    dart_code = dart_code.replace(target, replacement)
    with open('c:/berlin/berlin_nukus/lib/screens/student/sprechen/sprechen_data.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)
    print("Successfully replaced and updated!")
else:
    print("Target not found!")
