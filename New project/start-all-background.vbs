Option Explicit

Dim shell, fso, root, q
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
root = fso.GetParentFolderName(WScript.ScriptFullName)
q = Chr(34)

Dim backendPython, agentPython
backendPython = root & "\backend\venv\Scripts\python.exe"
agentPython = root & "\desktop-agent\venv\Scripts\pythonw.exe"

If (Not PythonWorks(backendPython)) Or (Not PythonWorks(agentPython)) Then
    MsgBox "Org Tracker can't start: the backend and/or desktop-agent virtual " & _
           "environment is missing or broken on this computer." & vbCrLf & vbCrLf & _
           "This usually happens when the project folder (including its 'venv' " & _
           "subfolders) was copied from a different computer - Python virtual " & _
           "environments only work on the machine that created them." & vbCrLf & vbCrLf & _
           "Fix: run setup.bat once in this project folder, then try again.", _
           vbCritical, "Org Tracker - Setup needed"
    WScript.Quit 1
End If

StartHidden "cmd.exe /c cd /d " & q & root & "\backend" & q & " && " & q & backendPython & q & " -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001"
StartHidden "cmd.exe /c cd /d " & q & root & "\frontend" & q & " && npm.cmd run dev"
StartHidden "cmd.exe /c cd /d " & q & root & "\desktop-agent" & q & " && " & q & agentPython & q & " agent.py"

Sub StartHidden(command)
    shell.Run command, 0, False
End Sub

Function PythonWorks(pyPath)
    Dim wshExec, tries
    PythonWorks = False

    If Not fso.FileExists(pyPath) Then
        Exit Function
    End If

    On Error Resume Next
    Set wshExec = shell.Exec(q & pyPath & q & " --version")
    If Err.Number <> 0 Then
        Err.Clear
        Exit Function
    End If
    On Error Goto 0

    tries = 0
    Do While wshExec.Status = 0 And tries < 100
        WScript.Sleep 50
        tries = tries + 1
    Loop

    If wshExec.Status = 1 And wshExec.ExitCode = 0 Then
        PythonWorks = True
    End If
End Function
