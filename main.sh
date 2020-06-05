#!/bin/bash

# Creates a .mnc file for variable $1 containing all files matching regex $2 (or a regex generated from $1)
writemnc() {
   local reg=${2:-"_${1}_.*-mod\.nc$"}
   local c=0
   for f in *; do 
      if [[ $f =~ $reg ]]; then 
         local c=$((c+1)); fi; done
   printf "multi-netcdf-version 1.0\nnfiles %d\n" $c > ${1}.mnc 
   local c=0
   for f in *; do 
      if [[ $f =~ $reg ]]; then 
         printf "file%d.filename %s\n" $((c++)) `readlink -f $f` >> ${1}.mnc; fi; done
}

# Unused. Creates a new netcdf file that concatenates matched files along the time dimension
concat() {
   local reg=${2:-"_${1}_.*-mod\.nc$"}
   ncrcat `ls | grep $reg` ${1}.nc
}

# Changes grid for supported variables
for f in *; do 
   if [[ $f =~ _(eta|temp|salt|u|v)_.*\.nc$ ]]; then
      echo $f
      $(dirname "$0")/oceanmaps2shoc $f `sed "s/\.nc/-mod\.nc/g" <<< "$f"` 140 159.8 -30 -5.2 coord2d; fi; done

# Merges u and v
for f in *; do
   if [[ $f =~ _u_.*-mod\.nc$ ]]; then
      ncks -A $f `sed "s/_u_/_v_/g" <<< "$f"`
      mv `sed "s/_u_/_v_/g" <<< "$f"` `sed "s/_u_/_uv_/g" <<< "$f"`; fi; done  

# Creates multi-netcdf files
for v in temp salt eta_t uv; do writemnc $v; done

# Changes grid for heatfluxes and wind stresses variables
for f in *; do
   if [[ $f =~ _force_.*\.nc$ ]]; then
      echo $f
      for v in tau_x tau_y sfc_hflux swflx; do
         $(dirname "$0")/om2splus.sh $f $v 140 159.8 -30 -5.2 `sed "s/\.nc/-mod\.nc/g" <<< "$f" | sed "s/force/$v/g"`; done; fi; done

# Merges i- and j-directed wind stresses, creates variable heatflux=lwr+sensible+latent
for f in *; do
   if [[ $f =~ _tau_x_.*-mod\.nc$ ]]; then
      ncks -A $f `sed "s/_tau_x_/_tau_y_/g" <<< "$f"`
      mv `sed "s/_tau_x_/_tau_y_/g" <<< "$f"` `sed "s/_tau_x_/_wind_/g" <<< "$f"`; fi
   if [[ $f =~ _sfc_hflux_.*-mod\.nc$ ]]; then
      ncatted -O -a units,swflx,o,c,"W m-2" `sed "s/_sfc_hflux_/_swflx_/g" <<< "$f"`
      ncks -A `sed "s/_sfc_hflux_/_swflx_/g" <<< "$f"` $f
      ncap2 -s 'heatflux=sfc_hflux-swflx' $f `sed "s/_sfc_hflux_/_heatflux_/g" <<< "$f"`
      ncks -O -x -v sfc_hflux,swflx `sed "s/_sfc_hflux_/_heatflux_/g" <<< "$f"` `sed "s/_sfc_hflux_/_heatflux_/g" <<< "$f"`; fi; done

# Creates multi-netcdf files
for v in wind heatflux swflx; do writemnc $v; done
