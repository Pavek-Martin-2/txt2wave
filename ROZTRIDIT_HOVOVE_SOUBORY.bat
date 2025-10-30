@echo off
verify on
title roztridit_hotove_soubory.bat

echo roztridi vsechny hotove soubory
echo vsechny vygenerovane soubory z priponou "wav" budou presunuty zde do adresare wav/
echo vsechny "mp3" presune do adresare mp3/
echo a "txt" presune do txt/
echo paklize v nejakem adresari jiz existuje soubor stejneho jmena tak bude bez dotazu prepsan novym

pause

REM move *.wav wav

move /Y *.wav wav
move /Y *.mp3 mp3
move /Y *.txt txt
REM /Y = nebude se ptat na prepsani jiz existujiciho souboru v nekterem adresari


