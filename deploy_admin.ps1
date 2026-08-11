Set-Location "c:\berlin\berlin_nukus\apps\admin_app"
Write-Host "Cleaning Admin App..."
flutter clean
Write-Host "Building Admin App..."
flutter build web --no-tree-shake-icons

Set-Location "c:\berlin\berlin_nukus"
Write-Host "Deploying Admin App to Firebase..."
firebase deploy --only hosting:berlin-nukus-n1-admin
