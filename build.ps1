param(
    [string]$Output = (Join-Path $PSScriptRoot "ClayMaze.exe")
)

$ErrorActionPreference = "Stop"

$pf86 = ${env:ProgramFiles(x86)}
$vswhere = Join-Path $pf86 "Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) { throw "Visual Studio (with the C++ workload) is required." }

$vs = & $vswhere -latest -property installationPath
$msvc = Get-ChildItem (Join-Path $vs "VC\Tools\MSVC") | Sort-Object Name | Select-Object -Last 1
$bin = Join-Path $msvc.FullName "bin\Hostx64\x86"

$sdk = Get-ChildItem (Join-Path $pf86 "Windows Kits\10\Lib") | Sort-Object Name | Select-Object -Last 1
$sdkLib = Join-Path $sdk.FullName "um\x86"

$obj = Join-Path ([IO.Path]::GetTempPath()) "ClayMaze.obj"

& (Join-Path $bin "ml.exe") /c /coff /nologo "/Fo$obj" (Join-Path $PSScriptRoot "ClayMaze\ClayMaze.asm")
if ($LASTEXITCODE -ne 0) { throw "Assembling failed." }

& (Join-Path $bin "link.exe") /nologo /subsystem:windows /entry:main@0 "/out:$Output" $obj "/libpath:$sdkLib" kernel32.lib shell32.lib ws2_32.lib
if ($LASTEXITCODE -ne 0) { throw "Linking failed." }

Remove-Item $obj -ErrorAction SilentlyContinue
Write-Host "Built $Output"
