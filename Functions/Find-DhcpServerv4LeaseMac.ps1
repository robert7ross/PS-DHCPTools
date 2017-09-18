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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$MACAddress,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)][string]$DHCPServer
    )

    BEGIN {
        Import-Module ActiveDirectory
    }

    PROCESS {
        foreach($MAC in $MACAddress){
            #look for MAC in $DHCPServer
        }
    }

    END {}
}