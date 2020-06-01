# Parameter file for SHOC forecasting

When working with OFAM model outputs, use the `oceanmaps2shoc` tool to convert them. 

Split the OFAM files to work with only a variable at a time (`ncks -v variable ofam-file.nc var-ofam.nc`); you can combine them again with `ncks -A`. Use `ncdump -v xt_ocean var-ofam.nc` (resp. `yt_ocean`, sometimes `xu_ocean` and `yu_ocean`) to find extreme values of longitude and latitude. The chosen values must be inside the extent of the file, but not too close to the limits. Then use `oceanmaps2shoc var-ofam.nc var-shoc.nc minlon maxlon minlat maxlat coord2d`. 

If the variable is a "2D unsupported variable", you can use the script `om2splus.sh` (placed in the same folder as `oceanmaps2shoc`) that will bypass that error at the cost of some attributes being lost.

Use the script `om2mom4hf.sh` (placed in the same folder as `om2splus.sh`) to create an `heatflux.nc` file assembled in the MOM4 manner. To be used with HEATFLUX method COMP_HEAT_MOM.

The Python script `extract-river.py` creates flow and temperature future time series for rivers based on 2016 data at the same season. Syntax is the following: `python extract-river.py START_TIME STOP_TIME path/to/timeseries [path/to/output] [-u "OUTPUT_TIMEUNIT"] [--verbose]`. Install necessary packages with `pip install cftime`.
