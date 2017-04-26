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
;   - Edited to do 2005 through 2012
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
; - edited to do 2005-2014
; - edited to output only lat/long, day, genveg, bmass burned, Hg emission
; 
; June 08, 2015
; - edited to output daily CO2 emissions (global) for Andy Jacobson (NOAA)
; 
; June 18, 2015
; - edited to output daily CO for Amazon for Merrit's meeting
; 
; APRIL 01, 2016
; - Edited to clip the CO and PM from the fires in and near Korea
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

pro clip_finnv15_Korea_dailytotals

t0 = systime(1) ;Procedure start time in seconds
close, /all

for j = 0,13 do begin ; do 2005-2015
print, 'J = ', j

outpath = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\APRIL2016\KORUS\'

  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2002_06202014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2002_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2002, PM2.5SKorea2002, CONKorea2002, PM2.5NKorea2002, COSiberia2002, PM2.5Siberia2002, COEChina2002, PM25EChina2002'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2003_06242014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2003_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2003, PM2.5SKorea2003, CONKorea2003, PM2.5NKorea2003, COSiberia2003, PM2.5Siberia2003, COEChina2003, PM25EChina2003'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2004_06252014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2004_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2004, PM2.5SKorea2004, CONKorea2004, PM2.5NKorea2004, COSiberia2004, PM2.5Siberia2004, COEChina2004, PM25EChina2004'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2005_06252014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2005_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2005, PM2.5SKorea2005, CONKorea2005, PM2.5NKorea2005, COSiberia2005, PM2.5Siberia2005, COEChina2005, PM25EChina2005'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2006_06262014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2006_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2006, PM2.5SKorea2006, CONKorea2006, PM2.5NKorea2006, COSiberia2006, PM2.5Siberia2006, COEChina2006, PM25EChina2006'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2007_06252014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2007_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2007, PM2.5SKorea2007, CONKorea2007, PM2.5NKorea2007, COSiberia2007, PM2.5Siberia2007, COEChina2007, PM25EChina2007'
      form = '(I6,8(",",D25.10))'
   endif
  if j eq 6 then begin ; 2008
      year = 2008
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2008_06252014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2008_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2008, PM2.5SKorea2008, CONKorea2008, PM2.5NKorea2008, COSiberia2008, PM2.5Siberia2008, COEChina2008, PM25EChina2008'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2009_06252014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2009_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2009, PM2.5SKorea2009, CONKorea2009, PM2.5NKorea2009, COSiberia2009, PM2.5Siberia2009, COEChina2009, PM25EChina2009'
      form = '(I6,8(",",D25.10))'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2010_06262014.txt'
      output1 = outpath+'FINNv15_COPM25_KOREA_2010_dailytotals_04012016.txt'
      openw, 1, output1
      printf, 1, 'day, COSKorea2010, PM2.5SKorea2010, CONKorea2010, PM2.5NKorea2010, COSiberia2010, PM2.5Siberia2010, COEChina2010, PM25EChina2010'
      form = '(I6,8(",",D25.10))'
  endif
 if j eq 9 then begin ; NEW 2011
    year = 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2011_06272014.txt'
       output1 = outpath+'FINNv15_COPM25_KOREA_2011_dailytotals_04012016.txt'
       openw, 1, output1
       printf, 1, 'day, COSKorea2011, PM2.5SKorea2011, CONKorea2011, PM2.5NKorea2011, COSiberia2011, PM2.5Siberia2011, COEChina2011, PM25EChina2011'
       form = '(I6,8(",",D25.10))'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2012_06282014.txt'
       output1 = outpath+'FINNv15_COPM25_KOREA_2012_dailytotals_04012016.txt'
       openw, 1, output1
       printf, 1, 'day, COSKorea2012, PM2.5SKorea2012, CONKorea2012, PM2.5NKorea2012, COSiberia2012, PM2.5Siberia2012, COEChina2012, PM25EChina2012'
       form = '(I6,8(",",D25.10))'
  endif
   if j eq 11 then begin ; 2013
    year = 2013
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2013_06202014.txt'
       output1 = outpath+'FINNv15_COPM25_KOREA_2013_dailytotals_04012016.txt'
       openw, 1, output1
       printf, 1, 'day, COSKorea2013, PM2.5SKorea2013, CONKorea2013, PM2.5NKorea2013, COSiberia2013, PM2.5Siberia2013, COEChina2013, PM25EChina2013'
       form = '(I6,8(",",D25.10))'
  endif
  if j eq 12 then begin ; 2014
    year = 2014
       infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\FEB_2015\GLOBAL_FINNv15_2014_02202015.txt'
       output1 = outpath+'FINNv15_COPM25_KOREA_2014_dailytotals_04012016.txt'
       openw, 1, output1
       printf, 1, 'day, COSKorea2014, PM2.5SKorea2014, CONKorea2014, PM2.5NKorea2014, COSiberia2014, PM2.5Siberia2014, COEChina2014, PM25EChina2014'
       form = '(I6,8(",",D25.10))'
  endif
  if j eq 13 then begin ; 2015
    year = 2014
    infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JAN2016\FINNv1.5_2015_01222016.txt'
    output1 = outpath+'FINNv15_COPM25_KOREA_2015_dailytotals_04012016.txt'
    openw, 1, output1
    printf, 1, 'day, COSKorea2015, PM2.5SKorea2015, CONKorea2015, PM2.5NKorea2015, COSiberia2015, PM2.5Siberia2015, COEChina2015, PM25EChina2015'
    form = '(I6,8(",",D25.10))'
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
bburned = fltarr(nfires)
hg = fltarr(nfires)
tree = fltarr(nfires)
herb = fltarr(nfires)
bare = fltarr(nfires)

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars
  data1 = fltarr(nvars)


;NEW for FINNv1.5 
;  0    1   2   3    4   5       6      7         8      9    10   11    12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'
;longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
  genveg[k] = data1[5]
  lct[k] = data1[4]
;  co2[k] = data1[12]
  co[k] = data1[13]
;  oc[k] = data1[25]
;  bc[k] = data1[26]
;  nox[k] = data1[16] ; REALLY NO (12/11/2014)
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
;  area[k] = data1[10]
;  bmass[k] = data1[11] 
;  tree[k] = data1[07]
;  herb[k] = data1[08]
;  bare[k] = data1[09]
 
  
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
numfires = n_elements(day)


daymin = 1 ;
daymax = 365 ;
if year eq 2012 or year eq 2008 or year eq 2004 then daymax = 366


; Chose area of totals 
;AREA1: SOUTH KOREA
latmin1 = 33.9
latmax1 = 38.4
lonmin1 = 124.5
lonmax1 = 129.9

;AREA2: NORTH KOREA
latmin2 = 38.4
latmax2 = 43.2
lonmin2 = 124.5
lonmax2 = 131.1

;AREA3: North China/Siberia
latmin3 = 43.2
latmax3 = 80.0
lonmin3 = 96.0
lonmax3 = 140.5

;AREA4: East China
latmin4 = 20.5
latmax4 = 43.2
lonmin4 = 96.0
lonmax4 = 124.5

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

;bburned = 0.0
;hg = 0.0

for i = 0,daymax-1 do begin
   today1 = where(lati lt latmax1 and lati gt latmin1 and longi gt lonmin1 and longi lt lonmax1 and day eq i and genveg gt 0)
   if today1[0] eq -1 then begin
    cototal1 = 0.0
    pmtotal1 = 0.0
    goto, nextone1
   endif
   cototal1= total(co(today1))
   pmtotal1 = total(pm25(today1))

   nextone1: 
   today2 = where(lati lt latmax2 and lati gt latmin2 and longi gt lonmin2 and longi lt lonmax2 and day eq i and genveg gt 0)
   if today2[0] eq -1 then begin
     cototal2 = 0.0
     pmtotal2 = 0.0
     goto, nextone2
   endif   
   cototal2= total(co(today2))
   pmtotal2 = total(pm25(today2))

   nextone2:
   today3 = where(lati lt latmax3 and lati gt latmin3 and longi gt lonmin3 and longi lt lonmax3 and day eq i and genveg gt 0)
   if today3[0] eq -1 then begin
     cototal3 = 0.0
     pmtotal3 = 0.0
     goto, nextone3
   endif
   cototal3= total(co(today3))
   pmtotal3 = total(pm25(today3))

   nextone3: 
   today4 = where(lati lt latmax4 and lati gt latmin4 and longi gt lonmin4 and longi lt lonmax4 and day eq i and genveg gt 0)
   if today4[0] eq -1 then begin
     cototal4 = 0.0
     pmtotal4 = 0.0
     goto, nextone4
   endif
   cototal4= total(co(today4))
   pmtotal4 = total(pm25(today4))
   
   nextone4: 
   printf, 1, format = form, i+1, cototal1, pmtotal1, cototal2, pmtotal2, cototal3, pmtotal3, cototal4, pmtotal4 
 
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