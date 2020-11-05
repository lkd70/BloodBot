; Created by LKD70, October 2020
; This project and all of its resources are published under the MIT license.
; A copy of this license can be obtained at: https://github.com/lkd70/BloodBot/blob/main/LICENSE


global Stats_Runs := 0

; ===============================
; Configuration file handling
; ===============================

global CorrectConfigVersion := 7
global ConfigPath := A_WorkingDir "\BloodBot.ini"
global MyHP := 0
global lowestDesiredHP := 0
global ExtraRestSeconds := 0
global TekPodHoldDownTimeout := 0
global TekPodMoveYDist := 0

;defaults for 1920*1080 with ini
global TekPodIconCoordsX := 1712
global TekPodIconCoordsY := 1019
global TekPodIconColour := 0xA48A27
global FridgeIconCoordsX := 765
global FridgeIconCoordsY := 557
global FridgeIconColour := 0xC1F5FF
global EngramSlotCoordsX := 0
global EngramSlotCoordsY := 0
global SearchBoxCoordsX := 0
global SearchBoxCoordsY := 0
global TransferAllButtonCoordsX := 0
global TransferAllButtonCoordsY := 0

if (FileExist(ConfigPath) != "") {
	; If the file exists, load it.
	IniRead, configVersion, %ConfigPath%, config, configVersion, 0
	if (configVersion = 0) {
			MsgBox, Looks like we're using an old config, let's update it!
			CreateConfig() ; Config version is less than 1 or unknown, let's start again.
		} else {
			; Check if config version is up to date
			if (configVersion = CorrectConfigVersion) {
				; We're all good. Load up the config!
				LoadConfig()
			} else {
				; Seems the config version isn't right. Let's create it again...
				MsgBox, Looks like we're using an old config, let's update it!
				CreateConfig()
			}
		}
} else {
	; The file doesn't exist. Let's create it.
	CreateConfig()
}

; ===============================
; End Configuration file handling
; ===============================


; ===============================
; Calculate rates and speeds
; ===============================
; I do this to basically show how it works rather than just hardcoding the maths
bloodGiven := 25 ; This might change in the future in Ark official. You never know...
usesOfExtractor := Floor((MyHP-lowestDesiredHP)/bloodGiven)
secondsForFull := ((MyHP / 10) * 1.3) + ExtraRestSeconds
; ===============================
; End Calculate rates and speeds
; ===============================


; ===============================
; Start workflow
; ===============================
MsgBox, F2: Start`rF4: Pause/Play`r`rBlood packs per run: %usesOfExtractor%`nStand OVER (not in) your tek pod and hit F2 to begin.
SetTimer Blood, On
CoordMode, Mouse, Client
Return
; ===============================
; End Start Workflow
; ===============================


; ===============================
; Define HotKeys
; ===============================
f9:: ExitApp, 0

f4:: Pause

F2::BloodToggle := !BloodToggle
	Blood:
		If (!BloodToggle)
			Return
		useTekPod()
		SecondsSleep(secondsForFull)
		Send E ; Exit tekpod
		sleep 1000
		leavePodOpenInventory()
		Sleep 500
		MouseMove, SearchBoxCoordsX, SearchBoxCoordsY, 1
		Sleep 500
		Click
		sleep 100
		SendInput, Extraction
		MouseMove, EngramSlotCoordsX, EngramSlotCoordsY, 1
		ToolTip, Bleeding, 0, 0
		Sleep 500
		SpamE(usesOfExtractor)
		Sleep 500
		MouseMove, TransferAllButtonCoordsX, TransferAllButtonCoordsY, 1 ; transfer all
		Sleep, 500
		click
		sleep, 50
		click
		sleep, 50
		ToolTip, Done, 0, 0
		sleep 500
		Send F
		sleep 1000
		Stats_Runs := Stats_Runs + 1
	Return
; ===============================
; End Define HotKeys
; ===============================


; ===============================
; Define runtime functions
; ===============================
CreateConfig() {
	MsgBox, We need to do a little setup in order for this script to work to its highest abilities.`nLet's get started.
	;; HP stat
	InputBox, _MyHP, HP, Please input your HP stat:,, 190, 150, Locale, 60, 100
	IniWrite, %_MyHP%, %ConfigPath%, settings, MyHP

	SplashTextOn, 500, 300, Setup: Positioning, Right let's get started.`nFor this script to work it requires a basic setup:`n`nA tek pod - a fridge infront of said tekpod.`nPositioning is key here - if the tek pod isn't accesible by looking right down once you've accessed the fridge, you need to reposition.`nThe fridge should be accessed without moving once leaving the tek pod.`n`nPlease get in your tek pod and click "R" to continue
	TekPodIconCoords := getTekpodPositioning()
	StringSplit, TekPodIconCoordsArray, TekPodIconCoords, "|"
	_TekPodIconCoordsX := TekPodIconCoordsArray1
	_TekPodIconCoordsY := TekPodIconCoordsArray2
	click
	PixelGetColor, _TekPodIconColour, %_TekPodIconCoordsX%, %_TekPodIconCoordsY%, Fast RGB
	TekPodIconColour = %_TekPodIconColour%
	SplashTextOn, 500, 100, Setup: Positioning, Sweet! Now with that info we can continue to setting up the fridge details...`nPlease exit the tek pod and open the fridge inventory. Once you've done that, hit "R" again to continue...
	FridgeCoords := getFridgePositioning()
	StringSplit, FridgeCoordsArray, FridgeCoords, "|"
	_FridgeIconCoordsX := FridgeCoordsArray1
	_FridgeIconCoordsY := FridgeCoordsArray2
	SplashTextOff
	ToolTip, Just a sec..., 0, 0
	sleep 100
	click
	sleep 1000
	PixelGetColor, _FridgeIconColor, %_FridgeIconCoordsX%, %_FridgeIconCoordsY%, Fast RGB
	FridgeIconColour = %_FridgeIconColor%
	ToolTip, ,0, 0

	sleep 100

	SearchBoxCoords := getSearchPositioning()
	StringSplit, SearchBoxCoordsArray, SearchBoxCoords, "|"
	_SearchBoxCoordsX := SearchBoxCoordsArray1
	_SearchBoxCoordsY := SearchBoxCoordsArray2

	EngramSlotCoords := getEngramPositioning()
	StringSplit, EngramSlotCoordsArray, EngramSlotCoords, "|"
	_EngramSlotCoordsX := EngramSlotCoordsArray1
	_EngramSlotCoordsY := EngramSlotCoordsArray2

	TransferAllCoords := getTransferAllPositioning()
	StringSplit, TransferAllButtonArray, TransferAllCoords, "|"
	_TransferAllButtonCoordsX := TransferAllButtonArray1
	_TransferAllButtonCoordsY := TransferAllButtonArray2

	EngramSlotCoordsX = %_EngramSlotCoordsX%
	EngramSlotCoordsY = %_EngramSlotCoordsY%
	SearchBoxCoordsX = %_SearchBoxCoordsX%
	SearchBoxCoordsY = %_SearchBoxCoordsY%
	TransferAllButtonCoordsX = %_TransferAllButtonCoordsX%
	TransferAllButtonCoordsY = %_TransferAllButtonCoordsY%
	TekPodIconCoordsX = %_TekPodIconCoordsX%
	TekPodIconCoordsY = %_TekPodIconCoordsY%
	FridgeIconCoordsX = %_FridgeIconCoordsX%
	FridgeIconCoordsY = %_FridgeIconCoordsY%

	IniWrite, %EngramSlotCoordsX%, %ConfigPath%, settings, EngramSlotCoordsX
	IniWrite, %EngramSlotCoordsY%, %ConfigPath%, settings, EngramSlotCoordsY
	IniWrite, %TransferAllButtonCoordsX%, %ConfigPath%, settings, TransferAllButtonCoordsX
	IniWrite, %TransferAllButtonCoordsY%, %ConfigPath%, settings, TransferAllButtonCoordsY
	IniWrite, %SearchBoxCoordsX%, %ConfigPath%, settings, SearchBoxCoordsX
	IniWrite, %SearchBoxCoordsY%, %ConfigPath%, settings, SearchBoxCoordsY
	IniWrite, %TekPodIconCoordsX%, %ConfigPath%, settings, TekPodIconCoordsX
	IniWrite, %TekPodIconCoordsY%, %ConfigPath%, settings, TekPodIconCoordsY
	IniWrite, %TekPodIconColour%, %ConfigPath%, settings, TekPodIconColour
	IniWrite, %FridgeIconCoordsX%, %ConfigPath%, settings, FridgeIconCoordsX
	IniWrite, %FridgeIconCoordsY%, %ConfigPath%, settings, FridgeIconCoordsY
	IniWrite, %FridgeIconColour%, %ConfigPath%, settings, FridgeIconColour

	; predefined settings
	IniWrite, 50, %ConfigPath%, settings, lowestDesiredHP
	IniWrite, 500, %ConfigPath%, settings, TekPodHoldDownTimeout
	IniWrite, 500, %ConfigPath%, settings, TekPodMoveYDist
	IniWrite, 10, %ConfigPath%, settings, ExtraRestSeconds
	IniWrite, %CorrectConfigVersion%, %ConfigPath%, config, configVersion
	MyHP := _MyHP
	TekPodHoldDownTimeout := 500
	TekPodMoveYDist := 20
	lowestDesiredHP := 50
	ExtraRestSeconds := 10
	return LoadConfig()
}

LoadConfig() {
	IniRead, _EngramSlotCoordsX, %ConfigPath%, settings, EngramSlotCoordsX, 0
	IniRead, _EngramSlotCoordsY, %ConfigPath%, settings, EngramSlotCoordsY, 0
	IniRead, _SearchBoxCoordsX, %ConfigPath%, settings, SearchBoxCoordsX, 0
	IniRead, _SearchBoxCoordsY, %ConfigPath%, settings, SearchBoxCoordsY, 0
	IniRead, _TransferAllButtonCoordsX, %ConfigPath%, settings, TransferAllButtonCoordsX, 0
	IniRead, _TransferAllButtonCoordsY, %ConfigPath%, settings, TransferAllButtonCoordsY, 0
	IniRead, _TekPodIconCoordsX, %ConfigPath%, settings, TekPodIconCoordsX, 1712
	IniRead, _TekPodIconCoordsY, %ConfigPath%, settings, TekPodIconCoordsY, 1019
	IniRead, _TekPodIconColour, %ConfigPath%, settings, TekPodIconColour, 0xA48A27
	IniRead, _FridgeIconCoordsX, %ConfigPath%, settings, FridgeIconCoordsX, 765
	IniRead, _FridgeIconCoordsY, %ConfigPath%, settings, FridgeIconCoordsY, 557
	IniRead, _FridgeIconColor, %ConfigPath%, settings, FridgeIconColour, 0xC1F5FF
	IniRead, _lowestDesiredHP, %ConfigPath%, settings, lowestDesiredHP, 50
	IniRead, _TekPodHoldDownTimeout, %ConfigPath%, settings, TekPodHoldDownTimeout, 10
	IniRead, _TekPodMoveYDist, %ConfigPath%, settings, TekPodMoveYDist, 20
	IniRead, _ExtraRestSeconds, %ConfigPath%, settings, ExtraRestSeconds, 10
	IniRead, _MyHP, %ConfigPath%, settings, MyHP, 0
	MyHP := _MyHP
	lowestDesiredHP := _lowestDesiredHP
	TekPodHoldDownTimeout := _TekPodHoldDownTimeout
	TekPodMoveYDist := _TekPodMoveYDist
	ExtraRestSeconds := _ExtraRestSeconds

	EngramSlotCoordsX := _EngramSlotCoordsX
	EngramSlotCoordsY := _EngramSlotCoordsY
	SearchBoxCoordsX := _SearchBoxCoordsX
	SearchBoxCoordsY := _SearchBoxCoordsY
	TransferAllButtonCoordsX := _TransferAllButtonCoordsX
	TransferAllButtonCoordsY := _TransferAllButtonCoordsY
	TekPodIconCoordsX := _TekPodIconCoordsX
	TekPodIconCoordsY := _TekPodIconCoordsY
	TekPodIconColour := _TekPodIconColour
	FridgeIconCoordsX := _FridgeIconCoordsX
	FridgeIconCoordsY := _FridgeIconCoordsY
	FridgeIconColour := _FridgeIconColor
	return true
}

leavePodOpenInventory() {
	ToolTip, Leaving pod, 0, 0
	Sleep 500
	send F
	Sleep 500
	t:= waitColour(FridgeIconColour, FridgeIconCoordsX, FridgeIconCoordsY, 100)
	ToolTip, Inventory Open, 0, 0
	if (t = 0)
		return leavePodOpenInventory()
	return true
}

useTekPod() {
	ToolTip, Using tek pod, 0, 0
	ShiftMouse(0, 50, 100, 10)
	Sleep 100
	Send {e Down}
	sleep %TekPodHoldDownTimeout%
	;MouseGetPos, posX, posY
	MouseMove, 1200, 520, 2
	;ShiftMouse(TekPodMoveYDist, -10, 10, 1)
	sleep %TekPodHoldDownTimeout%
	Send {e Up}
	ToolTip, Checking if we're in tek pod..., 0, 0
	t:=waitColour(TekPodIconColour, TekPodIconCoordsX, TekPodIconCoordsY, 100)
	ToolTip, Entered TekPod, 0, 0
	return true
}

waitColour(input, x, y, maxAttempts) {
	colour:=0
	coldif:=0
	waitcolour:
		loop %maxAttempts% {
			PixelGetColor, colour, x, y, Fast RGB
			coldif := similarColour(colour, input)
			ToolTip, Checking %colour% and %input% for a near match..., 0, 0
			if (coldif = 1) {
				return coldif
				;break waitcolour
			}
			sleep 100
		}
		ToolTip, Wait Colour max of %maxAttempts% exceeded., 0, 0
		sleep, 5000
		return coldif
	return coldif

}

spamE(times) {
	rec := times * 4
	x := 1
	Loop, %rec% {
		x:= x + 1
		amt := Floor(x/4)
		ToolTip, using extractor %amt% out of %times% times, 0, 0
		Click
		Loop, 10 {
			Send e
			sleep 100
		}
	}
	return true
}

similarColour(inputColour, comparisonColour, diff = 20) {
	tr := format("{:d}","0x" . substr(comparisonColour,3,2))
	tg := format("{:d}","0x" . substr(comparisonColour,5,2))
	tb := format("{:d}","0x" . substr(comparisonColour,7,2))

	pr := format("{:d}","0x" . substr(inputColour,3,2))
	pg := format("{:d}","0x" . substr(inputColour,5,2))
	pb := format("{:d}","0x" . substr(inputColour,7,2))

	distance := sqrt((tr-pr)**2+(tg-pg)**2+(pb-tb)**2)
	return (distance < diff)
}

ShiftMouse(x, y, times := 1, rate := 1) {
    Loop % times {
        DllCall("mouse_event", uint, 0x1, int, x ,int, y, uint, 0, int, 0)
        if (A_Index != times){
            if (rate >= 10){
                Sleep % rate
            } else {
                this._Delay(rate * 0.001)
            }
        }
    }
    return True
}

SecondsSleep(seconds) {
	seconds := Floor(seconds)
	x := 0
	Loop % seconds {
		Sleep, 1000
		x := x + 1
		ToolTip, Sleeping (%x% of %seconds% seconds) [Runs: %Stats_Runs%], 0, 0
	}
	return True
}

Delay( D=0.001 ) {
    Static F
    Critical
    F ? F : DllCall( "QueryPerformanceFrequency", Int64P,F )
    DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
    While( ( (Tick:=(pTick-cTick)/F)) <D ) {
        DllCall( "QueryPerformanceCounter", Int64P,pTick )
        Sleep -1
    }
    Return Round( Tick,3 )
}

getFridgePositioning() {
	sleep 100,
	KeyWait, r, D
	sleep 500
	SplashTextOff
	MsgBox, Great - now that we're in the fridge you should see there's a weight option in the center. This shows the weight stat of the fridge inventory. Netx to it is a weight icon. Please click on this...
	KeyWait, LButton, D
	MouseGetPos, FridgeIconX, FridgeIconY
	SplashTextOff
	DrawCircle(FridgeIconX, FridgeIconY, green)
	MsgBox,4 , Selected, Thanks, I've put a green circle on the screen, is this in the right place?
	IfMsgBox Yes
	{
		RemoveCircle()
		Return FridgeIconX "|" FridgeIconY
	} else
	{
		RemoveCircle()
		Return getFridgePositioning()
	}
}

getSearchPositioning() {
	sleep 500
	SplashTextOn, 500, 100, Setup: Positioning, Great`nNow could you please click the "search" box`n(as if you were going to search for something in YOUR inventory)
	KeyWait, LButton, D
	MouseGetPos, SearchBoxPosX, SearchBoxPosY
	SplashTextOff
	DrawCircle(SearchBoxPosX, SearchBoxPosY, green)
	MsgBox,4 , Selected, Thanks, I've put a green circle on the screen, is this in the right place?
	IfMsgBox Yes
	{
		RemoveCircle()
		Return SearchBoxPosX "|" SearchBoxPosY
	} else
	{
		RemoveCircle()
		Return getSearchPositioning()
	}
}

getTransferAllPositioning() {
	sleep 500
	SplashTextOn, 500, 100, Setup: Positioning, Great`nNow could you please click the "transfer all" box`n(in YOUR inventory)
	KeyWait, LButton, D
	MouseGetPos, transferPosX, transferPosY
	SplashTextOff
	DrawCircle(transferPosX, transferPosY, green)
	MsgBox,4 , Selected, Thanks, I've put a green circle on the screen, is this in the right place?
	IfMsgBox Yes
	{
		RemoveCircle()
		Return transferPosX "|" transferPosY
	} else
	{
		RemoveCircle()
		Return getSearchPositioning()
	}
}

getEngramPositioning() {
	sleep 500
	SplashTextOn, 500, 100, Setup: Positioning, Right-o now could you please select the engram icon in your inventory, this should be the first slot, just click it...
	KeyWait, LButton, D
	MouseGetPos, EngramPosX, EngramPosY
	SplashTextOff
	DrawCircle(EngramPosX, EngramPosY, green)
	MsgBox,4 , Selected, Thanks, I've put a green circle on the screen, is this in the right place?
	IfMsgBox Yes
	{
		RemoveCircle()
		Return EngramPosX "|" EngramPosY
	} else
	{
		RemoveCircle()
		Return getEngramPositioning()
	}
}

getTekpodPositioning() {
	Sleep 1000
	KeyWait, r, D
	sleep 500
	SendInput, i
	sleep 500
	SplashTextOn, 500, 100, Tekpod Positioning, Great, now that we're in a tek pod, can you please mover you mouse over the tek pod icon in the bottom right hand corner?`nOnce you've done this, click somewhere on the icon (Best is on the yellow arrow itself)
	KeyWait, LButton, D
	MouseGetPos, tekPodIconX, tekPodIconY
	SplashTextOff
	DrawCircle(tekPodIconX, tekPodIconY, green)
	MsgBox,4 , Selected, Thanks, I've put a green circle on the screen, is this in the right place?
	IfMsgBox Yes
	{
		RemoveCircle()
		Return tekPodIconX "|" tekPodIconY
	} else
	{
		RemoveCircle()
		Return getTekpodPositioning()
	}
}

/*
 ** GUI - Circle at x[0]/y[1] in colour[3] 
 */
DrawCircle(x, y, colour) {
    Gui, Destroy
	Gui, -Caption +ToolWindow +AlwaysOnTop
	Gui, Color, Lime
	Gui, +LastFound
	GuiHwnd := WinExist()
	DetectHiddenWindows, On
	WinSet, Transparent, 150, ahk_id %GuiHwnd%
	WinSet, Region, 0-0 W40 H40 E, ahk_id %GuiHwnd%
	x:=x-20
	y:=y-20
	Gui, Show, w500 h500 x%x% y%y%
	return true
}

RemoveCircle() {
    Gui, Hide
    return true
}

; ===============================
; End Define runtime functions
; ===============================
