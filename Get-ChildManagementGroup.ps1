function Get-ChildManagementGroup
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$managementGroupName
    )

    foreach ($managementGroup in Get-AzManagementGroup -GroupName $managementGroupName -Expand)
    {
        $getChildManagementGroups = $managementGroup.Children | Where-Object { $_.Type -ne "/subscriptions" }
        Write-Host "$($managementGroup.Name) [ $(($getChildManagementGroups.Children).Count) ]"
        if (($getChildManagementGroups.Children).Count -gt 0)
        {
            foreach ($child in $getChildManagementGroups)
            {
                Get-ChildManagementGroup -managementGroupName $child.Name
            }
        }
    }
}
