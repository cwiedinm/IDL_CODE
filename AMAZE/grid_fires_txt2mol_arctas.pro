; Read Christine's NA fire emissions file (kg/day)
; grid and convert to molecules/cm2/s
; March 16, 2009: Got this file from Louisa. Running with the two files from ARCTAS/AMAZE
; March 17, 2009: Found mistake in the indices that I used to read in the emisisons file. Edited and rerun

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


pro grid_fires_txt2mol_arctas

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
txtfile1 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\FireEmis_JAN_APR2008_global.txt'
txtfile2 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\FireEmis_MAY_SEP2008_global.txt'

nfires = nlines(txtfile1)+nlines(txtfile2)-2
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
ch4 = fltarr(nfires) ; Christine added 03/17/09

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

;map_set,0,0,/continents

; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4


data1 = fltarr(nvars)
ifire=0L
while not eof(ilun) do begin
  readf,ilun,data1
  ; Christine edited the indices from the input files on 03/16/2009
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6]
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ch4[ifire] = data1[21] ; Christine added CH4 on March 17, 2009

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

data1 = fltarr(nvars)
while not eof(ilun) do begin
  readf,ilun,data1
 if (data1[3] gt jday1) then begin
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6]
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ch4[ifire] = data1[21] ; Christine added CH4 on March 17, 2009

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


; grid fires for each species
specs = ['CO','NO','CB1','OC1','SO2','NH3']
molwts = [28, 30, 12, 12, 64, 17] *1.E-3  ;kg/mole
nspec = n_elements(specs)

; ******************************************************************************
; March 17, 2009
; Christine added this section to calculate and produce a file for OC in kg/day
 fire_data = oc

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
    emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + fire_data[ifire]
   endif else print,'day: ',jday[ifire],' not included.'
  endfor

  ;convert from kg/day to molecules/cm2/s
;  for ilat=0,nlat-1 do begin
;    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
;    gridarea = dx * dy * 1.e4   ;cm^2
;    sf = avog/gridarea/mw/s_per_day
;    for ilon=0,nlon-1 do begin
;      for iday=0,ndays-1 do begin
;        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
;      endfor
;    endfor
;  endfor


 ncfile = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\NETCDF_03162009/emissions_global_JanSept2008_OCmass_1x1.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer and L.Emmons'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'kg/day'
 ncdf_attput, ncid, varid,/char, 'long_name', 'OC fire emissions'
 ;ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid

; Christine also added BC emissions here
 fire_data = bc

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
    emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + fire_data[ifire]
   endif else print,'day: ',jday[ifire],' not included.'
  endfor

  ;convert from kg/day to molecules/cm2/s
;  for ilat=0,nlat-1 do begin
;    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
;    gridarea = dx * dy * 1.e4   ;cm^2
;    sf = avog/gridarea/mw/s_per_day
;    for ilon=0,nlon-1 do begin
;      for iday=0,ndays-1 do begin
;        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
;      endfor
;    endfor
;  endfor


 ncfile = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\NETCDF_03162009/emissions_global_JanSept2008_BCmass_1x1.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer and L.Emmons'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'kg/day'
 ncdf_attput, ncid, varid,/char, 'long_name', 'BC fire emissions'
 ;ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid

; ******************************************************************************

for ispec=0,nspec-1 do begin

  spec = specs[ispec]
  mw = molwts[ispec]
  case spec of
    'CO': fire_data = co
    'NO': fire_data = nox
    'CB1': fire_data = bc
    'OC1': fire_data = oc
    'SO2': fire_data = so2
    'NH3': fire_data = nh3
  endcase

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
    emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + fire_data[ifire]
   endif else print,'day: ',jday[ifire],' not included.'
  endfor

  ;convert from kg/day to molecules/cm2/s
  for ilat=0,nlat-1 do begin
    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
    gridarea = dx * dy * 1.e4   ;cm^2
    sf = avog/gridarea/mw/s_per_day
    for ilon=0,nlon-1 do begin
      for iday=0,ndays-1 do begin
        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
      endfor
    endfor
  endfor


 ncfile = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\NETCDF_03162009/emissions_global_JanSept2008_'+spec+'_'+resol+'.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer and L.Emmons'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'molecules/cm2/s'
 ncdf_attput, ncid, varid,/char, 'long_name', spec+' fire emissions'
 ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid

endfor

;stop
;-------------------------------
; Species to calculate from CO2
;-------------------------------
specs = ['C2H6','C2H4','C3H8','C3H6', $
 'CH2O','CH3OH','BIGALK','BIGENE','CH3COCH3','C2H5OH', $
 'CH3CHO','MEK','TOLUENE']
molwts = [30, 28, 44, 42,  $
  30, 32, 72, 56, 58, 46, $
   44, 72, 92]*1.E-3  ;kg/mole
nspec = n_elements(specs)
mw_co2 = 44.e-3  ;kg/mole

; Factors from Claire [mol-species/mol-CO2]
; Tropical forests (30S-30N)
tropsf = [1.07e-03, 1.86e-03, 9.00e-05, 3.49e-04, $
   8.89e-04, 1.67e-03, 1.32e-04, 3.21e-04, 2.850e-04, 6.030e-05, $
   8.560e-04, 5.180e-04, 2.010e-04]

;Temperate forests (lat>30)
tempsf =  [5.32e-04, 1.07e-03, 1.15e-04, 3.74e-04, $
   1.40e-03, 1.67e-03, 1.74e-04, 2.94e-04, 2.520e-04, 6.600e-05, $
   9.760e-04, 5.500e-04, 3.680e-04]

; Savanna/grass burning
savsf =   [2.84e-04, 7.54e-04, 5.45e-05, 1.66e-04, $
   2.23e-04, 1.08e-03, 8.28e-05, 1.75e-05, 2.030e-04, 4.590e-05, $
   5.560e-04, 3.210e-04, 1.280e-04]

for ispec = 0,nspec-1 do begin

  spec = specs[ispec]
  mw = molwts[ispec]
  print,spec,mw*1000.,tropsf[ispec],tempsf[ispec],savsf[ispec]

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

    dx = Rearth * cos(lat_grid[ilat]/deg_rad) * dlon/deg_rad  ;m
    gridarea = dx * dy * 1.e4   ;cm^2
    sf = avog/gridarea/mw/s_per_day

    ; Tropical Forests (genveg = 3):
    if (genveg[ifire] eq 3) then begin
      emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + co2[ifire]*tropsf[ispec]*sf
    endif else $

    ; TEMPERATE Forests (genveg = 4) (also including boreal forests = 5):
    if (genveg[ifire] eq 4) or (genveg[ifire] eq 5) then begin
      emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + co2[ifire]*tempsf[ispec]*sf
    endif else $

    ; Savannah/Grasslands (1):
    ; ** Including wooded savannas (2) and crops (9))
    if (genveg[ifire] eq 1) or (genveg[ifire] eq 2) or (genveg[ifire] eq 9) then begin
      emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday] + co2[ifire]*savsf[ispec]*sf
    endif else print,'Veg Type: ',genveg[ifire],' not included.'

   endif else print,'day: ',jday[ifire],' not included.'

  endfor

 ncfile = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_03132009\NETCDF_03162009/emissions_global_JanSept2008_'+spec+'_'+resol+'.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions'
 ncdf_attput,ncid,/GLOBAL,'authors','Christine Wiedinmyer and L.Emmons'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'molecules/cm2/s'
 ncdf_attput, ncid, varid,/char, 'long_name', spec+' fire emissions'
 ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid

endfor

end
