@echo off
set PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files\Git\cmd
flutter pub get
flutter build web --no-tree-shake-icons
