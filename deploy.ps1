# AlignOS Deployment Script
# This script pulls latest code and deploys the application on multiple ports to match router configuration
# Run this after setup-staging.ps1

param(
    [string]$Branch = "main",
    [switch]$Port80,
    [switch]$Port443,
    [switch]$Port5000,
    [switch]$All
)

$appPath = "C:\inetpub\alignos"
$repoUrl = "https://github.com/thewebkid/alignos.git"

# Store starting directory to return to later
$startingDir = Get-Location

# Pull latest code in the current development directory
Write-Host "=== Pulling Latest Code in Development Directory ===" -ForegroundColor Cyan
if (Test-Path ".git") {
    git stash
    git pull origin $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to pull in development directory" -ForegroundColor Red
        Set-Location $startingDir
        exit 1
    }
    Write-Host "Development directory updated" -ForegroundColor Green
} else {
    Write-Host "WARNING: Not in a git repository. Skipping development pull." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== AlignOS Multi-Port Deployment ===" -ForegroundColor Cyan
Write-Host ""

# If no ports specified, default to all ports
if (-not $Port80 -and -not $Port443 -and -not $Port5000 -and -not $All) {
    $Port80 = $true
    $Port443 = $true
    $Port5000 = $true
}

# If All is specified, enable all ports
if ($All) {
    $Port80 = $true
    $Port443 = $true
    $Port5000 = $true
}

# Clone or pull repository (same as regular deploy)
if (!(Test-Path "$appPath\.git")) {
    Write-Host "Cloning repository..." -ForegroundColor Green
    if (Test-Path $appPath) {
        Remove-Item -Path $appPath -Recurse -Force
    }
    git clone $repoUrl $appPath
    Set-Location $appPath
    git checkout $Branch
} else {
    Write-Host "Updating repository..." -ForegroundColor Green
    Set-Location $appPath
    git stash
    git checkout $Branch
    git pull origin $Branch
}

Write-Host "Repository updated" -ForegroundColor Green

# Install dependencies
Write-Host ""
Write-Host "Installing server dependencies..." -ForegroundColor Green
Set-Location "$appPath\server"
npm install --production

Write-Host ""
Write-Host "Installing client dependencies..." -ForegroundColor Green
Set-Location "$appPath\client"
npm install

Write-Host ""
Write-Host "Building client application..." -ForegroundColor Green
npm run build

# Deploy to different ports
Set-Location "$appPath\server"

# Stop existing instances
Write-Host ""
Write-Host "Stopping existing instances..." -ForegroundColor Yellow
pm2 delete alignos-80 2>$null
pm2 delete alignos-443 2>$null
pm2 delete alignos-5000 2>$null
pm2 delete alignos 2>$null

# Create environment files and start instances
if ($Port80) {
    Write-Host ""
    Write-Host "Deploying on port 80..." -ForegroundColor Green
    $env80 = "PORT=80`nMONGODB_URI=mongodb://localhost:27017/alignos`nNODE_ENV=production"
    [System.IO.File]::WriteAllText("$appPath\server\.env.80", $env80)
    
    # Copy the env file to .env before starting
    Copy-Item "$appPath\server\.env.80" "$appPath\server\.env" -Force
    pm2 start index.js --name alignos-80
    Write-Host "  Started on port 80" -ForegroundColor Green
}

if ($Port443) {
    Write-Host ""
    Write-Host "Deploying on port 443..." -ForegroundColor Green
    $env443 = "PORT=443`nMONGODB_URI=mongodb://localhost:27017/alignos`nNODE_ENV=production"
    [System.IO.File]::WriteAllText("$appPath\server\.env.443", $env443)
    
    # Copy the env file to .env before starting
    Copy-Item "$appPath\server\.env.443" "$appPath\server\.env" -Force
    pm2 start index.js --name alignos-443
    Write-Host "  Started on port 443" -ForegroundColor Green
}

if ($Port5000) {
    Write-Host ""
    Write-Host "Deploying on port 5000..." -ForegroundColor Green
    $env5000 = "PORT=5000`nMONGODB_URI=mongodb://localhost:27017/alignos`nNODE_ENV=production"
    [System.IO.File]::WriteAllText("$appPath\server\.env", $env5000)
    
    pm2 start index.js --name alignos-5000
    Write-Host "  Started on port 5000" -ForegroundColor Green
}

# Save PM2 configuration
pm2 save

Write-Host ""
Write-Host "=== Deployment Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "=== Application Status ===" -ForegroundColor Cyan
pm2 status

Write-Host ""
Write-Host "=== Access URLs ===" -ForegroundColor Cyan
if ($Port80) {
    Write-Host "  Port 80:   http://thewebkid.asuscomm.com" -ForegroundColor Green
    Write-Host "             http://192.168.50.209" -ForegroundColor Green
}
if ($Port443) {
    Write-Host "  Port 443:  https://thewebkid.asuscomm.com (requires SSL cert)" -ForegroundColor Yellow
    Write-Host "             https://192.168.50.209 (requires SSL cert)" -ForegroundColor Yellow
}
if ($Port5000) {
    Write-Host "  Port 5000: http://thewebkid.asuscomm.com:5000" -ForegroundColor Green
    Write-Host "             http://192.168.50.209:5000" -ForegroundColor Green
}

Write-Host ""
Write-Host "Note: Port 443 requires SSL certificate configuration." -ForegroundColor Yellow
Write-Host ""

# Return to starting directory
Set-Location $startingDir
Write-Host "Returned to starting directory: $startingDir" -ForegroundColor Cyan
Write-Host ""
