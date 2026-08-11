Stop-Process -Name "dart" -Force -ErrorAction SilentlyContinue
flutter clean
flutter pub get
flutter build web
