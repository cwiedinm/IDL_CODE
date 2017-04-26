; This program extracts the 8-day GFED data
; to a text file
; Christine, 11/11/2010

pro extract_gfedv2_8day

close, /all

;Chose extent of area to clip
latmin = -90.
latmax = 90.
lonmin = 0.
lonmax = 360.

Rearth = 6.37e6     ;m
area = 4.*!Pi* (REarth)^2
deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3   ; g per km
tg_kg = 1.e-9
mon_yr = 12.

 filename = 'F:\Data2\wildfire\GFED\V2\gfed2_mz4_97_06_8day.1x1.nc'
 ;if (file_test(filename) eq 0) then goto,skipfile
 nc_id=ncdf_open(filename)
 ncdf_varget,nc_id,'lat',lat
 ncdf_varget,nc_id,'lon',lon
 ncdf_varget,nc_id,'date',date ; YYYYMMDD
 ncdf_varget,nc_id,'CO',CO ; molecules/cm2/s [lon,lat,day]

 ndate = n_elements(date)
 nlon = n_elements(lon)
 nlat = n_elements(lat)
 dlon = (lon[1]-lon[0])/deg_rad
 dlat = (lat[1]-lat[0])/deg_rad
 dy = Rearth * dlat    ;m
 dx = Rearth * cos(lat/deg_rad) * dlon  ;m
 
 ; chose only 2006
 date06 = where(date gt 20060000)
 numdays = n_elements(date06)
 
 ; chose region
indlat = where(lat ge latmin and lat le latmax)
indlon = where(lon ge lonmin and lon le lonmax)
numlat = n_elements(indlat)
numlon = n_elements(indlon)
COnow = fltarr(numlon,numlat,numdays) ; emissions with units kg/day

openw, 1, 'F:\Data2\wildfire\GFED\V2\GFEDv2_8day_CO\CO_2006_kg_day.txt'
printf, 1, 'DATE,LAT,LON,CO'

for i = 0,numdays-1 do begin
   for j = 0,n_elements(indlat)-1 do begin
      for k = 0,n_elements(indlon)-1 do begin
            latnow = lat[indlat[i]]
            lonnow = lon[indlon[k]]
            gridarea = dx[indlat[i]]*dy*10000 ; cm2
            COnow[k,j,i] = CO[indlon[k],indlat[j],date06[i]]*gridarea*3600.*24.*28./1000./navog ; kg/day
            printf, 1, date[date06[i]],",",latnow,",",lonnow,",",COnow[k,j,i]
      endfor
     endfor 
endfor

close, /all

end ; End program