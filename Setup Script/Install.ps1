$LEOCERTPATH=".\LEGENDARYLEO\LEGENDARYLEO-CA.cer"
$SCU611CERTPATH=".\SCU611\SCU611-CA.cer"
$CERTDEST="Cert:\LocalMachine\Root"

$HOSTURL="https://github.com/SCU610/SCU611_Hosts/archive/master.zip"
$HOSTFILEPATH=".\SCU611\HOSTS\source.zip"
$HOSTPATH=".\SCU611\HOSTS"
$TEMPNAME="SCU611_Hosts-master"

$WINDOWSHOSTPATH="C:\Windows\System32\drivers\etc"

function check-admin
{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-CA
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow –NoNewLine "安装证书:"
    Import-Certificate -FilePath $LEOCERTPATH -CertStoreLocation $CERTDEST
    Import-Certificate -FilePath $SCU611CERTPATH -CertStoreLocation $CERTDEST
    Write-Host -ForegroundColor Green "完成"
    Write-Host "-----------------------"
}
function Get-Hosts
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "下载HOSTS文件:"
    if(!(Test-Path $HOSTPATH))
    {
        New-Item -ItemType "directory" -Force -Path $HOSTPATH | Out-Null
    }
    Invoke-WebRequest -Uri $HOSTURL -OutFile $HOSTFILEPATH
    Write-Host -ForegroundColor Green "完成"
    Write-Host "-----------------------"
    return
}

function Expand-Hosts
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "解压:"
    unzip -o -q $HOSTFILEPATH -d $HOSTPATH
    Copy-Item "$HOSTPATH\$TEMPNAME\*" "$HOSTPATH\" -Force
    Write-Host -ForegroundColor Green "完成"
    Write-Host "-----------------------"
    return
}

function Backup-Hosts
{
    $BACKUPPATH=".\Backup"
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "备份HOSTS:"
    if(!(Test-Path $BACKUPPATH))
    {
        New-Item -ItemType "directory" -Force -Path $BACKUPPATH | Out-Null
    }
    Copy-Item "$WINDOWSHOSTPATH\hosts" $BACKUPPATH -Force
    Write-Host -ForegroundColor Green "完成"
    Write-Host "-----------------------"
    return
}

function Remove-Temp
{
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow -NoNewline "清理临时文件:"
    Remove-Item $HOSTFILEPATH, "$HOSTPATH\*.pdf",  "$HOSTPATH\*.vsdx"
    Remove-Item "$HOSTPATH\SCU611_Hosts-master" -Recurse
    Write-Host -ForegroundColor Green "完成"
    return
}

Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow "开始执行安装脚本"
Write-Host "======================="
$AdminStatus=check-admin
<#
if( -not $AdminStatus)
{
    Write-Host -ForegroundColor Red "管理员权限检查失败，请关闭此窗口并以管理员权限重新运行Setup.bat"
    Write-Host "======================="
    Write-Host -ForegroundColor White -BackgroundColor Red "安装失败"
    return
}
#>
#Install-CA
Backup-Hosts
Get-Hosts
Expand-Hosts
Copy-Item "$HOSTPATH\$TEMPNAME\*" "$HOSTPATH\" -Recurse -Force
Remove-Temp
Write-Host "======================="
Write-Host -ForegroundColor White -BackgroundColor Green "安装成功"