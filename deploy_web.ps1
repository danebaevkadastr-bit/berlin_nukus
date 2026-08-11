Set-Location "c:\berlin\berlin_nukus\apps\student_app"
Write-Host "Building Student App..."
flutter build web --no-tree-shake-icons

Set-Location "c:\berlin\berlin_nukus\apps\teacher_app"
Write-Host "Building Teacher App..."
flutter build web --no-tree-shake-icons

Set-Location "c:\berlin\berlin_nukus\apps\admin_app"
Write-Host "Building Admin App..."
flutter build web --no-tree-shake-icons

Set-Location "c:\berlin\berlin_nukus"
Write-Host "Deploying to Firebase..."
firebase deploy
