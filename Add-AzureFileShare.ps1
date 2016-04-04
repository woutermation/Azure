function Add-AzureFileShare {
    <#
    .SYNOPSIS
        Creates an Azure file share with default folders
 
    .DESCRIPTION
        Create an Azure file share with some default folders.
        An Azure Storage Account needs to be created and the usernam and key must be known.

    .PARAMETER Username
        Specifies the Storage account name.

    .PARAMETER AccessKey
        The name of the list were to add a new value/entry to. Use a $ at the end to specify the list name.
        If the lists MyListRules and MyListRules2 exist in SCSM the MyList will result in an error.
 
    .PARAMETER FileShareName
        The name of the fileshare, must be in lowercase
        
    .EXAMPLE
         Add-AzureFileShare -Username storageaccount -AccessKey <YOUR ACCESS KEY 1 or 2> -FileShareName filesharename

    .INPUTS
        String
 
    .OUTPUTS
        Adds a new share with default directories to an Azure Storage Account
        Status is outputted to screen
 
    .NOTES
        Author:  Wouter de Dood
        Website: 
        Twitter: @WMouter
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$AccessKey,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$FileShareName
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Try {
            Import-Module Azure
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] Module not loaded, Azure Module is mandatory."
            Throw
        }
    }
    Process {
        $ErrorActionPreference = 'Stop'
        Try {
            # create a context for account and key
            $ctx   = New-AzureStorageContext $Username $AccessKey
            #create a new share
            $share = New-AzureStorageShare $FileShareName -Context $ctx
            #create the default directories in the share
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Action] Create default shares"
            New-AzureStorageDirectory -Share $share -Path Archive
            New-AzureStorageDirectory -Share $share -Path Failure
            New-AzureStorageDirectory -Share $share -Path Upload
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Status] Ok"
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] Not created!"
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] $($_.Exception.Message)"
        }

    }
    End {
        Try {
            Remove-Variable share, ctx, Username, AccessKey, FileShareName
        }
        Catch {
        }
    }
}