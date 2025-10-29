cls

Add-Type -AssemblyName System.Speech

$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer

$synth.GetInstalledVoices() | Select-Object -ExpandProperty VoiceInfo

$pole_hlasy = @(
"Microsoft Zira", # 0 eng.
"Microsoft Jakub", # 1 Cestina
"Microsoft Hedda", # 2
"Microsoft Katja", # 3
"Microsoft Stefan", # 4
"Microsoft David", # 5
"Microsoft Mark", # 6
"Microsoft Zira", # 7
"Microsoft Hortense", # 8
"Microsoft Julie", # 9
"Microsoft Paul", # 10
"Microsoft Andrei", # 11
"Microsoft Irina", # 12
"Microsoft Pavel", # 13
"Microsoft Filip", # 14
"Microsoft Hedda", # 15
"Microsoft David", # 16
"Microsoft Ivan", # 17
"Microsoft Hortense", # 18
"Microsoft Irina" # 19
)

echo $pole_hlasy.Length

$synth.SelectVoice($pole_hlasy[1]) # tady menit cislo (1 = cestina)

<#
$synth.SelectVoice("Microsoft Zira")
$synth.SelectVoice("Microsoft Irina")
$synth.SelectVoice("Microsoft Jakub")
#>

$synth.Rate = 0
# rychlost mluveni -10(slow), 10(fast)

$synth.Volume = 100
# 0(quiet), 100(loud)


for (;;) {
# infinite loop
$rekni = Read-Host -Prompt "co se ma rict ? "
#echo $rekni
#echo $rekni.GetType()
$synth.Speak($rekni)
sleep -Milliseconds 500
}

