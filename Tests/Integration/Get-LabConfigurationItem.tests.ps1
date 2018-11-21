# Use settings.psd1 from build to check all settings
$configurationPath = $(Resolve-Path -Path "$PSScriptRoot\..\..\AutomatedLab\settings.psd1" -ErrorAction Stop).Path

if (-not (Get-Module -List Newtonsoft.Json)) {Install-Module -Name Newtonsoft.Json -Force -SkipPublisherCheck -AllowClobber}
if (-not (Get-Module -List powershell-yaml)) {Install-Module -Name powershell-yaml -Force -SkipPublisherCheck -AllowClobber}
if (-not (Get-Module -List Datum)) {Install-Module -Name Datum -Force -SkipPublisherCheck -AllowClobber}

Import-Module -Name Newtonsoft.Json,powershell-yaml
Import-Module -Name Datum,"$PSScriptRoot\..\..\AutomatedLab.Common\AutomatedLab.Common" -Force

$reqdModules = @(
    'AutomatedLabUnattended'
    'PSLog',
    'PSFileTransfer',
    'AutomatedLabDefinition',
    'AutomatedLabWorker',
    'HostsFile',
    'AutomatedLabNotifications',
    'AutomatedLab'
)
foreach ($mod in $reqdModules)
{
    Import-Module -Name "$PSScriptRoot\..\..\$mod" -Force
}


Describe 'Get-LabConfigurationItem' {
    $functionCalls = (Get-ChildItem -Path "$PSScriptRoot\..\.." -Recurse -Filter *.ps*1 | select-string -Pattern 'Get-LabConfigurationItem -Name \w+').Matches.Value | Sort-Object -Unique

    It 'Should contain all settings' -Skip {
        Get-LabConfigurationItem -GlobalPath $configurationPath | Should -Not -Be $null
    }
    

    $configuration = Get-LabConfigurationItem -GlobalPath $configurationPath

    foreach ($call in $functionCalls)
    {
        $m = $call -match '-Name\s(?<Name>\w+)'
        It "Should contain a key for setting $($Matches.Name)" -Skip {
            $configuration.Contains($Matches.Name) | Should -Be $true
        }
    }
}