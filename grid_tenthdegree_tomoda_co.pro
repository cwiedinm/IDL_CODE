; This program takes the FINNv1 MOZ4 speciated files
; and puts them on a 0.5 x 0.5 grid
; and converts the species to kg/m2/day
; for AUDE and the GEIA site
; Outputs NetCDF files for each year
; JANUARY 12, 2012

; Edited on FEBRUARY 28, 2013 for JESSICA
; 
;FEBRUARY 09, 2015
;- Renamed grid_halfdegree_JF_CO.pro to grid_halfdegree_Sourish_CO
;
;
;APRIL 21, 2015
;- Ranamed file for Tom ODa
;
;-------------------------------
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

pro grid_tenthdegree_TOMODA_CO

close, /all

today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

; set up grid
resol='0.1x0.1'
dlat = 0.1
dlon = 0.1
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

Rearth = 6.37e6   ;m
deg_rad = 360./(2*!pi)
rad_deg = 2.*!pi/360.
avog = 6.022e23   ;molecules/mole
s_per_day = 86400.
dy = Rearth * dlat /deg_rad   ;m

; OPen Species file
specfile = 'E:\Data2\wildfire\SPECIATION\MOZ4\mz4_species_molwts2.csv'
intemp=ascii_template(specfile)
moz4species=read_ascii(specfile, template=intemp)
specs = moz4species.field1
molwts = moz4species.field2

nspec = n_elements(specs)



; OPEN THE MOZ4 EMISSION FILE(S) for the given year
year0 = 2011
yearfile = '2011'
n_files = 1
;txtfile1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2013_MOZ4_7112014.txt'

txtfile1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2011_06272014.txt'

; 1    2   3     4     5     6   7   8  9  10 11  12  13  14  15   16     17     18     19     20   21     22   23   24   25   26      27       28      29      30
;DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,
;31      32     33   34   35  36   37 38  39    40       41  42  43 44  45    46
;CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'



nfires = nlines(txtfile1)-n_files
index2 = intarr(nfires)
lonin = fltarr(nfires)
latin = fltarr(nfires)
jday = fltarr(nfires)
timein = fltarr(nfires)
genveg = intarr(nfires)
co2 = fltarr(nfires)
co = fltarr(nfires)
no = fltarr(nfires)
no2 = fltarr(nfires)
nh3 = fltarr(nfires)
so2 = fltarr(nfires)
ch4 = fltarr(nfires)
nmoc = fltarr(nfires)
bigald  = fltarr(nfires)
bigalk = fltarr(nfires)
bigene = fltarr(nfires)
c10h16 = fltarr(nfires)
c2h4 = fltarr(nfires)
C2H5OH = fltarr(nfires)
C2H6 = fltarr(nfires)
C3H6 = fltarr(nfires)
C3H8 = fltarr(nfires)
CH2O = fltarr(nfires)
CH3CHO = fltarr(nfires)
CH3COCH3 = fltarr(nfires)
CH3COCHO = fltarr(nfires)
CH3COOH = fltarr(nfires)
CH3OH = fltarr(nfires)
CRESOL = fltarr(nfires)
GLYALD = fltarr(nfires)
HYAC = fltarr(nfires)
ISOP = fltarr(nfires)
MACR = fltarr(nfires)
MEK = fltarr(nfires)
MVK = fltarr(nfires)
HCN = fltarr(nfires)
CH3CN = fltarr(nfires)
TOLUENE = fltarr(nfires)
PM25 = fltarr(nfires)
OC = fltarr(nfires)
BC = fltarr(nfires)
PM10 = fltarr(nfires)
HCOOH = fltarr(nfires)
C2H2 = fltarr(nfires)
bmass = fltarr(nfires)
area = fltarr(nfires) 

print,txtfile1
openr,ilun,txtfile1,/get_lun
sdum=' '
readf,ilun,sdum
vars = strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  print,'Lon: ',vars[4]
  print,'Lat: ',vars[3]
  print,'Day: ',vars[0]
  print,'Time: ',vars[1] ; Christine addeded 03/16/2009
  print,'GenVeg: ',vars[2] ; Christine addeded 03/16/2009

data1 = fltarr(nvars)
ifire=0L
while not eof(ilun) do begin
  readf,ilun,data1
;       0: longi
;       1: lat
;       2: day
;       3: TIME
;       4: lct
;       5: genLC
;       6: globreg
;       7: pcttree
;       8: pctherb
;       9: pctbare
;      10: area
;      11: bmass
;      12: CO2
;      13: CO
;      14: CH4
;      15: H2
;      16: NOx
;      17: NO
;      18: NO2
;      19: NH3
;      20: SO2
;      21: NMHC
;      22: NMOC
;      23: PM25
;      24: TPM
;      25: OC
;      26: BC
;      27: TPC
;      28: PM10
;      29: FACTOR
;  index2[ifire] = data1[0]
  lonin[ifire] = data1[0]
  latin[ifire] = data1[1]
  jday[ifire] = data1[2]
  genveg[ifire] = data1[5] 
  area[ifire] = data1[10] 
  co[ifire] = data1[13]
  PM25[ifire] = data1[23]
  ifire = ifire+1
endwhile
free_lun,ilun
jday1 = max(jday)
print,min(jday),jday1,ifire

print,'Nfires = ',nfires,' iFire = ',ifire
nfires=ifire
jday = jday[0:nfires-1]

ndays = Max(jday)-Min(jday)+1
print,'minday,maxday,numdays: ',Min(jday),Max(jday),ndays
day0 = Min(jday)

; Convert from JDs
date = lonarr(ndays)
time = fltarr(ndays)

for i = 0,ndays-1 do begin
  iday = i + day0-1
  time[i] = Julday(1,1,year0) - Julday(1,1,1990) + iday
  caldat,(Julday(1,1,year0)+iday),mon,day,year
  date[i] = year*10000L + mon*100L + day
endfor
print,'Dates: ',date[0],date[ndays-1]

; Totals in Tg/yr
print, 'totals in Tg/year'
;print,'CO2:',Total(co2)/ndays *365. *1.e-9, Total(co2)/ndays *365. *1.e-9*12./44.
print,'CO:',Total(co)/ndays *365. *1.e-9, Total(co)/ndays *365. *1.e-9*12./28.
print,'PM2.5:',Total(pm25)/ndays *365. *1.e-9, Total(no)/ndays *365. *1.e-9*14./30.
;print,'BC',Total(bc)/ndays *365. *1.e-9
;print,'OC',Total(oc)/ndays *365. *1.e-9
;print,'SO2',Total(so2)/ndays *365. *1.e-9, Total(so2)/ndays *365. *1.e-9*32./64.
;print,'NH3',Total(nh3)/ndays *365. *1.e-9, Total(nh3)/ndays *365. *1.e-9*14./17.
;print,'NMOC',Total(nmoc)/ndays *365. *1.e-9, Total(nmoc)/ndays *365. *1.e-9*14./17.
;print,'BIOMASS', Total(bmass), ' kg/m2 for only days of file'
print,'AREA BURNED' , Total(Area), ' m2 total for only days of file'
;bb = fltarr(nfires)
;for i = 0L,nfires-1 do begin
; bb[i] = bmass[i]*area[i]
;endfor
;print, 'biomass burned',  total(bb)



;for ispec=0,nspec-1 do begin
for ispec=0,1 do begin ; ONLY DO CO (JULY 10, 2014)
  spec = specs[ispec]
  mw = molwts[ispec]


  case spec of
 ;   'CO2': fire_data = co2
    'CO': fire_data = co
 ;   'NO': fire_data = no
     'PM25': fire_data = pm25
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
   endif else printf, 9,'day: ',jday[ifire],' not included. No emissions on this day'
  endfor

  ;convert from mole/day to kg/m2/day
;  for ilat=0,nlat-1 do begin
;    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
;    gridarea = dx * dy    ;m^2
;    sf = mw/1000./gridarea ; to convert mole/day --> kg/day/m2
;  for ilon=0,nlon-1 do begin
;      for iday=0,ndays-1 do begin
;        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
;      endfor
;    endfor
;  endfor


 ncfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\APR_2015\Tom_ODA\FINNv15_global_'+yearfile+'_'+spec+'_'+resol+'.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions, FINNv1.5'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from FINNv1.5 files'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'kg'
 ncdf_attput, ncid, varid,/char, 'long_name', spec+' fire emissions'
 ncdf_attput, ncid, varid,/short, 'mw', mw

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',lon_grid
 ncdf_varput,ncid,'lat',lat_grid
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'date',date
 ncdf_varput,ncid,'fire',emis_grid
 ncdf_close,ncid

endfor


; ******************************************************************************
close, /all
print, 'PROGRAM OVER'
end

