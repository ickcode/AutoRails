; #FUNCTION# ====================================================================================================================
; Name...........: __Save_Session()
; Description ...: Save the session and saves it to ini
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
Func __Save_Session()
	ConsoleWrite("save"&@crlf)
	IniWrite(@scriptdir&"/settings.ini","login","user",guictrlread($username))
	IniWrite(@scriptdir&"/settings.ini","login","pass",guictrlread($password))
	IniWrite(@scriptdir&"/settings.ini","login","host",guictrlread($hostname))
	if GUICtrlRead($auto_login) = 1 Then
	IniWrite(@scriptdir&"/settings.ini","Check","auto_login","true")
	Elseif GUICtrlRead($auto_login) = 4 Then
	IniWrite(@scriptdir&"/settings.ini","Check","auto_login","false")
	EndIf

	if GUICtrlRead($remember) = 1 Then
	IniWrite(@scriptdir&"/settings.ini","Check","remember","true")
	Elseif GUICtrlRead($remember) = 4 Then
	IniWrite(@scriptdir&"/settings.ini","Check","remember","false")
	EndIf

	$dir_app = @scriptdir&"/installed_apps/"&guictrlread($username)

	if FileExists($dir_app) = 0 Then
	DirCreate($dir_app)
	Else
	IniWrite($dir_app&"/apps.ini","Apps",guictrlread($username),guictrlread($appname))
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: __Load_Session()
; Description ...: Read the ini then Load the session
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
Func __Load_Session()
	if FileExists(@scriptdir & "/settings.ini") <> 1 then __Save_Session()
	$user_int = IniRead(@scriptdir&"/settings.ini","login","user","Username")
	$pass_int = IniRead(@scriptdir&"/settings.ini","login","pass","Password")
	$host_int = IniRead(@scriptdir&"/settings.ini","login","host","Hostname")
	$al_int = IniRead(@scriptdir&"/settings.ini","Check","auto_login","true")
	$r_int = IniRead(@scriptdir&"/settings.ini","Check","remember","true")
		if $r_int = "true" Then
		GUICtrlSetState($remember,1) 
		GUICtrlSetData($username,$user_int)
		GUICtrlSetData($password,$pass_int)
		GUICtrlSetData($hostname,$host_int)

		ElseIf $r_int = "false" Then
		GUICtrlSetState($remember,4) 
		EndIf
	If $al_int = "false" Then
	GUICtrlSetState($auto_login, 4)
	EndIf
	$dir_app = @scriptdir&"/installed_apps/"&guictrlread($username)
	if FileExists($dir_app) = 0 Then
	DirCreate($dir_app)
	Else
	$app_int = IniRead($dir_app&"/apps.ini","Apps",guictrlread($username),guictrlread($appname))
	GUICtrlSetData($appname,$app_int)
EndIf
			if $al_int = "true" Then
							GUICtrlSetState($auto_login, 1)
				Login()

			EndIf
EndFunc
; #FUNCTION# ====================================================================================================================
; Name...........: __FTP_Connect()
; Description ...: Executes SSH cmd " bundle install " on APP
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
Func __FTP_Connect()
	
	$_USERNAME= GUICtrlRead($username)
	$_PASSWORD= GUICtrlRead($password)
	$_HOST= GUICtrlRead($hostname)
	$FTP = _FTP_Open('AutoRails')
	$ghFTPCallBack = _FTP_SetStatusCallback($FTP , '_FTP_StatusHandler')
    $_FTP_HANDLE  = _FTP_Connect($FTP, $_HOST, $_USERNAME, $_PASSWORD, 0, 21, 1, 0, $ghFTPCallBack)
	if @error then msgbox(0,"Error","Connect") 

EndFunc
; #FUNCTION# ====================================================================================================================
; Name...........:  __Reconnect_FTP()
; Description ...: FTP reconnect
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
func __Reconnect_FTP()
		_FTP_Close($Open)
	__FTP_Connect()
		_FTP_DirSetCurrent($_FTP_HANDLE,$current_dir)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name...........: __Bundle_Install()
; Description ...: Executes SSH cmd " bundle install " on APP
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
Func __Bundle_Install()
if $Logged_In=true Then
	GUICtrlSetData($SSHopen, "bundle install ")
	_SayPlus('bundle install --path vendor/bundle')
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "bundle install SET")
Else
	_GUICtrlStatusBar_SetText($stat,"You must Log In!")
EndIf

Return 1
EndFunc ;<= END -  _Bundle_Install()
; #FUNCTION# ====================================================================================================================
; Name...........: __Restart_App() 
; Description ...: Removes then Upload Again the file "restart.txt" on APP
; Parameters ....: none
; Return values .: On Success - 1
; Return values .: On Failure - TODO
; Author ........: 
; ===============================================================================================================================
Func __Restart_App() 
	
$_APPNAME= GUICtrlRead($appname)

if $Logged_In=true Then
GUICtrlSetData($FTPopen, "Restarting App")
_FTP_FileDelete($_FTP_HANDLE , '/'&$_APPNAME&'/tmp/restart.txt')
_FTP_FilePut($_FTP_HANDLE , @ScriptDir&"/set_files/restart.txt", '/'&$_APPNAME&'/tmp/restart.txt')
if @error then
msgbox(0x40000 + 0,'error','Upload 1 failed--Reconnecting')
ftp_reload(1)
EndIf
GUICtrlSetData($FTPopen, "Done Restarting")	
Else
_GUICtrlStatusBar_SetText($stat,"You must Log In!")
EndIf
Return 1
EndFunc ;<= END -  __Restart_App()

Func __Delete_App()
	 #cs  - i accidently pressed this button. i had to start over again :D
	if $Logged_In=true Then
	$_APPNAME= GUICtrlRead($appname)
	GUICtrlSetData($SSHopen, "Deleting App...")
	_SayPlus("rm -r "&$_APPNAME)
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "Deleted")
	Else
	_GUICtrlStatusBar_SetText($stat,"You must Log In!")
	EndIf

	case $cache
	For $n = 0 To UBound($savedfiles,1) - 1
	$savedfiles[$n][0] = ""
	$savedfiles[$n][1] = "" 
	$savedfiles[$n][2] = "" 
	Next 
	$iSavedFiles=0 
	$cache =0
	FileDelete(@ScriptDir&"/edit_files")
	DirCreate(@ScriptDir&"/edit_files")
	#ce
EndFunc ;<= END -  __Delete_App()