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
; NOVEMBER 15, 2012
; - Edited to clip a region of fires and output to a file... 
;
;DECEMBER 10, 2012
;- edited to clip to CO only
;
;April 2013: 
;- Edited to clip only 2008 for Deeter's proposal 
;
;June 04, 2013
;- Edited to clip a file for Jenny Fisher that only exports the daily CO2 emissions and genveg type
;
;OCTOBER 02, 2013
;- Edited to provide Zitely the daily emissions for Mexico for March - July for each year
;
;JULY 07, 2014
;- editting to clip newly FINNv1.5 files to July and western US
;
;
;NOVEMBER 21, 2014
;- editting to clip FINNv1.5 files to Indonesia
;
;NOVEMBER 26, 3014
;- editing to clip to new region
;- running only 2013 and 2014 (The new FINNv1.5a output created 11/25-26/2014
;
;JANUARY 26, 2014
;- Edited to ouput 2007 files for Colleen Reed
;
;JULY 15, 2015
;- edited to output 2008 files for Colleen Reid
;
;
;FEBRUARY 27, 2016
;- edited to output 2015 files for James Laing (UW with Jaffe)
;
;FEBRUARY 27, 2016
;- Edited to output 2012 FINNv1.5 files for Lois Change (EMORY) 
;
;APRIL 01, 2016
;- Clipped 2015 FINNv.15 file for 2015 created January 2016 for Paola
;
;SEPTEMBER 19, 2016
;- edited to output all for Paola for paper review
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

pro clip_finnv15_GLOBAL_TOTALS_AAAR

t0 = systime(1) ;Procedure start time in seconds
close, /all



for j = 0,13 do begin 
print, 'J = ', j

  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2002_06202014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2002_09192016.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2003_06242014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2003_09192016.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2004_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2004_09192016.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2005_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2005_09192016.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2006_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2006_09192016.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2007_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2007_09192016.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2008_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2008_09192016.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2009_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2009_09192016.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2010_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2010_09192016.txt'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2011_06272014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2011_09192016.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2012_06282014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2012_09192016.txt'
  endif
  
  ; 09/19/2016: updated 2013, 2014 files to be used here. 
  
   if j eq 11 then begin ; 2013
    year = 2013
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2013_06202014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2013_09192016.txt'
  endif
   if j eq 12 then begin ; 2014
    year = 2014
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\NOV_2015\FINNv1.5_2014_12012015.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2014_09192016.txt'
  endif
  if j eq 13 then begin ; 2015
    year = 2015
    infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JAN2016\FINNv1.5_2015_01222016.txt'
    output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\PAOLA\FINNv15_PAOLA_2015_09192016.txt'
  endif
    

; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; Emissions are in kg/km2/day
print, 'YEar = ', year
print,'Reading: ',infile
print, 'Output file: ', output1

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
nmoc = fltarr(nfires)
area = fltarr(nfires)
lct = intarr(nfires)
bmass = fltarr(nfires)
openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)


;NEW for FINNv1.5 
;  0    1   2   3    4   5       6      7         8      9    10   11    12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'
for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
 ; jday[k] = day[k]
 ; genveg[k] = data1[5]
 ; lct[k] = data1[4]
 ; co2[k] = data1[12]
 ; co[k] = data1[13]
  oc[k] = data1[25]
  bc[k] = data1[26]
 ; nox[k] = data1[16]
 ; nh3[k] = data1[19]
 ; so2[k] = data1[20]
  pm25[k] = data1[23]
;  tpm[k] = data1[24]
 ; no[k] = data1[17]
 ; NO2[k] = data1[18]
;  nmhc[k] = data1[21]
 ; voc[k] =  data1[22]
 ; ch4[k] = data1[14]
 ; pm10[k] = data1[28]
 ; area[k] = data1[10]
 ; bmass[k] = data1[11]
  
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
numfires = n_elements(day)

; Chose area of totals
; SE ASIA DOMAIN FOR PAOLA
; EDITED 09/19/2016
latmin = -11.50
latmax = 15.3
lonmin = 93.
lonmax = 137.
daymin = 1 
daymax = 365 


openw, 1, output1
printf, 1, 'month,PM2.5, OC, BC'
form = '(I6,",",D25.10,",",D25.10,",",D25.10)'


; Do a loop over months
yearnum = year
; Set up months/days
monthset = intarr(13)

if yearnum ne 2008 or yearnum ne 2004 or yearnum ne 2012 then begin
  monthset[0] = 1
  monthset[1] = 32
  monthset[2] = 60
  monthset[3] = 91
  monthset[4] = 121
  monthset[5] = 152
  monthset[6] = 182
  monthset[7] = 213
  monthset[8] = 244
  monthset[9] = 274
  monthset[10] = 305
  monthset[11] = 335
  monthset[12] = 366
endif
if yearnum eq 2008 or yearnum eq 2004 or yearnum eq 2012 then begin
  monthset[0] = 1
  monthset[1] = 32
  monthset[2] = 61
  monthset[3] = 92
  monthset[4] = 122
  monthset[5] = 153
  monthset[6] = 183
  monthset[7] = 214
  monthset[8] = 245
  monthset[9] = 275
  monthset[10] = 306
  monthset[11] = 336
  monthset[12] = 367
endif

;USE THS CODE TO SUM OVER EACH MONTH
for l = 0,11 do begin ; sum over months for each year
  PM25tot = 0.0
  OCTot = 0.0
  BCtot = 0.0
  today = where(day ge monthset[l] and day lt monthset[l+1] and lati gt latmin and lati lt latmax and longi lt lonmax and longi gt lonmin)
  PM25tot = total(PM25[today])
  OCtot =  total(OC[today])
  BCtot =  total(BC[today])
  printf, 1, format = form, l+1,PM25tot, OCtot, BCtot
endfor ; end l loop


; USE THIS CODE TO PRINT OUT ALL FIRES IN THE AREA/TIME SPECIFIED
;for i = 0,numfires-1 do begin
;  if (lati[i] lt latmax and lati[i] gt latmin and longi[i] gt lonmin and longi[i] lt lonmax and day[i] gt daymin and day[i] lt daymax) then begin
;    ; 'day,vegtype, latitude, longitude, area, CO,NOx,NMOC,NH3,SO2,PM2.5,PM10, OC, BC'
;    printf, 1, format = form, day[i], genveg[i],lati[i], longi[i], area[i], co[i],nox[i],voc[i],nh3[i],so2[i],pm25[i],pm10[i],oc[i],bc[i]
;  endif
;endfor

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