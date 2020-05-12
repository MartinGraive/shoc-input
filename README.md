# Parameter file for SHOC forecasting

When working with OFAM model outputs, use the `oceanmaps2shoc` tool to convert them. 

Split the OFAM files to work with only a variable at a time (`ncks -v variable ofam-file.nc var-ofam.nc`). Use `ncdump -v xt_ocean var-ofam.nc` (resp. `yt_ocean`, sometimes `xu_ocean` and `yu_ocean`) to find extreme values of longitude and latitude. The chosen values must be inside the extent of the file, but not too close to the limits. Then use `oceanmaps2shoc var-ofam.nc var-shoc.nc minlon maxlon minlat maxlat coord2d`. If necessary, use `ncrename` to change the name of a variable to a "supported" name. To combine modified variables in a single file, use `ncks -A`.
