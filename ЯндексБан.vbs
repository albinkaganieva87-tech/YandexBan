Option Explicit 
Dim fso, sh, sha, hostsPath 
Dim yandexsites() 
Set fso = CreateObject("Scripting.FileSystemObject") 
Set sh = CreateObject("WScript.Shell") 
Set sha = CreateObject("Shell.Application") 


Dim initialSites, i
initialSites = Array("yandex.ru", "ya.ru", "mail.yandex.ru", "go.yandex.ru", "disk.yandex.ru", "dns.yandex.ru", "yandex.cloud", "web.max.ru", "music.yandex.ru","blog.yandex", "mail.yandex", "direct.yandex.ru", "cloud.yandex.ru", "afisha.yandex.ru")
)
ReDim yandexsites(UBound(initialSites))
For i = 0 To UBound(initialSites)
    yandexsites(i) = initialSites(i)
Next

hostsPath = "C:\Windows\System32\drivers\etc\hosts" 

If Not WScript.Arguments.Named.Exists("elevated") Then 
    sha.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ /elevated", "", "runas", 1 
    WScript.Quit 
End If 

Sub main() 
    Dim msg, choice 
    msg = "Выберите действие:" & vbCrLf & _ 
    "1 - Документация" & vbCrLf & _ 
    "2 - Заблокировать список" & vbCrLf & _ 
    "3 - Разблокировать список" & vbCrLf & _ 
    "4 - Добавить свой сайт в список" & vbCrLf & _ 
    "0 - Выход" 
    choice = InputBox(msg, "Яндекс Блокировщик 1.3", "1") 
    Select Case choice 
        Case "1": Documentation 
        Case "2": ban 
        Case "3": unban 
        Case "4": newbansite 
        Case "0": WScript.Quit 
        Case Else: If choice <> "" Then main 
    End Select 
End Sub 

Sub newbansite() 
    Dim newDomain
    newDomain = InputBox("Введите домен (например, vk.com):", "Добавление сайта") 
    If newDomain <> "" Then
       
        ReDim Preserve yandexsites(UBound(yandexsites) + 1)
        yandexsites(UBound(yandexsites)) = newDomain
        MsgBox "Сайт " & newDomain & " добавлен в текущий список сессии!", vbInformation
    End If
    main
End Sub 


Sub ban() 
    Dim domain, strPathPolicy, strPathDisallow, objFile, content 
    strPathPolicy = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\" 
    strPathDisallow = strPathPolicy & "DisallowRun\" 
    sh.RegWrite strPathPolicy & "DisallowRun", 1, "REG_DWORD" 
    sh.RegWrite strPathDisallow & "1", "Yandex.exe", "REG_SZ" 
    sh.RegWrite strPathDisallow & "2", "browser.exe", "REG_SZ" 
    
    If Not fso.FileExists(hostsPath) Then fso.CreateTextFile(hostsPath)
    Set objFile = fso.OpenTextFile(hostsPath, 1) 
    content = objFile.ReadAll 
    objFile.Close 
    
    Set objFile = fso.OpenTextFile(hostsPath, 8) 
    For Each domain In yandexsites 
        If InStr(content, domain) = 0 Then 
            objFile.WriteLine("0.0.0.0 " & domain) 
            objFile.WriteLine("0.0.0.0 www." & domain) 
        End If 
    Next 
    objFile.Close 
    RestartExplorer 
    sh.Run "ipconfig /flushdns", 0, True 
    MsgBox "Готово! Сайты заблокированы.", vbInformation 
    main 
End Sub 

Sub unban() 
    Dim domain, strContent, objFile 
    If Not fso.FileExists(hostsPath) Then Exit Sub
    Set objFile = fso.OpenTextFile(hostsPath, 1) 
    strContent = objFile.ReadAll 
    objFile.Close 
    For Each domain In yandexsites 
        strContent = Replace(strContent, "0.0.0.0 " & domain & vbCrLf, "") 
        strContent = Replace(strContent, "0.0.0.0 www." & domain & vbCrLf, "") 
    Next 
    Set objFile = fso.OpenTextFile(hostsPath, 2) 
    objFile.Write strContent 
    objFile.Close 
    sh.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", 0, "REG_DWORD" 
    RestartExplorer 
    sh.Run "ipconfig /flushdns", 0, True 
    MsgBox "Доступ восстановлен!", vbInformation 
    main 
End Sub 

Sub Documentation() 
    MsgBox "Версия 1.3: Теперь можно добавлять свои сайты в список блокировки.", vbInformation 
    main 
End Sub 

Sub RestartExplorer() 
    sh.Run "taskkill /f /im explorer.exe", 0, True 
    sh.Run "explorer.exe", 1, False 
End Sub 

main
