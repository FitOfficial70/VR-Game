<#!
.SYNOPSIS
    Starts a VR-capable application with an OpenXR runtime.

.DESCRIPTION
    This launcher does not inject code into, patch, bypass, or modify another
    application's files. It only starts an application that already supports
    OpenXR/VR (or accepts its own documented VR command-line option).

    Use this only with software you own or are authorized to run. An arbitrary
    non-VR game cannot be made into a proper VR experience by a generic script.

.PARAMETER Application
    Path to the VR-capable executable.

.PARAMETER ArgumentList
    Arguments documented by the application, such as --vr.

.PARAMETER WorkingDirectory
    Optional working directory for the application.

.PARAMETER Wait
    Wait until the application exits.

.EXAMPLE
    .\launch-vr.ps1 -Application 'C:\Games\MyVrGame\MyVrGame.exe' -ArgumentList '--vr'

.EXAMPLE
    .\launch-vr.ps1 -Application 'C:\Games\Luanti\luanti.exe' -ArgumentList '--vr' -Wait
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Application,

    [Parameter(Position = 1)]
    [string[]] $ArgumentList = @(),

    [string] $WorkingDirectory,

    [switch] $Wait
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedApplication = (Resolve-Path -LiteralPath $Application -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $resolvedApplication -PathType Leaf)) {
    throw "Application was not found: $resolvedApplication"
}

if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) {
    $WorkingDirectory = Split-Path -Parent $resolvedApplication
} else {
    $WorkingDirectory = (Resolve-Path -LiteralPath $WorkingDirectory -ErrorAction Stop).Path
}

# OpenXR uses the runtime selected in the user's VR software (SteamVR,
# Meta Quest Link, WMR, etc.). Do not overwrite it from a launcher.
Write-Host "Starting VR application: $resolvedApplication"
Write-Host "OpenXR runtime is selected by your installed VR platform."

$startParameters = @{
    FilePath         = $resolvedApplication
    WorkingDirectory = $WorkingDirectory
    ArgumentList     = $ArgumentList
    PassThru          = $true
}

$process = Start-Process @startParameters
if ($Wait) {
    Wait-Process -Id $process.Id
}
