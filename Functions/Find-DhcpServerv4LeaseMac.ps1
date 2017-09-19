Function Find-DhcpServerv4LeaseMac{
    <#
        .SYNOPSIS
        Finds the DHCP lease for a given MAC and DHCP server.
        
        .DESCRIPTION

        .OUTPUT
        Returns a DHCP lease object.

        .NOTES
        AUTHOR: Robert Ross
        LASTEDIT: 20170918
        KEYWORDS: DHCP
        LICENSE: MIT License, Copyright (c) 2017 Robert Ross

        .LINK
        https://github.com/robert7ross/PS-DHCPTools
    #>
    
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)][string]$MACAddress,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)][string]$DHCPServer
    )

    BEGIN {
        Import-Module ActiveDirectory
    }

    PROCESS {
        
        foreach($i in (10,8,6,4,2)){ $MACAddress = $MACAddress.Insert($i,'-') }
        
        [object]$DHCPServer = Get-ADComputer $DHCPServer
        $scopes = get-dhcpserverv4scope -computername $DHCPServer.Name

        $found = $false
        foreach($scope in $scopes){
            $leases = Get-dhcpserverv4lease -computername $DHCPServer.Name -scopeid $scope.ScopeId

            foreach($lease in $leases){
                if($MACAddress -eq ($lease.ClientId)){
                    return ($lease,$DHCPServer,$scope)
                    $found = $true
                    break
                }
            }
        }
        if(-not $found){
            Write-Host "MAC not found on DHCP Server" $DHCPServer.Name
        }
    }

}