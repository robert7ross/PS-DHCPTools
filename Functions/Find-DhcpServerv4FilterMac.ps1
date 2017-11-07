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

        .EXAMPLE
        Find-DhcpServerv4FilterMac 00-FF-FF-3E-34-A8 server
        Get the DHCP filter information for a specific MAC address from a specified server(s). 


        .NOTES
        AUTHOR: Robert Ross
        LASTEDIT: 20171107
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

        $MACAddress = $MACAddress.ToUpper()
                        
    }

    PROCESS {
        
        $Found = $false
        $FilterList = @() 
         
        foreach($DHCPServer in $DHCPServers){
            try{

                $FilteredMACs = Get-DhcpServerv4Filter -computername $DHCPServer -ErrorAction Continue

                foreach($MAC in $FilteredMACs){
                    if($MACAddress -eq ($MAC.MacAddress)){
                        $FilterList += ($MAC,$DHCPServer)
                        $Found = $true
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
        else{
            return $FilterList
        }
    }
   
}