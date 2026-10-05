# Prepara o Windows Server 2022 da VM para a AC2:
#   1. instala o IIS (Web Server) com o console de gerenciamento;
#   2. baixa este repositório do GitHub e copia o site para C:\inetpub\wwwroot\projeto;
#   3. testa http://localhost/projeto/;
#   4. baixa o ngrok para C:\ngrok (o authtoken você cadastra à mão, ele é pessoal).
#
# Como rodar (PowerShell como Administrador, dentro da VM):
#   Set-ExecutionPolicy -Scope Process Bypass -Force
#   .\setup-vm.ps1

param(
    [string]$Repositorio = "gabrielcomercial401-ux/ac2-site-iis-ngrok",
    [string]$Destino = "C:\inetpub\wwwroot\projeto",
    [switch]$SemNgrok
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Passo($texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { throw "Abra o PowerShell como Administrador e rode de novo." }

# 1. IIS
Passo "Instalando o IIS (Web Server)"
$iis = Get-WindowsFeature Web-Server
if ($iis.Installed) {
    Write-Host "IIS já estava instalado."
} else {
    Install-WindowsFeature Web-Server -IncludeManagementTools | Out-Null
    Write-Host "IIS instalado."
}
Start-Service W3SVC
Set-Service W3SVC -StartupType Automatic

# 2. Site
Passo "Baixando o site de github.com/$Repositorio"
$tmp = Join-Path $env:TEMP "ac2-site"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory $tmp | Out-Null
$zip = Join-Path $tmp "site.zip"
Invoke-WebRequest "https://github.com/$Repositorio/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
Expand-Archive $zip -DestinationPath $tmp -Force
$origem = Get-ChildItem $tmp -Directory | Select-Object -First 1

Passo "Copiando o site para $Destino"
New-Item -ItemType Directory $Destino -Force | Out-Null
Copy-Item (Join-Path $origem.FullName "*") $Destino -Recurse -Force
Write-Host "Arquivos copiados. index.html na raiz: $(Test-Path (Join-Path $Destino 'index.html'))"

# 3. Teste local
Passo "Testando http://localhost/projeto/"
try {
    $resp = Invoke-WebRequest "http://localhost/projeto/" -UseBasicParsing
    Write-Host "OK: status $($resp.StatusCode). O site abre localmente." -ForegroundColor Green
} catch {
    Write-Host "Falhou: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Confira se o Default Web Site está iniciado no IIS e se a porta é 80."
}

# 4. ngrok
if (-not $SemNgrok) {
    Passo "Baixando o ngrok para C:\ngrok"
    $pastaNgrok = "C:\ngrok"
    if (-not (Test-Path (Join-Path $pastaNgrok "ngrok.exe"))) {
        New-Item -ItemType Directory $pastaNgrok -Force | Out-Null
        $zipNgrok = Join-Path $tmp "ngrok.zip"
        Invoke-WebRequest "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile $zipNgrok -UseBasicParsing
        Expand-Archive $zipNgrok -DestinationPath $pastaNgrok -Force
    }
    $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($path -notlike "*$pastaNgrok*") {
        [Environment]::SetEnvironmentVariable("Path", "$path;$pastaNgrok", "Machine")
    }
    Write-Host "ngrok em $pastaNgrok\ngrok.exe"
}

Passo "Pronto. Próximos passos:"
Write-Host "  1. Abra http://localhost/projeto/ no navegador da VM."
Write-Host "  2. Cadastre o token (só uma vez):  C:\ngrok\ngrok.exe config add-authtoken SEU_TOKEN"
Write-Host "  3. Publique:                        C:\ngrok\ngrok.exe http 80"
Write-Host "  4. Abra a URL https://... + /projeto/ no celular e gere o QR Code em qrcode.html."
