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

pro process_global_area_ECO2
t0 = systime(1) ;Procedure start time in seconds
close, /all

openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE2011\PROCESS\Area_BMASS_ECO_REGIONAL_SUMMARIES_GOOD.txt' 
Printf, 1, 'FILE,DATE,REGION,AREATOT,BORFOR_AREA,TEMPFOR_AREA,TROPFOR_AREA,SHRUB_AREA,GRASS_AREA,CROP_AREA,BMASSTOT,BORFOR_BMASS,TEMPFOR_BMASS,TROPFOR_BMASS,SHRUB_BMASS,GRASS_BMASS,CROP_BMASS'
form = '(I3,",",A16,",",A16,",",14(F25.10,","))'

openw, 2, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE2011\PROCESS\CO_ECO_REGIONAL_SUMMARIESGOOD.txt' 
Printf, 2, 'FILE,DATE,REGION,TOTAL_CO,BORFOR_CO,TEMPFOR_CO,TROPFOR_CO,SHRUB_CO,GRASS_CO,CROP_CO'
form2 = '(I3,",",A16,",",A16,",",7(F25.10,","))'

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
  if j eq 10 then begin ; JAN-JUN 2010
      date = 'JAN-JUN 2010'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_JAN-JUN2010_04042011.txt'
  endif
  if j eq 11 then begin ; JUN-DEC 2010
      date = 'JUN-DEC 2010'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_JUN-DEC2010_04042011.txt'
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
endfor
close,ilun
free_lun,ilun

; Calculate bmass burned
bmassburn = bmass * area ; kg biomass burned

print, 'finished reading in input file and assigning arrays'
;    
TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0
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
; 
; Global Daily Totals   
;printf, 1, 'GLOBAL TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'GLOB'
; Calculate the area burned and the biomass burned by Vegetation Type
      TOTAREA = total(area)/1000000. ; km2
      TOTBMASS = total(bmassburn)/1.e6 ; Gg
      TOTCO = total(co)/1.e6 ; Gg
    ; TROPICAL FORESTS
      tropfor = where(genveg eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp1
      endif
      TROPAREA = total(area[tropfor])/1000000. ; km2
      TROPBMASS = total(bmassburn[tropfor])/1000000. ; Gg
      TROPCO = total(co[tropfor])/1.e6 ; Gg
      nexttemp1:
      ; TEMPERATE FORESTS
      tempfor = where(genveg eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        goto, nextbor1
      endif      
       TEMPAREA = total(area[tempfor])/1000000. ; km2
       TEMPBMASS = total(bmassburn[tempfor])/1000000. ; Gg
       TEMPCO = total(co[tempfor])/1.e6 ; Gg
      ; BOREAL FORESTS
      nextbor1:
      borfor = where(genveg eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        goto, nextgrass1
      endif
      BORAREA = total(area[borfor])/1000000. ; km2
      BORBMASS = total(bmassburn[borfor])/1000000. ; Gg
      BORCO = total(co[borfor])/1.e6 ; Gg
    ; GRASSLANDS
      nextgrass1:
      grass = where(genveg eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        goto, nextshrub1
      endif
      GRASSAREA = total(area[grass])/1000000. ; km2
      GRASSBMASS = total(bmassburn[grass])/1000000. ; Gg
      GRASSCO = total(co[grass])/1.e6 ; Gg
     ; SHRUB
      nextshrub1:
      shrub = where(genveg eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        goto, nextcrop1
      endif
      SHRUBAREA = total(area[shrub])/1000000. ; km2
      SHRUBBMASS = total(bmassburn[shrub])/1000000. ; Gg
      SHRUBCO = total(co[shrub])/1.e6 ; Gg
      ; CROP
      nextcrop1:
      crop = where(genveg eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        goto, nextend1
      endif
       CROPAREA = total(area[crop])/1000000. ; km2
       CROPBMASS = total(bmassburn[crop])/1000000. ; Gg
       CROPCO = total(co[crop])/1.e6 ; Gg

    nextend1:
;Printf, 1, 'FILE,DATE,REGION,AREATOT,BORFOR_AREA,TEMPFOR_AREA,TROPFOR_AREA,SHRUB_AREA,GRASS_AREA,CROP_AREA,BMASSTOT,BORFOR_BMASS,TEMPFOR_BMASS,TROPFOR_BMASS,SHRUB_BMASS,GRASS_BMASS,CROP_BMASS'
;form = '(I3,",",A16,",",A16,",",14(F25.10,","))'

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 

;Printf, 2, 'FILE,DATE,REGION,TOTAL_CO,BORFOR_CO,TEMPFOR_CO,TROPFOR_CO,SHRUB_CO,GRASS_CO,CROP_CO'
;form2 = '(I3,",",A16,",",A16,",",7(F25.10,","))'
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


; Northern Hemisphere Daily Totals   
;printf, 1, 'Northern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'NH'
  today = where(lati gt 0.)
  if today[0] lt 0 then begin
    goto, skip22
   endif 
   TOTAREA = total(area[today])/1000000. ; km2
   TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp2
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp2:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor2
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor2:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass2
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass2:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub2
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub2:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop2
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop2:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend2
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
              
    nextend2:
    skip22:  

 

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


; 
; Southern Hemisphere Daily Totals   
;printf, 1, 'Southern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'SH'
  today = where(lati lt 0.)
 if today[0] lt 0 then begin
     goto, skip23
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp3
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp3:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor3
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor3:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass3
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass3:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub3
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub3:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop3
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop3:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend3
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend3:
    skip23:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


; Northern Hemisphere South America
;Printf, 1, 'NORTHERN HEMISPHERE SOUTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 0-12, Long: -95 - -45'
reg = 'NHSA'
  today = where(lati gt 0. and lati lt 12. and longi gt -95. and longi lt -45.)
 if today[0] lt 0 then begin
     goto, skip24
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
       
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp4
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp4:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor4
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor4:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass4
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass4:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub4
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub4:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop4
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      
      ; CROP
      nextcrop4:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend4
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend4:
    skip24:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0



; Southern Hemisphere South America 
 reg = 'SHSA'
  today = where(lati gt -60. and lati lt 0. and longi gt -90. and longi lt -30.)
 if today[0] lt 0 then begin
     goto, skip25
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp5
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp5:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor5
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor5:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass5
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass5:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub5
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub5:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop5
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop5:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend5
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend5:
    skip25:  

 

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


  
; Southern Hemisphere Africa 
reg = 'SHAF'
  today = where(lati gt -40. and lati lt 0. and longi gt 5. and longi lt 55.)
 if today[0] lt 0 then begin
     goto, skip26
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp6
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp6:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor6
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor6:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass6
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass6:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub6
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub6:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop6
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop6:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend6
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend6:
    skip26:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0



; Northern Hemisphere Africa   
reg = 'NHAF'
  today = where(lati ge 0. and lati lt 23. and longi gt -20. and longi lt 60.) 
  if today[0] lt 0 then begin
     goto, skip27
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp7
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp7:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor7
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor7:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass7
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass7:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub7
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub7:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop7
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop7:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend7
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend7:
    skip27:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


 
; Northern Africa/Middle East 
reg = 'NAFME'
  today = where(lati gt 23. and lati lt 35. and longi gt -20. and longi lt 60.) 
  if today[0] lt 0 then begin
     goto, skip28
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp8
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp8:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor8
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor8:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass8
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass8:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub8
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub8:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop8
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop8:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend8
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend8:
    skip28:  

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 

;rintf, 2, 'FILE,DATE,REGION,TOTAL_CO,BORFOR_CO,TEMPFOR_CO,TROPFOR_CO,SHRUB_CO,GRASS_CO,CROP_CO'
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


 
; EUROPE   
reg = 'EURO'
  today = where(lati gt 35. and lati lt 75. and longi gt -12. and longi lt 30.)
  if today[0] lt 0 then begin
     goto, skip29
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
       TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp9
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp9:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor9
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor9:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass9
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass9:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub9
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub9:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop9
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop9:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend9
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend9:
    skip29:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


 
; AUSTRALIA 
reg = 'AUSTR'
  today = where(lati gt -50. and lati lt -10. and longi gt 110. and longi lt 180.) 
   if today[0] lt 0 then begin
     goto, skip30
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
  TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp10
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp10:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor10
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor10:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass10
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass10:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub10
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub10:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop10
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop10:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend10
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend10:
    skip30:  

 

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0



; Equatorial ASIA
reg = 'EQAS'
  today = where(lati gt -10. and lati lt 5. and longi gt 90. and longi lt 165.) 
   if today[0] lt 0 then begin
     goto, skip31
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp11
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp11:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor11
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor11:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass11
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass11:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub11
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub11:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop11
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop11:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend11
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend11:
    skip31:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


; SOUTHEAST ASIA
;Printf, 1, 'SOUTHEAST ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 5 - 35; Long: 60 - 145'
reg = 'SEAS'
  today = where(lati gt 5. and lati lt 35. and longi gt 60. and longi lt 145.)
   if today[0] lt 0 then begin
     goto, skip32
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp12
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp12:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor12
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor12:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass12
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass12:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub12
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub12:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop12
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop12:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend12
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend12:
    skip32:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


; CENTRAL ASIA
;Printf, 1, 'CENTRAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 35-50; Long 30 - 155'
reg = 'CENAS'
  today = where(lati gt 35. and lati lt 50. and longi gt 30. and longi lt 155.)  
   if today[0] lt 0 then begin
     goto, skip33
  endif  
  TOTAREA = total(area[today])/1000000. ; km2'
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp13
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp13:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor13
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor13:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass13
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass13:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub13
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub13:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop13
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop13:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend13
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend13:
    skip33:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0



; BOREAL ASIA
;Printf,1, ' BOREAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 50-80; Long 30-180'
reg = 'BORAS'
  today = where(lati gt 50. and lati lt 80. and longi gt 30. and longi lt 180.)
     if today[0] lt 0 then begin
     goto, skip34
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp14
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp14:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor14
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor14:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass14
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass14:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub14
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub14:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop14
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop14:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend14
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend14:
    skip34:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


  
; BOREAL NORTH AMERICA
;Printf, 1, ' BOREAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 49 - 79; Long -169 - -44'
reg = 'BORNA'
  today = where(lati gt 49. and lati lt 79. and longi gt -169. and longi lt -44.)
     if today[0] lt 0 then begin
     goto, skip35
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp15
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp15:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor15
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor15:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass15
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass15:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub15
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub15:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop15
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop15:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend15
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend15:
    skip35:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


  
; TEMPERATE NORTH AMERICA
;Printf, 1, 'TEMPERATE NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 27-49; Long -130 - -60'
reg = 'TEMNA'
  today = where(lati gt 27. and lati lt 49. and longi gt -130. and longi lt -60.)
     if today[0] lt 0 then begin
     goto, skip36
  endif  
  TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
   TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp16
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp16:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor16
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor16:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass16
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass16:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub16
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub16:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop16
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop16:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend16
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend16:
    skip36:  



printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0


   
; CENTRAL NORTH AMERICA
;Printf, 1, 'CENTRAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 12 - 27; Long -120 - -60'
reg = 'CENA'
     today = where(lati gt 12. and lati lt 27. and longi gt -120. and longi lt -60.)
     if today[0] lt 0 then begin
     goto, skip37
  endif  
    TOTAREA = total(area[today])/1000000. ; km2
    TOTBMASS = total(bmassburn[today])/1.e6 ; Gg
    TOTCO = total(co[today])/1.e6 ; Gg
  
  ; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        goto, nexttemp17
      endif
      TROPAREA = total(area[today[tropfor]])/1.e6; km2
      TROPBMASS = total(bmassburn[today[tropfor]])/1000000. ; Gg
      TROPCO = total(co[today[tropfor]])/1000000. ; Gg
      nexttemp17:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        goto, nextbor17
      endif      
       TEMPAREA = total(area[today[tempfor]])/1.e6;   km2
       TEMPBMASS = total(bmassburn[today[tempfor]])/1.e6;   Gg
       TEMPCO = total(co[today[tempfor]])/1.e6;   Gg
      ; BOREAL FORESTS
      nextbor17:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        goto, nextgrass17
      endif
      BORAREA = total(area[today[borfor]])/1.e6;   km2
      BORBMASS = total(bmassburn[today[borfor]])/1000000. ; Gg
      BORCO = total(co[today[borfor]])/1000000. ; Gg
    ; GRASSLANDS
      nextgrass17:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       GRASSAREA = 0.0
        goto, nextshrub17
      endif
      GRASSAREA = total(area[today[grass]])/1.e6;   km2
      GRASSBMASS = total(bmassburn[today[grass]])/1000000. ; Gg
      GRASSCO = total(co[today[grass]])/1000000. ; Gg
    ; SHRUB
      nextshrub17:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       SHRUBAREA = 0.0
        goto, nextcrop17
      endif
      SHRUBAREA = total(area[today[shrub]])/1.e6;   km2
      SHRUBBMASS = total(bmassburn[today[shrub]])/1000000. ; Gg
      SHRUBCO = total(co[today[shrub]])/1000000. ; Gg
      ; CROP
      nextcrop17:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         CROPAREA = 0.0
        goto, nextend17
      endif
       CROPAREA = total(area[today[crop]])/1.e6 ;   km2
       CROPBMASS = total(bmassburn[today[crop]])/1000000. ; Gg
       CROPCO = total(co[today[crop]])/1000000. ; Gg
    nextend17:
    skip37:  

printf, 1, format = form,j+1,date,reg,TOTAREA,BORAREA,TEMPAREA,TROPAREA,SHRUBAREA,GRASSAREA,CROPAREA,TOTBMASS,BORBMASS,TEMPBMASS,TROPBMASS,SHRUBBMASS,GRASSBMASS,CROPBMASS 
printf, 2, format = form2,j+1,date,reg,TOTCO,BORCO,TEMPCO,TROPCO,SHRUBCO,GRASSCO,CROPCO

TOTCO = 0.0
TROPCO = 0.0
TEMPCO = 0.0
BORCO = 0.0
GRASSCO = 0.0
SHRUBCO = 0.0
CROPCO = 0.0

TROPAREA = 0.0
TEMPAREA = 0.0
BORAREA = 0.0
GRASSAREA = 0.0
SHRUBAREA = 0.0
CROPAREA = 0.0
TOTAREA = 0.0

TOTBMASS = 0.0
TROPBMASS = 0.0
TEMPBMASS = 0.0
BORBMASS = 0.0
GRASSBMASS = 0.0
SHRUBMASS = 0.0
CROPBMASS = 0.0



  
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