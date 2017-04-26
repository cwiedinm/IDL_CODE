
; This is a file from Louisa, August 2010
; To create regional totals from GFEDv3
; 
; May 01, 2013: Edited to print out Amazon region for 1 year (monthly) for a grid

pro totals__month_Grid_gfed3_region
close, /all

;Totals of emissions for region:
latmin = -30.
latmax = 10.
lonmin = 260.
lonmax = 340.

Rearth = 6.37e6     ;m
area = 4.*!Pi* (REarth)^2

deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3             ; g per km
tg_kg = 1.e-9
mon_yr = 12.


openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2013\DEETER\GFEDv3_monthly_Totals_Amazon_Deeter_GRID.txt'
printf,1,'GFED-v3.1 '
printf,1,'Monthly totals (Gg/yr) for region '+String(latmin,latmax,lonmin,lonmax,format='(i0,"-",i0,"N, ",i0,"-",i0,"E")')
printf,1,'DATE,LAT,LONG,EMIS kg/month'

;for ispec = 0,nspec-1 do begin

 spec = 'CO'
 filename = 'E:\Data2\wildfire\GFED\GFEDv3\gfed3_0.5x0.5_'+spec+'.nc'
 if (file_test(filename) eq 0) then goto,skipfile
 nc_id=ncdf_open(filename)
 ncdf_varget,nc_id,'lat',lat
 ncdf_varget,nc_id,'lon',lon
 ncdf_varget,nc_id,'date',date

 ndate = n_elements(date)
 nyrs = ndate/12
 nlon = n_elements(lon)
 nlat = n_elements(lat)
 dlon = (lon[1]-lon[0])/deg_rad
 dlat = (lat[1]-lat[0])/deg_rad
 dy = Rearth * dlat    ;m
 dx = Rearth * cos(lat/deg_rad) * dlon  ;m
 coslat = cos(lat*!pi/180.)
 latw = coslat/total(coslat)

 ncdf_varget,nc_id,'bb',emis  ;[g/m2/month]
lon2 = lon
; indices of region
  form = '(I9,3(",",D25.10))'
 for k = 0,ndate-2 do begin
  for i=0,nlon-1 do begin
    for j = 0,nlat-1 do begin
        if(lat[j] lt latmin or lat[j] gt latmax or lon[i] lt lonmin or lon[i] gt lonmax or date[k] lt 20080000 or date[k] gt 20085050) then goto, skipfire
        ;indlon = where(lon ge lonmin and lon le lonmax)
        ;ilat = indlat[jlat]
        if lon2[i] gt 180 then lon2[i] = lon2[i]-360.
        emisconv = emis[i,j,k]*dx[j]*dy /g_kg    ;kg/mon
        
        printf, 1, format = form, date[k],lat[j],lon2[i], emisconv
        skipfire: 
      endfor
    endfor
  endfor
  ncdf_close,nc_id

  skipfile:
close, /all
end
