Function Find-DhcpServerv4FilterMac{
    <#
        .SYNOPSIS
        Looks for a MAC address in a DHCP server's filters.
        
        .DESCRIPTION
        Checks the filters on all supplied DHCP serves for any filter that matches
        the MAC address passed to the funtion.

        .OUTPUT
        If found:
            Filter - [MacAddress,List,Description]
            (DHCP Server) Computer Name
        If not found:
            -1


        .NOTES
        AUTHOR: Robert Ross
        LASTEDIT: 20171002
        KEYWORDS: DHCP, MAC
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
        
        foreach($i in (10,8,6,4,2)){ $MACAddress = $MACAddress.Insert($i,'-') }
                
        $found = $false
            
        foreach($DHCPServer in $DHCPServers){
            try{

                $FilteredMACs = Get-DhcpServerv4Filter -computername $DHCPServer -ErrorAction Continue

                foreach($MAC in $FilteredMACs){
                    if($MACAddress -eq ($MAC.MacAddress)){
                        return ($MAC,$DHCPServer)
                        $found = $true
                        break
                    }
                }
            }
            catch [System.Exception] {
                write-host $Error[0]
            }
        }
            
            
        if(-not $found){
            Write-Host "MAC not found on DHCP Server" $DHCPServer.Name
            return -1
        }
    }
   
}