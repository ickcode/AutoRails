#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Arjo Magno

 Script Function:
	Initialize RefineryCMS
	Initialize setup files.
	Direct to production.

add uhmm.. drag drop feature for external files
================================================================================
   Auto Rails Copyright (C) 2011  ArjoMagno  ---   You are not allowed to remove this comment block

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

================================================================================
; convert the script to a gem!! yeahyyy!!

; convert program to ruby. so that everyone can use it.!!
; add open notepad++
; open file zilla
; save cache per opening the controller
; add save plugin to ruby so everyone can use it!
;collect all made plugins so others can develop it!
;open all indexes.
;open all controllers
; open all models

;create access point
#ce ----------------------------------------------------------------------------

;TO DOs:
; auto check if server is available
; add a script file for ssh automation
; encrypt the password and username in ini file.
; read Host MySQL .
; add more options!
; revise algorithms
; convert ssh edit box to rich edit so it may use colors
;enable local development
; For SSH Beginners

; For Ruby on Rails Beginners

; LEGEND in comment lines :

;  Ruvle - means the line containg this code may be removed or so the code block is not vital                       remove this shit
;		 - you can delete the code block between "Ruvle" and "End Ruvle"  this program will still work

; NRK(need Ruby on Rails knowledge) - rails knowlege must be understood in order to see through the code
;ssh not connecting for the first time

;javascript.. on rails app .. uhm edit with open with.. clickable sections
#RequireAdmin
#include "includes/crc32.au3"  ; this include is for generating a unique file name for the files opened from FTP
#include "includes/plink_wrapper.au3"
#include "includes/EzMySql.au3"
;#include "FTP.au3"
;#include <HTTP.au3>

#include <Guimenu.au3>
#include <IE.au3>
#include <misc.au3>
#include <Constants.au3>
#include <winapi.au3>
#include <array.au3>
#include <FTPEx.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>
#include <GUIEdit.au3>
#include <GUIrichEdit.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>

Global $_USERNAME=""
Global $_PASSWORD=""
Global $_HOST=""
Global $_APPNAME
Global $Logged_In = False , $ftp = False ,$ssh= False
Global $win_func = False , $url_found = False
Global $_FTP_HANDLE ,$Open ,$stat,$_ftphandle
Global $ftp_callback ,$ftp_opened_list ,$FTP
Global  $ftp_history[20]
Global $FTPfile ,$saveto , $FTPfilename,$_plinkhandle ,$command ,$current_dir
Global $app[10][10]
Global $savedfiles[200][3] ; The files opened to RAM
Global $a0 , $a1 , $a2 , $a3 ,$a4 , $a5 , $a6 ,$a7 ,$a8 , $a9,$a10 ,$iSavedFiles=0 	
Global $iSavedFiles = 0
global $plink_found = false
Global $app_files[20][100]

;==============================================================================================
;							                                                     GUI Initializations
$x = -20 
$y =10
$title = "Auto Rails"
$version = "0.0.1"
;
;==============================================================================================

Global $INIhistory= @ScriptDir & '\History.ini'

If _Singleton($title, 1) = 0 Then
	MsgBox(0, "Warning", "An occurence of "&$title&" is already running")
	Exit
EndIf

$RG = GUICreate($title&" v."&$version , 690, 620, -1, -1)
GUICtrlCreateLabel("Username:", 160, 16, 55, 17) ;Fixed LABELs
GUICtrlCreateLabel("Password:", 336, 16, 53, 17)
GUICtrlCreateLabel("Host:", 8, 16, 29, 17)
GUICtrlCreateLabel("App name:", 16, 80, 55, 17)
GUICtrlCreateLabel("Status:", 16, 684, 200, 17)
GUICtrlCreateLabel("Return_Code:",16, 704, 200, 17)


$SSHstat = GUICtrlCreateLabel("SSH:", 8, 40, 30, 17);Static LABELs
$FTPstat = GUICtrlCreateLabel("FTP:", 8, 56, 30, 17)
$SSHopen = GUICtrlCreateLabel("Not Connected", 70, 40, 120, 17)
$FTPopen = GUICtrlCreateLabel("Not Connected", 70, 56,120, 17)
$http_ready = GUICtrlCreateLabel(". . . .", 119, 684, 200, 17)
$http_r_code = GUICtrlCreateLabel(". . . .", 150, 704, 200, 17)
$Remote = GUICtrlCreateLabel("Remote", 632, 50, 100, 17);  tell if remote mode or local
$auto_login = GUICtrlCreateCheckbox( "Auto Login",615, 30 , 0,0);
$remember = GUICtrlCreateCheckbox( "Remember me",615, 10 , 100,17);
;$alpha = GUICtrlCreateRadio( "Alpha",352, 43,80);
;$beta =  GUICtrlCreateRadio( "Beta", 435, 43 ,80);
;$final =  GUICtrlCreateRadio( "Final",520,43,80);
$hostname = GUICtrlCreateInput($_HOST, 40, 14, 113, 21)
$username = GUICtrlCreateInput($_USERNAME, 216, 14, 113, 21) ; input
$password = GUICtrlCreateInput($_PASSWORD, 392, 14, 113, 21,$ES_PASSWORD)
$appname = GUICtrlCreateInput("", 80, 80, 97, 21) 
$login = GUICtrlCreateButton("Login", 515, 8, 81, 33);Buttons
$Create = GUICtrlCreateButton("Create", 192, 80, 75, 25)
$cms = GUICtrlCreateButton("CMS",310, 72, 105, 41)
$Setup = GUICtrlCreateButton("Initialize", 420, 72, 105, 41)
$Bundle = GUICtrlCreateButton("Bundle install", 530, 72, 105, 41)
$intModel = GUICtrlCreateButton("Models", 200+$x, 184+$y, 113, 41)
$intController = GUICtrlCreateButton("Controllers", 198+$x, 131+$y, 113, 41)
$intView = GUICtrlCreateButton("Views", 198+$x, 235+$y, 113, 41)
$intCSS = GUICtrlCreateButton("Stylesheets", 198+$x, 290+$y, 113, 41)
$intJS = GUICtrlCreateButton("Javascripts", 198+$x, 340+$y, 113, 41)
$intHelper = GUICtrlCreateButton("Helpers", 198+$x, 390+$y, 113, 41)
$intConfig= GUICtrlCreateButton("Config", 198+$x, 440+$y, 113, 41)
;$blog = GUICtrlCreateButton("Blog", 624+$x, 152, 97, 49)
$cache = GUICtrlCreateButton("Refresh Save Cache", 360+50, 510+$y, 121, 57)
$clear_database = GUICtrlCreateButton("Clear Database", 490+50, 510+$y, 121, 57)
$restart = GUICtrlCreateButton("Restart App", 230+50, 510+$y, 121, 57)
$delete = GUICtrlCreateButton("Delete App", 100+50, 510+$y, 121, 57)
$open_url = GUICtrlCreateButton("Open App", 20, 510+$y, 121, 57)
;$news_website = GUICtrlCreateButton("News CMS", 350+$x, 380, 121, 40)
$notify = GUICtrlCreateLabel("Welcome",320,120,400,30) ;
GUICtrlSetFont(-1,20)
$stdin = GUICtrlCreateInput("",305,160,360,20)
$message = _GUICtrlEdit_Create($RG,"",305,190,370,300,BitOR($WS_VSCROLL, $ES_AUTOVSCROLL,$ES_MULTILINE,$GUI_SS_DEFAULT_EDIT, $GUI_SS_DEFAULT_INPUT))
$ind = 0
$shh_input = GUICtrlCreateDummy()
$FTP_Combo = GUICtrlCreateCombo("", 50, 110, 240, 25)
$FTP_Back = GUICtrlCreateButton("<", 16, 110, 25, 21)
$FTP_List = _GUICtrlListView_Create($RG,"FTP",16, 140, 150, 361,2)

global $ctrl_names[10][2] =[["file_edit",$a0],["control",$a1],["model",$a2]]
global $cn = 3

$stat = _GUICtrlStatusBar_Create($RG);status bar
_GUICtrlStatusBar_SetText($stat,"Log In , before you can start!")
_GUICtrlListView_SetColumnWidth($FTP_List,0,275)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUISetState()
Dim $AccelKeys[1][2]=[ ["{enter}", $shh_input] ]
GUISetAccelerators($AccelKeys)


ControlShow("","",$auto_login)
DirCreate(@ScriptDir&"/edit_files")
GUISetState(@SW_SHOW)
if FileExists(@scriptdir & "/settings.ini") <> 1 then save_ses()



if FileExists("C:/plink.exe") Then
$plink_found = true
Else
_GUICtrlStatusBar_SetText($stat,"Downloading Plink")
GUICtrlSetData($SSHopen, "Downloading")5
if download_plink() = 1 Then
$plink_found = true
EndIf
Endif

load_ses()

	
	if Check_Internet() == 0 Then _
		_GUICtrlStatusBar_SetText($stat,'Limited or no connectivity')

;============================================================================================================================================================================================
;                                                                                     LOOP
While 1 

if $Logged_In=true and $plink_found = true Then     
	update()  ;this function sees if the files Opened in FTP is modified
	$msg = StdoutRead($_plinkhandle) 
	ConsoleWrite(StdoutRead($_ftphandle))
    if @error then ExitLoop;end program

    if $msg <> "" Then  ;temporarly remove the eyesource generated by the ssh console ;;Part of TODO
;== this is rmvle - Remove color codes from stdout of plink(SSH)
 $msg = StringReplace($msg,"[00m","")     		
 $msg = StringReplace($msg,"[01;34m","")       		
  $msg =StringReplace($msg,"[01;36m","")                  		
  $msg =StringReplace($msg,"[m","")                       		
  $msg =StringReplace($msg,"[0m","")                       		
  $msg =StringReplace($msg,"[1m[32m","")                       		
  $msg =StringReplace($msg,"[40;31;01m","")   		    
  $msg =StringReplace($msg,"[1m[37m","")  
;== End rmvle   
        _GUICtrlEdit_AppendText($message,$msg)              
    EndIf     
     

	if _GUICtrlEdit_GetLineCount($message) > 500 Then       
		_GUICtrlEdit_SetText($message,"")   ; clear edit box(SSH output)                
    EndIf    

EndIf                


	$nMsg = GUIGetMsg() 
Switch $nMsg            
                        
Case $shh_input   ; in case if you input a command to the host   
	stdin()             

Case $GUI_EVENT_CLOSE  
	ConsoleWrite("Close")
	
_EzMySql_Close()
_EzMySql_ShutDown()

	_SayPlus("exit")    
	_Plink_close(); shutdown plink session                  
	_FTP_Close($Open)
	;ftp_Close()
	if ProcessExists("notepad++.exe") = 1 then ProcessClose("notepad++.exe")
	save_ses();save your username and password
		FileDelete(@ScriptDir&"/edit_files");delete temporary files
		DirCreate(@ScriptDir&"/edit_files")
		if ProcessExists("notepad++.exe") then ProcessClose("notepad++.exe"); i used notepad++ to edit the files from FTP
		Exit
case $FTP_Back       
	if _error_messages() <> -1 Then                     
	;_FTPBack()     
	EndIf      
Case $clear_database
	_clear_database()
;==============================================================================================
;                                                                                     OPEN APP - rmvle
Case $open_url
	$_HOST= GUICtrlRead($hostname)
	ShellExecute("http://www."&$_HOST) ; works when the route is set to root

;==============================================================================================
;                                                                                BUNDLE INSTALL
Case $Bundle 
;
;==============================================================================================
	if $Logged_In=true Then
		GUICtrlSetData($SSHopen, "bundle install ")
		_SayPlus('bundle install --path vendor/bundle')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "bundle install SET")
	Else
		_GUICtrlStatusBar_SetText($stat,"You must Log In!")
	EndIf
;============================================================================================== 
;                                                                                    DELETE APP 
case $delete 
;
;==============================================================================================
	 msgbox(0x40000 + 0,'error','Dont delete')
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
;==============================================================================================
;                                                                                   RESTART APP
case $restart
;
;==============================================================================================
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
;==============================================================================================
;                                                                                         LOGIN
Case $login                          ; Login to FTP and SSH
;                                                                                          
;==============================================================================================
Login()

;==============================================================================================
;                                                                                      CONTROLLER
case $intController
;                                                                                          
;==============================================================================================
	GUICtrlSetData($notify, "Controller")
	;ControlHide("","",-1)
	;show("model")
	$_APPNAME= GUICtrlRead($appname)
	;ControlShow("","",$intModel)
	_FTPGo("/"&$_APPNAME&"/app/controllers")

;==============================================================================================
;                                                                                           MODEL
case $intModel
;                                                                                          
;==============================================================================================
	GUICtrlSetData($notify, "Model")
	;ControlHide("","",-1)
	;show("model")
	$_APPNAME= GUICtrlRead($appname)
	;ControlShow("","",$intModel)
	_FTPGo("/"&$_APPNAME&"/app/models")
;==============================================================================================
;                                                                                           VIEW
case $intView
;                                                                                          
;==============================================================================================
	$_APPNAME= GUICtrlRead($appname)
	_FTPGo("/"&$_APPNAME&"/app/views")
;==============================================================================================
;                                                                               	 JAVASCRIPT
Case $intJS 
;                                                                                          
;==============================================================================================
	_FTPGo("/public_html/javascripts")
;==============================================================================================
;                                                                               	 STYLESHEET
Case $intCSS
;                                                                                          
;==============================================================================================
	_FTPGo("/public_html/stylesheets")	
;==============================================================================================
;                                                                               	    HELPERS
Case $intHelper
;                                                                                          
;==============================================================================================
	$_APPNAME= GUICtrlRead($appname)
	_FTPGo("/"&$_APPNAME&"/app/helpers")
;==============================================================================================
;                                                                               	     CONFIG
Case $intConfig
;                                                                                          
;==============================================================================================
	_FTPGo("/"&$_APPNAME&"/config")
;==============================================================================================
;                                                                             	INITIALIZE  CMS
case $CMS
;                                                                                          
;==============================================================================================
	CMS_setup()
;==============================================================================================
;                                                                      INITIALIZE   SIMPLE SETUP
Case $Setup  ; setups rails files in host
;                                                                                          
;==============================================================================================
	Simple_setup()
EndSwitch

WEnd
;                                                                                     ENDLOOP
;============================================================================================================================================================================================

;==============================================================================================
;                                                                               	FTP CONNECT
Func _connect();;;;
;
;==============================================================================================
	$_USERNAME= GUICtrlRead($username)
	$_PASSWORD= GUICtrlRead($password)
	$_HOST= GUICtrlRead($hostname)
	$FTP = _FTP_Open('AutoRails')
	$ghFTPCallBack = _FTP_SetStatusCallback($FTP , '_FTP_StatusHandler')
$_FTP_HANDLE  = _FTP_Connect($FTP, $_HOST, $_USERNAME, $_PASSWORD, 0, 21, 1, 0, $ghFTPCallBack)
	if @error then msgbox(0,"Error","Connect") 
		;_pre_load() sucks
EndFunc   ;==>_connect
;==============================================================================================
;==============================================================================================

func _pre_load()
	
			$_APPNAME= GUICtrlRead($appname)
	$app_files[0][0] = "/"&$_APPNAME&"/app/controllers"
	$app_files[1][0] = "/"&$_APPNAME&"/app/models"
	$app_files[2][0] = "/"&$_APPNAME&"/app/views"
	$app_files[3][0] = "/public_html/javascripts"
	$app_files[4][0] = "/public_html/stylesheets"
	$app_files[5][0] = "/"&$_APPNAME&"/app/helpers"
	$app_files[6][0] = "/"&$_APPNAME&"/config"
	for $x = 0 to 6 
	_FTP_DirSetCurrent($_FTP_HANDLE,$app_files[0][$x])
	$aFile = _FTP_ListToArray($_FTP_HANDLE )
for $i = 3 to UBound($aFile)-1
$app_files[$x][$i-2] = $aFile[$i]
Next
Next
msgbox(0,"Complete!","Preloading") 
	endfunc

Func save_ses() ; save's connection session
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
func reconnect_ftp()
		_FTP_Close($Open)
	_connect()
		_FTP_DirSetCurrent($_FTP_HANDLE,$current_dir)
	EndFunc
Func load_ses(); loads last saved session
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


func _check_url($url,$page)
;ConsoleWrite("Example GET Request:"&@CRLF)
$socket = _HTTPConnect($url)
;ConsoleWrite("Socket Created: "&$socket&@CRLF)
$get = _HTTPGet($url, $page, $socket)
;ConsoleWrite("Bytes sent: "&$get&@CRLF)
$recv = _HTTPRead($socket,1)
  ;  ConsoleWrite("HTTP Return Code: "&$recv[0]&@CRLF)
  ;  ConsoleWrite("HTTP Return Response: "&$recv[1]&@CRLF)
   ; ConsoleWrite("Number of headers: "&UBound($recv[3])&@CRLF)
#cs
$recv = _HTTPRead($socket,1)
If @error Then
    ConsoleWrite("_HTTPRead Error: "&@error&@CRLF)
    ConsoleWrite("_HTTPRead Return Value: "&$recv &@CRLF)
Else
    ConsoleWrite("HTTP Return Code: "&$recv[0]&@CRLF)
    ConsoleWrite("HTTP Return Response: "&$recv[1]&@CRLF)
    ConsoleWrite("Number of headers: "&UBound($recv[3])&@CRLF)
    ConsoleWrite("Size of data downloaded: "&StringLen($recv[4])&" bytes"&@CRLF)
    ConsoleWrite("Page downloaded: "&@CRLF&$recv[4]&@CRLF)
    $O_IE = _IECreate()
    _IEBodyWriteHTML( $O_IE , $recv[4] )
EndIf
	#ce
If @error Then
	ConsoleWrite("error opening URL")
Else
	$url_found = True
	Return $recv[0]
EndIf

EndFunc


;
#region Ftp Navigation Functions......................................


Func _FTPGo($sChangeDir)
			ConsoleWrite("_FTPGo"&@CRLF)
			$current_dir = $sChangeDir
if _error_messages() <> - 1 Then
	Local $sFTPCurrent = _FTP_DirGetCurrent($_FTP_HANDLE )
	
	;$current_dir = $sFTPCurrent 
	If @error Then 	ConsoleWrite("why!")

	;If $sChangeDir = $sFTPCurrent Then Return
	_Push_History($sFTPCurrent, $ftp_history)
	;_FTPSetBackTip($sFTPCurrent)
			ConsoleWrite($sChangeDir)
	_FTP_DirSetCurrent($_FTP_HANDLE , $sChangeDir)
	If @error Then
		ConsoleWrite("Open File"&@crlf)
		ControlShow("","",$FTP_List)
		$FTPfilename= _GUICtrlListView_GetItemText($FTP_List,_guictrllistview_gethotitem($FTP_list))
		GUICtrlSetData($notify,$FTPfilename)
		_GUICtrlStatusBar_SetText($stat,"Loading")
		_Pop_History($ftp_history)
		$FTPfile=  $sFTPCurrent &"/"&_GUICtrlListView_GetItemText($FTP_List,_guictrllistview_gethotitem($FTP_list))
		$CRC32 = _CRC32(_GUICtrlListView_GetItemText($FTP_List,_guictrllistview_gethotitem($FTP_list))&$iSavedFiles)
		$saveto=@ScriptDir&"/edit_files/"&Hex($CRC32)&"-"&_GUICtrlListView_GetItemText($FTP_List,_guictrllistview_gethotitem($FTP_list))

		if not FileExists($saveto) Then
		_FTP_FileGet($_FTP_HANDLE ,$FTPfile,$saveto)
		$savedfiles[$iSavedFiles][0] = $saveto
		$savedfiles[$iSavedFiles][1] = FileGetTime($saveto,0,1)
		$savedfiles[$iSavedFiles][2] = 	$FTPfile
		$iSavedFiles = $iSavedFiles + 1
		Else
		$cache = 1
		EndIf

		ShellExecute($saveto)

		_GUICtrlStatusBar_SetText($stat,$FTPfilename)
	Else
	_ComboHistoryAdd($FTP_Combo, $ftp_opened_list, $sChangeDir)
	_FtpRefresh()

	EndIf
EndIf
EndFunc   ;==>_FTPGo

;;Func _FTPSetBackTip($sDir)
;	ConsoleWrite(" _FTPSetBackTip"&@CRLF)
;	If $sDir = '/' Then Return GUICtrlSetTip($FTP_Back, 'Back to /')
;	$sDir = StringTrimLeft($sDir, StringInStr($sDir, '/', 0, -1))
;	If $sDir = '' Then Return GUICtrlSetTip($FTP_Back, 'Navigate Back')
	;GUICtrlSetTip($FTP_Back, 'Back to ' & $sDir)
;EndFunc   ;==>_FTPSetBackTip

Func _FTPParent($sCurrentDir)
	ConsoleWrite("_FTPParent"&@CRLF)
	Local $pos = StringInStr($sCurrentDir, '/', 0, -1)
	If $pos = 1 Then Return '/'
	Return StringLeft($sCurrentDir, $pos - 1)
EndFunc   ;==>_FTPParent
#cs
Func _FTPBack()
	ConsoleWrite("_FTPBack"&@CRLF)
	If $ftp_history[0] = '' Then Return GUICtrlSetTip($FTP_Back, 'Navigate Back')
	Local $Back = _Pop_History($ftp_history)
	;_FTPSetBackTip($ftp_history[0])
	_FTP_DirSetCurrent($_FTP_HANDLE , $Back)
	If @error Then
		Return
	EndIf

	_ComboHistoryAdd($FTP_Combo, $ftp_opened_list, $Back)
	_FtpRefresh()

	GUICtrlSetState($FTP_List, $GUI_FOCUS)
EndFunc   ;==>_FTPBack
#ce
Func _FtpRefresh()
	ConsoleWrite("_FTPRefresh"&@CRLF)

_GUICtrlListView_DeleteAllItems($FTP_List)
$aFile = _FTP_ListToArray($_FTP_HANDLE )
for $i = 3 to UBound($aFile)-1
_GUICtrlListView_AddItem($FTP_List,$aFile[$i])
Next

EndFunc   ;==>_FtpRefresh
#endregion Ftp Navigation Functions......................................

Func _Push_History($item, ByRef $aHistory)
		ConsoleWrite("_Push_History"&@CRLF)
	If $aHistory[0] = $item Then Return
	For $i = 19 To 1 Step -1
		$aHistory[$i] = $aHistory[$i - 1]
	Next
	$aHistory[0] = $item
EndFunc   ;==>_Push_History
Func _Pop_History(ByRef $aHistory, $iNoDelete = True)
	ConsoleWrite("_Pop_History"&@CRLF)
	If Not $iNoDelete Then Return $aHistory[0]
	Local $pop = $aHistory[0]
	For $i = 0 To 18
		$aHistory[$i] = $aHistory[$i + 1]
	Next
	$aHistory[19] = ''
	Return $pop
EndFunc   ;==>_Pop_History

Func _ComboHistoryAdd(ByRef $FTP_Combo, ByRef $sCombo, $item)
	ConsoleWrite("_ComboHistoryAdd"&@CRLF)
	Local $split = StringSplit($sCombo, '|')
	_ArraySearch($split, $item)
	If Not @error Then
		GUICtrlSetData($FTP_Combo, $item, $item)
		Return
	EndIf
	If $split[0] > 9 Then
		_ArrayDelete($split, 1)
		$sCombo = _ArrayToString($split, '|', 1) & '|' & $item
		GUICtrlSetData($FTP_Combo, '', $item)
		GUICtrlSetData($FTP_Combo, $sCombo, $item)
	Else
		$sCombo &= '|' & $item
		GUICtrlSetData($FTP_Combo, $item, $item)
	EndIf
EndFunc   ;==>_ComboHistoryAdd




Func _GUIImageList_GetSystemImageList($bLargeIcons = False)
	Local $SHGFI_USEFILEATTRIBUTES = 0x10, $SHGFI_SYSICONINDEX = 0x4000, $SHGFI_SMALLICON = 0x1;, $SHGFI_LARGEICON = 0x0;,$FILE_ATTRIBUTE_NORMAL = 0x80
	Local $FileInfo = DllStructCreate("dword hIcon; int iIcon; DWORD dwAttributes; CHAR szDisplayName[255]; CHAR szTypeName[80];")
	Local $dwFlags = BitOR($SHGFI_USEFILEATTRIBUTES, $SHGFI_SYSICONINDEX)
	If Not ($bLargeIcons) Then $dwFlags = BitOR($dwFlags, $SHGFI_SMALLICON)
	Local $hIml = _WinAPI_SHGetFileInfo(".txt", $FILE_ATTRIBUTE_NORMAL, DllStructGetPtr($FileInfo), DllStructGetSize($FileInfo), $dwFlags)
	Return $hIml
EndFunc   ;==>_GUIImageList_GetSystemImageList
Func _WinAPI_SHGetFileInfo($pszPath, $dwFileAttributes, $psfi, $cbFileInfo, $uFlags)
	Local $return = DllCall(DllOpen('shell32.dll'), "DWORD*", "SHGetFileInfo", "str", $pszPath, "DWORD", $dwFileAttributes, "ptr", $psfi, "UINT", $cbFileInfo, "UINT", $uFlags)
	If @error Then Return SetError(@error, 0, 0)
	Return $return[0]
EndFunc   ;==>_WinAPI_SHGetFileInfo


Func _error_messages()
return 1
if $Logged_In = False Then
	_GUICtrlStatusBar_SetText($stat,"You must login")
	Return -1
	ConsoleWrite("Error"&@crlf)
Else
		If $ssh = False Then
			_GUICtrlStatusBar_SetText($stat,"You must enable SSH")
		Else
			Return -1
			EndIf
		If $ftp = False Then
			_GUICtrlStatusBar_SetText($stat,"You must enable FTP")
		Else

			Return -1
			EndIf
		EndIf


EndFunc



Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $tInfo
 local $course_path =@ScriptDir&"/data/COURSES"

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $iCode

			Case $NM_DBLCLK ;any.
					Switch $hWndFrom
					Case $FTP_list
						_FTPgo(_FTP_DirGetCurrent($_FTP_HANDLE )&"/"&_GUICtrlListView_GetItemText($FTP_List,_guictrllistview_gethotitem($FTP_list)));works
					EndSwitch
			Case $NM_RCLICK
					Switch $hWndFrom
					Case $FTP_list
					   _RClick()
					EndSwitch


	if @error Then ConsoleWrite("error")

	EndSwitch




    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

func update()

For $i = 0 to 100
if $savedfiles[$i][1] <> FileGetTime($savedfiles[$i][0],0,1)  Then
	ConsoleWrite("update"&@crlf)
Local $success = True
;_FTP_DirSetCurrent($_FTP_HANDLE ,$savedfiles[$i][2])
_FTP_FileDelete($_FTP_HANDLE , $savedfiles[$i][2])
if @error  then $success = False
_FTP_FilePut($_FTP_HANDLE ,$savedfiles[$i][0],$savedfiles[$i][2])
if @error  then ConsoleWrite("Error!"&@crlf)
	 ;SoundPlay(@ScriptDir&"/communi2.wav")
_FTP_FileDelete($_FTP_HANDLE , '/'&$_APPNAME&'/tmp/restart.txt')
 _FTP_FilePut($_FTP_HANDLE , @ScriptDir&"/set_files/restart.txt", '/'&$_APPNAME&'/tmp/restart.txt') 
 if @error  Then 
	   msgbox(0x40000 + 0,'error','Upload 1 failed. Reconnecting')
	 ftp_reload(1)
	 _FTP_FileDelete($_FTP_HANDLE , $savedfiles[$i][2])
_FTP_FilePut($_FTP_HANDLE ,$savedfiles[$i][0],$savedfiles[$i][2])
_FTP_FileDelete($_FTP_HANDLE , '/'&$_APPNAME&'/tmp/restart.txt')
 _FTP_FilePut($_FTP_HANDLE , @ScriptDir&"/set_files/restart.txt", '/'&$_APPNAME&'/tmp/restart.txt') 
 EndIf
 
 
_GUICtrlStatusBar_SetText($stat,"Saved "&$savedfiles[$i][2]&"  -  at  -  "&Time())
$savedfiles[$i][1] = FileGetTime($savedfiles[$i][0],0,1)
EndIf
next
EndFunc

func stdin()
$command = GUICtrlRead($stdin)
GUICtrlSetData($stdin,"")
StdinWrite($_plinkhandle,$command& @cr)
EndFunc

Func _RClick()
If $Logged_In Then
Local Enum   $idDelete, $idRename, $idRefresh, $idFolder, $idAbort, $idConnect , $idFile
	Local $hMenu = _GUICtrlMenu_CreatePopup()
	Local $iTotalSelected = _GUICtrlListView_GetSelectedCount($FTP_list)



		If $iTotalSelected = 1 Then 
			_GUICtrlMenu_AddMenuItem($hMenu, "Rename", $idRename)
			_GUICtrlMenu_AddMenuItem($hMenu, "Delete", $idDelete)
			Switch _GUICtrlMenu_TrackPopupMenu($hMenu, $FTP_list, -1, -1, 1, 1, 2)
						Case $idDelete
								ftp_deletefile()
						Case $idRename
							ConsoleWrite("rename")
						Case Else
			EndSwitch
		Else
			_GUICtrlMenu_AddMenuItem($hMenu, "Refresh", $idRefresh)
			_GUICtrlMenu_AddMenuItem($hMenu, "Create File", $idFile)	
			_GUICtrlMenu_AddMenuItem($hMenu, "Create Folder", $idFolder)	
			Switch _GUICtrlMenu_TrackPopupMenu($hMenu, $FTP_list, -1, -1, 1, 1, 2)
			        Case $idRefresh
						ftp_reload()
						_FtpRefresh()
					Case $idFile
						 ftp_createfile()

					Case $idFolder
						Local $sFolderName = InputBox('Create New Directory', 'Enter Directory Name', '', " M", Default, 130, Default, Default, 0, $RG)
						If Not @error Then

							_FTP_DirCreate($_FTP_HANDLE , $sFolderName)
						ftp_reload()
							_FtpRefresh()
						EndIf
					Case Else
			EndSwitch
		EndIf


	_GUICtrlMenu_DestroyMenu($hMenu)
EndIf
EndFunc   ;==>_QueueListView_RClick

func ftp_createfile()
	Local $filename = InputBox('Create New File', 'Enter File Name', '', " M", Default, 130, Default, Default, 0, $RG)
	If Not @error Then
	FileWrite(@ScriptDir&"/edit_files/"&$filename,"")
	_FTP_FilePut($_FTP_HANDLE ,@ScriptDir&"/edit_files/"&$filename,$current_dir&"/"&$filename)
	ConsoleWrite($current_dir&"/"&$filename&" CREATED "&@crlf )
								ftp_reload()
							_FtpRefresh()
EndIf
EndFunc

func ftp_deletefile()
	local $filename = _GUICtrlListView_GetItemText($FTP_list,	_GUICtrlListView_GetHotItem($FTP_list))
_FTP_FileDelete($_FTP_HANDLE ,$current_dir&"/"&$filename)
ConsoleWrite($current_dir&"/"&$filename&" DELETED "&@crlf )
							if not @error Then 
								_GUICtrlStatusBar_SetText($stat,$filename&" Deleted")
								ftp_reload()
							_FtpRefresh()
						Else
							_GUICtrlStatusBar_SetText($stat,"Unable to Delete FOLDER")
							EndIf
						EndFunc


func ftp_reload($i = Default)
	ConsoleWrite("Reload FTP chache"&@crlf)
	Local $iFlag
	If $i = Default Then $iFlag =  $INTERNET_FLAG_FROM_CACHE
	if $i = 1 Then $iFlag = $INTERNET_FLAG_RESYNCHRONIZE
	if $i = 2 Then $iFlag =	BitOR($INTERNET_FLAG_RESYNCHRONIZE,$INTERNET_FLAG_NEED_FILE)
	if $i = 3 Then $iFlag =	 BitAND($INTERNET_FLAG_RELOAD, $INTERNET_FLAG_NEED_FILE)
	if $i = 4 Then $iFlag =	 $INTERNET_FLAG_RELOAD
		Static $tWIN32_FIND_DATA = DllStructCreate($tagWIN32_FIND_DATA)
		Static $pWIN32_FIND_DATA = DllStructGetPtr($tWIN32_FIND_DATA)
		Local $callFindFirst = DllCall($__ghWinInet_FTP, 'handle', 'FtpFindFirstFileW', 'handle', $_FTP_HANDLE , 'wstr', "", 'ptr', $pWIN32_FIND_DATA, 'dword', $iFlag , 'dword_ptr', $ftp_callback)
	EndFunc
Func Time()
	local $hour
	$m = "AM"
	if @HOUR >= 12 and @min > 0 Then 
		$hour = @hour - 12
		if @hour = 12 then $hour = 12
		$m = "PM"
		EndIf
		$time = $hour&":"&@MIN&":"&@SEC&" "&$m
		Return $time
	EndFunc



func	Simple_setup()
if $Logged_In=true Then
$_APPNAME= GUICtrlRead($appname)
GUICtrlSetData($SSHopen, "checking")
_SayPlus("ls")
$buf_collect = _Collect_stdout(500)
If StringInStr($buf_collect, $_APPNAME,1) then
MsgBox(0,"found!", "Delete app first")
Else
	_SayPlus("rails new "&$_APPNAME&" -d mysql")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "public_html")
    _SayPlus("rm public_html")
	_SayPlus("ln -s ~/"&$_APPNAME&"/public ~/public_html")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "delete index.html")
	_SayPlus("rm -f ~/"&$_APPNAME&"/public/index.html")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, ".htaccess ")
	_SayPlus('echo -e "'&'PassengerEnabled On\nPassengerAppRoot /home/'&$_USERNAME&'/'&$_APPNAME&'\n" > ~/'&$_APPNAME&'/public/.htaccess')
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, ".htaccess SET")
	_FTP_FileDelete($_FTP_HANDLE ,'/'&$_APPNAME&'/public/javascripts/rails.js')
	_FTP_FilePut($_FTP_HANDLE ,@ScriptDir&"/set_files/rails.js",'/'&$_APPNAME&'/public/javascripts/rails.js')
		;gemfile
		GUICtrlSetData($FTPopen, ".Gemfile ")
		$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/set_files/Gemfile", '/'&$_APPNAME&'/Gemfile',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed. Reconnecting')
				ftp_reload(1)
				EndIf
            EndIf
	GUICtrlSetData($FTPopen, ".Gemfile SET! ")

		GUICtrlSetData($SSHopen,"cd "&$_APPNAME)
		_SayPlus("cd "&$_APPNAME)
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "bundle install")
	_SayPlus('bundle install --path vendor/bundle')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "bundle install SET")

		GUICtrlSetData($FTPopen, ".database.yml ")
		$ht = FileRead(@ScriptDir&"/set_files/database.yml")
		$ht = StringReplace($ht,"<!user>",$_USERNAME)
		$ht = StringReplace($ht,"<!pass>",$_PASSWORD)
		$ht = StringReplace($ht,"<!app>",$_APPNAME)

		; auto create very secure password
		FileDelete(@ScriptDir&"/tmp/database.yml")
		FileWrite(@ScriptDir&"/tmp/database.yml",$ht)
$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/tmp/database.yml", '/'&$_APPNAME&'/config/database.yml',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed')
            EndIf
	GUICtrlSetData($FTPopen, ".database.yml SET! ")

	;	GUICtrlSetData($SSHopen, "rails scaffold")
;_SayPlus('rails generate scaffold post title:string content:text')
	;	_Expect($_USERNAME&"@"&$_HOST)

		GUICtrlSetData($SSHopen, "rake db:create")
	_SayPlus('bundle exec rake db:create')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "rails db:migrate")
	_SayPlus('bundle exec rake db:migrate')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "rails db:migrate SET")

		GUICtrlSetData($FTPopen, "Restarting App")
	 _FTPDelFile($_FTP_HANDLE , '/'&$_APPNAME&'/tmp/restart.txt')
$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/set_files/restart.txt", '/'&$_APPNAME&'/tmp/restart.txt',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed , Attemping to reconnect')
           Else
GUICtrlSetData($FTPopen, "Done Restarting")
GUICtrlSetData($http_ready, "Running")
_FTPGo("/"&$_APPNAME)
Endif


Else
					_GUICtrlStatusBar_SetText($stat,"You must Log In!")
	EndIf
EndFunc

Func CMS_setup()

	GUICtrlSetData($SSHopen, "checking")
_SayPlus("ls")
$buf_collect = _Collect_stdout(500)
If StringInStr($buf_collect, $_APPNAME,1) then
MsgBox(0,"found!", "Delete app first")
Else 
If StringInStr($buf_collect, "Gemfile",1) then
GUICtrlSetData($SSHopen, "Found and Replacing Gemfile")
_FTP_FileDelete($_FTP_HANDLE , "/Gemfile")
_FTP_FilePut($_FTP_HANDLE ,@ScriptDir&"/set_files/CMS/Gemfile","/Gemfile")

GUICtrlSetData($SSHopen, "Found and Replacing Done!")
GUICtrlSetData($SSHopen, "Bundle install")
_SayPlus("bundle install")
_Expect($_USERNAME&"@"&$_HOST)
GUICtrlSetData($SSHopen, "Refinery CMS install")
$_APPNAME= GUICtrlRead($appname)
_SayPlus("bundle exec refinerycms "&$_APPNAME&" -d mysql -u "&$_USERNAME&" -p "&$_PASSWORD&" --skip-db ")
_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "public_html")
    _SayPlus("rm public_html")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "replacing public_html")
	_SayPlus("ln -s ~/"&$_APPNAME&"/public ~/public_html")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, "delete index.html")
	_SayPlus("rm -f ~/"&$_APPNAME&"/public/index.html")
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, ".htaccess ")
	_SayPlus('echo -e "'&'PassengerEnabled On\nPassengerAppRoot /home/'&$_USERNAME&'/'&$_APPNAME&'\n" > ~/'&$_APPNAME&'/public/.htaccess')
	_Expect($_USERNAME&"@"&$_HOST)
	GUICtrlSetData($SSHopen, ".htaccess SET")
		GUICtrlSetData($FTPopen, ".Gemfile ")

		$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/set_files/CMS/Gemfile2.txt", '/'&$_APPNAME&'/Gemfile',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed. Reconnecting')
				ftp_reload(1)
				EndIf
            EndIf
	GUICtrlSetData($FTPopen, ".Gemfile SET! ")

		GUICtrlSetData($SSHopen, "cd "&$_APPNAME)
		_SayPlus("cd "&$_APPNAME)
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "bundle install")
	_SayPlus('bundle install --path vendor/bundle')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "bundle install SET")

					GUICtrlSetData($FTPopen, ".database.yml ")
		$ht = FileRead(@ScriptDir&"/set_files/database.yml")
		$ht = StringReplace($ht,"<!user>",$_USERNAME)
		$ht = StringReplace($ht,"<!pass>",$_PASSWORD)
		$ht = StringReplace($ht,"<!app>",$_APPNAME)
			FileDelete(@ScriptDir&"/tmp/database.yml")
			FileWrite(@ScriptDir&"/tmp/database.yml",$ht)

$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/tmp/database.yml", '/'&$_APPNAME&'/config/database.yml',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed')
            EndIf
	GUICtrlSetData($FTPopen, ".database.yml SET! ")

		GUICtrlSetData($SSHopen, "rake db:setup")
	_SayPlus('bundle exec rake db:setup')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "rails db:migrate")
	_SayPlus('bundle exec rake db:migrate')
		_Expect($_USERNAME&"@"&$_HOST)
		GUICtrlSetData($SSHopen, "rails db:migrate SET")

			GUICtrlSetData($FTPopen, "Restarting App")
	 _FTPDelFile($_FTP_HANDLE , '/'&$_APPNAME&'/tmp/restart.txt')
$Ftpp = _FtpPutFile($_FTP_HANDLE , @ScriptDir&"/set_files/restart.txt", '/'&$_APPNAME&'/tmp/restart.txt',0x08000000)
            if @error = -1 then
                msgbox(0x40000 + 0,'error','Upload 1 failed , Attemping to reconnect')
           Else
GUICtrlSetData($FTPopen, "Done Restarting")
_FTPGo("/"&$_APPNAME)
EndIf
EndIf

EndFunc
Func _FTP_StatusHandler($hInternet, $dwContent, $dwInternetStatus, $lpvStatusInformation, $dwStatusInformationLength)

	Switch $dwInternetStatus
		Case $INTERNET_STATUS_RESOLVING_NAME
			_GUICtrlStatusBar_SetText($stat,'Resolving Name...')
		Case $INTERNET_STATUS_NAME_RESOLVED
			_GUICtrlStatusBar_SetText($stat,'Name Resolved')
		Case $INTERNET_STATUS_CONNECTING_TO_SERVER
			_GUICtrlStatusBar_SetText($stat,'Connecting to Server: ')
		Case $INTERNET_STATUS_CONNECTED_TO_SERVER
			_GUICtrlStatusBar_SetText($stat,'Connected!')
		Case $INTERNET_STATUS_CONNECTION_CLOSED
			_GUICtrlStatusBar_SetText($stat,'Connection Closed.')
		Case $INTERNET_STATUS_CLOSING_CONNECTION
			_GUICtrlStatusBar_SetText($stat,'Closing Connection...')
		Case $INTERNET_STATUS_STATE_CHANGE
			_GUICtrlStatusBar_SetText($stat,'State Change Value = ')
		Case Else
			;$aTimers[$g_tIdleClock] = TimerInit()
	EndSwitch

EndFunc 
func Check_Internet()
	return Ping("www.google.com")
EndFunc

Func Login()
	If $win_func = True Then
		$login = 15 
		$win_func = False
	EndIf
	if $Logged_In=false Then
		_GUICtrlStatusBar_SetText($stat,"Logging in!")
		GUICtrlSetData($SSHopen, "Connecting.")
		GUICtrlSetData($FTPopen, "Waiting")
		$_USERNAME= GUICtrlRead($username)
		$_PASSWORD= GUICtrlRead($password)
		$_HOST= GUICtrlRead($hostname)
		_GUICtrlStatusBar_SetText($stat,"Opening SSH")
		if $plink_found == true then
		$_plinkhandle = Run("c:/plink.exe -P 22 -l "&$_USERNAME&" -pw "&$_PASSWORD&" -ssh "&$_HOST,@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDERR_CHILD + $STDOUT_CHILD)
			$msg = StdoutRead($_plinkhandle)
		_GUICtrlEdit_AppendText($message,$msg)
		GUICtrlSetData($SSHopen, "Connected !")
		Else
		_GUICtrlStatusBar_SetText($stat,"Plink not Found")
		GUICtrlSetData($SSHopen, "Plink Not Found")
		EndIf

		_GUICtrlStatusBar_SetText($stat,"Opening FTP")
		GUICtrlSetData($FTPopen, "Connecting.")
		
		;	$_ftphandle = Run("ftp "&$_HOST&" -u "&$_USERNAME&" -p "&$_PASSWORD,@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDERR_CHILD + $STDOUT_CHILD)
		;	ConsoleWrite(StdoutRead($_ftphandle))
		_connect()
		ConsoleWrite("connected"&@crlf)
		GUICtrlSetData($FTPopen, "Connected !")
		$Logged_In=true
		$_APPNAME= GUICtrlRead($appname)
		_FTPGo("/"&$_APPNAME)
		 _EzMySql_Startup() 
 _EzMySql_Open($_HOST, $_USERNAME,$_PASSWORD, $_USERNAME&"_"&$_APPNAME, "3306")
 _EzMySql_SelectDB($_USERNAME&"_"&$_APPNAME)

		_GUICtrlStatusBar_SetText($stat,"Logged in!")
	Elseif $_HOST <> GUICtrlRead($hostname) then
		_GUICtrlStatusBar_SetText($stat,"Already Logged In!")
	EndIf	
EndFunc

Func _clear_database()
	
	_EzMySql_Exec("DROP DATABASE "&$_USERNAME&"_"&$_APPNAME) 
 		_SayPlus('cd '&$_APPNAME)
		_Expect($_USERNAME&"@"&$_HOST)
		_SayPlus('bundle exec rake db:create')
		_Expect($_USERNAME&"@"&$_HOST)
		_SayPlus('bundle exec rake db:migrate')
		_Expect($_USERNAME&"@"&$_HOST)
		
		consolewrite("done!")
		GUICtrlSetData($notify, "Database Cleared!")
	EndFunc
ConsoleWrite("end")