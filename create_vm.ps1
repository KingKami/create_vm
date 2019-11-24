$ErrorActionPreference= 'silentlycontinue'
. .\credentials.ps1
$global:CURRENT_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path
$global:LOG_FILE_NAME = "create_vm.log"
$global:LOG_FILE_PATH = Join-Path $CURRENT_DIRECTORY $LOG_FILE_NAME
$global:MANAGER_EMAIL_BODY = ""
$global:REQUESTER_EMAIL_BODY = ""
$global:TECHNICIAN_EMAIL_BODY = ""
$global:NUMBER_OF_VM_TO_CREATE = 0

function load_powercli() {
    Get-Module -Name VMware* -ListAvailable | Import-Module
    if ($Error[0]) {
        return 0
    }
    else {
        return 1
    }
}
function connect_to_vcenter() {
    Connect-VIServer -User $global:USER -Password $global:PASSWORD -Server $Server -Force
}

function import_csv([string]$file) {
    $list = Import-Csv $file -Delimiter ';'
    return $list
}

function create_log_file() {
    if (!(Test-Path $LOG_FILE_PATH)) {
        New-Item -path $global:CURRENT_DIRECTORY -name $global:LOG_FILE_NAME -type "file" | Out-Null
    }
}

function write_to_log([string]$message) {
    create_log_file
    $timestamp = Get-Date -UFormat '%m/%d/%Y %R'
    $message_to_write = "$timestamp $message"
    Add-Content -Path $LOG_FILE_PATH -Value $message_to_write
    if ($message -match "fail") {
        #Write-Host $message_to_write -ForegroundColor Red
        $global:TECHNICIAN_EMAIL_BODY = "<li>$message_to_write</li>"
        send_mail $global:TECHNICIAN_EMAIL_BODY  $global:TECHNICIAN_EMAIL_ADDRESS  "FAILURE $timestamp"
    }
    # #else {
    #     Write-Host $message_to_write -ForegroundColor Green
    # #}
}

function send_mail([string]$email_body, [string]$email_receiver, [string]$email_object) {
    if ($email_body -match "fail") {
        $open_color_div = "<div class='failure'>"
    }
    else {
        $open_color_div = "<div class='success'>"
    }
    $template = Get-Content "email-template.txt" -Raw
    $From = $global:SERVICE_ACCOUNT_EMAIL_ADDRESS
    $To = $email_receiver
    $Subject = $email_object
    $Body = Invoke-Expression "@`"`r`n$template`r`n`"@"
    $SMTPServer = "smtp.gmail.com"
    $SMTPPort = 587
    $encodingMail = [System.Text.Encoding]::UTF8
    try {
        Send-MailMessage `
            -From $From `
            -to $To `
            -Subject $Subject `
            -Body $Body `
            -SmtpServer $SMTPServer `
            -port $SMTPPort `
            -Encoding $encodingMail `
            -BodyAsHtml `
            -Credential (Get-Credential -credential $global:SERVICE_ACCOUNT_EMAIL_ADDRESS) `
            -UseSsl
    }
    catch {
        write_to_log "unsuccessful attempt to send email to $To"
    }
}

function create_vm_from_csv([Object[]]$csv_list) {
    $return = 0
    foreach ($line in $csv_list) {
        $global:NUMBER_OF_VM_TO_CREATE += 1
        $date_time = Get-Date -UFormat '%m/%d/%Y %R'
        $Name = $line.Name
        $VMHost = $line.VMHost
        $Datastore = $line.Datastore
        $DiskMB = $line.DiskMB
        $MemoryMB = $line.MemoryMB
        $NumCpu = $line.NumCpu
        $DiskStorageFormat = $line.DiskStorageFormat
        $requester = $line.requested_by
        $description = "VM created on $date_time for $requester"
        $vm_specs = "Name: $Name VMHost: $VMHost Datastore: $Datastore DiskMB: $DiskMB MemoryMB: $MemoryMB NumCpu: $NumCpu DiskStorageFormat: $DiskStorageFormat"
        write_to_log "$Name will be created with the following specs: $vm_specs"
        write_to_log "Starting $Name creation process`n"
        if (New-VM 	`
                -Name  $Name `
                -VMHost  $VMHost `
                -Datastore  $Datastore `
                -DiskMB  $DiskMB `
                -MemoryMB  $MemoryMB `
                -NumCpu  $NumCpu `
                -DiskStorageFormat  $DiskStorageFormat `
                -Notes $description `
                -Confirm  `
                -RunAsync) {
            write_to_log "successfully created vm $Name"
            $vm_specs = "<ul><li>Name: $Name</li><li>VMHost: $VMHost</li><li>Datastore: $Datastore</li><li>DiskMB: $DiskMB</li><li>MemoryMB: $MemoryMB</li><li>NumCpu: $NumCpu</li><li>DiskStorageFormat: $DiskStorageFormat</li></ul>"
            $global:REQUESTER_EMAIL_BODY = "<li>We successfully created vm $Name on $date_time with the following specs: $vm_specs</li>"
            $global:MANAGER_EMAIL_BODY += "<li>We successfully created vm $name on $date_time for $requester with the following specs: `n`t$vm_specs</li>" 
            send_mail $global:REQUESTER_EMAIL_BODY  $global:REQUESTER_EMAIL_ADDRESS  "$Name is ready!"
            $return += 1
        }
        else {
            write_to_log "failure while creating vm $Name"
        }
        
        if (!$Error[0]) {
            write_to_log $Error[0]
        }

    }
    return $return
}



function main() {
    $Error.Clear()
    if (load_powercli) {
        write_to_log "Successfully loaded PowerCLI module"
        if (connect_to_vcenter) {
            write_to_log "Connected successfully"
            $list = import_csv(".\vm_list.csv")
            if (!$list) {
                write_to_log "failure while importing csv file"
                Exit-PSSession
            }
            else {
                write_to_log "Successfully imported csv file"
                $returned_val = create_vm_from_csv($list)
                write_to_log "Successfully created $returned_val vm out of $global:NUMBER_OF_VM_TO_CREATE"
                $global:MANAGER_EMAIL_BODY += "`n`nSuccessfully created $returned_val vm out of $global:NUMBER_OF_VM_TO_CREATE"
                send_mail $global:MANAGER_EMAIL_BODY  $global:MANAGER_EMAIL_ADDRESS  "Detailed report on VM creations"
                send_mail $global:MANAGER_EMAIL_BODY  $global:TECHNICIAN_EMAIL_ADDRESS  "Detailed report on VM creations"
                Exit-PSSession
            }
        }
        else {
            write_to_log "connexion failed"
            Exit-PSSession
        }
    }
    else {
        write_to_log "Failure while loading PowerCLI"
        Exit-PSSession
    }
}

main
