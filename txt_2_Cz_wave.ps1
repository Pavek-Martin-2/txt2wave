cls

# prelozi vsechny nalezene textove soubory v cestine ( kodovani UTF8 ) do souboru Wav pripanne take do mp3

Set-PSDebug -Strict # jakakoliv nedeklarovana promenna pri jejim zavolani udela chybu skriptu
#Set-PSDebug -Off
#echo $irtiruturtr

Remove-Variable exist_ffmpeg, prog, file_txt, d_file_txt, input_txt -ErrorAction SilentlyContinue
# pridano 2.11.2025 - pokud by se smazal soubor "ROZTRIDIT_HOVOVE_SOUBORY.bat" tak ho vytvori znova
#$file_bat = "a.txt"
$file_bat = "ROZTRIDIT_HOTOVE_SOUBORY.bat"

$fileExist = Test-Path $file_bat # otestuje exisatenci souboru $file_bat
if ( $fileExist -clike "False" ) { # poukud soubor neexistuje tak to vytvori a naplni ho obsahem z $pole_bat

# pole prikazu davkoveho souboru - uspora pameti, definice pole uvnitr podminky
# pole se definuje pouze v pripade ze je ho opravdu potreba :)
$pole_bat = @(
"@echo off",
"verify on",
"title ROZTRIDIT_HOTOVE_SOUBORY.bat",
"",
"echo roztridi vsechny hotove soubory",
'echo vsechny vygenerovane soubory z priponou "wav" budou presunuty zde do adresare wav/',
'echo vsechny "mp3" presune do adresare mp3/',
'echo a "txt" presune do txt/',
"echo pokud by nejaky z techto adresaru neexistoval program do vytvori",
"echo paklize v nejakem adresari jiz existuje soubor stejneho jmena tak bude bez dotazu prepsan novym",
"pause",
"",
":label_1",
"dir wav > nul",
"if errorlevel == 1 goto chyba_wav",
"move /Y *.wav wav",
"",
":label_2",
"dir mp3 > nul",
"if errorlevel == 1 goto chyba_mp3",
"move /Y *.mp3 mp3",
"",
":label_3",
"dir txt > nul",
"if errorlevel == 1 goto chyba_txt",
"move /Y *.txt txt",
"",
"goto konec",
"",
":chyba_wav",
"mkdir wav",
'echo BYL VYTVOREN NOVY ADRESAR "WAV"',
"goto label_1",
"",
":chyba_mp3",
"mkdir mp3",
'echo BYL VYTVOREN NOVY ADRESAR "MP3"',
"goto label_2",
"",
":chyba_txt",
"mkdir txt",
'echo BYL VYTVOREN NOVY ADRESAR "TXT"',
"goto label_3",
"",
":konec",
"@echo on",
"pause"
)

# samotni zapis souboru bat (pokud by byl smazan)
Set-Content -Path $file_bat -Encoding ASCII -Value $pole_bat
sleep 1
}


# test jestli program nalezl utilitu "ffmpeg" aby bylo moze vytvaret take souboru *.mp3 ( uspora mista na disku )
$exist_ffmpeg = 0


#$prog = "ffmpegXXXX" # testovaci
$prog = "ffmpeg"
if ( Get-Command $prog -ErrorAction SilentlyContinue ){
$exist_ffmpeg = 1

# pridano 16.11.2025, nastaveni hodnoty verbose u vystupu ffmpeg, viz scrennshoty
$pole_lvl = @("quiet", "panic", "fatal", "error", "warning", "info", "verbose", "debug", "trace")
#                0        1        2        3        4          5        6         7        8
$lvl = $pole_lvl[3] # (default=5)

}


# vyhledava *.txt souboru v adrsari
$file_txt = @()
$file_txt += Get-ChildItem -file -Include "*.txt" -Name
#echo $file_txt

$d_file_txt = $file_txt.Length -1
#echo $d_file_txt


# pokud, neni zadny soubor *.txt v adresary
if ( $d_file_txt -lt 0 ){
Write-Host -ForegroundColor Red "nenalezeny zadne soubory 'txt'"
echo "konec"
sleep 5
exit 1    
}


#
Add-Type -AssemblyName System.Speech
$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer

$hlasy = $synth.GetInstalledVoices() | Select-Object -ExpandProperty VoiceInfo # dela vypis hlasu
$d_hlasy = $hlasy.Length -1
#echo $d_hlasy

<#
for ($aa = 0; $aa -le $d_hlasy; $aa++) {
$out_1 = ""
$out_1 += [string] $aa
$out_1 += " - "
$out_1 += $hlasy[$aa].Name
$out_1 += " - "
$out_1 += $hlasy[$aa].Culture.Name
echo $out_1
}

$out_2 = "vyber hlas 0-"
$out_2 += [string] $d_hlasy
$out_2 += " ?"
[int] $volba = Read-Host -Prompt $out_2
#echo $volba
#>

# nejdou otevrit hlasy ktery maj na konci privlastek "Desktop", nezjisteno proc !
# napr. misto hlasu "Microsoft Irina Desktop" vybrat ze seznamu "Microsoft Irina" a pak to funguje


# oprava
# prepsani nalezenich nazvu hlasu do noveho pole z vynechanim vsech co maj na konci "Desktop"
$pole_hlasy_2 = @()
$pole_hlasy_2_jazyk = @()

for ($bb = 0; $bb -le $d_hlasy; $bb++) {

[string] $hlas = $hlasy[$bb].name
#echo $hlas
$test = $hlas.IndexOf("Desktop") # pokud nanajde "Desktop" $test = -1
#echo $test #int32

if ($test -eq -1) {
#echo $hlas
$pole_hlasy_2 += $hlas
$pole_hlasy_2_jazyk += [string] $hlasy[$bb].Culture.Name
}

}

$d_pole_hlasy_2 = $pole_hlasy_2.Length -1

echo "toto je seznam vsech nalezenych hlasu"
echo "ktere jsou dostupne ve funkci predcitani ve Windows"
echo "pokud by v tomto seznamu nejaky naistalovany"
echo "hlas chybel tak sputte soubor 'unlock-win-tts-voices.bat'"
echo "v adresari 'unlock-win-tts-voices-main'"
echo "ale napred si prectete instrukce v souboru"
echo "'unlock-win-tts-voices-main/CTI_ME.txt'"
echo ""

for ($cc = 0; $cc -le $d_pole_hlasy_2; $cc++) {
#echo $cc
$out_2 = ""
$out_2 += [string] $cc
$out_2 +=" - "
$out_2 += $pole_hlasy_2[$cc]
$out_2 +=" - "
$out_2 += $pole_hlasy_2_jazyk[$cc]
echo $out_2
}

#echo "vyber 0 - $d_pole_hlasy_2"
[int] $volba = Read-Host -Prompt "vyber hlas 0 - $d_pole_hlasy_2"
#echo $volba

if (( $volba -lt 0 ) -or ( $volba -gt $d_pole_hlasy_2 )) {
Write-Host -ForegroundColor red "chyba zadani"
echo "konec"
sleep 5
exit 1
}


# mluveni
$synth.SelectVoice($pole_hlasy_2[$volba])
#$synth.SelectVoice("Microsoft Jakub")
#$synth.SelectVoice("Microsoft Hortense")

# Nastavení hlasitosti a rychlosti
$synth.Volume = 100 # hlasitost 0-100 
$synth.Rate = 0 # -10 az 10 ( 0 = normalni rychlost mluveni )

# lze nastavit stereo/mono a frekvenci
#$streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(8000,[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,[System.Speech.AudioFormat.AudioChannel]::Mono)
$streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(16000,[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,[System.Speech.AudioFormat.AudioChannel]::Stereo)
#$streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(16000,[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,[System.Speech.AudioFormat.AudioChannel]::Mono)



for ( $dd = 0; $dd -le $d_file_txt; $dd++ ){
$input_txt = $file_txt[$dd]                                  
#echo $input_txt
#write-host -ForegroundColor Yellow $input_txt

# nazev vystupniho souboru *.wav
$name_wav = $input_txt.Substring(0,$input_txt.Length -3)
$name_wav += "wav"
#echo $name_wav
write-host -ForegroundColor Yellow "$input_txt --> $name_wav"
sleep 2
# smaze stary wav, pokud existuje
Remove-Item -Path $name_wav -Force -ErrorAction SilentlyContinue
sleep 1


# postupne nacteni obsahu vsech nalezenych *.txt souboru v aktualnim adresary
Remove-Variable text -ErrorAction SilentlyContinue

$text = Get-Content $input_txt -Encoding UTF8 # UTF8 je pro cestinu
#Write-Host -ForegroundColor yellow $text 
# melo by se zobrazit jako cesky text z diakritikou ( paklize ne tak je chyba a *.wav bude rikat kraviny )
echo $text
sleep 2

$synth.SetOutputToWaveFile($name_wav, $streamFormat )

$synth.Speak($text)
#$synth.Dispose() # uzavreni streamu

Write-Host -ForegroundColor Cyan "text byl ulozen do souboru '$name_wav'"
sleep 2

# nazev vystupniho souboru *.mp3
if ( $exist_ffmpeg -eq 1 ){
$name_mp3 = $name_wav.Substring(0,$name_wav.Length -3)
$name_mp3 += "mp3"
Write-Host -ForegroundColor Yellow "$name_wav --> $name_mp3"
sleep 2
#echo $name_mp3
# smaze stary mp3, pokud esistuje
Remove-Item -Path $name_mp3 -Force -ErrorAction SilentlyContinue
sleep 1
# & ffmpeg -loglevel $lvl -y -i $name_wav -b:a 192k -vol 1024 $name_mp3
& ffmpeg -y -loglevel $lvl -i $name_wav -vol 1024 $name_mp3 # upraveno 16.11.2025
# & ffmpeg -y -i $name_wav $name_mp3
Write-Host -ForegroundColor Cyan "text byl ulozen do souboru '$name_mp3'"
}

} # for $dd

$synth.Dispose() # uzavreni streamu
echo "vse hotovo"

$out_3 = ""
$out_3 += "nyni muzes spustit soubor "
$out_3 += '"'
$out_3 += $file_bat
$out_3 += '"'
Write-Host -ForegroundColor Yellow $out_3
#Write-Host -ForegroundColor Yellow 'nyni muzes spustit soubor "ROZTRIDIT_HOVOVE_SOUBORY.bat"'
sleep 10

