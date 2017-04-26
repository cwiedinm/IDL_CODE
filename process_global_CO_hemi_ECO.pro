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

pro process_global_area_ECO
t0 = systime(1) ;Procedure start time in seconds
close, /all

openw, 1, 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\HEMI_CO_ECO_SUMMARIES.txt' 
Printf, 1, 'FILE,DATE,REGION,CO_BORFOR,CO_TEMPFOR,CO_TROPFOR,CO_SHRUB,CO_GRASS,CO_CROP'
form = '(I3,",",A16,",",A16,",",6(F25.10,","))'
;  printf, 1, format = form,j+1,date,reg,COborfor,COtempfor,COtropfor, COshrub, COgrass,COcrop

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

COin = 0.0
VOCin = 0.0
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
COtropfor = 0.0
COtempfor = 0.0
COborfor = 0.0
COshrub = 0.0
COgrass = 0.0
COcrop = 0.0


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
        COtropfor = 0.0
        goto, nexttemp1
      endif
      COtropfor = total(CO[tropfor])/1.e6; input is in kg/day --> ouput in Gg/day
      nexttemp1:
      tempfor = where(genveg eq 4)
      if tempfor[0] lt 0 then begin
        COtempfor = 0.0
        goto, nextbor1
      endif      
       COtempfor = total(CO[tempfor])/1.e6; input is in kg/day --> ouput in Gg/day
      ; BOREAL FORESTS
      nextbor1:
      borfor = where(genveg eq 5)
      if borfor[0] lt 0 then begin
        COborfor = 0.0
        goto, nextgrass1
      endif
      COborfor = total(CO[borfor])/1.e6; input is in kg/day --> ouput in Gg/day
    ; GRASSLANDS
      nextgrass1:
      grass = where(genveg eq 1)
      if grass[0] lt 0 then begin
        COgrass = 0.0
        goto, nextshrub1
      endif
      COgrass = total(CO[grass])/1.e6; input is in kg/day --> ouput in Gg/day
    ; SHRUB
      nextshrub1:
      shrub = where(genveg eq 2)
      if shrub[0] lt 0 then begin
        COshrub = 0.0
        goto, nextcrop1
      endif
      COshrub = total(CO[shrub])/1.e6; input is in kg/day --> ouput in Gg/day
      ; CROP
      nextcrop1:
      crop = where(genveg eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        COcrop = 0.0
        goto, nextend1
      endif
       COcrop = total(CO[crop])/1.e6 ; input is in kg/day --> ouput in Gg/day
    nextend1:
    skip20:  
;Printf, 1, 'DATE,REGION,CO_BORFOR,CO_TEMPFOR_CO_TROPFOR_CO_SHRUB_CO_GRASS,CO_CROP'
;form = '(I3,",",A16,",",6(F25.10,","))'

  printf, 1, format = form,j+1,date,reg,COborfor,COtempfor,COtropfor, COshrub, COgrass,COcrop

; Northern Hemisphere Daily Totals   
;printf, 1, 'Northern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'NH'
  today = where(lati gt 0.)
  if today[0] lt 0 then begin
    goto, skip22
   endif  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        COtropfor = 0.0
        goto, nexttemp2
      endif
      COtropfor = total(CO[today[tropfor]])/1.e6; input is in kg/day --> ouput in Gg/day
      nexttemp2:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        COtempfor = 0.0
        goto, nextbor2
      endif      
       COtempfor = total(CO[today[tempfor]])/1.e6; input is in kg/day --> ouput in Gg/day
      ; BOREAL FORESTS
      nextbor2:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        COborfor = 0.0
        goto, nextgrass2
      endif
      COborfor = total(CO[today[borfor]])/1.e6; input is in kg/day --> ouput in Gg/day
    ; GRASSLANDS
      nextgrass2:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
       COgrass = 0.0
        goto, nextshrub2
      endif
      COGrass = total(CO[today[grass]])/1.e6; input is in kg/day --> ouput in Gg/day
    ; SHRUB
      nextshrub2:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
       COshrub = 0.0
        goto, nextcrop2
      endif
      COshrub = total(CO[today[shrub]])/1.e6; input is in kg/day --> ouput in Gg/day
      ; CROP
      nextcrop2:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
         COcrop = 0.0
        goto, nextend2
      endif
       COcrop = total(CO[today[crop]])/1.e6 ; input is in kg/day --> ouput in Gg/day
    nextend2:
     skip22:  
;Printf, 1, 'DATE,REGION,CO_BORFOR,CO_TEMPFOR_CO_TROPFOR_CO_SHRUB_CO_GRASS,CO_CROP'
;form = '(I3,",",A16,",",6(F25.10,","))'

  printf, 1, format = form,j+1,date,reg,COborfor,COtempfor,COtropfor, COshrub, COgrass,COcrop
; Southern Hemisphere Daily Totals   
;printf, 1, 'Southern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'SH'
  today = where(lati lt 0.)
 if today[0] lt 0 then begin
     goto, skip23
  endif  
  
; Calculate the area burned and the biomass burned by Vegetation Type
    ; TROPICAL FORESTS
      tropfor = where(genveg[today] eq 3)
      if tropfor[0] lt 0 then begin
        TROPAREA = 0.0
        TROPBMASS = 0.0
        COtropfor = 0.0
        goto, nexttemp3
      endif
      COtropfor = total(CO[today[tropfor]])/1.e6; input is in kg/day --> ouput in Gg/day
      nexttemp3:
      tempfor = where(genveg[today] eq 4)
      if tempfor[0] lt 0 then begin
        TEMPAREA = 0.0
        TEMPBMASS = 0.0
        COtempfor = 0.0
        goto, nextbor3
      endif      
       COtempfor = total(CO[today[tempfor]])/1.e6; input is in kg/day --> ouput in Gg/day
      ; BOREAL FORESTS
      nextbor3:
      borfor = where(genveg[today] eq 5)
      if borfor[0] lt 0 then begin
        BORAREA = 0.0
        BORBMASS = 0.0
        COborfor = 0.0
        goto, nextgrass3
      endif
      COborfor = total(CO[today[borfor]])/1.e6; input is in kg/day --> ouput in Gg/day
    ; GRASSLANDS
      nextgrass3:
      grass = where(genveg[today] eq 1)
      if grass[0] lt 0 then begin
        GRASSAREA = 0.0
        GRASSBMASS = 0.0
        COgrasfor = 0.0
        goto, nextshrub3
      endif
      COGrass = total(CO[today[grass]])/1.e6; input is in kg/day --> ouput in Gg/day
    ; SHRUB
      nextshrub3:
      shrub = where(genveg[today] eq 2)
      if shrub[0] lt 0 then begin
        SHRUBAREA = 0.0
        SHRUBBMASS = 0.0
        COshrubfor = 0.0
        goto, nextcrop3
      endif
      COshrub = total(CO[today[shrub]])/1.e6; input is in kg/day --> ouput in Gg/day
      ; CROP
      nextcrop3:
      crop = where(genveg[today] eq 9)
      if crop[0] lt 0 then begin
        CROPAREA = 0.0
        CROPBMASS = 0.0
        COcropfor = 0.0
        goto, nextend3
      endif
       COcrop = total(CO[today[crop]])/1.e6 ; input is in kg/day --> ouput in Gg/day
    nextend3:
     skip23:  
;Printf, 1, 'DATE,REGION,CO_BORFOR,CO_TEMPFOR_CO_TROPFOR_CO_SHRUB_CO_GRASS,CO_CROP'
;form = '(I3,",",A16,",",6(F25.10,","))'

  printf, 1, format = form,j+1,date,reg,COborfor,COtempfor,COtropfor, COshrub, COgrass,COcrop

  
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