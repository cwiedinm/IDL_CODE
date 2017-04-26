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

pro process_global_fireemis_summary
t0 = systime(1) ;Procedure start time in seconds
close, /all

openw, 1, 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\REGIONAL_SUMMARIES.txt' 
Printf, 1, 'DATE,REGION,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS'


for j = 0,11 do begin ; j loop is over all of the files. 
  if j eq 0 then begin ; 2005
      date = '2005'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2010\GLOB_2005_08242010.txt'
  endif
  if j eq 1 then begin ; 2006
      date = '2006'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2010\GLOB_2006_09032010.txt'
  endif
  if j eq 2 then begin ; JAN-APR 2007
      date = 'JAN-APR 2007'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-APR2007_09072010.txt'      
  endif
  if j eq 3 then begin ; MAY-SEPT 2007
      date = 'MAY-SEPT 2007'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_MAY-SEPT2007_09072010.txt'      
  endif
  if j eq 4 then begin ; OCT-DEC 2007
      date = 'OCT-DEC 2007'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2007_09072010.txt'
  endif
  if j eq 5 then begin ; JAN-APR 2008
      date = 'JAN-APR 2008'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-APR2008_09082010.txt'  
  endif
  if j eq 6 then begin ; MAY-SEPT 2008
      date = 'MAY-SEPT 2008'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_MAY-SEPT2008_03252011_correctLCT.txt'
  endif
  if j eq 7 then begin ; OCT-DEC 2008
    date = 'OCT-DEC 2008'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2008_09082010.txt'
   endif
  if j eq 8 then begin ; JAN-NOV 2009
      date = 'JAN-NOV 2009'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-NOV2009_09082010.txt'
  endif
  if j eq 9 then begin ; DEC 2009
      date = 'DEC 2009'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_DEC2009_09092010.txt'
  endif
  if j eq 10 then begin ; JAN-APR 2010
      date = 'JAN-APR 2010'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-APR2010_09092010.txt'
  endif
  if j eq 11 then begin ; MAY-AUG27 2010
      date = 'MAY-AUG27 2010'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_MAY-AUG27_2010_09092010.txt'
  endif
  
printf, 1, 'REGIONAL Emissions from '+infile

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
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
;    
; OUTPUT FILE HEADER
;'CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS'

form = '(I3,",",A16,",",A8,",",27(F25.10,","))'

CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

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

; Global Daily Totals   
;printf, 1, 'GLOBAL TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'GLOB'
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp1
      endif
      TROPAREA = total(area[tropfor])/1000000. ; AREA = km2
      bmassarr = area[tropfor]*bmass[tropfor]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp1:
      tempfor = where(genveg eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor1
      endif      
      TEMPAREA = total(area[tempfor])/1000000. ; AREA = km2
      bmassarr = area[tempfor]*bmass[tempfor]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor1:
      borfor = where(genveg eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass1
      endif
      BORAREA = total(area[borfor])/1000000. ; AREA = km2
      bmassarr = area[borfor]*bmass[borfor]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass1:
      grass = where(genveg eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub1
      endif
      GRASSAREA = total(area[grass])/1000000. ; AREA = km2
      bmassarr = area[grass]*bmass[grass]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub1:
      shrub = where(genveg eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop1
      endif
      SHRUBAREA = total(area[shrub])/1000000. ; AREA = km2
      bmassarr = area[shrub]*bmass[shrub]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop1:
      crop = where(genveg eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend1
      endif
      CROPAREA = total(area[crop])/1000000. ; AREA = km2
      bmassarr = area[crop]*bmass[crop]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend1:
    CO2in = total(CO2)/1.e6 ; input is in kg/day --> ouput in Gg/day
    COin = total(CO)/1.e6
    NOXin = total(NOX)/1.e6
    NOin = total(NO)/1.e6
    NO2in = total(NO2)/1.e6
    NH3in = total(NH3)/1.e6
    SO2in = total(SO2)/1.e6
    VOCin = total(VOC)/1.e6
    NMHCin = total(NMHC)/1.e6
    CH4in = total(CH4)/1.e6
    PM25in = total(PM25)/1.e6
    OCin = total(OC)/1.e6
    BCin = total(BC)/1.e6
    TPMin = total(TPM)/1.e6
    PM10in = total(PM10)/1.e6
    skip20:  
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS

CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Northern Hemisphere Daily Totals   
;printf, 1, 'Northern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'NH'
  today = where(lati gt 0.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip21
   endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp2
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp2:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor2
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor2:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass2
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass2:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub2
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub2:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop2
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop2:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend2
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend2:
      CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip21:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Southern Hemisphere Daily Totals   
;printf, 1, 'Southern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'SH'
  today = where(lati lt 0.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip22
  endif  
  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp3
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp3:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor3
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor3:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass3
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass3:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub3
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub3:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop3
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop3:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend3
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend3:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip22:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Northern Hemisphere South America
;Printf, 1, 'NORTHERN HEMISPHERE SOUTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 0-12, Long: -95 - -45'
reg = 'NHSA'
  today = where(lati gt 0. and lati lt 12. and longi gt -95. and longi lt -45.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip1
  endif  
 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp4
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp4:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor4
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor4:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass4
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass4:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub4
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub4:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop4
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop4:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend4
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend4:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip1:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Southern Hemisphere South America 
;Printf, 1, 'Southern Hemisphere South America (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -60 - 0, Long: -90 - -30'
 reg = 'SHSA'
  today = where(lati gt -60. and lati lt 0. and longi gt -90. and longi lt -30.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip2
  endif  
 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp5
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp5:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor5
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor5:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass5
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass5:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub5
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub5:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop5
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop5:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend5
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend5:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip2:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Southern Hemisphere Africa 
;Printf,1, 'Southern Hemisphere Africa (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -40 - 0; Long: 5 - 55'
reg = 'SHAF'
  today = where(lati gt -40. and lati lt 0. and longi gt 5. and longi lt 55.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip3
  endif  

 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp6
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp6:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor6
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor6:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass6
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass6:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub6
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub6:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop6
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop6:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend6
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend6:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip3:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Northern Hemisphere Africa    
;Printf, 1, 'Northern Hemisphere Africa (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 0-23; Long: -20 - 60'
reg = 'NHAF'
  today = where(lati ge 0. and lati lt 23. and longi gt -20. and longi lt 60.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip4
  endif  

 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp7
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp7:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor7
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor7:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass7
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass7:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub7
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub7:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop7
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop7:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend7
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend7:
    CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip4:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Northern Africa/Middle East 
;Printf, 1, 'Northern Africa/Middle East (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 23-35; Long: -20 - 60'
reg = 'NAFME'
  today = where(lati gt 23. and lati lt 35. and longi gt -20. and longi lt 60.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip5
  endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp8
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp8:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor8
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor8:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass8
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass8:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub8
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub8:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop8
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop8:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend8
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend8:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip5:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; EUROPE   
;Printf, 1, 'EUROPE (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 35-75; Long: -12 - 30'
reg = 'EURO'
  today = where(lati gt 35. and lati lt 75. and longi gt -12. and longi lt 30.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip6
  endif  
 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp9
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp9:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor9
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor9:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass9
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass9:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub9
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub9:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop9
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop9:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend9
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend9:
   CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip6:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; AUSTRALIA 
;Printf, 1, 'AUSTRALIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -50 - -10; Long: 110 - 180'
reg = 'AUSTR'
  today = where(lati gt -50. and lati lt -10. and longi gt 110. and longi lt 180.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip7
  endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp10
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp10:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor10
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor10:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass10
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass10:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub10
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub10:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop10
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop10:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend10
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend10:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip7:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; Equatorial ASIA
;Printf, 1, 'Equatorial ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -10 - 5; Long: 90 - 165'
reg = 'EQAS'
  today = where(lati gt -10. and lati lt 5. and longi gt 90. and longi lt 165.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip8
  endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp11
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp11:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor11
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor11:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass11
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass11:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub11
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub11:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop11
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop11:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend11
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend11:
     CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip8:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; SOUTHEAST ASIA
;Printf, 1, 'SOUTHEAST ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 5 - 35; Long: 60 - 145'
reg = 'SEAS'
  today = where(lati gt 5. and lati lt 35. and longi gt 60. and longi lt 145.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip9
  endif  

; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp12
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp12:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor12
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor12:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass12
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass12:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub12
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub12:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop12
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop12:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend12
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend12:
    CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip9:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; CENTRAL ASIA
;Printf, 1, 'CENTRAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 35-50; Long 30 - 155'
reg = 'CENAS'
  today = where(lati gt 35. and lati lt 50. and longi gt 30. and longi lt 155.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip10
  endif  

; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp13
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp13:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor13
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor13:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass13
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass13:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub13
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub13:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop13
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop13:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend13
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend13:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip10:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; BOREAL ASIA
;Printf,1, ' BOREAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 50-80; Long 30-180'
reg = 'BORAS'
  today = where(lati gt 50. and lati lt 80. and longi gt 30. and longi lt 180.)
  if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip11
  endif  

 ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp14
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp14:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor14
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor14:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass14
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass14:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub14
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub14:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop14
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop14:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend14
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend14:
   CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip11:
  printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; BOREAL NORTH AMERICA
;Printf, 1, ' BOREAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 49 - 79; Long -169 - -44'
reg = 'BORNA'
  today = where(lati gt 49. and lati lt 79. and longi gt -169. and longi lt -44.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip31
  endif  

; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp15
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp15:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor15
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor15:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass15
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass15:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub15
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub15:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop15
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop15:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend15
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend15:
 CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip31:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; TEMPERATE NORTH AMERICA
;Printf, 1, 'TEMPERATE NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 27-49; Long -130 - -60'
reg = 'TEMNA'
  today = where(lati gt 27. and lati lt 49. and longi gt -130. and longi lt -60.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip51
  endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp16
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp16:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor16
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor16:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass16
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass16:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub16
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub16:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop16
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop16:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend16
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend16:
 CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip51:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

; CENTRAL NORTH AMERICA
;Printf, 1, 'CENTRAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 12 - 27; Long -120 - -60'
reg = 'CENA'
  today = where(lati gt 12. and lati lt 27. and longi gt -120. and longi lt -60.)
 if today[0] lt 0 then begin
    CO2in = 0.0
    COin = 0.0
    NOXin = 0.0
    NOin = 0.0
    NO2in = 0.0
    NH3in = 0.0
    SO2in = 0.0
    VOCin = 0.0
    NMHCin = 0.0
    CH4in = 0.0
    PM25in = 0.0
    OCin = 0.0
    BCin = 0.0
    TPMin = 0.0
    PM10in = 0.0
    TROPAREA = 0.0
    TROPBMASS = 0.0
    TEMPAREA = 0.0
    TEMPBMASS = 0.0
    BORAREA = 0.0
    BORBMASS = 0.0
    GRASSAREA = 0.0
    GRASSBMASS = 0.0
    SHRUBAREA = 0.0
    SHRUBBMASS = 0.0
    CROPAREA = 0.0
    CROPBMASS = 0.0
    goto, skip61
  endif  

; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp17
      endif
      TROPAREA = total(area[today[tropfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tropfor]]*bmass[today[tropfor]]
      TROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; TEMPERATE FORESTS
      nexttemp17:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor17
      endif      
      TEMPAREA = total(area[today[tempfor]])/1000000. ; AREA = km2
      bmassarr = area[today[tempfor]]*bmass[today[tempfor]]
      TEMPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; BOREAL FORESTS
      nextbor17:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass17
      endif
      BORAREA = total(area[today[borfor]])/1000000. ; AREA = km2
      bmassarr = area[today[borfor]]*bmass[today[borfor]]
      BORBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; GRASSLANDS
      nextgrass17:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub17
      endif
      GRASSAREA = total(area[today[grass]])/1000000. ; AREA = km2
      bmassarr = area[today[grass]]*bmass[today[grass]]
      GRASSBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; SHRUB
      nextshrub17:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop17
      endif
      SHRUBAREA = total(area[today[shrub]])/1000000. ; AREA = km2
      bmassarr = area[today[shrub]]*bmass[today[shrub]]
      SHRUBBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    ; CROP
      nextcrop17:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend17
      endif
      CROPAREA = total(area[today[crop]])/1000000. ; AREA = km2
      bmassarr = area[today[crop]]*bmass[today[crop]]
      CROPBMASS = total(bmassarr)/1.e6 ; BMASS = Gg DM
    nextend17:
  CO2in = total(CO2[today])/1.e6
  COin = total(CO[today])/1.e6
  NOXin = total(NOX[today])/1.e6
  NOin = total(NO[today])/1.e6
  NO2in = total(NO2[today])/1.e6
  NH3in = total(NH3[today])/1.e6
  SO2in = total(SO2[today])/1.e6
  VOCin = total(VOC[today])/1.e6
  NMHCin = total(NMHC[today])/1.e6
  CH4in = total(CH4[today])/1.e6
  PM25in = total(PM25[today])/1.e6
  OCin = total(OC[today])/1.e6
  BCin = total(BC[today])/1.e6
  TPMin = total(TPM[today])/1.e6
  PM10in = total(PM10[today])/1.e6
  skip61:
 printf, 1, format = form,j+1,date,reg,CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TROPAREA,TROPBMASS,TEMPAREA,TEMPBMASS,BORAREA,BORBMASS,GRASSAREA,GRASSBMASS,SHRUBAREA,SHRUBBMASS,CROPAREA,CROPBMASS
  
CO2in = 0.0
COin = 0.0
NOXin = 0.0
NOin = 0.0
NO2in = 0.0
NH3in = 0.0
SO2in = 0.0
VOCin = 0.0
NMHCin = 0.0
CH4in = 0.0
PM25in = 0.0
OCin = 0.0
BCin = 0.0
TPMin = 0.0
PM10in = 0.0
TROPAREA = 0.0
TROPBMASS = 0.0
TEMPAREA = 0.0
TEMPBMASS = 0.0
BORAREA = 0.0
BORBMASS = 0.0
GRASSAREA = 0.0
GRASSBMASS = 0.0
SHRUBAREA = 0.0
SHRUBBMASS = 0.0
CROPAREA = 0.0
CROPBMASS = 0.0

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