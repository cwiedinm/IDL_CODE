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
;   
; SEPTEMBER 14, 2012
; - Started editing to have new emissions files
; - all years are in single files
; - 
; SEPTEMBER 19, 2012
; - Set up to run for BRIT (global daily CO2, CO) [pretty much just clipping the original files
; - only do 2007-2012
; 
; OCTOBER 03, 2012
; - set up to clip out only the CONUS
; - include a new file for the CONUS for 2012 (through SEPT.) 
; 
; OCTOBER 04, 2012
;   - set up to do annual global
;   
; OCTOBER 25, 2012
;   - getting boreal Forest BC for David Knapp     
;   
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

pro process_Boreal_global_TOTALS_fireemis_DK
t0 = systime(1) ;Procedure start time in seconds
close, /all

output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\global_Boreal_totals.txt'
openw, 1, output1
printf, 1, 'year, fires, borealfires, CO2, CO, SO2, NOX, NO, NO2, PM25, PM10, BC, OC, CH4, NH3'
form = '(I6,",",I20,",",I20,","12(",",D25.10))'

for j = 0,9 do begin ; do 2002-2011
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
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2012_09102012.txt'
     ; infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS_2012_10022012.txt'
     ; output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCTOBER2012\CONUS\DAILY__GLOB_CO2CO_2012_09192012.txt'
  endif
    

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
  genveg[k] = data1[5]
  co2[k] = data1[12]
  co[k] = data1[13]
  oc[k] = data1[25]
  bc[k] = data1[26]
  nox[k] = data1[16]
  nh3[k] = data1[19]
  so2[k] = data1[20]
  pm25[k] = data1[23]
;  tpm[k] = data1[24]
  no[k] = data1[17]
  NO2[k] = data1[18]
;  nmhc[k] = data1[21]
;  voc[k] =  data1[22]
  ch4[k] = data1[14]
  pm10[k] = data1[28]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)

; Set up arrays
CO2tot = 0.0
COtot = 0.0
NOxtot = 0.0 
NOtot = 0.0
NO2tot = 0.0
SO2tot = 0.0
PM25tot = 0.0
PM10tot = 0.0
BCtot = 0.0
OCtot = 0.0
CH4tot = 0.0
NH3tot = 0.0
count2 = 0L

for i = 0,nfires-1 do begin
  if day[i] gt count then goto, skip1
  if lati[i] lt 45. then goto, skip1 ; only Emissions gt 40 lat
  count2 = 1+count2
  CO2tot = CO2tot+CO2[i]
  COtot = COtot+CO[i]
  NOxtot = NOxtot +nox[i]
  NOtot = NOtot+no[i]
  NO2tot = NO2tot+no2[i]
  SO2tot = SO2tot+so2[i]
  PM25tot = PM25tot+pm25[i]
  PM10tot = PM10tot+pm10[i]
  BCtot = BCtot+bc[i]
  OCtot = OCtot+oc[i]
  CH4tot = CH4tot+ch4[i]
  NH3tot = NH3tot+nh3[i]
  skip1:
endfor

; ' CO2, CO, SO2, NOX, NO, NO2, PM25, PM10, BC, OC, CH4, NH3'
 printf, 1, format = form, year, nfires, count2, CO2tot, COtot, SO2tot, NOXtot, NOtot, NO2tot, PM25tot, PM10tot, BCtot, OCtot, CH4tot, NH3tot


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