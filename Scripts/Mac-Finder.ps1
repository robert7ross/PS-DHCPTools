Function Get-DHCPServers{
    <#
        .SYNOPSIS
        Uses netsh to retrieve a list of Dynamic Host Configuration Protocol (DHCP) servers in the environment.

        .DESCRIPTION

        .OUTPUT
        Returns an array of DHCP server hostnames as strings. 
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

Function Find-DhcpServerv4LeaseMac{
    <#
        .SYNOPSIS
        Finds the DHCP lease for a given MAC and DHCP server.
        
        .DESCRIPTION
        nothing

        .OUTPUTS
        Returns a DHCP lease object.

        .EXAMPLE
        Find-DhcpServerv4LeaseMac 00-AA-BB-CC-DD-EE server
        Get the DHCP lease information for a specific MAC address returning the server and scope as well.
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
            Write-Host "MAC" $MACAddress "not found in leases."
        }
    }

}

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
            Write-Host "MAC" $MACAddress "not found in filters."
            #return -1
        }
        else{
            return $FilterList
        }
    }
   
}

$test_MAC = Read-Host 'Enter MAC (must be in hyphenated format, ex aa-bb-cc-dd-ee-ff)'

$server = Read-Host 'Which DHCP Server do you want to search? (leave blank and press ENTER to search all)'
write-host "This search takes 2-3 minutes to complete."

if(-not $server){
    $server = Get-DHCPServers
}

Find-DhcpServerv4LeaseMac $test_MAC $server

Find-DhcpServerv4FilterMac $test_MAC $server