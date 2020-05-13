#!/bin/bash

echo "Usage: ./om2splus.sh file variable minlon maxlon minlat maxlat"
echo ""

FILE="$2-mod.nc"
UNITS=`ncdump -h $1 | grep "$2:units" | sed -E "s/.*$2\:units = \"(.+)\" ;/\1/"`
LONG=`ncdump -h $1 | grep "$2:long_name" | sed -E "s/.*$2\:long_name = \"(.+)\" ;/\1/"`
STANDARD=`ncdump -h $1 | grep "$2:standard_name" | sed -E "s/.*$2\:standard_name = \"(.+)\" ;/\1/"`

ncks -v $2 $1 $FILE
ncrename -v $2,eta_t $FILE
$( dirname "$0" )/oceanmaps2shoc $FILE $FILE $3 $4 $5 $6 coord2d
ncrename -v eta_t,$2 $FILE 
ncatted -O -a units,$2,o,c,"$UNITS" $FILE
ncatted -O -a long_name,$2,o,c,"$LONG" $FILE
if [ "$STANDARD" == "" ]
then
   ncatted -O -a standard_name,$2,d,, $FILE
else
   ncatted -O -a standard_name,$2,o,c,"$STANDARD" $FILE
fi
ncatted -O -a valid_range,$2,d,, $FILE
