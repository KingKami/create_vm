# Create VM

## TP1 virtualisation automation on VMware

Making of a powershell script to automate the creation of 10 VM's

### Make a VM with the command New-VM with the following parameters:

- 1572 Mo of vRam
- 1 disk of 125 Mo on «ThickEagerZero» format
- 2 vCPU

### Make 10 VM's with a powershell script with the following:

- 10 parameters of your choice (including the previous 3)
- Sources the parameters from a .csv file
- Each action must be prompted colorfully to the terminal and written in the log file
- Notifications must be sent for each completed task

### 3 colorful HTML email reports:

- For the technician: reports for each error
- For the client: report on what's been done
- For the manager: statistical report on the completed tasks


### Notes

make a credentials.ps1 with the following lines

```ps1
$global:USER = 'esxi user name'
$global:PASSWORD = 'esxi user password'
$global:SERVER = 'esxi ip or hostname if dns is set'
$global:SERVICE_ACCOUNT_EMAIL_ADDRESS = "email address"
$global:MANAGER_EMAIL_ADDRESS = "email address"
$global:REQUESTER_EMAIL_ADDRESS = "email address"
$global:TECHNICIAN_EMAIL_ADDRESS = "email address"
```

For help on how to setup you Gmail account to send email through the script follow this [post](https://support.google.com/mail/answer/185833)