@echo off
verify on
title ROZTRIDIT_HOVOVE_SOUBORY.bat

echo roztridi vsechny hotove soubory
echo vsechny vygenerovane soubory z priponou "wav" budou presunuty zde do adresare wav/
echo vsechny "mp3" presune do adresare mp3/
echo a "txt" presune do txt/
echo pokud by nejaky z techto adresaru neexistoval program do vytvori
echo paklize v nejakem adresari jiz existuje soubor stejneho jmena tak bude bez dotazu prepsan novym
pause

:label_1
dir wav > nul
if errorlevel == 1 goto chyba_wav
move /Y *.wav wav

:label_2
dir mp3 > nul
if errorlevel == 1 goto chyba_mp3
move /Y *.mp3 mp3

:label_3
dir txt > nul
if errorlevel == 1 goto chyba_txt
move /Y *.txt txt

goto konec

:chyba_wav
mkdir wav
echo BYL VYTVOREN NOVY ADRESAR "WAV"
goto label_1

:chyba_mp3
mkdir mp3
echo BYL VYTVOREN NOVY ADRESAR "MP3"
goto label_2

:chyba_txt
mkdir txt
echo BYL VYTVOREN NOVY ADRESAR "TXT"
goto label_3

:konec
@echo on
pause
