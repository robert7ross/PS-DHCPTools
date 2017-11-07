Function Find-DhcpServerv4LeaseMac{
    <#
        .SYNOPSIS
        Finds the DHCP lease for a given MAC and DHCP server.
        
        .DESCRIPTION
        nothing

        .OUTPUTS
        Returns a DHCP lease object or -1 if not found.

        .EXAMPLE
        Find-DhcpServerv4LeaseMac 00-AA-BB-CC-DD-EE server
        Get the DHCP lease information for a specific MAC address returning the server and scope as well.

        .NOTES
        AUTHOR: Robert Ross
        LASTEDIT: 20171107
        KEYWORDS: DHCP
        LICENSE: MIT License, Copyright (c) 2017 Robert Ross

        .LINK
        https://github.com/robert7ross/PS-DHCPTools
    #>
    
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)][string]$MACAddress,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)][string[]]$DHCPServers
    )

    BEGIN {
        Import-Module ActiveDirectory
    }

    PROCESS {
        
        $MACAddress = $MACAddress.ToUpper()
        
        $found = $false
         
        foreach($DHCPServer in $DHCPServers){
            try{

                [object]$DHCPServer = Get-ADComputer $DHCPServer -ErrorAction Continue
                $scopes = get-dhcpserverv4scope -computername $DHCPServer.Name -ErrorAction Continue


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
            }
            catch [System.Exception] {
                Write-Verbose $Error[0]
            }
        }
            
            
        if(-not $found){
            return -1
        }
    }

}