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
; 
; June 08, 2015
; - edited to output daily CO2 emissions (global) for Andy Jacobson (NOAA)
; 
; 
; APRIL 21, 2016 
; - Edited to run 2015 emissions for Andy
; 
; May 20, 2016
; - edited to run 2012 - 2015 emissions for Navrongo for Ricardo
; - edited to print out daily fire CO emissions for a 1 x 1 box around the KN
; 
; JULY 13, 2016
; - edited to run all years and make monthly mean CO emissions (1 degere) for Merritt
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

pro finnv15_CO_Merritt_monthly_1deg

t0 = systime(1) ;Procedure start time in seconds
close, /all



for j =0,14 do begin ; do 2011-2014
print, 'J = ', j

  close, /all
  if j eq 0 then begin ; 2002
      year = 2002
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2002_06202014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2003_06242014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2004_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2005_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2006_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2007_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2008_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2009_06252014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
     infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2010_06262014.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
 if j eq 9 then begin ; NEW 2011
    year = 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2011_06272014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2012_06282014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
   if j eq 11 then begin ; 2013
    year = 2013
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2013_06202014.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
     if j eq 12 then begin ; 2014
    year = 2014
       infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\FEB_2015\GLOBAL_FINNv15_2014_02202015.txt'
       output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
  if j eq 13 then begin ; 2015
    year = 2015
    infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JAN2016\FINNv1.5_2015_01222016.txt'
    output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\JULY2016\MERRITT\FINNv15_CO_monthly_1degree_2005_07132016.txt'
  endif
    
openw, 1, output1
printf, 1, 'month, Lat, lon, CO'
form = '(I6,3(",",D25.10))'

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
for i=0,nvars-1 do print,i,': ',vars[i]
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
  co[k] = data1[13]

  
endfor

close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
count = ndays-1
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
numfires = n_elements(day)


; Set up months/days 
monthset = intarr(13)
yearnum = year
; Do a loop over months
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

;COtot = fltarr(360,180,12)
COtot = 0.0
nlon = 360
nlat = 180
nmon = 12
resol = 1.0 
month = [1,2,3,4,5,6,7,8,9,10,11,12]

 for l = 0,11 do begin ; sum over months for each year
      for m = 0,359 do begin
        for k = 0,179 do begin
          COtot = 0.0
          latinow = k-89.5
          longinow = m-179.5
          today = where(day ge monthset[l] and day lt monthset[l+1] and lati gt k-90. and lati le k-89. and longi gt longinow-0.5 and longi le longinow+0.5)
          COtot = total(co[today])
          printf, 1, format = form, month[l], latinow, longinow, COtot
;          form = '(I6,3(",",D25.10))'
        endfor ; end k loop
      endfor ; end m loop
 endfor ; end l loop

; ncfile = output1
; print,ncfile
;
; ncid = ncdf_create(ncfile,/clobber)
; ; Define dimensions
; xid = ncdf_dimdef(ncid,'lon',nlon)
; yid = ncdf_dimdef(ncid,'lat',nlat)
; tid = ncdf_dimdef(ncid,'time',nmon)
;
; ; Define dimension variables with attributes
; xvarid = ncdf_vardef(ncid,'lon',[xid],/float)
; ncdf_attput, ncid, xvarid,/char, 'units', 'degrees_east'
; ncdf_attput, ncid, xvarid,/char, 'long_name', 'Longitude'
; yvarid = ncdf_vardef(ncid,'lat',[yid],/float)
; ncdf_attput, ncid, yvarid,/char, 'units', 'degrees_north'
; ncdf_attput, ncid, yvarid,/char, 'long_name', 'Latitude'
; tvarid = ncdf_vardef(ncid,'time',[tid],/float)
; ncdf_attput, ncid, tvarid,/char, 'long_name', 'Month'
; ncdf_attput, ncid, tvarid,/char, 'units', 'Month'
; tvarid = ncdf_vardef(ncid,'date',[tid],/long)
; ncdf_attput, ncid, tvarid,/char, 'units', 'YYYY'
; ncdf_attput, ncid, tvarid,/char, 'long_name', 'year'
; ;Define global attributes
; ncdf_attput,ncid,/GLOBAL,'title','monthly Fire emissions, FINNv1.5'
; ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer'
; ncdf_attput,ncid,/GLOBAL,'Grid',resol
; ncdf_attput,ncid,/GLOBAL,'History','Created 18 July 2016 from FINNv1.5 MOZ4 files'
;
; varid = ncdf_vardef(ncid, 'fire', [xid,yid,tid], /float)
; ncdf_attput, ncid, varid,/char, 'units', 'kg/day
; ncdf_attput, ncid, varid,/char, 'long_name', 'CO fire emissions'
;
; ncdf_control,ncid,/ENDEF
;
; ncdf_varput,ncid,'lon',longi
; ncdf_varput,ncid,'lat',lati
; ncdf_varput,ncid,'month',month
; ncdf_varput,ncid,'year',year
; ncdf_varput,ncid,'fire',COtot
; ncdf_close,ncid
;

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