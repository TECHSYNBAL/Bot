@echo off

REM Build Flutter web app
echo Building Flutter web app...
flutter build web --release

REM Copy vercel.json to build directory
echo Copying Vercel configuration...
copy vercel.json build\web\vercel.json

REM Deploy to Vercel
echo Deploying to Vercel...
cd build\web
vercel --prod


