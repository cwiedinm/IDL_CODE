
; This is a file from Louisa, August 2010
; To create regional, monthly totals from GFEDv3
; Edited on May 2011 for Ghana
; 
; May 2012 for Nigeria --> NOTE: THIS STILL DOES ANNUAL TOTALS
;   For monthly totals-  
;   E:\Data3\AFRICA\GFED\totals_gfed3_ghana_cw.pro
; 
; April 23, 2013
; - Edited to clip out the Amazon for Deeter's proposal
; - and print out the values of Tg/grid/mont for proposal


pro totals_gfed3_orig_SA_deeter2

close, /all

;Totals of emissions for region :
latmin = -25.
latmax = 5.
lonmin = 280.
lonmax = 320.

Rearth = 6.37e6     ;m
area = 4.*!Pi* (REarth)^2

deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3             ; g per km
tg_kg = 1.e-9
mon_yr = 12.

years = indgen(13)+1997
months = indgen(12)+1
  
openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2013\DEETER\GFEDv3_grid_Amazon_092008_Deeter2.txt'
printf,1,'GFED-v3.1 '
printf,1,'Monthly Total grid (kg/month) for 2008 Sept for region '+String(latmin,latmax,lonmin,lonmax,format='(i0,"-",i0,"N, ",i0,"-",i0,"E")')
printf,1, 'Lat, LON, CO'

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

ncdf_varget,nc_id,'bb',bb  ;[g/m2/month]

  spectot = fltarr(nyrs,12)
     ; Get year/month
     yrmo = 20080915
     inddate = where(date eq yrmo)
     ; indices of region
     indlat = where(lat ge latmin and lat le latmax)
     indlon = where(lon ge lonmin and lon le lonmax)
     for ilon = 0,n_elements(indlon)-1 do begin
      for jlat = 0,n_elements(indlat)-1 do begin
        ilat = indlat[jlat]
        emlat = bb[lon[indlon[ilon]],lat[indlat[jlat]],inddate]*dx[ilat]*dy /g_kg    ;kg/mon
        printf, 1, lat[indlat[jlat]],",", lon[indlon[ilon]],",", emlat
      endfor 
     endfor

  ncdf_close,nc_id

  skipfile:
close, /all
end
