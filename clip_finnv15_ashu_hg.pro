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
;DECEMBER 11, 2014
;- changed name from clip_finnv15_indo2 to clip_finnv15_rim
;- Edited to clip out only small region during RIM fire for AGU poster with Serena and SUsan
;- Edited only input/output for 2013
;- Changed to process MOZ4 file (not direct FINN output file)
;
;APRIL 22, 2015
;- renamed from clip_finnv15_rim.pro to clip_finnv15_TOMODA.pro
;- Edited to do 2011 - 2014
;- updated input and output file names
;- edited to do entire globe and all days of year
;- edited to output only CO, PM2.5, PM10
;- 
;
; MAY 01, 2015
; - renamed clip_finnv15_ASHU_HG.pro
; - changed output files
; - edited to do 2002-2014
; - edited to output only lat/long, day, genveg, bmass burned, Hg emission
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

pro clip_finnv15_ASHU_HG

t0 = systime(1) ;Procedure start time in seconds
close, /all



for j = 0,12 do begin ; do 2011-2014
print, 'J = ', j

  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2002_06202014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2002_05012015.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2003_06242014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2003_05012015.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2004_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2004_05012015.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2005_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2005_05012015.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2006_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2006_05012015.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2007_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2007_05012015.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2008_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2008_05012015.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2009_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2009_05012015.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2010_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2010_05012015.txt'
  endif
 if j eq 9 then begin ; NEW 2011
    year = 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2011_06272014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2011_05012015.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2012_06282014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg_2012_05012015.txt'
  endif
   if j eq 11 then begin ; 2013
    year = 2013
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2013_06202014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg__2013_05012015.txt'
  endif
     if j eq 12 then begin ; 2014
    year = 2014
       infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\FEB_2015\GLOBAL_FINNv15_2014_02202015.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\MAY_2015\ASHU_HG\FINNv15_Hg__2014_05012015.txt'
  endif
  
    
openw, 1, output1
printf, 1, 'day,genveg, latitude, longitude,biomassburned,Hg'
form = '(I6,",",I6,4(",",D25.10))'

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
;qlongi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
  genveg[k] = data1[5]
  lct[k] = data1[4]
  co2[k] = data1[12]
  co[k] = data1[13]
  oc[k] = data1[25]
  bc[k] = data1[26]
  nox[k] = data1[16] ; REALLY NO (12/11/2014)
  nh3[k] = data1[19]
  so2[k] = data1[20]
  pm25[k] = data1[23]
  tpm[k] = data1[24]
  no[k] = data1[17]
  NO2[k] = data1[18]
;  nmhc[k] = data1[21]
  voc[k] =  data1[22]
  ch4[k] = data1[14]
  pm10[k] = data1[28]
  area[k] = data1[10]
  bmass[k] = data1[11] 
  
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
; Edtied 12/11/2014 for Western US
latmin = -90.0
latmax = 90.0
lonmin = -180.
lonmax = 180.
daymin = 1 ;
daymax = 365 ; 
if year eq 2012 or year eq 2008 or year eq 2004 then daymax = 366

; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and svanna
;    2 = woody savanna
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
;    6 = temperate evergreen needleleaf forests (added 06/20/2014)
;    


; USE THIS CODE TO PRINT OUT ALL FIRES IN THE AREA/TIME SPECIFIED
for i = 0,numfires-1 do begin
  biomassburned = 0.0
  Hg = 0.0
  HGEF = 0.0
  if (lati[i] lt latmax and lati[i] gt latmin and longi[i] gt lonmin and longi[i] lt lonmax and day[i] ge daymin and day[i] le daymax and genveg[i] gt 0) then begin
     biomassburned = bmass[i]*area[i] ;kg/m2 * m2 = kg
     if genveg[i] eq 1 or genveg[i] eq 9 then HGEF = 274.0*1e-6
     if genveg[i] eq 2 then HGEF = 41.1*1e-6
     if genveg[i] eq 5 then HGEF = 315.0*1e-6
     if genveg[i] eq 3 or genveg[i] eq 4 or genveg[i] eq 6 then HGEF = 239.0*1e-6
     Hg = HGEF*biomassburned ; g Hg emitted
                              ;'day,genveg, latitude, longitude,biomassburned,Hg'
     printf, 1, format = form, day[i],genveg[i], lati[i], longi[i], biomassburned, Hg
  endif
endfor

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