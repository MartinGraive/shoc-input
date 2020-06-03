#!/bin/bash

echo "Usage: ./om2mom4hf.sh file minlon maxlon minlat maxlat [outfile]"
echo ""

FILE=${6:-heatflux.nc}

$( dirname "$0" )/om2splus.sh $1 swflx $2 $3 $4 $5
$( dirname "$0" )/om2splus.sh $1 lw_heat $2 $3 $4 $5
$( dirname "$0" )/om2splus.sh $1 sens_heat $2 $3 $4 $5
$( dirname "$0" )/om2splus.sh $1 evap_heat $2 $3 $4 $5

ncrename -v swflx,swr swflx-mod.nc
ncrename -v sens_heat,sensible sens_heat-mod.nc
ncrename -v evap_heat,latent evap_heat-mod.nc

ncap2 -A -s "lwr=lw_heat*(-1)" lw_heat-mod.nc 
ncks -x -v lw_heat lw_heat-mod.nc $FILE
ncatted -O -a long_name,lwr,o,c,"upward long wave flux" $FILE
ncatted -O -a standard_name,lwr,d,, $FILE

ncks -A swflx-mod.nc $FILE
ncks -A sens_heat-mod.nc $FILE
ncks -A evap_heat-mod.nc $FILE

ncatted -O -a units,sensible,o,c,"W m-2" $FILE
ncatted -O -a units,lwr,o,c,"W m-2" $FILE
ncatted -O -a units,swr,o,c,"Wm-2" $FILE
ncatted -O -a units,latent,o,c,"kg/m2/sec" $FILE

rm swflx-mod.nc lw_heat-mod.nc sens_heat-mod.nc evap_heat-mod.nc

