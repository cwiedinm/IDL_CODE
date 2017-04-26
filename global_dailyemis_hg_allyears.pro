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
;DECEMBER 28, 2012
;- Edited to calculate the Hg Emissions from the output files for Dorothee
;- Using emission factors from the Hg paper with Hans
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

pro global_dailyemis_Hg_allyears
t0 = systime(1) ;Procedure start time in seconds
close, /all



for j = 0,10 do begin ; do 2002-2012
  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2002_05102011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2002.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2003_05102011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2003.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\GLOB_2004_05122011.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2004.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\JUNE2011\GLOB_2005_06212011.txt'
        output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2005.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2010\AUGUST2010\GLOB_2006_09032010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2006.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2007_09172012.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2007.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2008_09172012.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2008.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2009_09192012.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2009.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2010_09192012.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2010.txt'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2011.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\GLOBAL_JAN-NOV2012_11082012.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2012\HGemis\Hgemis_12282012_all2012.txt'
  endif
    
openw, 1, output1
printf, 1, 'day, latitude, Longitude, DM, AREA, CO2, CO, PM25, NOX, VOC, Hg'
form = '(I6,10(",",D25.10))'

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
factor = fltarr(nfires)
hg = fltarr(nfires)

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
  lct[k] = data1[4]
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
  voc[k] =  data1[22]
  ch4[k] = data1[14]
  pm10[k] = data1[28]
  area[k] = data1[10]
  bmass[k] = data1[11]
  factor[k] = data1[29]
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
;latmin = 36.0
;latmax = 41.0
;lonmin = -109.5
;lonmax = -101.0
daymin = 1
if (year eq 2004 or year eq 2008 or year eq 2012) then daymax = 366 else daymax = 365

;if (lati[i] gt latmin and lati[i] lt latmax and longi[i] lt lonmax and longi[i] gt lonmin) then begin 
;today = where(lati gt 0. and lati lt 12. and longi gt -95. and longi lt -45. and genveg eq 9;)
 
for i = 0,numfires-1 do begin
 if day[i] gt daymax then goto, skip1
 
; Calculate Hg emissions for each fire
; First, assign Hg Emission factors: 
  if genveg[i] eq 1 then hgef = 274.*1e-6 ; grasslands
  if genveg[i] eq 2 then hgef = 41.1*1e-6 ; shrublands
  if genveg[i] eq 3 then hgef = 239.*1e-6 ; tropical forest: took number for temperate forest
  if genveg[i] eq 4 then hgef = 239.*1e-6 ; temperate forest
  if genveg[i] eq 5 then hgef = 315.*1e-6  ; Boreal forest
  if genveg[i] eq 9 then hgef = 274.*1e-6  ; Crop

; Calculate Hg Emissions
  hg[i] = hgef*area[i]*bmass[i]/1000.*(factor[i])

; Print emissions to output file
; printf, 1, 'day, latitude, Longitude, CO2, CO, PM25, NOX, VOC, Hg'
  printf, 1, format = form, day[i], lati[i],longi[i], CO2[i],CO[i], PM25[i], NOx[i], VOC[i],Hg[i]

skip1:
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