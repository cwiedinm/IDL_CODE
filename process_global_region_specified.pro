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
; 
; JULY 05, 2011
;   - Edited to output only region that Sara T. needs
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

pro process_global_REGION_SPECIFIED
t0 = systime(1) ;Procedure start time in seconds
close, /all

openw, 1, 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE2011\PROCESS\AREA_TOTALS.txt' 
Printf, 1, 'REGION,AREABUREND_BIOMASSBURN'
form = '(A16,",",2(F25.10,","))'
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

  totarea = total(area)
  totbmass = total(bmass)
  printf, 1, format = form,reg,totarea,totbmass

;Printf, 1, 'DATE,REGION,AREABUREND_BIOMASSBURN'
;form = '(,A16,",",2(F25.10,","))'

; Northern Hemisphere Daily Totals   
;printf, 1, 'Northern Hemisphere TOTALS (Gg Species, km2 AREA, Gg BMASS BURNED)'
reg = 'NH'
nhemi= where(lati gt 0.0)
  totarea = total(area[nhemi])
  totbmass = total(bmass[nhemi])
  printf, 1, format = form,reg,totarea,totbmass


reg = 'SH'
  shemi = where(lati lt 0.)
  totarea = total(area[shemi])
  totbmass = total(bmass[shemi])
 printf, 1, format = form,reg,totarea,totbmass


; Northern Hemisphere South America
;Printf, 1, 'NORTHERN HEMISPHERE SOUTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 0-12, Long: -95 - -45'
reg = 'NHSA'
  today = where(lati gt 0. and lati lt 12. and longi gt -95. and longi lt -45.)
  if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip24
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip24:  
    printf, 1, format = form,reg,totarea,totbmass

; Southern Hemisphere South America 
;Printf, 1, 'Southern Hemisphere South America (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -60 - 0, Long: -90 - -30'
 reg = 'SHSA'
  today = where(lati gt -60. and lati lt 0. and longi gt -90. and longi lt -30.)
 if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip25
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip25:  
    printf, 1, format = form,reg,totarea,totbmass
    
; Southern Hemisphere Africa 
;Printf,1, 'Southern Hemisphere Africa (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -40 - 0; Long: 5 - 55'
reg = 'SHAF'
  today = where(lati gt -40. and lati lt 0. and longi gt 5. and longi lt 55.)
 if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip26
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip26:  
    printf, 1, format = form,reg,totarea,totbmass

; Northern Hemisphere Africa    
;Printf, 1, 'Northern Hemisphere Africa (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 0-23; Long: -20 - 60'
reg = 'NHAF'
  today = where(lati ge 0. and lati lt 23. and longi gt -20. and longi lt 60.)
 if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip27
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip27:  
    printf, 1, format = form,reg,totarea,totbmass
    
; Northern Africa/Middle East 
;Printf, 1, 'Northern Africa/Middle East (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 23-35; Long: -20 - 60'
reg = 'NAFME'
  today = where(lati gt 23. and lati lt 35. and longi gt -20. and longi lt 60.)
 if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip28
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip28:  
    printf, 1, format = form,reg,totarea,totbmass
  
; EUROPE   
;Printf, 1, 'EUROPE (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 35-75; Long: -12 - 30'
reg = 'EURO'
  today = where(lati gt 35. and lati lt 75. and longi gt -12. and longi lt 30.)
  if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip29
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip29:  
    printf, 1, format = form,reg,totarea,totbmass
  
  
; AUSTRALIA 
;Printf, 1, 'AUSTRALIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -50 - -10; Long: 110 - 180'
reg = 'AUSTR'
  today = where(lati gt -50. and lati lt -10. and longi gt 110. and longi lt 180.)
  if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip30
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip30:  
    printf, 1, format = form,reg,totarea,totbmass
  

; Equatorial ASIA
;Printf, 1, 'Equatorial ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: -10 - 5; Long: 90 - 165'
reg = 'EQAS'
  today = where(lati gt -10. and lati lt 5. and longi gt 90. and longi lt 165.)
  if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip31
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip31:  
    printf, 1, format = form,reg,totarea,totbmass
    
; SOUTHEAST ASIA
;Printf, 1, 'SOUTHEAST ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 5 - 35; Long: 60 - 145'
reg = 'SEAS'
  today = where(lati gt 5. and lati lt 35. and longi gt 60. and longi lt 145.)
   if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip32
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip32:  
    printf, 1, format = form,reg,totarea,totbmass
    
  
; CENTRAL ASIA
;Printf, 1, 'CENTRAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 35-50; Long 30 - 155'
reg = 'CENAS'
  today = where(lati gt 35. and lati lt 50. and longi gt 30. and longi lt 155.)
   if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip33
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip33:  
    printf, 1, format = form,reg,totarea,totbmass
  
; BOREAL ASIA
;Printf,1, ' BOREAL ASIA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 50-80; Long 30-180'
reg = 'BORAS'
  today = where(lati gt 50. and lati lt 80. and longi gt 30. and longi lt 180.)
    if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip34
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip34:  
    printf, 1, format = form,reg,totarea,totbmass
  
; BOREAL NORTH AMERICA
;Printf, 1, ' BOREAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 49 - 79; Long -169 - -44'
reg = 'BORNA'
  today = where(lati gt 49. and lati lt 79. and longi gt -169. and longi lt -44.)
   if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip35
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip35:  
    printf, 1, format = form,reg,totarea,totbmass
  
  
; TEMPERATE NORTH AMERICA
;Printf, 1, 'TEMPERATE NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 27-49; Long -130 - -60'
reg = 'TEMNA'
  today = where(lati gt 27. and lati lt 49. and longi gt -130. and longi lt -60.)
   if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip36
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip36:  
    printf, 1, format = form,reg,totarea,totbmass
  
  
; CENTRAL NORTH AMERICA
;Printf, 1, 'CENTRAL NORTH AMERICA (Gg Species, km2 AREA, Gg BMASS BURNED); Lat: 12 - 27; Long -120 - -60'
reg = 'CENA'
  today = where(lati gt 12. and lati lt 27. and longi gt -120. and longi lt -60.)
   if today[0] lt 0 then begin
    totarea = 0.0
    totbmass = 0.0
    goto, skip37
  endif
    totarea = total(area[today])
    totbmass = total(bmass[today])
    skip37:  
    printf, 1, format = form,reg,totarea,totbmass
  
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