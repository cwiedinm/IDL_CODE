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
; DECEMBER 02, 2010
; - edited to output only the region that Helen Worton wants in Beijing 
; 
; JANUARY 20, 2011
; - edited to output only Siberia for Dan Jaffee
; 
; MAY 10, 2011
; - edited to pull out only CO for Pat Reddy
; 
; JULY 05, 2011
;   - Edited for Sarah T. 
;   
;   July 25, 2011
;   - edited to output daily fires from AFRICA
; 
;  April 02, 2012
;  - edited to output daily fires for CALIFORNIA
;  
;  July 17, 2012
;  - edited to output daily fires for CO and Western US
;  
;  August 29, 2012
;   - Edited to output fires for only a region (for fire vulnerability paper)
;   - only 2005 - 2011
;   - only region from 0 to 90N and either -50 to -180E or 80 to 180 E
; 
; SEPTEBMER 11, 2012
;   - Edited to include 2012 file (created yesterday) as well
;   - Edited to do 2002 through 2012
;   - Edited to output Russia region 
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

pro process_dailly_global_fireemis_RUSSIA
t0 = systime(1) ;Procedure start time in seconds
close, /all

for j = 0,16 do begin ; do all years
  close, /all

  if j eq 0 then begin ; 2005
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\JUNE2011\GLOB_2005_06212011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2005_09112012.txt'
  endif
  if j eq 1 then begin ; 2006
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\AUGUST2010\GLOB_2006_09032010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2006_09112012.txt'
  endif
  if j eq 2 then begin ; JAN-APR 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_JAN-APR2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_JAN-APR2007_09112012.txt'
  endif
  if j eq 3 then begin ; MAY-SEPT 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_MAY-SEPT2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_MAY-SEPT2007_09112012.txt'
  endif
  if j eq 4 then begin ; OCT-DEC 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_OCT-DEC2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_OCT-DEC2007_09112012.txt'
  endif
  if j eq 5 then begin ; JAN-APR 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_JAN-APR2008_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_JAN-APR2008_09112012.txt'
  endif
  if j eq 6 then begin ; MAY-SEPT 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MARCH2011\GLOB_MAY-SEPT2008_03252011_correctLCT.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_MAY-SEPT2008_09112012.txt'
  endif
  if j eq 7 then begin ; OCT-DEC 2008
      infile ='E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_OCT-DEC2008_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_OCT-DEC2008_09112012.txt'
  endif
  if j eq 8 then begin ; JAN-NOV 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_JAN-NOV2009_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_JAN-NOV2009_09112012.txt'
  endif
  if j eq 9 then begin ; DEC 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\SEPTEMBER2010\GLOB_DEC2009_09092010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_DEC2009_09112012.txt'
  endif
  if j eq 10 then begin ; JAN-JUN29 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MARCH2011\GLOB_JAN-JUN2010_04042011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_JAN-JUN2010_09112012.txt'
  endif
  if j eq 11 then begin ; JUN30-DEC 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MARCH2011\GLOB_JUN-DEC2010_04042011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_JUN-DEC2010_09112012.txt'
  endif
  if j eq 12 then begin ; NEW 2011 (03/2012)
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2011_09112012.txt'
  endif
if j eq 13 then begin ; 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2002_05102011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2002_09112012.txt'
  endif
  if j eq 14 then begin ; 2003
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2003_05102011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2003_09112012.txt'
  endif
  if j eq 15 then begin ; 2004
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2004_05122011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_FIREEMIS_RUSSIA_2004_09112012.txt'
  endif
  if j eq 16 then begin ; 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2012_09102012.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\RUSSIA\DAILY_RUSSIA_2012_09112012.txt'
  endif
    
openw, 1, output1


printf, 1, 'day, CO, PM2.5'
form = '(I4,",",D25.10,",",D25.10)'
  

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

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)


;  1    2   3   4    5   6       7      8         9       10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
;  genveg[k] = data1[5]
;  co2[k] = data1[12]
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
;  voc[k] =  data1[22]
;  ch4[k] = data1[14]
;  pm10[k] = data1[28]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)

; RUSSIA ONLY
latmin = 46.0
latmax = 76.0
longmin = 33.0
longmax = 180.0

for i = 0,count do begin
; 
  today = where(jday eq i AND (lati ge latmin and lati le latmax and longi ge longmin and longi le longmax))
  if today[0] lt 0 then begin
    COin = 0.0
    PM25in = 0.0
  endif
  if today[0] ge 0 then begin
    PM25in = total(PM25[today])
    COin = total(CO[today])
  endif

printf, 1, format = form, i, COin, PM25in
  skip20:
endfor


close, /all
print, 'Closing ', infile


endfor ; End of j loop over the different input files

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