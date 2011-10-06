#include-once
Global Enum $g_bEnable, $g_hUser32dll, $g_hCallBack, $g_TimerID, $HoverMax
Global $aHover[$HoverMax] = [False, DllOpen('user32.dll'), DllCallbackRegister("__CheckUnderMouse", "none", ""), 0]
Global $aCtrlHwnds[1] = [0]
OnAutoItExitRegister('_Release')

Func _MouseHover_SetFocus($hCtrlID)

	If Not IsHWnd($hCtrlID) Then $hCtrlID = GUICtrlGetHandle($hCtrlID)

	For $i = 1 To $aCtrlHwnds[0]
		If $aCtrlHwnds[0] = $hCtrlID Then Return SetError(2, 0, 1) ; Already registered
	Next

	ReDim $aCtrlHwnds[UBound($aCtrlHwnds) + 1]
	$aCtrlHwnds[0] += 1
	$aCtrlHwnds[$aCtrlHwnds[0]] = $hCtrlID

	If $aHover[$g_bEnable] And $aHover[$g_TimerID] = 0 Then __SetTimer()

	Return 1

EndFunc   ;==>_MouseHover_SetFocus

Func _MouseHover_Enable()
	$aHover[$g_bEnable] = True
	If $aCtrlHwnds[0] > 0 Then __SetTimer()
EndFunc   ;==>_MouseHover_Enable

Func _MouseHover_Disable()
	Local $tmp = $aHover[$g_bEnable]
	$aHover[$g_bEnable] = False
	If $aHover[$g_TimerID] <> 0 Then DllCall($aHover[$g_hUser32dll], "int", "KillTimer", "hwnd", 0, "int", $aHover[$g_TimerID])
	$aHover[$g_TimerID] = 0
	Return $tmp
EndFunc   ;==>_MouseHover_Disable

Func __SetTimer()
	Local $Call = DllCall($aHover[$g_hUser32dll], "int", "SetTimer", "hwnd", 0, "int", 0, "int", 100, "ptr", DllCallbackGetPtr($aHover[$g_hCallBack]))
	If @error Then Return SetError(1, 0, 0)
	$aHover[$g_TimerID] = $Call[0]
EndFunc   ;==>__SetTimer

Func __CheckUnderMouse()

	Static $Last_Handle = 0, $Last_MouseX = 0, $Last_MouseY = 0

	Local $Mouse = MouseGetPos()

	If $Mouse[0] <> $Last_MouseX Or $Mouse[1] <> $Last_MouseY Then;Mouse Position has changed
		$Last_MouseX = $Mouse[0]
		$Last_MouseY = $Mouse[1]

		Local $Handle = DllCall($aHover[$g_hUser32dll], "int", "WindowFromPoint", "long", $Last_MouseX, "long", $Last_MouseY)

		If $Last_Handle <> $Handle[0] Then ; Handle Under Mouse has changed
			$Last_Handle = $Handle[0]

			Local $i, $bFound = False
			For $i = 1 To $aCtrlHwnds[0]
				If $Last_Handle = $aCtrlHwnds[$i] Then ; Handle is one of the controls we are watching
					$bFound = True
					ExitLoop
				EndIf
			Next

			If $bFound Then DllCall($aHover[$g_hUser32dll], "hwnd", "SetFocus", "hwnd", $Last_Handle)

		EndIf
	EndIf

EndFunc   ;==>__CheckUnderMouse

Func _Release()
	_MouseHover_Disable()
	DllCallbackFree($aHover[$g_hCallBack])
	DllClose($aHover[$g_hUser32dll])
EndFunc   ;==>_Release