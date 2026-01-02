# AlignOS Deployment Script for Staging Server
# Run this script on the staging PC after running setup-staging.ps1

param(
    [string]$Branch = "main"
)

$appPath = "C:\inetpub\alignos"
$repoUrl = "https://github.com/thewebkid/alignos.git"
$appName = "alignos"

Write-Host "=== AlignOS Staging Deployment ===" -ForegroundColor Cyan
Write-Host "Repository: $repoUrl" -ForegroundColor Yellow
Write-Host "Branch: $Branch" -ForegroundColor Yellow
Write-Host "Deploy Path: $appPath" -ForegroundColor Yellow
Write-Host ""

# Clone or pull repository
if (!(Test-Path "$appPath\.git")) {
    Write-Host "Cloning repository for the first time..." -ForegroundColor Green
    if (Test-Path $appPath) {
        Write-Host "Warning: Directory exists but is not a git repository. Removing..." -ForegroundColor Yellow
        Remove-Item -Path $appPath -Recurse -Force
    }
    git clone $repoUrl $appPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
        exit 1
    }
    Set-Location $appPath
    git checkout $Branch
} else {
    Write-Host "Pulling latest changes..." -ForegroundColor Green
    Set-Location $appPath
    git stash
    git checkout $Branch
    git pull origin $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to pull latest changes" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Repository updated" -ForegroundColor Green

# Install server dependencies
Write-Host ""
Write-Host "Installing server dependencies..." -ForegroundColor Green
Set-Location "$appPath\server"

if (!(Test-Path "package.json")) {
    Write-Host "ERROR: server/package.json not found!" -ForegroundColor Red
    exit 1
}

npm install --production
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install server dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Server dependencies installed" -ForegroundColor Green

# Install client dependencies and build
Write-Host ""
Write-Host "Installing client dependencies..." -ForegroundColor Green
Set-Location "$appPath\client"

if (!(Test-Path "package.json")) {
    Write-Host "ERROR: client/package.json not found!" -ForegroundColor Red
    exit 1
}

npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install client dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Client dependencies installed" -ForegroundColor Green

Write-Host ""
Write-Host "Building client application..." -ForegroundColor Green
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build client" -ForegroundColor Red
    exit 1
}
Write-Host "Client built successfully" -ForegroundColor Green

# Create .env file if it doesn't exist
$envPath = "$appPath\server\.env"
if (!(Test-Path $envPath)) {
    Write-Host ""
    Write-Host "Creating .env file..." -ForegroundColor Green
    $envContent = "PORT=5000`nMONGODB_URI=mongodb://localhost:27017/alignos`nNODE_ENV=production"
    [System.IO.File]::WriteAllText($envPath, $envContent)
    Write-Host ".env file created" -ForegroundColor Green
    Write-Host "You may need to edit $envPath for your environment" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host ".env file already exists" -ForegroundColor Green
}

# Deploy with PM2
Write-Host ""
Write-Host "Deploying application with PM2..." -ForegroundColor Green
Set-Location "$appPath\server"

# Check if app is already running
$pm2List = pm2 list | Out-String
if ($pm2List -match $appName) {
    Write-Host "Restarting existing application..." -ForegroundColor Yellow
    pm2 restart $appName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to restart application" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Starting application for the first time..." -ForegroundColor Yellow
    pm2 start index.js --name $appName --watch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to start application" -ForegroundColor Red
        exit 1
    }
}

# Save PM2 process list
pm2 save

Write-Host "Application deployed" -ForegroundColor Green

# Show status
Write-Host ""
Write-Host "=== Application Status ===" -ForegroundColor Cyan
pm2 status

# Get local IP addresses
Write-Host ""
Write-Host "=== Access URLs ===" -ForegroundColor Cyan
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" } | Select-Object -ExpandProperty IPAddress
foreach ($ip in $ipAddresses) {
    Write-Host "http://${ip}:5000" -ForegroundColor Green
}
Write-Host "http://localhost:5000" -ForegroundColor Green

Write-Host ""
Write-Host "=== Deployment Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Useful PM2 commands:" -ForegroundColor Cyan
Write-Host "  pm2 status       - Show running processes" -ForegroundColor White
Write-Host "  pm2 logs alignos - View application logs" -ForegroundColor White
Write-Host "  pm2 restart alignos - Restart the app" -ForegroundColor White
Write-Host "  pm2 stop alignos - Stop the application" -ForegroundColor White
Write-Host "  pm2 monit        - Monitor in real-time" -ForegroundColor White
Write-Host ""
