# Certificate generator for Cassandra Client-to-Node SSL (Windows PowerShell)
$ErrorActionPreference = "Stop"

# Set location to the parent directory of this script (project root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$ScriptDir\.."

$CertsDir = "certs"
$KeystorePath = "$CertsDir\cassandra.keystore"
$CertPath = "$CertsDir\cassandra.crt"
$Password = "cassandra123"
$Alias = "cassandra"

# Allow passing external IP or hostname as argument, default to localhost
param(
    [string]$HostIP = "localhost"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Cassandra SSL Keystore & Certificate Generator (PowerShell)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Ensure certs directory exists
if (-not (Test-Path $CertsDir)) {
    New-Item -ItemType Directory -Path $CertsDir | Out-Null
    Write-Host "[*] Created directory: $CertsDir"
}

# Check if keytool is available in PATH
$KeytoolCheck = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $KeytoolCheck) {
    Write-Host "[!] Error: 'keytool' is not installed or not in PATH." -ForegroundColor Red
    Write-Host "    Please install Java JDK and verify that 'keytool' is available in your environment variables." -ForegroundColor Yellow
    Exit 1
}

# Remove existing keystore if exists to avoid conflicts
if (Test-Path $KeystorePath) {
    Write-Host "[-] Removing existing keystore at $KeystorePath..."
    Remove-Item $KeystorePath -Force
}

Write-Host "[*] Generating Java Keystore for host/IP: $HostIP..."
& keytool -genkeypair `
  -alias $Alias `
  -keyalg RSA `
  -keysize 2048 `
  -validity 3650 `
  -keystore $KeystorePath `
  -storepass $Password `
  -keypass $Password `
  -dname "CN=$HostIP, OU=DevOps, O=Demo, L=Pune, ST=MH, C=IN"

Write-Host "[+] Keystore successfully generated at $KeystorePath" -ForegroundColor Green

# Remove existing certificate if exists
if (Test-Path $CertPath) {
    Write-Host "[-] Removing existing certificate at $CertPath..."
    Remove-Item $CertPath -Force
}

Write-Host "[*] Exporting public certificate..."
& keytool -exportcert `
  -alias $Alias `
  -keystore $KeystorePath `
  -storepass $Password `
  -rfc `
  -file $CertPath

Write-Host "[+] Certificate successfully exported to $CertPath" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Certificates setup complete!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
