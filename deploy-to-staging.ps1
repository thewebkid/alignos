# AlignOS Deployment Script for Staging Server
# Run this script on the staging PC (192.168.50.209) after running setup-staging.ps1
# This will clone/update the repository, install dependencies, build, and deploy

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
    
    # Stash any local changes
    git stash
    
    # Pull latest
    git checkout $Branch
    git pull origin $Branch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to pull latest changes" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✓ Repository updated" -ForegroundColor Green

# Install server dependencies
Write-Host "`nInstalling server dependencies..." -ForegroundColor Green
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
Write-Host "✓ Server dependencies installed" -ForegroundColor Green

# Install client dependencies and build
Write-Host "`nInstalling client dependencies..." -ForegroundColor Green
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
Write-Host "✓ Client dependencies installed" -ForegroundColor Green

Write-Host "`nBuilding client application..." -ForegroundColor Green
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build client" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Client built successfully" -ForegroundColor Green

# Create .env file if it doesn't exist
$envPath = "$appPath\server\.env"
if (!(Test-Path $envPath)) {
    Write-Host "`nCreating .env file..." -ForegroundColor Green
    @"
PORT=5000
MONGODB_URI=mongodb://localhost:27017/alignos
NODE_ENV=production
"@ | Out-File -FilePath $envPath -Encoding UTF8
    Write-Host "✓ .env file created" -ForegroundColor Green
    Write-Host "  You may need to edit $envPath for your environment" -ForegroundColor Yellow
} else {
    Write-Host "`n✓ .env file already exists" -ForegroundColor Green
}

# Deploy with PM2
Write-Host "`nDeploying application with PM2..." -ForegroundColor Green
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

Write-Host "✓ Application deployed" -ForegroundColor Green

# Show status
Write-Host "`n=== Application Status ===" -ForegroundColor Cyan
pm2 status

# Get local IP addresses
Write-Host "`n=== Access URLs ===" -ForegroundColor Cyan
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" } | Select-Object -ExpandProperty IPAddress
foreach ($ip in $ipAddresses) {
    Write-Host "http://${ip}:5000" -ForegroundColor Green
}
Write-Host "http://localhost:5000" -ForegroundColor Green

Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Useful PM2 commands:" -ForegroundColor Cyan
Write-Host "  pm2 status              - Show running processes" -ForegroundColor White
Write-Host "  pm2 logs $appName        - View application logs" -ForegroundColor White
Write-Host "  pm2 restart $appName     - Restart the application" -ForegroundColor White
Write-Host "  pm2 stop $appName        - Stop the application" -ForegroundColor White
Write-Host "  pm2 monit               - Monitor in real-time" -ForegroundColor White
Write-Host ""
