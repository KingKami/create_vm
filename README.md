# Create VM

## TP1 automatisation virtualisation VMware

## Création d’un script Powershell pour la création de 10 VM

### Effectuez la création d’une VM via la commande New-VMavec les paramètres suivants:

- 1572 Mo de vRam
- 1 disque de 125 Mo au format «ThickEagerZero»
- 2 vCPU

### Effectuez la création de 10 VM via un script Powershell avec:

- 10 paramètres à définir selon vos choix (dont les 3 précédents)
- Sources des informations depuis un fichier .csv•Confirmation d’actions et récapitulatif d’actions à l’écran
- Notifications en fin de traitement

### 3 rapports email en HTML (avec couleurs):

- Pour le technicien: Erreurs sur la création d’une VM
- Pour le demandeur: Rapport sur ce qui a été réalisé
- Pour le responsable: Rapport résumé toutes les créations de VMs


### Notes

make a credentials.ps1 with the following lines

```
$global:USER = 'esxi user name'
$global:PASSWORD = 'esxi user password'
$global:SERVER = 'esxi ip or hostname if dns is set'
$global:SERVICE_ACCOUNT_EMAIL_ADDRESS = "email address" 
$global:MANAGER_EMAIL_ADDRESS = "email address"
$global:REQUESTER_EMAIL_ADDRESS = "email address"
$global:TECHNICIAN_EMAIL_ADDRESS = "email address"
```

For help on how to setup you Gmail account to send email through the script follow this [post](https://support.google.com/mail/answer/185833)