# FindIngressEmail
 Find Inbound Email Domains

## Examples

### Quick Send


 Invoke-FindIngressEmail -SMTPServer example.mail.protection.outlook.com -Subject "Device Code" -BodyFile ./email.html -FromFile ./fromEmails.txt -ToEmail "ceo@example.com" -Encoding unicode -Delay 15 -RetryDelay 35 -Verbose |tee outlog.txt


### Using a Mail Proxy with SMTP Authentication

Start-Job -name asciiDeviceCode -ScriptBlock {  Import-Module /home/rev/FindIngressEmails.ps1; Invoke-FindIngressEmail -SMTPServer example.mail.protection.outlook.com -Subject "Your Device Code Expired" -BodyFile ./DeviceCode.html -FromFile ./fromEmails.txt -Delay 5 -RetryDelay 35 -Verbose -ToEmail "target@example.com" -EmailSmtpUser loginUser -EmailSmtpPass loginPasword }

### Azure Cloud Shell Job


Start-Job -name asciiDeviceCode -ScriptBlock {  Import-Module /home/rev/FindIngressEmails.ps1; Invoke-FindIngressEmail -SMTPServer example.mail.protection.outlook.com -Subject "Your Device Code Expired" -BodyFile ./DeviceCode.html -FromFile ./fromEmails.txt -Delay 5 -RetryDelay 35 -Verbose -ToEmail "target@example.com" -BodyEncoding bigendianunicode -SubjectEncoding oem -HeadersEncoding utf8NoBOM -BodyTransferEncoding EightBit }

