#~/bin/bash

DATE=${1:-`/bin/date +%Y%m%d`}
URLDATE=`date -d $DATE +%d%b%y`
URLDATE=`echo $URLDATE | sed 's/^0//' `



LOGDIR="/home/chi/LOG/index"
SEC_FILE="idx_hsi$DATE.csv"
SEC_FILE_OLD="idx_$URLDATE.csv"


HHI_FILE="idx_hhi$DATE.csv"
HHI_FILE_OLD="idx_$URLDATE.csv"

echo $SEC_FILE
wget -nv -O $LOGDIR/"$SEC_FILE" -w 1 --random-wait -e robots=off -T 60 -U "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0" "http://www.hsi.com.hk/HSI-Net/static/revamp/contents/en/indexes/report/hsi/$SEC_FILE_OLD"

#wget -nv -O $LOGDIR/"$HHI_FILE" -w 1 --random-wait -e robots=off -T 60 -U "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0" "http://www.hsi.com.hk/HSI-Net/static/revamp/contents/en/indexes/report/hscei/$HHI_FILE_OLD"


iconv -f UTF-16LE -t utf-8 $LOGDIR/$SEC_FILE -o $LOGDIR/$SEC_FILE.utf8
#iconv -f UTF-16LE -t utf-8 $LOGDIR/$HHI_FILE -o $LOGDIR/$HHI_FILE.utf8

sed -i '1,2d' $LOGDIR/$SEC_FILE.utf8
tr "\t" "," < $LOGDIR/$SEC_FILE.utf8 > $LOGDIR/$SEC_FILE.idx.tmp
#only keep HSI onlu
sed -i '2,$d' $LOGDIR/$SEC_FILE.idx.tmp



#sed -i '1,2d' $LOGDIR/$HHI_FILE.utf8
#tr "\t" "," < $LOGDIR/$HHI_FILE.utf8 >> $LOGDIR/$SEC_FILE.idx.tmp

cat $LOGDIR/$SEC_FILE.idx.tmp | cut -d"," -f2,3,8,13 --complement > $LOGDIR/$SEC_FILE.idx
sed -i 's/^/hsi,/g' $LOGDIR/$SEC_FILE.idx

sed -i "1i code,date,high,low,close,change,dividend,pe,index turnover,market turnover" $LOGDIR/$SEC_FILE.idx

rm $LOGDIR/$SEC_FILE.idx.tmp
rm $LOGDIR/$SEC_FILE

mv $LOGDIR/$SEC_FILE.idx $LOGDIR/splunk_data
