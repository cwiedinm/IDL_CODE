; Read emissions and find totals of each component

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
pro totals_gfed2_ghana_CW
!quiet=1
close, /all
Rearth = 6.37e6     ;m
deg_rad = 360./(2.*!pi)
navog = 6.02205e23
g_kg = 1.e3             ; g per km
tg_kg = 1.e-9
mon_yr = 12.

; set lat,lon for region
;latmin = -85.
;latmax = -49.
;lonmin = 360.-87.26
;lonmax = 360.-32.54
;lonmin = 360.-167.
;lonmax = 300.-64.

; AUSTRALIA
;latmin = -46.
;latmax = -25.
;lonmin = 135.
;lonmax = 160.

; GLOBAL
;latmin = -90.
;latmax = 90.
;lonmin = 0.
;lonmax = 360.

; GHANA
latmin = 8.5
latmax = 12.
lonmin = -4.
lonmax = 2.


; CHINA
; AREA: 28.5 - 52N   90 - 147 E 
;latmin = 28.5
;latmax = 52.
;lonmin = 90.
;lonmax = 147.

; SEAS
; AREA: -10 to 28 5N   90 - 158 E
;latmin = -10.
;latmax = 28.5
;lonmin = 90.
;lonmax = 158.
;
; INDIA
; AREA: 5-52N  65.5 - 90 E  
;latmin = 5.
;latmax = 52.
;lonmin = 65.5
;lonmax = 90.

;SIBERIA
;AREA: 52 - 80 N  65.5 - 180. E  
;latmin = 52.
;latmax = 80.
;lonmin = 65.5
;lonmax = 180.


; CONTUS: LONG: <=-60 And >=-126 (234); LAT: >29 And <49
;filename = './nc/gfed2.1x1.nc'

;filename = 'F:\Data2\wildfire\GFED\V2\gfed2.1x1.1997_2008.nc'
filename = 'E:\Data2\wildfire\GFED\GFEDv3\gfed3_0.5x0.5_OC.nc'
nc_id=ncdf_open(filename)
ncdf_varget,nc_id,'lat',lat
ncdf_varget,nc_id,'lon',lon
ncdf_varget,nc_id,'date',date
  ncdf_varget,nc_id,'bb',emis  ;[g/m2/month]
; ncdf_varget,nc_id,'CO',emis   ;in g CO/m2/month
;ncdf_varget,nc_id,'CH4',emisch4   ; in g CH4/m2/month
;ncdf_varget,nc_id,'BC',emisbc   ; in g BC/m2/month
;ncdf_varget,nc_id,'NOx',emisnox   ; in g NOX/m2/month
;ncdf_varget,nc_id,'bb',emisnmhc  ; in g NMHC/m2/month
;ncdf_varget,nc_id,'OC',emisoc  ; in g OC/m2/month
;ncdf_varget,nc_id,'PM2p5',emispm2p5  ; in g OC/m2/month
;ncdf_varget,nc_id,'TPM',TPM  ; in g TPM/m2/month
;ncdf_varget,nc_id,'CO2',CO2  ; in g CO2/m2/month
;ncdf_varget,nc_id,'SO2',SO2  ; in g SO2/m2/month
ncdf_close,nc_id

nlon = N_elements(lon)
nlat = N_elements(lat)
dlon = (2.*!pi)/nlon
dlat = 180./(nlat-1)/deg_rad
dy = Rearth * dlat    ;m
dx = Rearth * cos(lat/deg_rad) * dlon  ;m

coslat = cos(lat*!pi/180.)
latw = coslat/total(coslat)

; CHristine Added this
;lon2 = lon
for i = 0, nlon-1 do begin
	if lon[i] gt 180 then lon[i]=lon[i]-360
endfor

;print,date
ndate = n_elements(date)
emistot = fltarr(ndate,10)

openw, 1, 'E:\Data3\AFRICA\GFED\gfed3_monthly_GHANA_OC.txt'
;printf,1, 'DATE,CO,CH4,BC,NOx,NMHC,OC,PM2p5,TPM, CO2,SO2'
printf, 1, 'DATE, OC'
form = '(I9,",",F10.5)'

for idate = 0,ndate-1 do begin

;  emis1 = Reform(emis[*,*,idate])
;  emis2 = Reform(emisch4[*,*,idate])
;  emis3 = Reform(emisbc[*,*,idate])
;  emis4 = Reform(emisnox[*,*,idate])
;  emis5 = Reform(emisnmhc[*,*,idate])
;  emis6 = Reform(emisoc[*,*,idate])
;  emis7 = Reform(emispm2p5[*,*,idate])
;  emis8 = Reform(TPM[*,*,idate])
;  emis9 = Reform(CO2[*,*,idate])
;  emis10 = Reform(SO2[*,*,idate])
  emis5 = Reform(emis[*,*,idate])

  indlat = where(lat ge latmin and lat le latmax)
  indlon = where(lon ge lonmin and lon le lonmax)

  totemis1 = 0.
  totemis2 = 0.
  totemis3 = 0.
  totemis4 = 0.
  totemis5 = 0.
  totemis6 = 0.
  totemis7 = 0.
  totemis8 = 0.
  totemis9 = 0.
  totemis10 = 0.

  for jlat = 0,n_elements(indlat)-1 do begin
    ilat = indlat[jlat]

 ;   emlat1 = emis1[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
 ;   emlat2 = emis2[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
 ;   emlat3 = emis3[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
 ;   emlat4 = emis4[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
    emlat5 = emis5[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
 ;   emlat6 = emis6[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
 ;   emlat7 = emis7[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
  ;  emlat8 = emis8[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
  ;  emlat9 = emis9[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]
  ;  emlat10 = emis10[*,ilat]*dx[ilat]*dy /g_kg        ;kg/month[lon]

 ;   totemis1 = totemis1 + Total(emlat1[indlon],1)
 ;   totemis2 = totemis2 + Total(emlat2[indlon],1)
 ;   totemis3 = totemis3 + Total(emlat3[indlon],1)
 ;   totemis4 = totemis4 + Total(emlat4[indlon],1)
    totemis5 = totemis5 + Total(emlat5[indlon],1)
 ;   totemis6 = totemis6 + Total(emlat6[indlon],1)
 ;   totemis7 = totemis7 + Total(emlat7[indlon],1)
 ;   totemis8 = totemis8 + Total(emlat8[indlon],1)
  ;  totemis9 = totemis9 + Total(emlat9[indlon],1)
  ;  totemis10 = totemis10 + Total(emlat10[indlon],1)


  endfor

;  emistot[idate,0] = totemis1*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,1] = totemis2*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,2] = totemis3*tg_kg ;*mon_yr  ;Tg/yr
 ; emistot[idate,3] = totemis4*tg_kg ;*mon_yr  ;Tg/yr
  emistot[idate,4] = totemis5*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,5] = totemis6*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,6] = totemis7*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,7] = totemis8*tg_kg ;*mon_yr  ;Tg/yr
;  emistot[idate,8] = totemis9*tg_kg ;*mon_yr  ;Tg/yr
 ; emistot[idate,9] = totemis10*tg_kg ;*mon_yr  ;Tg/yr


;  printf,1,format = form, date[idate],emistot[idate,0],emistot[idate,1],$
;    emistot[idate,2],emistot[idate,3],emistot[idate,4],emistot[idate,5],$
;	emistot[idate,6],emistot[idate,7],emistot[idate,8],emistot[idate,9]

printf, 1, format=form, date[idate],emistot[idate,4]
endfor
close, /all

;stop

end
