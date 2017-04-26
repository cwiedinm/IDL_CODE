; Read Christine's NA fire emissions file (kg/day)
; grid and convert to molecules/cm2/s
; March 16, 2009: Got this file from Louisa. Running with the two files from ARCTAS/AMAZE
; March 17, 2009: Edited this version to output OC and BC in kg/day
; April 09, 2009: corrected CO2 conversion
; April 17, 2009: Edited this code to only output 1 NetCDF file with the biomass burned
; April 20, 2009: Edited to adjust for area burned and area of grid cell
;-------------------------------
;+
function nlines,file,help=help
;       =====>> LOOP THROUGH FILE COUNTING LINES
;
tmp = ' '
nl = 0L
on_ioerror,NOASCII
if n_elements(file) eq 0 then file = pickfile()
openr,lun,file,/get_lun
while not eof(lun) do begin
  readf,lun,tmp
  nl = nl + 1L
  endwhile
close,lun
free_lun,lun
NOASCII:
return,nl
end
;-------------------------------


pro grid_fires_txt2mol_arctas_biomass
close, /all
today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

year0 = 2008
; set up grid
;resol='0.5x0.5'
;dlat = 0.5
;dlon = 0.5
;latmin = -90.
;latmax = 90.
;lonmin = 0.
;lonmax = 360.
resol='1x1'
dlat = 1
dlon = 1
latmin = -90.
latmax = 90.
lonmin = 0.
lonmax = 360.

nlat = (latmax-latmin)/dlat
nlon = (lonmax-lonmin)/dlon

lon_grid = findgen(nlon)*dlon+lonmin+0.5*dlon
lat_grid = findgen(nlat)*dlat+latmin+0.5*dlat
print,lon_grid[0],lon_grid[nlon-1]
print,lat_grid[0],lat_grid[nlat-1]

Rearth = 6.37e6         ;m
deg_rad = 360./(2*!pi)
rad_deg = 2.*!pi/360.
avog = 6.022e23         ;molecules/mole
s_per_day = 86400.
dy = Rearth * dlat /deg_rad   ;m

; read Christine's files
txtfile1 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\FireEmis_JAN_APR2008_global_04082009_newcode2.txt'
txtfile2 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\FireEmis_MAY_SEPT_2008_global_04082009_newcode2.txt'
log = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\Netcdf\log.txt'
openw, 9, log


nfires = nlines(txtfile1)+nlines(txtfile2)-2
index2 = intarr(nfires)
lonin = fltarr(nfires)
latin = fltarr(nfires)
jday = fltarr(nfires)
timein = fltarr(nfires) ; christine added 03/16/2009
genveg = intarr(nfires)
co2 = fltarr(nfires)
co = fltarr(nfires)
nox = fltarr(nfires)
nh3 = fltarr(nfires)
so2 = fltarr(nfires)
bc = fltarr(nfires)
oc = fltarr(nfires)
bmass = fltarr(nfires)
area = fltarr(nfires) ; added april 20, 2009

print,txtfile1
openr,ilun,txtfile1,/get_lun
sdum=' '
readf,ilun,sdum
vars = strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]

print,'Lon: ',vars[1]
print,'Lat: ',vars[2]
print,'Day: ',vars[3]
print,'Time: ',vars[4] ; Christine addeded 03/16/2009

;map_set,0,0,/continents

; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4

data1 = fltarr(nvars)
ifire=0L
while not eof(ilun) do begin
  readf,ilun,data1
  ; Christine edited the indices from the input files on 03/16/2009
  index2[ifire] = data1[0]
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6] ; This was an incorrect index. Fixed on 04/09/09
  area[ifire] = data1[11] ; Added area on April 20, 2009
  bmass[ifire] = data1[12] ; Added biomass on April 17, 2009
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ;plots,lonin[ifire],latin[ifire],psym=3
  ifire = ifire+1
endwhile
free_lun,ilun
jday1 = max(jday)
print,min(jday),jday1,ifire

print,txtfile2
openr,ilun,txtfile2,/get_lun
sdum=' '
readf,ilun,sdum
vars = strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
print,'Lon: ',vars[1]
print,'Lat: ',vars[2]
print,'Day: ',vars[3]
print,'Time: ',vars[4] ; Christine addeded 03/16/2009

; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4

data1 = fltarr(nvars)
while not eof(ilun) do begin
  readf,ilun,data1
 if (data1[3] gt jday1) then begin
  index2[ifire] = data1[0]
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6] ; Edited these indices on 04/10/09
  bmass[ifire] = data1[12]
  area[ifire] = data1[11] ; Added area on April 20, 2009
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ifire = ifire+1
 endif
endwhile
free_lun,ilun

print,nfires,ifire
nfires=ifire
jday = jday[0:nfires-1]

ndays = Max(jday)-Min(jday)+1
print,Min(jday),Max(jday),ndays
day0 = Min(jday)

date = lonarr(ndays)
time = fltarr(ndays)
for i = 0,ndays-1 do begin
  iday = i + day0-1
  time[i] = Julday(1,1,year0) - Julday(1,1,1990) + iday
  caldat,(Julday(1,1,year0)+iday),mon,day,year
  date[i] = year*10000L + mon*100L + day
endfor
print,date[0],date[ndays-1]


; Totals in Tg/yr
print,'CO2:',Total(co2)/ndays *365. *1.e-9, Total(co2)/ndays *365. *1.e-9*12./44.
print,'CO:',Total(co)/ndays *365. *1.e-9, Total(co)/ndays *365. *1.e-9*12./28.
print,'NOx:',Total(nox)/ndays *365. *1.e-9, Total(nox)/ndays *365. *1.e-9*14./30.
print,'BC',Total(bc)/ndays *365. *1.e-9
print,'OC',Total(oc)/ndays *365. *1.e-9
print,'SO2',Total(so2)/ndays *365. *1.e-9, Total(so2)/ndays *365. *1.e-9*32./64.
print,'NH3',Total(nh3)/ndays *365. *1.e-9, Total(nh3)/ndays *365. *1.e-9*14./17.
print,'BIOMASS', Total(bmass), ' kg/m2 for only days of file'
print,'AREA BURNED' , Total(Area), ' m2 total for only days of file'

bb = fltarr(nfires)
for i = 0L,nfires-1 do begin
	bb[i] = bmass[i]*area[i]
endfor
print, 'biomass burned',  total(bb)

;******************************************************************************
; CREATE NETCDF FILE HERE
; NETCDF FILE ONLY TO HAVE BIOMASS BURNED IN IT
; April 17, 2009
; Christine edited this to produce biomass burned kg
   fire_data = bb ; kg biomass burned

  ;grid emissions
  emis_grid = fltarr(nlon,nlat,ndays)
  for ifire = 0L,nfires-1 do begin
   iday = jday[ifire]-day0
   if (iday ge 0) then begin
    lon1 = lonin[ifire]
    lat1 = latin[ifire]
    if (lon1 lt 0.5*dlon) then lon1 = lon1+360.
    ilat = Round((lat1-(latmin+0.5*dlat))/dlat)
    ilon = Round((lon1-(lonmin+0.5*dlon))/dlon)
    if (ilon eq nlon) then ilon=0
    	; emis_grid here is kg/m2 * m2 = kg biomass burned
    emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + fire_data[ifire]
   endif else printf,9,'day: ',jday[ifire],' not included. NO fires on this day (Bmass file)'
  endfor

;; convert from kg/day to kg/m2/day (divide by area of grid)
;  for ilat=0,nlat-1 do begin
;    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
;    gridarea = dx * dy ; m2 * 1.e4   ;cm^2
;    sf = 1/gridarea
;    for ilon=0,nlon-1 do begin
;      for iday=0,ndays-1 do begin
;        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
;      endfor
;    endfor
;  endfor

 ncfile = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\Netcdf\emissions_global_JanSept2008_BiomassBurned_1x1_dbl.nc'
 print,ncfile

 ncid = ncdf_create(ncfile,/clobber)
 ; Define dimensions
 xid = ncdf_dimdef(ncid,'lon',nlon)
 yid = ncdf_dimdef(ncid,'lat',nlat)
 tid = ncdf_dimdef(ncid,'time',ndays)

 ; Define dimension variables with attributes
 xvarid = ncdf_vardef(ncid,'lon',[xid],/float)
 ncdf_attput, ncid, xvarid,/char, 'units', 'degrees_east'
 ncdf_attput, ncid, xvarid,/char, 'long_name', 'Longitude'
 yvarid = ncdf_vardef(ncid,'lat',[yid],/float)
 ncdf_attput, ncid, yvarid,/char, 'units', 'degrees_north'
 ncdf_attput, ncid, yvarid,/char, 'long_name', 'Latitude'
 tvarid = ncdf_vardef(ncid,'time',[tid],/float)
 ncdf_attput, ncid, tvarid,/char, 'long_name', 'Time'
 ncdf_attput, ncid, tvarid,/char, 'units', 'days since 1990-01-01 00:00:00'
 ncdf_attput, ncid, tvarid,/char, 'calendar', 'Gregorian'
 tvarid = ncdf_vardef(ncid,'date',[tid],/long)
 ncdf_attput, ncid, tvarid,/char, 'units', 'YYYYMMDD'
 ncdf_attput, ncid, tvarid,/char, 'long_name', 'Date'
 ;Define global attributes
 ncdf_attput,ncid,/GLOBAL,'title','Daily Biomass Burned'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer and L.Emmons'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'kg/day' ; edited on April 20, 2009

 ncdf_attput, ncid, varid,/char, 'long_name', 'Biomass Burned'
 ;ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid


; ******************************************************************************

print, 'PROGRAM OVER'
end
