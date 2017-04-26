; THis program will do analysis on the fire emissions files created in January 2010
; Created 01/30/2010
; 
; MAY 03, 2010
;   - edited to process the Emission Estimates made in February 2010 and May 2010
;   - includes global regions and daily output
; 
; May 05, 2010
;   - Edited to output daily emissions for regional, daily emissions
;   
; SEPTEMBER 16, 2010
; - Edited to take latest emissions files created in August/September, 2010
; - Changed inputs/outputs to include PM10. 
;  - edited a lot of code... 
;  
;  March 26, 2011
;  - Edited to use the final input files as of 03/26/2011 (address reviews for GMD paper)
;  - Set up 13 regions for comparison to GFED
;  March 27, 2011
;  - edited to do summaries for each file
; 
;  April 05, 2011
;  - edited to output only CO emissions by region and ecosystem-type
;  - this one only does global, NH, and SH
; 
;  JUNE 21, 2011
;   - Edited to output area burned and biomass burned by region and ecosystem Type
;   
; AUGUST 05, 2013
; - Edited to output area burned and emissions for Steve Arnold/Sarah Monks Regions
; 
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

pro process_regional_annual_totals_steveA
t0 = systime(1) ;Procedure start time in seconds
close, /all

openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2013\PROCESS\Regional_FINNv1_annual_totals_08052013.txt' 
Printf, 1, 'FILE,REGION,year,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
form = '(A60,",",A10,",",I5,",",10(",",F25.10))'


for j = 0,10 do begin ; do 2002-2011
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2002_05102011.txt'
;      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2002_09192012.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2003_05102011.txt'
;      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2003_09192012.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2004_05122011.txt'
 ;     output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2004_09192012.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\JUNE2011\GLOB_2005_06212011.txt'
  ;    output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2005_09192012.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\AUGUST2010\GLOB_2006_09032010.txt'
   ;   output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2006_09192012.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2007_09172012.txt'
    ;  output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2007_09192012.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2008_09172012.txt'
     ; output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2008_09192012.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2009_09192012.txt'
   ;   output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2009_09192012.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2010_09192012.txt'
    ;  output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2010_09192012.txt'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
     ; output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY_GLOB_CO2CO_2011_09192012.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\GLOBAL_2012_02282013.txt'
     ; output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY__GLOB_CO2CO_2012_09192012.txt'
  endif
  
yearnum = year
printf, 1, 'Processing emissions from '+infile

; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; Emissions are in kg/km2/day

print,'Reading: ',infile

nfires = nlines(infile)-1
longi = fltarr(nfires)
lati = fltarr(nfires)
day = intarr(nfires)
jday = intarr(nfires)
lct = intarr(nfires)
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
area = fltarr(nfires)
bmass = fltarr(nfires)
nmoc = fltarr(nfires)

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)


;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; area in m2
; biomass in kg/m2
; emissions in kg/day

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
  genveg[k] = data1[5]
  co2[k] = data1[12]
  co[k] = data1[13]
  oc[k] = data1[25]
  bc[k] = data1[26]
  nox[k] = data1[16]
  nh3[k] = data1[19]
  so2[k] = data1[20]
  pm25[k] = data1[23]
  tpm[k] = data1[24]
  no[k] = data1[17]
  NO2[k] = data1[18]
  nmhc[k] = data1[21]
  voc[k] =  data1[22]
  ch4[k] = data1[14]
  pm10[k] = data1[28]
  area[k] = data1[10]
  bmass[k] = data1[11]
  lct[k] = data1[4]
  nmoc[k] = data1[22]
endfor ; end k loop
close,ilun
free_lun,ilun

; Calculate bmass burned
bmassburn = bmass * area ; kg biomass burned

print, 'finished reading in input file and assigning arrays'
print, 'Input file = ', infile
print, 'Year = ', year
print, 'Day min = ', min(day), ' and day max = ', max(day)
print, 'Number of fires read in: ,', n_elements(co2)
print, ' '
;    
TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0



; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
; 
;    Units for input file
;    area  --> m2
;    bmass --> kg dm/m2
; 
; Biomass burned = bmass * area ; kg


; PRINT ANNUAL EMISSIONS
daymin = 0
daymax = 366

; Global Daily Totals   
;printf, 1, 'GLOBAL TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
      reg = 'GLOB_ALL'
      today = where(day ge daymin and day le daymax)
      if today[0] lt 0 then goto, skipnew1

; Calculate the area burned and the biomass burned by Vegetation Type
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
  
;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'

printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

skipnew1:

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

; Meditteranean
reg = 'MEDI'
latmin = 25.
latmax = 50.
lonmin =0. 
lonmax =50. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
  if today[0] lt 0 then begin
    goto, skip100
  endif 
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
                 
;    nextend2:
    skip100:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;North East Siberia
reg = 'NESI'
latmin = 45.
latmax = 80.
lonmin =115. 
lonmax =179. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
  if today[0] lt 0 then begin
    goto, skip22
  endif 
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
                 
    nextend2:
    skip22:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0
; 
;Alaska/Canada
reg = 'ALCA'
latmin = 45.
latmax = 72.
lonmin =-170. 
lonmax =-52. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
 if today[0] lt 0 then begin
     goto, skip23
  endif  
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend3:
    skip23:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;North Central Siberia
reg = 'NCSI'
latmin = 45.
latmax = 80.
lonmin =50. 
lonmax =115. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
 if today[0] lt 0 then begin
     goto, skip24
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend4:
    skip24:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;Africa -- Northern Hemisphere
reg = 'NHAF'
latmin = 0.
latmax = 35.
lonmin =-17.5 
lonmax =50. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
 if today[0] lt 0 then begin
     goto, skip25
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend5:
    skip25:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

  
;Equitorial Asia
reg = 'EQAS'
latmin = -12.
latmax = 10.
lonmin =90. 
lonmax =150. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
if today[0] lt 0 then begin
     goto, skip26
 endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend6:
    skip26:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0


;SouthEast Asia
reg = 'SEAS'
latmin = 10.
latmax = 45.
lonmin =90. 
lonmax =150. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
  if today[0] lt 0 then begin
     goto, skip27
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend7:
    skip27:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0


;Africa -- Southern Hemisphere
reg = 'SHAF'
latmin = -35.
latmax = 0.
lonmin =-17.5 
lonmax =60. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
  if today[0] lt 0 then begin
     goto, skip28
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend8:
    skip28:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0
 
;Europe
reg = 'EURO'
latmin = 35.
latmax = 70.
lonmin =-17.5 
lonmax =60. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
  if today[0] lt 0 then begin
     goto, skip29
  endif  
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend9:
    skip29:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;Australia
reg = 'AUST'
latmin = -40.
latmax = -12.
lonmin =110. 
lonmax =160. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
   if today[0] lt 0 then begin
     goto, skip30
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend10:
    skip30:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;NSAM
reg = 'NSAM'
latmin = -20.
latmax = 12.
lonmin =-80. 
lonmax =-35. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)
   if today[0] lt 0 then begin
     goto, skip31
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend11:
    skip31:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

; 
;Western US
reg = 'WNAM'
latmin = 22.
latmax = 45.
lonmin =-130. 
lonmax =-95. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)   
if today[0] lt 0 then begin
     goto, skip32
  endif  
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend12:
    skip32:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

;CEAM
reg = 'CEAM'
latmin = 8.
latmax = 22.
lonmin =-110. 
lonmax =-80. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)   
   if today[0] lt 0 then begin
     goto, skip33
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend13:
    skip33:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0


;ENAM
reg = 'ENAM'
latmin = 22.
latmax = 45.
lonmin =-95. 
lonmax =-60. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)   
     if today[0] lt 0 then begin
     goto, skip34
  endif  
      TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend14:
    skip34:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0
  
;CSAS
reg = 'CSAS'
latmin = 5.
latmax = 45.
lonmin =50. 
lonmax =90. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)   
  if today[0] lt 0 then begin
     goto, skip35
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend15:
    skip35:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0
  
;SSAM
reg = 'SSAM'
latmin = -55.
latmax = -20.
lonmin =-80. 
lonmax =-35. 
today = where(lati ge latmin and lati le latmax and longi ge lonmin and longi le lonmax and day ge daymin and day le daymax)   
     if today[0] lt 0 then begin
     goto, skip36
  endif  
     TOTAREA = total(area[today])/1000000. ; km2
      TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
      TOTCO2 = total(co2[today])/1.e6 ; Tg
      TOTCO = total(co[today])/1.e6 ; Gg 
      TOTCH4 = total(ch4[today])/1.e6 ; Gg
      TOTNMOC = total(nmoc[today])/1.e6 ; Gg
      TOTNMHC = total(nmhc[today])/1.e6 ; Gg
      TOTNOX = total(nox[today])/1.e6 ; Gg
      TOTNO = total(no[today])/1.e6 ; Gg
      TOTNO2 = total(no2[today])/1.e6 ; Gg
      TOTNH3 = total(nh3[today])/1.e6 ; Gg
      TOTSO2 = total(so2[today])/1.e6 ; Gg
      TOTPM25 = total(pm25[today])/1.e6 ; Gg
      TOTTPM = total(tpm[today])/1.e6 ; Gg
      TOTOC = total(oc[today])/1.e6 ; Gg
      TOTBC = total(bc[today])/1.e6 ; Gg
    nextend16:
    skip36:  

;Printf, 1, 'FILE,REGION,year,month,CO2,CO,CH4,NMOC,PM25,TPM,OC,BC,AREA,BIOMASS'
;form = '(A16,",",A16,",",I5,",",I3,10(",",F25.10))'
printf, 1, format = form,infile,reg,year,TOTCO2,TOTCO,TOTCH4,TOTNMOC,TOTPM25,TOTTPM,TOTOC,TOTBC,TOTAREA,TOTBMASS

TOTAREA = 0.0
TOTBMASS = 0.0
TOTCO = 0.0
TOTNOX = 0.0
TOTCO2 = 0.0
TOTCH4 = 0.0
TOTNMOC = 0.0
TOTNMHC = 0.0
TOTNO = 0.0
TOTNO2 = 0.0
TOTNH3 = 0.0
TOTSO2 = 0.0
TOTPM25 = 0.0
TOTTPM = 0.0
TOTOC = 0.0
TOTBC = 0.0

   

; Closing l loop (for each Month
;print, "Finished with month ", month," and year ", year   
;endfor ; end l loop
; ***************************************************************  
print, 'Finished with file # ', j+1
print, 'Closing ', infile

endfor ; End of j loop over the different input files
close, /all
; ***************************************************************
;           END PROGRAM
; ***************************************************************
    t1 = systime(1)-t0
    print,'Fire Processing Code> End Procedure in   '+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
    junk = check_math() ;This clears the math errors
    print, ' This run was done on: ', SYSTIME()
    close,/all   ;make sure ALL files are closed

END