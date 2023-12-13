# FindIngressEmail
 Find Inbound Email Domains

## Examples

### Quick Send


 $EmailBody = gc ./email.html|out-string
 Invoke-FindIngressEmail -SMTPServer example.mail.protection.outlook.com -Subject "Device Code" -BodyFile ./email.html -FromFile fromEmails.txt -ToEmail "ceo@example.com" -Encoding unicode -Delay 15 -RetryDelay 35 -Verbose |tee outlog.txt


### Azure Cloud Shell Job


Start-Job -name asciiDeviceCode -ScriptBlock {  Import-Module /home/rev/FindIngressEmails.ps1; Invoke-FindIngressEmail -smtpServer example.mail.protection.outlook.com -Subject "Microsoft 365 Session Sync Required" -bodyFile /root/dev/email.html -fromFile -toEmail $_ -Delay 10 -Encoding ascii }

