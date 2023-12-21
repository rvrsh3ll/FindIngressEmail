function Invoke-FindIngressEmail {
    <#
        .SYNOPSIS

        Check mail filters from random domains.

        .DESCRIPTION

        A script to test the efficacy of SPAM filters.

        .PARAMETER SMTPServer

        Target SMTP server.

        .PARAMETER Subject

        Specifies the subject of the email.

        .PARAMETER BodyFile

        Specify an HTML formatted file for the email body.

        .PARAMETER FromFile

        Specify a file with a single or multiple From email addresses 'noreply@microsoofty.com'.

        .PARAMETER ToEmail

        Specify the To email address.

        .PARAMETER EmailSmtpUser

        Specify an SMTP user.

        .PARAMETER EmailSmtpPass

        Specify an SMTP password.

        .PARAMETER BodyEncoding

        Specify the Body Encoding.

        .PARAMETER SubjectEncoding

        Specify the Subject Encoding.

        .PARAMETER HeadersEncoding

        Specify the Body Headers Encoding.

        .PARAMETER BodyTransferEncoding

        Specify the Body Transfer Encoding.

        .PARAMETER Delay

        Specify the delay between sending emails.

        .PARAMETER RetryDelay

        Specify the delay between rate limited emails.


        .EXAMPLE

        C:\PS> Import-Module .\FindIngressEmail.ps1
        # Example using a proxy SMTP service such as mailgun.
        C:\PS> Invoke-FindIngressEmail -SMTPServer smtp.mailgun.org -Subject "Your Device Code Expired" -BodyFile ./DeviceCode.html -FromFile ./fromEmails.txt -EmailSmtpUser "postmaster@<insert domain>" -EmailSmtpPass "SMTPPass" -Delay 5 -RetryDelay 35 -Verbose -ToEmail "target@<insert domain>"
        # Example using a Microsoft Direct Send endpoint to spoof internally.
        C:\PS> Invoke-FindIngressEmail -SMTPServer <insertcompany>.mail.protection.outlook.com -Subject "Your Device Code Expired" -BodyFile ./DeviceCode.html -FromFile ./fromEmails.txt -Delay 5 -RetryDelay 35 -Verbose -ToEmail "target@<insert domain>"
        # Example using different encoding options.
        C:\PS> Invoke-FindIngressEmail -SMTPServer <insertcompany>.mail.protection.outlook.com -Subject "Your Device Code Expired" -BodyFile ./DeviceCode.html -FromFile ./fromEmails.txt -Delay 5 -RetryDelay 35 -Verbose -ToEmail "target@<insert domain>" -BodyEncoding bigendianunicode -SubjectEncoding oem -HeadersEncoding utf8NoBOM -BodyTransferEncoding EightBit
        #>

    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true)]
    [String]$SMTPServer,
    [Parameter(Mandatory=$true)]
    [String]$Subject,
    [Parameter(Mandatory=$true)]
    [String]$BodyFile,
    [Parameter(Mandatory=$true)]
    [String]$FromFile,
    [Parameter(Mandatory=$true)]
    [String]$ToEmail,
    [Parameter(Mandatory=$false)]
    [String]$EmailSmtpUser,
    [Parameter(Mandatory=$false)]
    [String]$EmailSmtpPass,
    [Parameter(Mandatory=$false)]
    [ValidateSet("ascii","bigendianutf32","unicode","utf8","utf8NoBOM","bigendianunicode","oem","utf7","utf8BOM","utf32")]
    [String]$BodyEncoding,
    [Parameter(Mandatory=$false)]
    [ValidateSet("ascii","bigendianutf32","unicode","utf8","utf8NoBOM","bigendianunicode","oem","utf7","utf8BOM","utf32")]
    [String]$SubjectEncoding,
    [Parameter(Mandatory=$false)]
    [ValidateSet("ascii","bigendianutf32","unicode","utf8","utf8NoBOM","bigendianunicode","oem","utf7","utf8BOM","utf32")]
    [String]$HeadersEncoding,
    [Parameter(Mandatory=$false)]
    [ValidateSet("QuotedPrintable","Base64","SevenBit","EightBit","Unknown")]
    [String]$BodyTransferEncoding,
    [Parameter(Mandatory=$false)]
    [Int]$Delay = 10,
    [Parameter(Mandatory=$false)]
    [Int]$RetryDelay = 31
    )
    $EmailBody = Get-Content $BodyFile |Out-String
    $FromEmails = Get-Content $FromFile
    $m = New-Object System.Net.Mail.MailMessage
    $m.IsBodyHtml = $true
    $m.to.Add($ToEmail)
    $m.Body = $EmailBody
    $m.subject = $Subject
    $fromEmails| % {
        try {
            $FromAddress = $_
            $m.From = $FromAddress
            $m.Sender = $FromAddress
            $m.ReplyToList.Add($FromAddress)
            if ($BodyEncoding) {
                $m.BodyEncoding = [System.Text.Encoding]::$BodyEncoding
            } 
            if ($SubjectEncoding) {
                $m.SubjectEncoding = [System.Text.Encoding]::$SubjectEncoding
            }
            if ($HeadersEncoding) {
                $m.HeadersEncoding = [System.Text.Encoding]::$HeadersEncoding
            }
            if ($BodyTransferEncoding) {
                $m.BodyTransferEncoding = [System.Net.Mime.TransferEncoding]::$BodyTransferEncoding
            }
            $m.Headers.Add('Return-Path',$FromAddress)
            $smtp = new-object Net.Mail.SmtpClient($SMTPServer)
            if ($EmailSmtpUser -and $EmailSmtpPass) {
                $smtp.Credentials =  New-Object System.Net.NetworkCredential($EmailSmtpUser , $EmailSmtpPass)
            } elseif (($EmailSmtpUser -and !$EmailSmtpPass) -xor (!$EmailSmtpUser -and $EmailSmtpPass)) {
                Write-Output -Message "[*] Both Username and Password are required."
                break
            } 
            $smtp.Send($m)
            Write-Verbose -Message "[*] Sending from $FromAddress to $ToEmail .."
            Start-Sleep -Seconds $Delay
        }
        catch {
            Write-Warning $Error[0]
            Write-Verbose $Error[0]
            Start-Sleep -Seconds $RetryDelay
            continue
        }
    }
}