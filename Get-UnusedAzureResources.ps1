function Get-UnusedAzureResources
{
    <#
    .SYNOPSIS
        Reads all unused Azure Resources
 
    .DESCRIPTION
        Currently the following resources are checked
            - NIC
            - Public IP
            - Harddisks
        If one of the above resources is not attached, the name will show up in the output.
        Take action to delete the resource(s) to save money.
 
    .PARAMETER subscriptionId
        The subscription id of the Azure Subscription
    .PARAMETER tenantId
        The tenant id used for authentication
        
    .EXAMPLE
        Get-UnusedAzureResources -subscriptionId "1234-5432-123-44" -tenantId "13323-22123-35783-00444"
    
    .INPUTS
        Subscription and tenant id
 
    .OUTPUTS
        A list of unused resources
 
    .NOTES
        Author:  Wouter de Dood
        Website: 
        Twitter: @WMouter
    #>

    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $subscriptionId,
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $tenantId
    )
    
    begin
    {
        # Check and or install pre-req
        if (!(Get-InstalledModule -Name Az.Accounts -ErrorAction SilentlyContinue))
        {
            try
            {
                Write-Output "Set execution policy for currentuser"
                Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
                Write-Output "Installing Nuget provider"
                Get-PackageProvider -Name "Nuget" -Force | Out-Null
                Write-Output "Installing Az Module"
                Install-Module Az.Accounts -Scope CurrentUser -Force -AllowClobber
            }
            catch
            {
                Write-Error $($_.Exception.Message)
                throw($($_.Exception.Message))
            }
        }
        # Check if logged in already
        $connected = $false
        $currentContext = Get-AzContext
        if (($currentContext.Tenant.Id -eq $tenantId) -and ($currentContext.Subscription.Id -eq $subscriptionId))
        {
            $connected = $true
        }
    }
    
    process
    {
        try
        {
            $ErrorActionPreference = "Stop"
            if ($connected -eq $false)
            {
                Write-Output "Logging in to Azure, login popup may apear behind powershell screen"
                Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId -UseDeviceAuthentication
            }
            Write-Output "Get all disks that are not attached"
            $allUnusedDisks = (Get-AzDisk | Where-Object { $_.DiskState -eq "Unattached" } | Select-Object Name)
            $allUnusedDisks | Format-List
            Write-Output "Get all NICs that are not attached"
            $allUnusedNics = (Get-AzNetworkInterface | Where-Object { (!($_.VirtualMachine)) } | Select-Object Name)
            $allUnusedNics | Format-List
            Write-Output "Get all PIPs that are not attached"
            $allUnusedPips = (Get-AzPublicIpAddress | Where-Object { (!($_.IpConfiguration)) } | Select-Object Name)
            $allUnusedPips | Format-List
        }
        catch
        {
            Write-Error $($_.Exception.Message)
            throw($($_.Exception.Message))
        }
    }
    
    end
    {
        
    }
}
