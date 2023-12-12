function Invoke-FindIngressEmail {

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
    [ValidateSet("ascii","bigendianutf32","unicode","utf8","utf8NoBOM","bigendianunicode","oem","utf7","utf8BOM","utf32")]
    [String]$Encoding = "ascii",
    [Parameter(Mandatory=$false)]
    [Int]$Delay = 10,
    [Parameter(Mandatory=$false)]
    [Int]$RetryDelay = 31
    )
    $EmailBody = Get-Content $BodyFile |Out-String
    $FromEmails = Get-Content $FromFile
    $WarningPreference='silentlycontinue'
    
    # Default rate limit is 30 messages per minute https://learn.microsoft.com/en-us/office365/servicedescriptions/exchange-online-service-description/exchange-online-limits?redirectedfrom=MSDN#RecipientLimits

    $fromEmails|%{
        try {
            Send-MailMessage -SmtpServer $SmtpServer -Subject $Subject -Body $EmailBody -BodyAsHtml -From $_ -To $ToEmail -UseSSL -Encoding $Encoding -ErrorAction Stop
            Write-Verbose -Message "[*] Sending from $_ to $ToEmail .."
            Start-Sleep -Seconds $Delay
        }
        catch {
            Start-Sleep -Seconds $RetryDelay
        }
    }
}
