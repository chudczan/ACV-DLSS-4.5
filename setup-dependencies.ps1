$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Get-Sha256([string]$Path) {
    $stream = [System.IO.File]::OpenRead($Path)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant() }
    finally { $stream.Dispose(); $sha.Dispose() }
}
$root = $PSScriptRoot
$downloadDir = Join-Path $root 'build\downloads'
New-Item -ItemType Directory -Force $downloadDir | Out-Null
$sdkDir = Join-Path $root 'external\streamline-2.14.16'
$sdkZip = Join-Path $downloadDir 'streamline-sdk-v2.14.16.zip'
$sdkHash = '32041e51db0cab709a271b72a352281b690c2abbd669a827809401a5dd23956b'
if (-not (Test-Path -LiteralPath "$sdkDir\lib\x64\sl.interposer.lib")) {
    if (-not (Test-Path -LiteralPath $sdkZip)) {
        Invoke-WebRequest 'https://github.com/NVIDIA-RTX/Streamline/releases/download/v2.14.16/streamline-sdk-v2.14.16.zip' -OutFile $sdkZip
    }
    if ((Get-Sha256 $sdkZip) -ne $sdkHash) {
        throw "Streamline checksum mismatch: $sdkZip"
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sdkZip, $sdkDir)
}
$nvapiDir = Join-Path $root 'external\nvapi\nvapi-main\amd64'
New-Item -ItemType Directory -Force $nvapiDir | Out-Null
$nvapiLib = Join-Path $nvapiDir 'nvapi64.lib'
if (-not (Test-Path -LiteralPath $nvapiLib)) {
    Invoke-WebRequest 'https://raw.githubusercontent.com/NVIDIA/nvapi/70d337db9186e968eab622f7e786de7e437faf3d/amd64/nvapi64.lib' -OutFile $nvapiLib
}
if ((Get-Sha256 $nvapiLib) -ne '901e479e548d41c30688c7481f0c6353c0be7fdee978796d27d87c32e19ce172') {
    throw "NVAPI checksum mismatch: $nvapiLib"
}
Write-Host 'Dependencies ready: Streamline 2.14.16 (x64), NVAPI.'
