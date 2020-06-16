#!/bin/bash

if [ "$#" -lt 6 ] || [ "$#" -gt 7 ]; then
   echo "Usage: ./om2splus.sh file variable minlon maxlon minlat maxlat [outfile]"
   exit
fi

file=${7:-$2-mod.nc}
units=`ncdump -h $1 | grep "$2:units" | sed -E "s/.*$2\:units = \"(.+)\" ;/\1/"`
long=`ncdump -h $1 | grep "$2:long_name" | sed -E "s/.*$2\:long_name = \"(.+)\" ;/\1/"`
standard=`ncdump -h $1 | grep "$2:standard_name" | sed -E "s/.*$2\:standard_name = \"(.+)\" ;/\1/"`

ncks -v $2 $1 $file
ncrename -v $2,eta_t $file
$(dirname "$0")/oceanmaps2shoc $file $2-mod-tmp.nc $3 $4 $5 $6 coord2d
mv $2-mod-tmp.nc $file
ncrename -v eta_t,$2 $file 
ncatted -O -a units,$2,o,c,"$units" $file
ncatted -O -a long_name,$2,o,c,"$long" $file
if [ "$standard" == "" ]; then
   ncatted -O -a standard_name,$2,d,, $file
else ncatted -O -a standard_name,$2,o,c,"$standard" $file
fi
ncatted -O -a valid_range,$2,d,, $file
