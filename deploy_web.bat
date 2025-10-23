@echo off
echo Building Flutter web app...
flutter build web

echo Copying to docs folder...
xcopy build\web\* docs\ /s /e /y

echo Committing changes...
git add docs
git commit -m "Update site"
git push origin main

echo ✅ Deployment complete!
pause
