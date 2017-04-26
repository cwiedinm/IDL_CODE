; This program takes the FINNv1 MOZ4 speciated files
; and puts them on a 0.5 x 0.5 grid
; and converts the species to kg/m2/day
; for AUDE and the GEIA site
; Outputs NetCDF files for each year
; JANUARY 12, 2012

; Edited on FEBRUARY 28, 2013 for JESSICA
; 
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

pro grid_halfdegree_JESSICA_AG
close, /all

today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

; set up grid
resol='0.5x0.5'
dlat = 0.5
dlon = 0.5
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
specfile = 'E:\Data2\wildfire\SPECIATION\MOZ4\mz4_species_molwts.csv'
intemp=ascii_template(specfile)
moz4species=read_ascii(specfile, template=intemp)
specs = moz4species.field1
molwts = moz4species.field2

nspec = n_elements(specs)


; OPEN THE MOZ4 EMISSION FILE(S) for the given year
year0 = 2012
n_files = 1
txtfile1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\SPECIATE\MOZ4\GLOB_2003_05152011_MOZ4.txt'

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
;       0: DAY
;       1: TIME
;       2: GENVEG
;       3: LATI
;       4: LONGI
;       5: AREA
;       6: CO2
;       7: CO
;       8: H2
;       9: NO
;      10: NO2
;      11: SO2
;      12: NH3
;      13: CH4
;      14: NMOC
;      15: BIGALD
;      16: BIGALK
;      17: BIGENE
;      18: C10H16
;      19: C2H4
;      20: C2H5OH
;      21: C2H6
;      22: C3H6
;      23: C3H8
;      24: CH2O
;      25: CH3CHO
;      26: CH3COCH3
;      27: CH3COCHO
;      28: CH3COOH
;      29: CH3OH
;      30: CRESOL
;      31: GLYALD
;      32: HYAC
;      33: ISOP
;      34: MACR
;      35: MEK
;      36: MVK
;      37: HCN
;      38: CH3CN
;      39: TOLUENE
;      40: PM25
;      41: OC
;      42: BC
;      43: PM10
;      44: HCOOH
;      45: C2H2
  index2[ifire] = data1[0]
  lonin[ifire] = data1[4]
  latin[ifire] = data1[3]
  jday[ifire] = data1[0]
  timein[ifire] = data1[1] 
  genveg[ifire] = data1[2] 
  area[ifire] = data1[5] 
  co2[ifire] = data1[6]
  co[ifire] = data1[7]
  oc[ifire] = data1[41]
  bc[ifire] = data1[42]
  no[ifire] = data1[9]
  no2[ifire] = data1[10]
  nh3[ifire] = data1[12]
  so2[ifire] = data1[11]
  ch4[ifire] = data1[13]
  nmoc[ifire] = data1[14]
  bigald[ifire] = data1[15]
  bigalk[ifire] = data1[16]
  bigene[ifire] = data1[17]
  c10h16[ifire] = data1[18]
  c2h4[ifire] = data1[19]
  C2H5OH[ifire] = data1[20]
  C2H6[ifire] = data1[21]
  C3H6[ifire] = data1[22]
  C3H8[ifire] = data1[23]
  CH2O[ifire] = data1[24]
  CH3CHO[ifire] = data1[25]
  CH3COCH3[ifire] = data1[26]
  CH3COCHO[ifire] = data1[27]
  CH3COOH[ifire] = data1[28]
  CH3OH[ifire] = data1[29]
  CRESOL[ifire] = data1[30]
  GLYALD[ifire] = data1[31]
  HYAC[ifire] = data1[32]
  ISOP[ifire] = data1[33]
  MACR[ifire] = data1[34]
  MEK[ifire] = data1[35]
  MVK[ifire] = data1[36]
  HCN[ifire] = data1[37]
  CH3CN[ifire] = data1[38]
  TOLUENE[ifire] = data1[39]
  PM25[ifire] = data1[40]
  PM10[ifire] = data1[43]
  HCOOH[ifire] = data1[44]
  C2H2[ifire] = data1[45]
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
print,'CO2:',Total(co2)/ndays *365. *1.e-9, Total(co2)/ndays *365. *1.e-9*12./44.
print,'CO:',Total(co)/ndays *365. *1.e-9, Total(co)/ndays *365. *1.e-9*12./28.
print,'NO:',Total(no)/ndays *365. *1.e-9, Total(no)/ndays *365. *1.e-9*14./30.
print,'BC',Total(bc)/ndays *365. *1.e-9
print,'OC',Total(oc)/ndays *365. *1.e-9
print,'SO2',Total(so2)/ndays *365. *1.e-9, Total(so2)/ndays *365. *1.e-9*32./64.
print,'NH3',Total(nh3)/ndays *365. *1.e-9, Total(nh3)/ndays *365. *1.e-9*14./17.
print,'NMOC',Total(nmoc)/ndays *365. *1.e-9, Total(nmoc)/ndays *365. *1.e-9*14./17.
;print,'BIOMASS', Total(bmass), ' kg/m2 for only days of file'
print,'AREA BURNED' , Total(Area), ' m2 total for only days of file'
bb = fltarr(nfires)
for i = 0L,nfires-1 do begin
  bb[i] = bmass[i]*area[i]
endfor
print, 'biomass burned',  total(bb)

; NOW- GRID FIRE EMISSIONS AND PUT INTO INDIVIDUAL NetCDF FILES

specfile = 'E:\Data2\wildfire\SPECIATION\MOZ4\mz4_species_molwts.csv'
intemp=ascii_template(specfile)
moz4species=read_ascii(specfile, template=intemp)
specs = moz4species.field1
molwts = moz4species.field2

nspec = n_elements(specs)

for ispec=0,nspec-1 do begin

  spec = specs[ispec]
  mw = molwts[ispec]
  case spec of
    'CO2': fire_data = co2
    'CO': fire_data = co
    'NO': fire_data = no
    'NO2': fire_data = no2
    'SO2': fire_data = so2
    'NH3': fire_data = NH3
    'CH4': fire_data = CH4
    'NMOC': fire_data = nmoc
    'BIGALD': fire_data = bigald
    'BIGALK': fire_data = bigalk
    'BIGENE': fire_data = bigene
    'C10H16': fire_data = c10H16
    'C2H4': fire_data = c2h4
    'C2H5OH':fire_data =C2H5OH
    'C2H6':fire_data = C2H6
    'C3H6': fire_data = C3H6
    'C3H8' : fire_data = C3H8
    'CH2O' : fire_data = CH2O
    'CH3CHO': fire_data = CH3CHO
    'CH3COCH3' : fire_data = CH3COCH3
    'CH3COCHO' : fire_data = CH3COCHO
    'CH3COOH': fire_data = CH3COOH
    'CH3OH': fire_data = CH3OH
    'CRESOL': fire_data = CRESOL
    'GLYALD': fire_data = GLYALD
    'HYAC': fire_data = HYAC
    'ISOP': fire_data = ISOP
    'MACR': fire_data = MACR
    'MEK': fire_data = MEK
    'MVK': fire_data = MVK
    'HCN': fire_data = HCN
    'CH3CN': fire_data = CH3CN
    'TOLUENE': fire_data = TOLUENE
    'HCOOH': fire_data = HCOOH
    'C2H2': fire_data = C2H2
    'PM25': fire_data = pm25
    'PM10': fire_data = pm10
    'OC': fire_data = OC
    'BC': fire_data = BC
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
  for ilat=0,nlat-1 do begin
    dx = Rearth * cos(lat_grid[ilat]*rad_deg) * dlon*rad_deg  ;m
    gridarea = dx * dy    ;m^2
    sf = mw/1000./gridarea ; to convert mole/day --> kg/day/m2
  for ilon=0,nlon-1 do begin
      for iday=0,ndays-1 do begin
        emis_grid[ilon,ilat,iday] = emis_grid[ilon,ilat,iday]*sf
      endfor
    endfor
  endfor


 ncfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2012\SPECIATE\MOZ4\FINNv1_global_2003_'+spec+'_'+resol+'.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Daily fire emissions, FINNv1'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer'
 ncdf_attput,ncid,/GLOBAL,'Grid',resol
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from FINNv1 MOZ4 files'

 varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'kg/day/m2'
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

