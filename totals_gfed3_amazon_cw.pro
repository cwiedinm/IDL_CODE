; Read emissions and find totals of each component
; Edited on May 11, 2011 to calculate GFEDv3 monthly emissions 
; Edited May 04, 2012 to calcualte monthly emissions for NIGERIA
;-----------------------------------------------------------------------------
; Total2D:
;    This function does the actual work for 1 2-dimensional data slice.

; from Martin's mozem_total.pro 23 Aug 2000

; data in molec/cm2/s

FUNCTION total2d, data, latw, moleweight, NoPrint=noprint

   ;; Radius of earth
   REarth = 6371.e3    ;; m

   ;; Determine if result shall be printed
   doprint = ( Keyword_Set(NoPrint) EQ 0 AND N_Elements(moleweight) GT 0 )

   ;; Default moleweight
   IF N_Elements(moleweight) EQ 0 THEN moleweight = 1.

   s = size(data, /Dimensions)
   NLON = s[0]

   ;; Compute surface area of earth in m2
   area = 4.*!Pi* (REarth)^2

   ;; Compute zonal averages in g/m2/s
   zonalco = total(data, 1)/NLON * moleweight / 6.02205e23 * 1.e4

   ;; Compute area weighted latitude totals in g/day
   totco = total(zonalco*latw,1) * area * 86400.

   ;; Scale to annual total in Tg/yr
   result = 365.*total(totco)*1.e-12

   ;; Print if so desired
   IF doprint THEN $
      print,'Annual total = ',result,' Tg/yr'

   RETURN, result

END


;-----------------------------------------------------------------------------
pro totals_gfed3_AMAZON_CW
!quiet=1
close, /all
Rearth = 6.37e6     ;m
deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3             ; g per km
tg_kg = 1.e-9
mon_yr = 12.


;AMAZON
latmin = -25.
latmax = 5.
lonmin = -80. + 360
lonmax = -40. + 360.

filename = 'E:\Data2\wildfire\GFED\GFEDv3\gfed3_0.5x0.5_CO.nc'
nc_id=ncdf_open(filename)
ncdf_varget,nc_id,'lat',lat
ncdf_varget,nc_id,'lon',lon
ncdf_varget,nc_id,'date',date
ncdf_varget,nc_id,'bb',emis  ;[g/m2/month]
ncdf_close,nc_id

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

;print,date
emistot = fltarr(ndate,10)

openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2013\DEETER\gfed3_monthly_AMAZON_CO.txt'
printf,1,'GFED-v3.1 '
printf,1,'MONTHLY Totals (Tg/month) for region '+String(latmin,latmax,lonmin,lonmax,format='(i0,"-",i0,"N, ",i0,"-",i0,"E")')
printf, 1, 'DATE, CO'
form = '(I9,",",F10.5)'

for idate = 0,ndate-1 do begin
  emis5 = Reform(emis[*,*,idate])

  indlat = where(lat ge latmin and lat le latmax)
  indlon = where(lon ge lonmin and lon le lonmax)

  totemis5 = 0.
 
  for jlat = 0,n_elements(indlat)-1 do begin
    ilat = indlat[jlat]

    emlat5 = emis5[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
    totemis5 = totemis5 + Total(emlat5[indlon],1)
 

  endfor

  emistot[idate,4] = totemis5*tg_kg ;*mon_yr  ;Tg/yr

printf, 1, format=form, date[idate],emistot[idate,4]
endfor
close, /all

;stop

end
