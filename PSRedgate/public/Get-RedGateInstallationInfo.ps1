function Get-RedGateInstallationInfo
{
    <#
    .SYNOPSIS
    This cmdlet will return a hash with a list of installed redgate applications on this machine, as well as their locations

    .DESCRIPTION
    This cmdlet is used to locate cmdlets, to prevent relying on the path, as well as determining what versions are available on the machine.

    .EXAMPLE
    Get-RedGateInstallationInfo

    This will return a hashtable filled with the redgate applications installed on this machine.

    .NOTES
    This cmdlet is useful because it prevents us having to affect the user's path, while still making it quick to access
    the command line tool locations.
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        # The name of the application you want the information about
        [string] $ApplicationName
    )
    BEGIN
    {
        $executables = @{
            'SQL Source Control'              = ''
            'SQL Data Generator'              = 'SQLDataGenerator.exe'
            'SSMS Integration Pack Framework' = ''
            'SQL Doc'                         = 'SQLDoc.exe'
            'SQL Test'                        = ''
            'SQL Compare'                     = 'SQLCompare.exe'
            'DLM Automation'                  = ''
            'SQL Dependency Tracker'          = ''
            'SQL Multi Script'                = 'SQLMultiScript.exe'
            'SQL Data Compare'                = 'SQLDataCompare.exe'
            'SSMS Integration Pack'           = ''
            'SQL Search'                      = ''
            'SQL Prompt'                      = ''
        }

        # loading private data from the module manifest
        $private:PrivateData = $MyInvocation.MyCommand.Module.PrivateData
        $installationInformation = $private:PrivateData['installationInformation']
    }
    PROCESS
    {
        try
        {
            if (-not($installationInformation))
            {
                $installationInformation = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
                    Select-Object *, @{Label = "ApplicationName"; Expression = {$($_.DisplayName -replace "\d+$", '').Trim()}} |
                    Select-Object *, @{Label = "ExecutableName"; Expression = {$executables[$_.ApplicationName]}} |
                    Where-Object Publisher -Like 'Red Gate*'

            }
            Write-Output $installationInformation | Where-Object ApplicationName -Like "*$ApplicationName*"
        }
        catch
        {
            Write-Host  -Object $_.Exception | Format-List -Force
            break
        }
    }
    END
    {
        $private:PrivateData['installationInformation'] = $installationInformation
    }
}