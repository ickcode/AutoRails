#include-Once

; ====================================================================================================================================
; Title....................: plink_wrapper
; AutoIt Version...........: 3.3.6.1
; Language.................: English
; Description..............: UDF Functions to Control "plink.exe" allowing intelligent response to text displayed in terminal sessions
; Author...................: Joel Susser (susserj)
; Last Modified............: 07/12/2011
; Status:..................: Alpha 1.1
; Testing Workstation......; WinXP sp3, win7 32bit (It likely works with other versions of Windows but I cannot confirm this right now )
; Tested Version of Autoit.; Autoit 3.3.6.1

; What is plink?
    ;plink is a command line terminal emulation program similar to putty that allows rudimentary scripting.

;Requirements
    ; Autoit 3.3.6.X
    ; putty.exe, plink.exe. You can acquire these programs at "http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html".

; Hints
    ; If you are using the ssh protocol I suggest you connect to your server first
    ; with putty before you use plink for the first time so that you will not
    ; be disrupted by the authentication certificate requests.

    ; When entering your userid and password variables I suggest that you add an
    ; additional space at the end of these strings. I'm not sure why but if you don't it will likely
    ; cut off the last letters of your userid and password.

    ; Figuring out what screen information to wait for before continuing the data input stream
    ; can sometimes be difficult. I suggest using the putty logging feature to record the text that appears on each screen.
    ; I beleive it is advisable to do so in small chunks.

    ; Also, choose strings to recognize that are unique and at the end of the putty screen capture logging sessions
    ; for each screen. Avoid terminal escape coding.
; ================================================================================================================================

#comments-start
    Changelog:
    6-09-2011 changed example script to use equivalent path with spaces
    7-09-2011 added function _Collect_stdout and modified example script
    7-12-2011 added function _ExpectTimed and modified example script
#comments-end


;#Current List of Functions=======================================================================================================
;_Start_plink($_plink_loc,$_plinkserver)
;_Plink_close()
;_Init_plink_log($_plink_logfile)
;_Expect($match_text)
;_Expector($match_text1, $say1, $match_text2, $say2, $match_text3, $say3)
;_Expectlog($match_text)
;_Say($output)
;_SayPlus($output)
;_Plink_close_logfile($_plink_logfile_handle)
;_Collect_stdout($time)
;_ExpectTimed($match_text, $_plink_timeout)

; ===============================================================================================================================


; #VARIABLES# ====================================================================================================================
    global $_plinkhandle=""                 ; used to handle starting of plink
    global $_plinkserver=""                 ; name of server you wish to connect to
    global $_plink_loc =""                  ; location of plink.exe executable on workstation
    global $_plink_display_messages=false   ; display interim messages to screen (default false)
    global $_plink_display_message_time=1   ; time in seconds messages are displayed
    global $_plink_logging=false            ; record plink log file (default false)
    global $_plink_logfile=""               ; location of plink log file
    global $_plink_logfile_handle=""        ; plink log file handle
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Plink_close
; Description ...: closes plink.exe process
; Author ........: Joel Susser (susserj)
; Syntax.........: $_Plink_close()
; Parameters ....: none required
; example .......: _Plink_close()
;
; Remarks .......: plink.exe should only be running once

; ===============================================================================================================================
func _Plink_close()
    ;If there are any stray plink sessions kill them
    if ProcessExists("plink.exe") then
        ProcessClose("plink.exe")
    Else
            return false
    endif

EndFunc
; ===============================================================================================================================



; #FUNCTION# ====================================================================================================================
; Name...........: _Start_plink
; Description ...: open a new plink.exe terminal session
; Author ........: Joel Susser (susserj)
; Syntax.........: $_plinkhandle=_Start_plink($_plink_loc, $_plinkserver)
; Parameters ....: $_plink_loc is the location of the plink.exe ececutable on you workstation
; Parameters ....: $_plinkserver is the location of the server you wish to access
; Example........: $_plinkhandle = _Start_plink("c:/putty/plink.exe", "testserver.com")
; Return values .: $plinkhandle, pid of cmd processor
; Remarks........; Currently configured to use ssh protocol
; Remarks .......: Needs to be made more robust
; ===============================================================================================================================

;download Plink
Func download_plink( $path = "C:/")
	InetGet("http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe",$path&"plink.exe")
	return 1
	EndFunc
;start the plink session
func _Start_plink($_plink_loc,$_plinkserver)

    _Plink_close(); close any stray plink sessions before starting

    if $_plink_loc = "" then
        MsgBox(0, "Error", "Unable to open plink.exe",10)
        return false
        Exit
    endif

    if $_plinkserver = "" then
        MsgBox(0, "Error", "Unable to open server",10)
        Exit
        return false
    endif

    $_plinkhandle = Run(@comspec & " /c" & $_plink_loc & " -ssh " & $_plinkserver,"",@SW_HIDE,7)
    return $_plinkhandle
endFunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Init_plink_log
; Description ...: open a new file handle for saving a log file recording your plink terminal session
; Syntax.........: _Init_plink_log($_plink_logfile)
; Parameters ....: $_plink_logfile is the location of the log file
; Example........: _Init_plink_log("c:/putty/plink.log")
; Author ........: Joel Susser (susserj)
; Remarks .......: If the file exists it will be ovewritten (2)
; Remarks........: Initializing the log file does not mean logging gets turned on.
; remarks........; Logging gets turned on with the flag $_plink_logging=true. The default is false
; Remarks........; Sometimes the log files get too long and you just want to log a small section of code see $_Expectlog()
; Remarks........;
; ===============================================================================================================================
;Initialize plink session log file
func _Init_plink_log($_plink_logfile)
    $_plink_logfile_handle = FileOpen($_plink_logfile, 2)
    ; Check if file opened for writing OK
    If $_plink_logfile_handle = -1 Then
        MsgBox(0, "Error", "Unable to open file.")
        Exit
    EndIf
    return true
endfunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Expect
; Description ...: Pause until expected text is displayed on output stream of terminal
; Syntax.........: _Expect("text string")
; Parameters ....: one parameter containing a text string.
; Example........: _Expect("Password:")
; Author ........: Joel Susser (susserj)
; Remarks .......: If the flag $_plink_logging is set to true then it will record all the data sent to the output screen
; Remarks........: while it is waiting for the required text to appear. If it runs to long and doesn't find the text this
; remarks........; file can get very big so be careful.
; Remarks........; If the flag $plink_display_message is set to true then it will popup a messages showing you that the text is found.
; Remarks........; I usaully leave the $_plink_display_messages flag on but reduce the time display to 1 second. However, during
; Remards........; development I usually bump it up to 5 seconds.
; ===============================================================================================================================

func _Expect($match_text)
    local $text
    local $found
    While 1
        $text = StdoutRead($_plinkhandle)
        if $_plink_logging Then
            filewriteline($_plink_logfile_handle,"**********************NEW SECTION************************")
            filewrite($_plink_logfile_handle,$match_text)
            filewrite($_plink_logfile_handle,$text)
            filewriteline($_plink_logfile_handle,"**********************END SECTION************************")
        endif
        $found = StringRegExp($text,$match_text)
        If $found = 1 Then
            If $_plink_display_messages Then MsgBox(4096, $match_text, $text, $_plink_display_message_time)
            ExitLoop
        endif
    sleep(100)
    Wend
EndFunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Expector
; Description ...: Depending on the text that is found in the input stream, perform one of three different tasks
; Syntax.........: _Expector($match_text1, $say1, $match_text2, $say2, $match_text3, $say3)
; Parameters ....: If string in $match_text1 is found then sent the text in $say1 input string
; Parameters ....: If string in $match_text2 is found then sent the text in $say2 input string
; Parameters ....: If string in $match_text3 is found then give the user a popup message and exit script
; Author ........: Joel Susser (susserj)
; Remarks .......:
; Example........: _Expector("Press <Space Bar> to continue", " ", "Do you wish to continue", "y" "Error no data found", "Script shutting down")
; Remarks .......:
; Remarks........: I'm not fully satified with this function. It requires exactly 6 parameters. It should be more fexable to handle
; remarks........; a variable number of parameters.
; Remarks........; Also, it should perhaps have some error handling to check that the parameters it receives are correct.
; Remarks........; Right now when I only need only two choices, not three choices I put dummy data in my second pair of data variables
; Remards........;
; ===============================================================================================================================
func _Expector($match_text1, $say1, $match_text2, $say2, $match_text3, $say3)
    local $text

    While 1
        $text = StdoutRead($_plinkhandle)
        if $_plink_logging then
            filewrite($_plink_logfile_handle,"**********************NEW SECTION************************")
            filewrite($_plink_logfile_handle,"Expector")
            filewrite($_plink_logfile_handle,$text)
            filewrite($_plink_logfile_handle,"**********************END SECTION************************")
        endif
        If $_plink_display_messages Then MsgBox(4096, $match_text1 & $match_text2, $text, $_plink_display_message_time)
        sleep(5000)



        If StringRegExp($text,$match_text3) then
            MsgBox(4096, "System Error", $say3, 6)
            ProcessClose("plink.exe")
            FileClose($_plink_logfile)
            exit; close program
        endif

        If StringRegExp($text,$match_text2) then
            _Say($say2)
            ExitLoop
        Endif



        If StringRegExp($text,$match_text1) then
            _Say($say1)
            ExitLoop
        Endif
    sleep(100)
    Wend
EndFunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Expectlog
; Description ...: Similar to _Expect but if forces a logging of the data for a particular search patern in the input stream
; Description ...: Pause until text is displayed on output stream of terminal
; Syntax.........: _Expectlog("text string")
; Parameters ....: one parameter containing a text string.
; Example........: _Epector("Password:")
; Author ........: Joel Susser (susserj)
; Remarks .......:
; Remarks........: As I indicated previously, the log files can get very big.
; remarks........; This function allows targeted logging related to a specific area of your script.
; Remarks........; It is primarily used for debugging. After your script is functional, you will likely convert your _Expectlog
; Remarks........; function calls to _Expect.
; Remards........;
; ===============================================================================================================================
func _Expectlog($match_text)
    local $text
    local $found
    While 1
        $text = StdoutRead($_plinkhandle)
        filewrite($_plink_logfile_handle,"**********************" &  $match_text &  "************************" )
        filewrite($_plink_logfile_handle,$match_text)
        filewrite($_plink_logfile_handle,$text)
        $found = StringRegExp($text,$match_text)
        If $found = 1 Then
            MsgBox(4096, $match_text, $text, 10)
            ExitLoop
        endif
        sleep(100)
    Wend
EndFunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Say
; Description ...: Send the following text string to the input stream of the terminal session
; Syntax.........: _Say("text")
; Parameters ....: Function takes on parameter which contains the text to sent to the input stream.
; Example........: _Say("y")
; Author ........: Joel Susser (susserj)
; Remarks .......: Don't try and say to much at once. Wait for the screen to appear with the prompt for information
; Remards........; This say does not perform a carrage return. If you need a carrage return use _SayPlus
; ===============================================================================================================================
; Say Function
func _Say($output)
    StdinWrite($_plinkhandle, $output)
endfunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _SayPlus
; Description ...: Send the following text string to the input stream of the terminal session
; Syntax.........: _SayPlus("text")
; Parameters ....: Function takes on parameter which contains the text to sent to the input stream.
; Example........: _SayPlus("y")
; Author ........: Joel Susser (susserj)
; Remarks .......: Don't try and say to much at once. Wait for the screen to appear with the prompt for information
; Remards........; This type of say performs a carrage return. If you don't need a carrage return use _Say()
; ===============================================================================================================================
func _SayPlus($output)
    StdinWrite($_plinkhandle, $output & @CR)
endfunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Plink_close_logfile
; Description ...: close the plink logging file
; Syntax.........: _Plink_close_logfile($_plink_logfile_handle_)
; Parameters ....: $_Plink_close_logfile_handle
; Example........: N/A
; Author ........: Joel Susser (susserj)
; Remarks .......:
; Remards........;
; ===============================================================================================================================
;Close log file
func _Plink_close_logfile($_plink_logfile_handle)
    FileClose($_plink_logfile_handle)
endfunc
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name...........: _Collect_stdout
; Description ...: Collects text sent to output stream of terminal for specified period of time
; Syntax.........: $variable = _Collect_stdout($time)
; Parameters ....: Function takes one parameter which specifies time(milliseconds) to collect the input buffer.
; Returns........: Returns the contents of stdout collected during specified time interval
; Example........: $output_buffer = $_Collect_stdout(500); 500 is half a second
; Author ........: Joel Susser (susserj)
;
; Remarks........; This function was inspired by comments made by (Phil; justhatched) and jp10558
; Remarks .......: There are certain situations which can benefit from the ability to collectively parse the stdout stream.
; Remarks........: The potential problem with this approach is that it can sometimes be difficult to predict how long it takes for certain
; remarks........; screens to output their text due to variables such as server load and internet speed etc.
; Remarks........; That being said, with proper testing the time interval can potentially be evaluated for such situations and
; Remarks........; upon potential failure to succeed, the procedure can be repeated.
; Remarks........; See New Sample Script
;
; ===============================================================================================================================
Func _Collect_stdout($_plink_timeout)

    local $text
    local $sBuffertext
    local $iBegin = TimerInit()
    While 1
        $text = StdoutRead($_plinkhandle)
        $sBuffertext = $sBuffertext & $text
        if $_plink_logging Then
            filewriteline($_plink_logfile_handle, $text)
         endif
         If TimerDiff($iBegin) > $_plink_timeout then
           ExitLoop
        endif
    sleep(100)

Wend
    return $sBuffertext
EndFunc

; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ExpectTimed
; Description ...: Searches for a string in the stdout stream which was collected for a specified period of time
; Syntax.........: $variable = _Epect_timed("string", $time)
; Parameters ....: Function takes two parameters. First is string to find, second is period of in time(milliseconds) to collect the input buffer
; Returns........: Returns the contents of stdout collected during specified time interval
; Example........: $output_buffer = $_Expect__timed("Login:", 5000);  5 seconds
; Author ........: Joel Susser (susserj)
;
; Remarks........; This function was inspired by comments made by (Phil; justhatched) and jp10558
; Remarks .......: There are certain situations which can benefit from the ability to collectively parse the stdout stream.
; Remarks........: The potential problem with this approach is that it can sometimes be difficult to predict how long it takes for certain
; remarks........; screens to output their text due to variables such as server load and internet speed etc.
; Remarks........; That being said, with proper testing the time interval can potentially be evaluated for such situations and
; Remarks........; upon potential failure to succeed, the procedure can be repeated.
; Remarks........; See New Sample Script
; ===============================================================================================================================
 Func _ExpectTimed($match_text, $_plink_timeout)
    local $found
    local $sBuf_text
    $sBuf_text = _Collect_stdout($_plink_timeout)
    $found = StringRegExp($sBuf_text, $match_text)
    If $found Then
        If $_plink_display_messages Then MsgBox(4096, $match_text, $sBuf_text, $_plink_display_message_time)
        return $sBuf_text
    endif
EndFunc

; ===============================================================================================================================




; Sample Script Starts Here=============================================================================================================
;

#cs
#include plink_wrapper.au3
;Initialize Variables------------------------------------------------------------------------------------------------------------
$username="admin " ; It seems necessary to put an extra space after the login name. The last character is being cut off.
$password="admin1 "; It seems necessary to put an extra space after the password. The last characters is being cut off.
$_plink_logging=true                        ; Turn Logging ON (default is off)
$_plink_display_messages=true               ; Turn Screen Messages ON (default is on)
$_plink_display_message_time=5              ; Display message for 5 secs (default 1 sec)
;--------------------------------------------------------------------------------------------------------------------------------

; Initizations-------------------------------------------------------------------------------------------------------------------
$_plinkhandle=_Start_plink("c:\PROGRA~1\1putty\plink.exe","hostname.com"); Initialized plink connection to server
_Init_plink_log("c:\PROGRA~1\putty\plink.log"); Initialize log file. Required even it not being used
;(Special Notes for Windows 7. If you are puttying plink, putty, and plink.log in a subdirectory of "c:\Program Files\" make sure
; you give your user account sufficient rights. Otherwises it may fail to run properly.
; To find the short file name, navigate to directory with cmd console, then type "command". This will show you the short name)
; -------------------------------------------------------------------------------------------------------------------------------


; Terminal Emulation Session Interaction
_Expect("login as:")
_SayPlus($username)
_Expect("Password:")
_SayPlus($password)
_Expect("hostname >")
_SayPlus("ls")
_Expect("hostname >")

;--------Sample Coding to illustrate using _Collect_stdout function-----------------
_SayPlus("vncserver")
$buf_collect = _Collect_stdout(5000);  (5 sec)
If StringInStr($buf_collect, "computer:0",1) then
    ;some function
ElseIf StringInStr($buf_collect, "computer:1",1) then
    ; some function
ElseIf StringInStr($buf_collect, "computer:2",1) then
    ; some function
Elseif
...
Else
MsgBox(0,"Error", "Unable to find required string")

Endif
;----------------------------------------------------------------------------------

;--------Sample Coding to illustrate using _ExpectTimed function -----------------
; Terminal Emulation Session Interaction
$buf_collect = _ExpectTimed("login as:", 1000)
if not $buf_collect then
 MsgBox(4096, "error", "unable to log into server", $_plink_display_message_time)
 exit
Endif

   
_SayPlus($username)
_ExpectTimed("Password:", 1000)
_SayPlus($password)
_ExpectTimed("hostname >", 1000)
_SayPlus("ls")
_ExpectTimed("hostname >", 1000)


;----------------------------------------------------------------------------------


_SayPlus("exit")

;SHUTDOWN-----------------------------------------------------------------------------------------------------------------------
_Plink_close(); shutdown plink session
_Plink_close_logfile($_plink_logfile_handle);shutdown log file
; ------------------------------------------------------------------------------------------------------------------------------

#ce