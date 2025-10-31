cls

# prelozi vsechny nalezene textove soubory v cestine ( kodovani UTF8 ) do souboru Wav pripanne take do mp3

# test jestli program nalezl utilitu "ffmpeg" aby bylo moze vytvaret take souboru *.mp3 ( uspora mista na disku )
Remove-Variable exist_ffmpeg, prog, file_txt, d_file_txt, input_txt -ErrorAction SilentlyContinue
$exist_ffmpeg = 0

#$prog = "ffmpegXXXX" # testovaci
$prog = "ffmpeg"
if ( Get-Command $prog -ErrorAction SilentlyContinue ){
$exist_ffmpeg = 1
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
ffmpeg -y -i $name_wav -b:a 192k -vol 1024 $name_mp3
#ffmpeg -y -i $name_wav $name_mp3
Write-Host -ForegroundColor Cyan "text byl ulozen do souboru '$name_mp3'"
}

} # for $dd

$synth.Dispose() # uzavreni streamu
echo "vse hotovo"

sleep 10

