Function Start-AzureStorageDirCopy {
    <#
    .SYNOPSIS
        Copies all files from source - destination directory
 
    .DESCRIPTION
        All files within the source directory are forced copied to the destionation folder
        This is done in the same storage account context

        View and copy storage access keys
        In the Azure Portal, navigate to your storage account, click All settings and then click Access keys to view, copy, and regenerate your account access keys.
        The Access Keys blade also includes pre-configured connection strings using your primary and secondary keys that you can copy to use in your applications.
 
    .PARAMETER shareName
        Storage Account share name

    .PARAMETER saAccount
        Storage Account Name

    .PARAMETER saKey
        Storage Account Key

    .PARAMETER srcDir
        Source irectory

    .PARAMETER dstDir
        Destination directory
        
    .EXAMPLE
        Start-AzureStorageDirCopy -shareName "share" -saAccount "storage account name" -saKey "storage account key" -srcDir "SourceDir" -dstDir "DestDir"

    .EXAMPLE
        Start-AzureStorageDirCopy -shareName "share" -saAccount "saName" -saKey "AAABBB111222AAABBB111222AAABBB111222==" -srcDir "SourceDir" -dstDir "DestDir"
    
    .INPUTS
        Source / Destination folder
 
    .OUTPUTS
        Copies all files
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
        [string]$shareName,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$saAccount,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$saKey,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$srcDir,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$dstDir
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Try {
            $context = New-AzureStorageContext $saAccount $saKey
            $share   = Get-AzureStorageShare $shareName -Context $context
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] $($_.Exception.Message)"
            Throw
        }
    }
    Process {
        $ErrorActionPreference = 'Stop'
        Try {
            $allFiles = Get-AzureStorageFile -Share $share -Path $srcDir | Get-AzureStorageFile
            if ($allFiles.count -ge 1) {
                foreach ($file in $allFiles) {
                    Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - Copy $($file.Name) from $srcDir to $dstDir in SA $saAccount"
                    Start-AzureStorageFileCopy -SrcShareName $shareName -SrcFilePath $srcDir/$($file.Name) -DestShareName $shareName -DestFilePath $dstDir/$($file.Name) -Context $context -DestContext $context -Force | Out-Null
                }
            }
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] $($_.Exception.Message)"
            Throw
        }
    }
    End {
        Remove-Variable context, share
    }
} #end function Start-AzureStorageDirCopy