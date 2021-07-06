@echo off
setlocal
del docs\*.png
call flutter pub global run dartdoc:dartdoc --output docs
copy doc\*.png docs
echo Done!
endlocal
