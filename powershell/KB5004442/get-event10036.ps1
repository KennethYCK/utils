#The script used to get Event ID 10036 for CVE-2021-26414 and export into CSV file
#More detail can reference Microsoft link
#https://support.microsoft.com/en-us/topic/kb5004442-manage-changes-for-windows-dcom-server-security-feature-bypass-cve-2021-26414-f1400b52-c141-43d2-941e-37ed901c769c


$allevent = (Get-WinEvent -FilterHashtable @{logname='system';id=10036}).message
$result =@()
foreach($record in $allevent)
{
    $record -match '(?<name>\w+\\\w+).* (?<IP>(\d{1,3}\.){3}\d{1,3})'
    $hash =@{
        User=$Matches.name
        IP = $Matches.ip
        }
    $object =New-Object psobject -Property $hash
    $result+=$object
}

$result | sort-object ip -Unique | export-csv event_10036.csv -NoTypeInformation
