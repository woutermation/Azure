function Get-ChildManagementGroup
{
    param (
        [Parameter(Mandatory = $false)]
        [string]$managementGroupID
    )

    begin
    {
        $returnValue = @()
        $rootManagementGroupIsSet = $false
    }
    process
    {
        #
        # If no management group is provided, find the root management group and set the management group ID
        #
        if ($managementGroupID -eq "")
        {
            Write-Verbose "Find root management group as no groupName is provided"
            $allManagementGroups = Get-AzManagementGroup
            do
            {
                foreach ($managementGroup in $allManagementGroups)
                {
                    $checkManagementGroup = $(Get-AzManagementGroup -GroupName $($managementGroup.Name) -Expand)
                    Write-Verbose "Checking $(($checkManagementGroup).Name)"
                    if ($null -eq $(($checkManagementGroup).ParentName))
                    {
                        Write-Verbose "Setting management ID to [ $(($checkManagementGroup).Name) ]"
                        $managementGroupID = $($checkManagementGroup.Name)
                        $rootManagementGroupIsSet = $true
                        #
                        # Leave the foreach loop if the root management group is found
                        #
                        break
                    }
                }
            } while ($rootManagementGroupIsSet -eq $false)
            
        }
        Write-Verbose "Get management group [ $($managementGroupID) ]"
        $allManagementGroups = Get-AzManagementGroup -GroupName $managementGroupID -Expand
        #
        # Loop through all management groups and check if they have children
        #
        foreach ($managementGroup in $allManagementGroups)
        {
            Write-Verbose "Checking [ $(($managementGroup).Name) ] for children"
            $getChildManagementGroupCount = @($managementGroup.Children | Where-Object { $_.Type -eq "Microsoft.Management/managementGroups" }).Count
            if ($getChildManagementGroupCount -gt 0)
            {
                Write-Verbose "Found children [ $($getChildManagementGroupCount) ] for [ $(($managementGroup).Name) ]"
                $returnValue = $returnValue + $managementGroup
                $allChildren = $managementGroup.Children | Where-Object { $_.Type -eq "Microsoft.Management/managementGroups" }
                foreach ($child in $allChildren)
                {
                    Get-ChildManagementGroup -managementGroupID $child.Name
                }
            }
            else
            {
                $returnValue = $returnValue + $managementGroup
                Write-Verbose "No children found for [ $(($managementGroup).Name) ]"
            }
        }
    }
    end
    {
        return $returnValue
    }
}