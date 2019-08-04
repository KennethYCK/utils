param([string]$date)
if (!$date)
{
    $today= get-date
}
else
{
    $date= [datetime]::ParseExact($date,"yyyyMMdd",$null)
    $today= get-date $date
}

Write-Host $today




$URLDate= Get-Date $today -uFormat "%d%b%y"
$URLDate= $URLDate.Replace("0","")
$Old_File = "idx_$($URLDATE).csv"
$tmp_file = "idx_$($URLDATE).csv.tmp"
$File_Name= "$(Get-Date $today -uFormat '%y%M%d') .csv"
Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0" -Uri "http://www.hsi.com.hk/HSI-Net/static/revamp/contents/en/indexes/report/hsi/idx_$($URLdate).csv" -OutFile $Old_File

Import-Csv -Delimiter "`t" $Old_File -Encoding Unicode | Export-Csv $tmp_file -Delimiter "," -NoTypeInformation -Encoding UTF8 

gc $tmp_file | Select-Object -Skip 2 | Select-Object -First 1 | Set-Content $File_Name -Encoding UTF8
