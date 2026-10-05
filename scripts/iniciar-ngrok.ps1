# Abre o túnel do ngrok para a porta do IIS.
# Uso:  .\iniciar-ngrok.ps1          (porta 80)
#       .\iniciar-ngrok.ps1 -Porta 8080
# Deixe o terminal aberto durante a apresentação. Ctrl+C encerra o túnel.

param([int]$Porta = 80)

$ngrok = "C:\ngrok\ngrok.exe"
if (-not (Test-Path $ngrok)) { $ngrok = "ngrok" }

$local = if ($Porta -eq 80) { "http://localhost/projeto/" } else { "http://localhost:$Porta/projeto/" }
try {
    Invoke-WebRequest $local -UseBasicParsing | Out-Null
    Write-Host "Site OK em $local" -ForegroundColor Green
} catch {
    Write-Host "O site não abriu em $local. Corrija o IIS antes de ligar o ngrok." -ForegroundColor Red
    exit 1
}

Write-Host "A URL pública aparece em 'Forwarding'. Acrescente /projeto/ no final." -ForegroundColor Cyan
& $ngrok http $Porta
