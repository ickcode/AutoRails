

#include-once




Global $msgId[1][6] = [[0, 0, 100, DllCallbackRegister('_queue', 'none', ''), 0, 'lib10rsZd']]

#cs

	DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

	$msgId[0][0]   - Count item of array
	[0][1]   - Reserved
	[0][2]   - Message timer interval, ms (see _MsgTimerInterval())
	[0][3]   - Handle to callback function
	[0][4]   - The control identifier as returned by "SetTimer" function (see _MsgRegister())
	[0][5]   - Suffix of the title registered window (Don`t change it)

	$msgId[i][0]   - The control identifier (controlID) as returned by _MsgRegister()
	[i][1]   - Registered receiver ID name
	[i][2]   - Registered user function
	[i][3]   - Handle to registered window
	[i][4-5] - Reserved

#ce

Global $msgQueue[1][2] = [[0]]

#cs

	DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

	$msgQueue[0][0] - Count item of array
	[0][1] - Don`t used

	$msgQueue[i][0] - Registered user function ($msgId[i][2])
	[i][1] - Message data

#ce

Const $MSG_WM_COPYDATA = 0x004A

;~ local $OnMessagesExit = Opt('OnExitFunc', 'OnMessagesExit')
OnAutoItExitRegister('OnMessagesExit')

Local $wmInt = 0
Local $qeInt = 0


; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgReceiverList
; Description:		Retrieves a list of receivers.
; Syntax:			_MsgReceiverList (  )
; Parameter(s):		None.
; Return Value(s):	Returns an array of matching receiver names that have been registered by a _MsgRegister() function.
;					The zeroth array element contains the number of receivers.
; Author(s):		Yashied
; Note(s):			Returned variable will always be an array and a dimension of not less than 1.
;====================================================================================================================================

Func _MsgReceiverList()

	Local $wList = WinList(), $Lenght = StringLen($msgId[0][5])

	Dim $rList[1] = [0]
	For $i = 1 To $wList[0][0]
		If StringRight($wList[$i][0], $Lenght) = $msgId[0][5] Then
			ReDim $rList[$rList[0] + 2]
			$rList[0] += 1
			$rList[$rList[0]] = StringTrimRight($wList[$i][0], $Lenght)
		EndIf
	Next
	Return $rList
EndFunc   ;==>_MsgReceiverList

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgRegister
; Description:		Creates a registers the specified function as a receiver.
; Syntax:			_MsgRegister ( $sIdentifier, $sFunction )
; Parameter(s):		$sIdentifier - Local identifier (any name) to be registered at the receive of messages. If the receiver with the
;								   specified identifier already exists in the system will be sets @error flag.
;					$sFunction   - The name of the function to call when a message is received. Not specifying this parameter
;								   will be removed the receiver associated with the $sIdentifier. The function cannot be a built-in AutoIt
;								   function or plug-in function and must have the following header:
;
;								   func _MyReceiver($sMessage)
;
;								   IMPORTANT! The function should return 0 for successful completion, otherwise the functions will be called
;								   again later, etc. until it is returned to zero. This is necessary to control access to shared data (if any).
;								   For this purpose you can use specifying additional control flags:
;
;								   local $IntFlag = 0
;
;								   _MsgRegister('my_local_receiver_id_name', '_MyReceiver')
;
;								   ...
;
;								   $IntFlag = 1
;
;								   ; At this point, the _MyReceiver() is locked.
;
;								   $IntFlag = 0
;
;								   ...
;
;								   func _MyReceiver($sMessage)
;									   if $IntFlag = 1 then
;										   return 1
;									   endif
;
;									   ...
;
;									   return 0
;								   endfunc; _MyReceiver
;
; Return Value(s):	Success: Returns the identifier (controlID) of the new registered receiver.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgRegister($sIdentifier, $sFunction)

	Local $ID, $Title
	Local $i, $j = 0, $k, $l, $b, $t

	If (Not IsString($sIdentifier)) Or (Not IsString($sFunction)) Or ($msgId[0][3] = 0) Or (StringStripWS($sIdentifier, 8) = '') Then Return SetError(1, 0, 0)

	$sFunction = StringStripWS($sFunction, 3)
	$t = StringLower($sIdentifier)
	For $i = 1 To $msgId[0][0]
		If StringLower($msgId[$i][1]) = $t Then
			$j = $i
			ExitLoop
		EndIf
	Next

	If $j = 0 Then
		$Title = $sIdentifier & $msgId[0][5]
		If ($sFunction = '') Or (IsHWnd(_winhandle($Title))) Then Return SetError(0, 0, 1)
		$ID = 1
		Do
			$b = 1
			For $i = 1 To $msgId[0][0]
				If $msgId[$i][0] = $ID Then
					$ID += 1
					$b = 0
					ExitLoop
				EndIf
			Next
		Until $b
		If $msgId[0][0] = 0 Then
			_start()
			If @error Then Return 0
		EndIf
		ReDim $msgId[$msgId[0][0] + 2][6]
		$msgId[$msgId[0][0] + 1][0] = $ID
		$msgId[$msgId[0][0] + 1][1] = $sIdentifier
		$msgId[$msgId[0][0] + 1][2] = $sFunction
		$msgId[$msgId[0][0] + 1][3] = GUICreate($Title)
		$msgId[$msgId[0][0] + 1][4] = 0
		$msgId[$msgId[0][0] + 1][5] = 0
		$msgId[0][0] += 1
		If $msgId[0][0] = 1 Then GUIRegisterMsg($MSG_WM_COPYDATA, '_WM_COPYDATA')
		Return SetError(0, 0, $ID)
	EndIf

	If $sFunction > '' Then
		$msgId[$j][2] = $sFunction
		$ID = $msgId[$j][0]
	Else
		$wmInt = 1

		$k = 1
		$t = StringLower($msgId[$j][2])
		While $k <= $msgQueue[0][0]
			If StringLower($msgQueue[$k][0]) = $t Then
				For $i = $k To $msgQueue[0][0] - 1
					For $l = 0 To 1
						$msgQueue[$i][$l] = $msgQueue[$i + 1][$l]
					Next
				Next
				ReDim $msgQueue[$msgQueue[0][0]][2]
				$msgQueue[0][0] -= 1
				ContinueLoop
			EndIf
			$k += 1
		WEnd
		If $msgId[0][0] = 1 Then
			GUIRegisterMsg($MSG_WM_COPYDATA, '')
			_stop()
		EndIf
		GUIDelete($msgId[$j][3])
		For $i = $j To $msgId[0][0] - 1
			For $l = 0 To 5
				$msgId[$i][$l] = $msgId[$i + 1][$l]
			Next
		Next
		ReDim $msgId[$msgId[0][0]][6]
		$msgId[0][0] -= 1
		$ID = 0

		$wmInt = 0
	EndIf

	Return SetError(0, 0, $ID)
EndFunc   ;==>_MsgRegister

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgRelease
; Description:		Removes all registered local receivers.
; Syntax:			_MsgRelease (  )
; Parameter(s):		None.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgRelease()

	$wmInt = 1

	ReDim $msgQueue[1][2]
	$msgQueue[0][0] = 0
	GUIRegisterMsg($MSG_WM_COPYDATA, '')
	For $i = 1 To $msgId[0][0]
		GUIDelete($msgId[$i][3])
	Next
	ReDim $msgId[1][6]
	$msgId[0][0] = 0
	_stop()

	$wmInt = 0

	Return SetError(@error, 0, (Not @error))
EndFunc   ;==>_MsgRelease

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgSend
; Description:		Sends a data to the registered receiver.
; Syntax:			_MsgSend ( $sIdentifier, $sMessage )
; Parameter(s):		$sIdentifier - The identifier (name) of the registered receiver.
;					$sMessage    - The string of data to send.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero. @extended flag can also be set to following values:
;							-1 - if message queue busy
;							 2 - if registered window not found
;
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgSend($sIdentifier, $sMessage)

	Local $hWnd, $SendErr = False, $aRet, $tMessage, $tCOPYDATA

	If (Not IsString($sIdentifier)) Or (Not IsString($sMessage)) Or (StringStripWS($sIdentifier, 8) = '') Then Return SetError(1, 0, 0)

	$hWnd = _winhandle($sIdentifier & $msgId[0][5])
	If $hWnd = 0 Then Return SetError(1, 2, 0)

	$tMessage = DllStructCreate('char[' & StringLen($sMessage) + 1 & ']')
	DllStructSetData($tMessage, 1, $sMessage)
	$tCOPYDATA = DllStructCreate('dword;dword;ptr')
	DllStructSetData($tCOPYDATA, 2, StringLen($sMessage) + 1)
	DllStructSetData($tCOPYDATA, 3, DllStructGetPtr($tMessage))
	$aRet = DllCall('user32.dll', 'lparam', 'SendMessage', 'hwnd', $hWnd, 'int', $MSG_WM_COPYDATA, 'wparam', 0, 'lparam', DllStructGetPtr($tCOPYDATA))
	If @error Then $SendErr = 1
	$tCOPYDATA = 0
	$tMessage = 0
	If $SendErr Then Return SetError(1, 0, 0)
	If $aRet[0] = -1 Then Return SetError(1, -1, 0)
	Return SetError(0, 0, 1)
EndFunc   ;==>_MsgSend

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgTimerInterval
; Description:		Sets a frequency of the processing queue messages.
; Syntax:			_MsgTimerInterval ( $iTimerInterval )
; Parameter(s):		$iTimerInterval - Timer interval in millisecond.
; Return Value(s):	Success: Returns a new timer interval.
;					Failure: Returns a previous (or new) timer interval is used and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			The time interval during which messages reach the receiver. The initial (at the start of the script) value of the
;					timer interval is 100.
;====================================================================================================================================

Func _MsgTimerInterval($iTimerInterval)

	If Not IsInt($iTimerInterval) Then Return SetError(1, 0, $msgId[0][2])
	If $iTimerInterval = 0 Then Return SetError(0, 0, $msgId[0][2])
	If $iTimerInterval < 50 Then $iTimerInterval = 50
	_stop()
	If @error Then Return SetError(1, 0, $msgId[0][2])
	$msgId[0][2] = $iTimerInterval
	_start()
	If @error Then
		GUIRegisterMsg($MSG_WM_COPYDATA, '')
		Return SetError(1, 0, $msgId[0][2])
	EndIf
	Return $msgId[0][2]
EndFunc   ;==>_MsgTimerInterval

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgWindowHandle
; Description:		Retrieves an internal handle of a window associated with the receiver.
; Syntax:			_MsgWindowHandle ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _MsgRegister() function.
; Return Value(s):	Success: Returns handle to registered window.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgWindowHandle($controlID)

	If Not IsInt($controlID) Then Return 0

	For $i = 1 To $msgId[0][0]
		If $msgId[$i][0] = $msgId Then Return $msgId[$i][3]
	Next
	Return 0
EndFunc   ;==>_MsgWindowHandle

; #FUNCTION# ========================================================================================================================
; Function Name:	_IsReceiver
; Description:		Check if the identifier associated with the receiver.
; Syntax:			_IsReceiver ( $sIdentifier )
; Parameter(s):		$sIdentifier - The identifier (name) to check.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 if identifier is not associated with the receiver.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _IsReceiver($sIdentifier)
	If (Not IsString($sIdentifier)) Or (_winhandle($sIdentifier & $msgId[0][5]) = 0) Then Return 0
	Return 1
EndFunc   ;==>_IsReceiver

Func _function($hWnd)
	For $i = 0 To $msgId[0][0]
		If $msgId[$i][3] = $hWnd Then Return $msgId[$i][2]
	Next
	Return 0
EndFunc   ;==>_function

Func _message($sFunction, $sMessage)
	ReDim $msgQueue[$msgQueue[0][0] + 2][2]
	$msgQueue[$msgQueue[0][0] + 1][0] = $sFunction
	$msgQueue[$msgQueue[0][0] + 1][1] = $sMessage
	$msgQueue[0][0] += 1
EndFunc   ;==>_message

Func _queue()

	If ($wmInt = 1) Or ($qeInt = 1) Or ($msgQueue[0][0] = 0) Then Return

	$qeInt = 1

	Local $Ret = Call($msgQueue[1][0], $msgQueue[1][1])

	If (@error <> 0xDEAD) And (@extended <> 0xBEEF) Then
		Local $Lenght = $msgQueue[0][0] - 1

		Switch $Ret
			Case 0
				For $i = 1 To $Lenght
					For $j = 0 To 1
						$msgQueue[$i][$j] = $msgQueue[$i + 1][$j]
					Next
				Next
				ReDim $msgQueue[$Lenght + 1][2]
				$msgQueue[0][0] = $Lenght
			Case Else
				If $Lenght > 1 Then _swap(1, 2)
		EndSwitch
	EndIf

	$qeInt = 0
EndFunc   ;==>_queue

Func _start()
	If $msgId[0][4] = 0 Then
		Local $aRet = DllCall('user32.dll', 'int', 'SetTimer', 'hwnd', 0, 'int', 0, 'int', $msgId[0][2], 'ptr', DllCallbackGetPtr($msgId[0][3]))
		If (@error) Or ($aRet[0] = 0) Then Return SetError(1, 0, 0)
		$msgId[0][4] = $aRet[0]
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_start

Func _stop()
	If $msgId[0][4] > 0 Then
		Local $aRet = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', 0, 'int', $msgId[0][4])
		If (@error) Or ($aRet[0] = 0) Then Return SetError(1, 0, 0)
		$msgId[0][4] = 0
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_stop

Func _swap($Index1, $Index2)

	Local $tmp

	For $i = 0 To 1
		$tmp = $msgQueue[$Index1][$i]
		$msgQueue[$Index1][$i] = $msgQueue[$Index2][$i]
		$msgQueue[$Index2][$i] = $tmp
	Next
EndFunc   ;==>_swap

Func _winhandle($sTitle)

	Local $wList = WinList()

	$sTitle = StringLower($sTitle)
	For $i = 1 To $wList[0][0]
		If StringLower($wList[$i][0]) = $sTitle Then Return $wList[$i][1]
	Next
	Return 0
EndFunc   ;==>_winhandle

Func _WM_COPYDATA($hWnd, $msgId, $wParam, $lParam)

	If ($wmInt = 1) Then Return -1

	Local $Function = _function($hWnd)

	If $Function > '' Then

		Local $tCOPYDATA = DllStructCreate('dword;dword;ptr', $lParam)
		Local $tMsg = DllStructCreate('char[' & DllStructGetData($tCOPYDATA, 2) & ']', DllStructGetData($tCOPYDATA, 3))

		_message($Function, DllStructGetData($tMsg, 1))
		Return 0
	EndIf

	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>_WM_COPYDATA

Func OnMessagesExit()
	GUIRegisterMsg($MSG_WM_COPYDATA, '')
	_stop()
	DllCallbackFree($msgId[0][3])
;~ 	Call($OnMessagesExit)
EndFunc   ;==>OnMessagesExit
