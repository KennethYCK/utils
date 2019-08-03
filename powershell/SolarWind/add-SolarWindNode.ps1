<#
    Author :Kenneth Yeung
    Base on Sample from OrionSDK https://github.com/solarwinds/OrionSDK
    More Doc can reference http://solarwinds.github.io/OrionSDK/schema/

    Read the CSV file and bulk create node for Windows Server, added monitor for CPU, RAM, DISK and Network interface

#>
#
#    Global Config Section
#

$hostname = "localhost"
#$username = "admin"
$SNMPcommunity = "public"
$NetAdapterName = "vmxnet3 Ethernet Adapter"

#    End Global Config Section
$all_node = import-csv SolarWind_add_node.csv




$swis = Connect-Swis -host $hostname
write-host "Login Successfully"

function Add_Poller($type, $nodeID)
{
    $NetObject_Type = $type[0]
    
    $poller = @{
        NetObject="$($NetObject_Type):"+$nodeID;
        NetObjectType=$NetObject_Type;
        NetObjectID=$nodeID;
    }

    $poller["PollerType"]=$type;
    $pollerUri = New-SwisObject $swis -EntityType "Orion.Pollers" -Properties $poller
    write-host $pollerUri

}




foreach($node in $all_node)
{
    $newNodeProps = @{
        IPAddress = $node.ip;
        EngineID = 1;
    
        # SNMP v2 specific
        ObjectSubType = "SNMP";

        SNMPVersion = 2;

        DNS = "";
        SysName = "";
        Community =$SNMPcommunity ;
        # === default values ===

        # EntityType = 'Orion.Nodes'
        Caption = $node.servername
        # DynamicIP = false
        # PollInterval = 120
        # RediscoveryInterval = 30
        # StatCollection = 10  
    }

    $newNodeUri = New-SwisObject $swis -EntityType "Orion.Nodes" -Properties $newNodeProps
    write-host "Create Node $($node.servername) Succesfully"

    $nodeProps = Get-SwisObject $swis -Uri $newNodeUri
    $nodeId = $nodeProps.nodeID

    $all_vol = Get-Volume |?{$_.drivetype -eq "Fixed"} 

    $discovered = Invoke-SwisVerb $swis Orion.NPM.Interfaces DiscoverInterfacesOnNode $nodeId

    if ($discovered.Result -ne "Succeed") {
        Write-Host "Interface discovery failed."
    }
    else {
        
        #Remove interfaces that dont have a caption of 'vmnet ethernet'
        $discovered.DiscoveredInterfaces.DiscoveredLiteInterface | ?{ $_.Caption.InnerText -notmatch $NetAdapterName } | %{ $discovered.DiscoveredInterfaces.RemoveChild($_) | Out-Null }

        # Add the remaining interfaces
        Invoke-SwisVerb $swis Orion.NPM.Interfaces AddInterfacesOnNode @($nodeId, $discovered.DiscoveredInterfaces, "AddDefaultPollers") | Out-Null
    }


    <# 
        Detail poller type can referen https://github.com/solarwinds/OrionSDK/wiki/Poller-Types
    #>

    Add_Poller "N.Status.ICMP.Native" $nodeID
    Add_Poller "N.ResponseTime.ICMP.Native" $nodeID
    Add_Poller "N.Cpu.SNMP.HrProcessorLoad" $nodeID
    Add_Poller "N.Memory.SNMP.HrStorage" $nodeID

    Invoke-SwisVerb $swis pollnow "N:$($nodeid)"

}