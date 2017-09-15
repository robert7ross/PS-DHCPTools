Function Get-DHCPServers{
    <#
        .SYNOPSIS
        Uses netsh to retrieve a list of Dynamic Host Configuration Protocol (DHCP) servers in the environment.

        .DESCRIPTION

        .NOTES
        AUTHOR: Robert Ross
        LASTEDIT: 20170915
        KEYWORDS: DHCP
        LICENSE: MIT License, Copyright (c) 2017 Robert Ross

        .LINK
        https://github.com/robert7ross/PS-DHCPTools
    #>

    [CmdletBinding()]

    param(
        #[Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        #[string[]]$MACAddress
    )

    BEGIN {
        $netsh_output = Invoke-Expression "cmd /c netsh dhcp show server"
    }

    PROCESS {
        if(($netsh_output[($netsh_output.length) - 1]) -eq "Command completed successfully."){
            Write-Verbose $netsh_output[1]

            $server_list = @()
            foreach($line in $netsh_output){
                if($line.length -gt 0){
                    $line = $line.trim("`t")
                    
                    if($line.startswith("Server")){
                        $server_list += $line.split(" ")[1].trim("[").split(".")[0]
                    }
                }
            }
            return $server_list
        }
        else{
            write-host "Failed to retrieve the server list."
        }
    }
}