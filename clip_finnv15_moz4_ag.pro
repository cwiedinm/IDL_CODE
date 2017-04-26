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
;OCTOBER 26, 2016
;- Edited to output early 2015 fire emissions for Columbia
;- included new emissions file for 2015 that was created September 2016
;
;October 29, 2016
;- Edited to output monthly CO totals from MOZ Speciated files
;- So, changed the input files read and changed the areas that were summed over each month
; 
; November 07, 2016
; - renamed clip_finnv15_'+name+' to clip_finnv15_MOZ4_ag
; DIDN't FINISH! REDID processing with the speciation files
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

pro clip_finnv15_MOZ4_ag

t0 = systime(1) ;Procedure start time in seconds
close, /all

; Decide if include ag fires or not
withag = 1

if withag eq 1 then name  = 'AG'
if withag eq 0 then name = 'NOAG'

for j = 0,13 do begin 
  print, 'J = ', j

  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2002_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2002_11072016.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2003_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2003_11072016.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2004_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2004_11072016.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2005_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2005_11072016.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2006_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2006_11072016.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2007_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2007_11072016.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2008_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2008_11072016.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2009_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2009_11072016.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2010_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2010_11072016.txt'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2011_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2011_11072016.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2012_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2012_11072016.txt'
  endif
  
  ; 09/19/2016: updated 2013, 2014 files to be used here. 
     if j eq 11 then begin ; 2013
    year = 2013
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\MOZ4\GLOBAL_FINNv15_2013_MOZ4_7112014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2013_11072016.txt'
  endif
   if j eq 12 then begin ; 2014
    year = 2014
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\NOV_2015\SECIATED\GLOBAL_FINNv15_2014_MOZ4_12012015.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2014_11072016.txt'
  endif
 
 ; 10/26/2016: Changed the 2015 FINNv1.5 file to the one that was created in Sept. 2016
 
  if j eq 13 then begin ; 2015
    year = 2015
 ;   infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JAN2016\FINNv1.5_2015_01222016.txt'
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\SPECIATE\GLOBAL_FINNv15_2015_MOZ4_11072016.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv15_'+name+'_2014_11072016.txt'
  endif
    

; INPUT FILES FROM JAN. 29, 2010
;  1    2   3      4    5      6   7  8  9  10 11  12  13  14  15   16     17     18     19     20   21     22   23   24   25   26     27       28       29       30    31     32    33   34   35   36  37  38  39     40      41  42 43 44   45    46
;'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CCH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'  ; 11
; Emissions are in kg/km2/day
print, 'YEar = ', year
print,'Reading: ',infile
print, 'Output file: ', output1

nfires = nlines(infile)-1

; Set up output Arrays

day = intarr(nfires)
jday = intarr(nfires)
genveg = intarr(nfires)
lati = fltarr(nfires)
longi = fltarr(nfires)
area = = fltarr(nfires)

    CO2emis = fltarr(nfires)
    COemis = fltarr(nfires)
    NOXemis = fltarr(nfires)
    VOCemis = fltarr(nfires)
    SO2emis = fltarr(nfires)
    NH3emis = fltarr(nfires)
    PM25emis = fltarr(nfires)
    OCemis = fltarr(nfires)
    CH4emis = fltarr(nfires)
    BCEMIS = fltarr(nfires)
    NOemis = fltarr(nfires)
    NO2emis = fltarr(nfires)
    PM10emis = fltarr(nfires)
    H2emis = fltarr(nfires) ; added 09/29/2010
    NOemis = fltarr(nfires)
    NO2emis = fltarr(nfires)
    
; Set up speciated VOC arrays
BIGALDemis =  fltarr(nfires)
BIGALKemis =  fltarr(nfires)
BIGENEemis =  fltarr(nfires)
C10H16emis =  fltarr(nfires)
C2H4emis =  fltarr(nfires)
C2H5OHemis =  fltarr(nfires)
C2H6emis =  fltarr(nfires)
C3H6emis =  fltarr(nfires)
C3H8emis =  fltarr(nfires)
CH2Oemis =  fltarr(nfires)
CH3CHOemis =  fltarr(nfires)
CH3COCH3emis =  fltarr(nfires)
CH3COCHOemis =  fltarr(nfires)
CH3COOHemis =  fltarr(nfires)
CH3OHemis =  fltarr(nfires)
CRESOLemis =  fltarr(nfires)
GLYALDemis =  fltarr(nfires)
HYACemis =  fltarr(nfires)
ISOPemis =  fltarr(nfires)
MACRemis =  fltarr(nfires)
MEKemis =  fltarr(nfires)
MVKemis =  fltarr(nfires)
NOemis =  fltarr(nfires)
HCNemis =  fltarr(nfires)
CH3CNemis =  fltarr(nfires)
TOLUENEemis =  fltarr(nfires)
HCOOHemis = fltarr(nfires) ; Added 08/19/2010
C2H2emis = fltarr(nfires) ; Added 08/19/2010


openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)


for i=0,nvars-1 do print,i,': ',vars[i] ; READING in VARIABLES
  data1 = fltarr(nvars)


;NEW for FINNv1.5 
;  0   1    2      3    4     5   6   7  8  9  10  11  12  13  14    15     16     17     18     19   20     21   22   23   24   25     26        27       28       29   30     31    32   33   34   35  36  37  38    39      40   41 42 43   44    45
;'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CCH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'  ; 11
;; NEED TO START WITH 0, not 1!!
for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[4]
  lati[k] = data1[3]
  day[k] = data1[0]
  jday[k] = day[k]
  genveg[k] = data1[2]
    CO2emis = data[6]
    COemis = data[7]
;    NOXemis = data[0]
    VOCemis = data[14]
    SO2emis = data[11]
    NH3emis = data[12]
    PM25emis = data[40]
    OCemis = data[41]
    CH4emis = data[13]
    BCEMIS = data[42]
    NOemis = data[9]
    NO2emis = data[10]
    PM10emis = data[43]
    H2emis = data[8] 
    BIGALDemis =  data[15]
    BIGALKemis =  data[16]
    BIGENEemis =  data[17]
    C10H16emis =  data[18]
    C2H4emis =  data[19]
    C2H5OHemis =  data[20]
    C2H6emis =  data[21]
    C3H6emis =  data[22]
    C3H8emis =  data[23]
    CH2Oemis =  data[24]
    CH3CHOemis =  data[25]
    CH3COCH3emis =  data[]
    CH3COCHOemis =  data[0]
    CH3COOHemis =  data[0]
    CH3OHemis =  data[0]
    CRESOLemis =  data[0]
    GLYALDemis =  data[0]
    HYACemis =  data[0]
    ISOPemis =  data[0]
    MACRemis =  data[0]
    MEKemis =  data[0]
    MVKemis =  data[0]
    NOemis =  data[0]
    HCNemis =  data[0]
    CH3CNemis =  data[0]
    TOLUENEemis =  data[0]
    HCOOHemis = data[0] ; Added 08/19/2010
    C2H2emis = data[0]
  
endfor ; End loop for EADING in VARIABLES

close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
numfires = n_elements(day)

; Chose area of totals
; DOMAIN 1: SOUTHERN AFRICA
latmin1 = -36.
latmax1 = 4.
lonmin1 = -18.
lonmax1 = 59.
daymin = 1 
daymax = 366 

; DOMAIN 2: SOUTH AMERICA
latmin2 = -58.
latmax2 = 5.
lonmin2 = -83.
lonmax2 = -32.

; DOMAIN 3: AUSTRALASIA
latmin3 = -48.
latmax3 = -10.
lonmin3 = 112.
lonmax3 = 181.

; DOMAIN 4: Maritime SEAS
latmin4 = -10.
latmax4 = 10.
lonmin4 = 91.
lonmax4 = 165.

openw, 1, output1
printf, 1, 'MONTH,CO_D1,NMOC_D1,CCH3OH_D1,CH2O_D1,C2H6_D1,CO_D2,NMOC_D2,CH3OH_D2,CH2O_D2,C2H6_D2,CO_D3,NMOC_D3,CH3OH_D3,CH2O_D3,C2H6_D3,CO_D4,NMOC_D4,CH3OH_D4,CH2O_D4,C2H6_D4'
form = '(I6,20(",",D25.10))'


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
   CO_D1 = 0.0
   NMOC_D1 = 0.0
   CH3OH_D1 = 0.0
   CH2O_D1 = 0.0
   C2H6_D1 = 0.0
   CO_D2 = 0.0
   NMOC_D2 = 0.0
   CH3OH_D2 = 0.0
   CH2O_D2 = 0.0
   C2H6_D2 = 0.0
   CO_D3 = 0.0
   NMOC_D3 = 0.0
   CH3OH_D3 = 0.0
   CH2O_D3 = 0.0
   C2H6_D3 = 0.0
   CO_D4 = 0.0
   NMOC_D4 = 0.0
   CH3OH_D4 = 0.0
   CH2O_D4 = 0.0
   C2H6_D4 = 0.0
; DOMAIN 1
   today1 = where(day ge monthset[l] and day lt monthset[l+1] and lati gt latmin1 and lati lt latmax1 and longi lt lonmax1 and longi gt lonmin1)
   if today1[0] eq -1 then goto, next2 

   CO_D1 = total(CO[today1])
   NMOC_D1 = total(voc[today1])
   CH3OH_D1= total(Ch3oh[today1])
   CH2O_D1 = total(ch2o[today1])
   C2H6_D1= total(c2h6[today1])
   ; DOMAIN 2
next2:
   today2 = where(day ge monthset[l] and day lt monthset[l+1] and lati gt latmin2 and lati lt latmax2 and longi lt lonmax2 and longi gt lonmin2)
   if today2[0] eq -1 then goto, next3
   CO_D2 = total(CO[today2])
   NMOC_D2 = total(voc[today2])
   CH3OH_D2= total(Ch3oh[today2])
   CH2O_D2 = total(ch2o[today2])
   C2H6_D2= total(c2h6[today2])

   ; DOMAIN 3
   next3:
   today3 = where(day ge monthset[l] and day lt monthset[l+1] and lati gt latmin3 and lati lt latmax3 and longi lt lonmax3 and longi gt lonmin3)
   if today3[0] eq -1 then goto, next4
   CO_D3 = total(CO[today3])
   NMOC_D3 = total(voc[today3])
   CH3OH_D3= total(Ch3oh[today3])
   CH2O_D3 = total(ch2o[today3])
   C2H6_D3= total(c2h6[today3])

   ; DOMAIN 2
   next4:
   today4 = where(day ge monthset[l] and day lt monthset[l+1] and lati gt latmin4 and lati lt latmax4 and longi lt lonmax4 and longi gt lonmin4)
   if today4[0] eq -1 then goto, printnow
   CO_D4 = total(CO[today4])
   NMOC_D4 = total(voc[today4])
   CH3OH_D4= total(Ch3oh[today4])
   CH2O_D4 = total(ch2o[today4])
   C2H6_D4= total(c2h6[today4])

    printnow:
   printf, 1, format = form, l+1,CO_D1,NMOC_D1,CH3OH_D1,CH2O_D1,C2H6_D1,CO_D2,NMOC_D2,CH3OH_D2,CH2O_D2,C2H6_D2,CO_D3,NMOC_D3,CH3OH_D3,CH2O_D3,C2H6_D3,CO_D4,NMOC_D4,CH3OH_D4,CH2O_D4,C2H6_D4

endfor ; end l loop


; USE THIS CODE TO PRINT OUT ALL FIRES IN THE AREA/TIME SPECIFIED
;for i = 0,numfires-1 do begin
;  if (lati[i] lt latmax and lati[i] gt latmin and longi[i] gt lonmin and longi[i] lt lonmax and day[i] gt daymin and day[i] lt daymax) then begin
;    ; 'day,vegtype, latitude, longitude, area, CO,NOx,NMOC,NH3,SO2,PM2.5,PM10, OC, BC'
;    printf, 1, format = form, day[i], genveg[i],lati[i], longi[i], co2[i], co[i],nox[i],voc[i],nh3[i],so2[i],pm25[i],pm10[i],oc[i],bc[i]
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