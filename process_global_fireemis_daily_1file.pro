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
; OCTOBER 13, 2010
;   - edited to process only 1 file 
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

pro process_global_fireemis_daily_1file
t0 = systime(1) ;Procedure start time in seconds
close, /all
;    INFILE = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2008_09082010.TXT'
      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_JUN-DEC2010_04042011.txt'
;      infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2010\GLOB_2006_GLOBCOVER_10112010.txt'
      output1 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_GLOBAL.txt'
      output2 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_NH.txt'
      output3 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_SH.txt'
      output4 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_CONUS.txt'
      output5 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_WESTUS.txt'
      output6 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_EASTUS.txt'
      output7 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_CANAK.txt'
      output8 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_MXCA.txt'
      output9 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_SOUTHAM.txt'
      output10 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_AFRICA.txt'
      output11 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_EUROPE.txt'
      output12= 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_AUSTRALIA.txt'
      output13 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_SEASIA.txt'
      output14 = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\PROCESS\2010\DAILY_FIREEMIS_GLOB_JUN-DEC2010_04052011_ASIA.txt'
  
openw, 1, output1
openw, 2, output2
openw, 3, output3
openw, 4, output4
openw, 5, output5
openw, 6, output6
openw, 7, output7
openw, 8, output8
openw, 9, output9
openw, 10, output10
openw, 11, output11
openw, 12, output12
openw, 13, output13
openw, 14, output14

printf, 1, 'Daily GLOBAL Emissions from '+infile

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
bmassburn = fltarr(nfires)
 TOTTROP = fltarr(nfires)
 TOTTEMP = fltarr(nfires)
 TOTBOR = fltarr(nfires)
 TOTSHRUB = fltarr(nfires)
 TOTCROP = fltarr(nfires)
 TOTGRAS = fltarr(nfires)

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
; Get information to calculate the biomass burned per generic veg type, added 10/13/2010
  area[k] = data1[10]
  bmass[k] = data1[11]
  bmassburn[k]=area[k]*bmass[k] ; kg biomass burned
   if genveg[k] eq 3 then TOTTROP[k] = bmassburn[k]
   if genveg[k] eq 4 then TOTTEMP[k] = bmassburn[k]
   if genveg[k] eq 5 then TOTBOR[k] = bmassburn[k]
   if genveg[k] eq 2 then TOTSHRUB[k] = bmassburn[k]
   if genveg[k] eq 9 then TOTCROP[k] = bmassburn[k]
   if genveg[k] eq 1 then TOTGRAS[k] = bmassburn[k]

endfor
close,ilun
free_lun,ilun


print, 'finished reading in input file and assigning arrays'

form = '(I4,",",21(F25.10,","))'

ndays = max(day)   
count = ndays-1

; Global Daily Totals   
printf, 1, 'GLOBAL TOTALS (Gg Species or Mg Bmass)'
Printf, 1, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'

for i = 0,count do begin
  today = where(jday eq i)
  if today[0] lt 0 then goto, skip20
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
  TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 1, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip20:
endfor


; Northern Hemisphere Daily Totals   
printf, 2, 'Northern Hemisphere TOTALS (Gg Species or Mg Bmass)'
Printf, 2, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND lati gt 0.)
  if today[0] lt 0 then goto, skip21
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 2, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip21:
endfor
;Printf, 1, ','

; Southern Hemisphere Daily Totals   
printf, 3, 'Southern Hemisphere TOTALS (Gg Species or Mg Bmass)'
Printf, 3, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND lati lt 0.)
  if today[0] lt 0 then goto, skip22
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 3, format = form,  i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip22:
endfor
;Printf, 1, ','


; CONTINENTAL US
Printf, 4, 'CONTINENTAL US (Gg Species or Mg Bmass)'
Printf, 4, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 26. and lati lt 50. and longi gt -125. and longi lt -67.))
  if today[0] lt 0 then goto, skip1
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 4, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip1:
endfor
;Printf, 14, ','

; WESTERN U.S. 
Printf, 5, 'Western US (Gg Species or Mg Bmass)'
Printf, 5, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 24. and lati lt 49. and longi gt -124. and longi lt -100.))
  if today[0] lt 0 then goto, skip2
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 5, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip2:
endfor
;Printf, 1, ','

; EASTERN U.S. 
Printf, 6, 'Eastern US (Gg Species or Mg Bmass)'
Printf, 6, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 24. and lati lt 49. and longi gt -100. and longi lt -60.))
  if today[0] lt 0 then goto, skip3
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 6, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip3:
endfor
;Printf, 1, ','


; CANADA/AK    
Printf, 7, 'Canada/Alaska (Gg Species or Mg Bmass)'
Printf, 7, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati ge 50. and lati lt 70. and longi gt -170. and longi lt -55.))
  if today[0] lt 0 then goto, skip4
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 7, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin, PM10in
  skip4:
endfor
;Printf, 7, ','


; Mexico and Central America 
Printf, 8, 'Mexico/Central America (Gg Species or Mg Bmass)'
Printf, 8, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 10. and lati lt 28. and longi gt -120. and longi lt -65.))
  if today[0] lt 0 then goto, skip5
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 8, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip5:
endfor
;Printf, 1, ','


; SOUTH AMERICA    
Printf, 9, 'South America (Gg Species or Mg Bmass)'
Printf, 9,'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt -56. and lati lt 12. and longi gt -83. and longi lt -34.))
 if today[0] lt 0 then goto, skip6
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 9, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip6:
endfor
;Printf, 1, ','

; AFRICA 
Printf, 10, 'Africa (Gg Species or Mg Bmass)'
Printf, 10, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt -36. and lati lt 15. and longi gt -19. and longi lt 52.))
 if today[0] lt 0 then goto, skip7
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3  
  printf, 10, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  
  skip7:
endfor
;Printf, 10, ','

; EUROPE 
Printf, 11, 'Europe (Gg Species or Mg Bmass)'
Printf, 11, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 35. and lati lt 90. and longi gt -10. and longi lt 35.))
 if today[0] lt 0 then goto, skip8
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 11, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip8:
endfor
;Printf, 1, ','


; AUSTRALIA
Printf, 12, 'AUSTRALIA (Gg Species or Mg Bmass)'
Printf, 12, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt -50. and lati lt -11. and longi gt 112. and longi lt 155.))
  if today[0] lt 0 then goto, skip9
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 12, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip9:
endfor
;Printf, 1, ','


; SE ASIA
Printf, 13, 'SE ASIA and INDIA (Gg Species or Mg Bmass)'
Printf, 13, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt -10. and lati lt 32. and longi gt 68. and longi lt 150.))
  if today[0] lt 0 then goto, skip10
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 13, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip10:
endfor
;Printf, 1, ','

; ASIA
Printf, 14, 'ASIA (RUSSIA and CHINA) (Gg Species or Mg Bmass)'
Printf, 14, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10,TOTTROP,TOTTEMP,TOTBOR,TOTSHRUB,TOTCROP,TOTGRAS'
for i = 0,count do begin
  today = where(jday eq i AND (lati gt 32. and lati lt 80. and longi gt 68. and longi lt 180.))
  if today[0] lt 0 then goto, skip11
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
    TOTTROPin = total(TOTTROP[today])/1.e3
  TOTTEMPin = total(TOTTEMP[today])/1.e3
  TOTBORin = total(TOTBOR[today])/1.e3
  TOTSHRUBin = total(TOTSHRUB[today])/1.e3
  TOTCROPin = total(TOTCROP[today])/1.e3
  TOTGRASin = total(TOTGRAS[today]) /1.e3 
  printf, 14, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin,PM10in,TOTTROPin,TOTTEMPin,TOTBORin,TOTSHRUBin,TOTCROPin,TOTGRASin
  skip11:
endfor
;Printf, 1, ','

close, /all

print, 'Closing ', infile


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