function WSUS-Approve-Patch
{
    param(
    [Parameter(Mandatory=$true)]
    [String[]]
    $ComputerName,

    [Parameter(Mandatory=$true)]
    [String[]]
    $WSUSGroupName,

    [String[]]
    $WSUSServername
    )

    $wsusserver=Get-WsusServer -name $WSUSServername -PortNumber 8530
    
    $allpatch=($wsusserver.GetComputerTargetbyName($ComputerName)).GetUpdateInstallationInfoPerUpdate() |? ($_.UpdateInstallationstate -eq "NotInstall")


    foreach( $patch in $allpatch)
    {
     $tmp=Get-WsusUpdate -UpdateId $patch.updateid
     if  ($tmp.classificatin -eq "Security Updates")
     {
        Approve-WsusUpdate -update $tmp -Action Install -TargetGroupName $WSUSGroupName
     }
     if  ($tmp.classificatin -eq "Critical Updates")
     {
      Approve-WsusUpdate -update $tmp -Action Install -TargetGroupName $WSUSGroupName
     }
    }


}
