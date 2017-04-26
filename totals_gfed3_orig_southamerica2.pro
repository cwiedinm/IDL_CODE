
; This is a file from Louisa, August 2010
; To create regional, monthly totals from GFEDv3
; Edited on May 2011 for Ghana


pro totals_gfed3_orig_SouthAmerica2
close, /all
;Totals of emissions for region:
; 
latmin = -25.
latmax = 5.
lonmin = 280.
lonmax = 320


Rearth = 6.37e6     ;m
area = 4.*!Pi* (REarth)^2

deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3             ; g per km
tg_kg = 1.e-9
mon_yr = 12.

species = ['CO2','CH4','CO','NO','NMHC','SO2','BC','OC']
nspec=n_elements(species)
years = indgen(13)+1997
months = indgen(12)+1

openw, 1, 'E:\Data3\proposals\2013\Deeter_NASA\GFEDv3_monthly_Totals_AMAZONIA.txt'
;openw,1,'totals_gfed3_mon.txt'
printf,1,'GFED-v3.1 '
printf,1,'Annual Totals (Tg/yr) for region '+String(latmin,latmax,lonmin,lonmax,format='(i0,"-",i0,"N, ",i0,"-",i0,"E")')
printf,1,format='(a15,12(",",a10))','Species, Year',String(months)

for ispec = 0,nspec-1 do begin

 spec = species[ispec]

 filename = 'E:\Data2\wildfire\GFED\GFEDv3\gfed3_0.5x0.5_'+spec+'.nc'
 ;filename = '/Volumes/data/emissions/gfed3/gfed3_0.5x0.5_'+spec+'.nc'
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

  spectot = fltarr(nyrs,12)
  for iyr=0,nyrs-1 do begin
   for imon = 0,11 do begin
     itim = iyr*12+imon
     emis1 = emis[*,*,itim]
     ; indices of region
     indlat = where(lat ge latmin and lat le latmax)
     indlon = where(lon ge lonmin and lon le lonmax)
     totemis = 0.
     for jlat = 0,n_elements(indlat)-1 do begin
       ilat = indlat[jlat]
       emlat = emis1[*,ilat]*dx[ilat]*dy /g_kg    ;kg/mon
       totemis = totemis + Total(emlat[indlon],1)
     endfor 
     spectot[iyr,imon] = totemis *1.e-9 *12.  ;Tg/yr
   endfor
   printf,1,format='(a15,",",i6,12(",",f10.2))',spec,years[iyr],spectot[iyr,*]
  endfor
  ncdf_close,nc_id

  skipfile:
endfor
close, /all
end
