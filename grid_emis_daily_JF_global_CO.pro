;This program reads in emissions and grids them up on a 0.5 degree grid for each day
; Created by christine
; April 20, 2012
; First Application is for SEAC4RS in 2011
; 
; July 10, 2014
; - Edited to read in the netCDF file of a domain definition from JF and put the emissions onto that grid. 
; - 
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

pro grid_emis_daily_JF_global_CO

close, /all

      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'


; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; Emissions are in kg/km2/day

print,'Reading: ',infile

nfires = nlines(infile)-1
lon = fltarr(nfires)
lati = fltarr(nfires)
day = intarr(nfires)
jday = intarr(nfires)
genveg = intarr(nfires)
co2 = fltarr(nfires)
co = fltarr(nfires)
nox = fltarr(nfires)
no = fltarr(nfires)
no2 = fltarr(nfires)
nh3 = fltarr(nfires)
so2 = fltarr(nfires)
bc = fltarr(nfires)
oc = fltarr(nfires)
pm25 = fltarr(nfires)
tpm = fltarr(nfires)
voc = fltarr(nfires)
nmhc = fltarr(nfires)
ch4 = fltarr(nfires)
pm10 = fltarr(nfires)

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)

;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
;

for k=0L,nfires-1 do begin
  readf,ilun,data1
  lon[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
;  genveg[k] = data1[5]
  co2[k] = data1[12]
  co[k] = data1[13]
;  oc[k] = data1[25]
;  bc[k] = data1[26]
;  nox[k] = data1[16]
;  nh3[k] = data1[19]
;  so2[k] = data1[20]
  pm25[k] = data1[23]
;  tpm[k] = data1[24]
;  no[k] = data1[17]
;  NO2[k] = data1[18]
;  nmhc[k] = data1[21]
  voc[k] =  data1[22]
;  ch4[k] = data1[14]
;  pm10[k] = data1[28]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'

; define arrays
longgrid = fltarr(720)
latigrid = fltarr(360)
COemisgrid = fltarr(720,360,365)

print, 'finished reading input file'

output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2012\SEAC4RS\DAILY_FIREEMIS_SEAC4RS_gridded_daily_totals_2011_0420012.txt'
openw, 10, output1
printf, 10, "LAT,LONG,DAY,CO' 
form = '(F25.10,",",F25.10,",",I4,",",F25.10)'

for i = 230,270 do begin  ; go over each day
        ntotdays = 365
        thismonth = where(day eq i)

; loop around the 0.5 degree spaces
  latmin = -90.
  longmin = -180.
for j = 0,719 do begin
  for k = 0,359 do begin
      grid = where((lati[thismonth] ge latmin+(k*0.5)) and (lati[thismonth] lt latmin+((k+1)*0.5)) and (lon[thismonth] ge longmin+(j*0.5)) and (lon[thismonth] le longmin+((j+1)*0.5)))
      latigrid[k] = latmin+(k*0.5)
      longgrid[j] = longmin+(j*0.5)
      COemisgrid[j,k,i] = 0.0
      if grid[0] lt 0 then begin
         goto, skipfire
      endif
      if grid[0] gt -1 then begin 
          COemisgrid[j,k,i] = total(co[thismonth[grid]])
          printf, 10, format=form,latigrid[k],longgrid[j],i+1,COemisgrid[j,k,i]
      endif    
      skipfire:
  endfor
endfor    
close, 1
endfor ; end of daily loop 
 
print, 'Program all finished :)'
end ; End of program
 
         