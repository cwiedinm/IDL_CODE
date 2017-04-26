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
;  APRIL 04, 2012
;  - edited to clip sites for DOE Project
;  - output only a few emission types
; April 05, 2012
; - Edited to clip California Region 
; April 20, 2012
;  - Edited for SEACRS REgion for 2011
; July 23, 2012 
;   - Edited for 2012 file... only CO
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

pro process_global_fireemis_daily_cliparea_CO_WEST_2012

t0 = systime(1) ;Procedure start time in seconds
close, /all

      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2012\SEAC4RS\DAILY_FIREEMIS_SEAC4RS_CLIP_2011_0420012.txt'
    
openw, 1, output1

printf, 1, 'Daily Emissions from file: '+infile+' clipped to SEACRS Region
printf, 1, 'day,latitude,longitude,CO2,CO,PM2.5,NMOC'
form = '(I10,6(",",D25.10))'
  

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

;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
;

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
;  genveg[k] = data1[5]
  co2[k] = data1[12]
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
  voc[k] =  data1[22]
;  ch4[k] = data1[14]
;  pm10[k] = data1[28]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'

; Latitude and longitude extent for California
latmin = -30.0 
latmax = 50.0
lonmin = 40.0
lonmax = 180.0

for k = 0,nfires-1  do begin
; PRINT OUT IN ANOTHER FILE THE FIRES ONLY FROM THE REGION DEFINED ABOVE
  if lati[k] gt latmin and lati[k] lt latmax and longi[k] gt lonmin and longi[k] lt lonmax then begin
;      printf, 1, 'day,latitude,longitude,CO2,CO,PM2.5,NMOC'
      printf, 1, format = form, day[k],lati[k],longi[k],co2[k],co[k],PM25[k],voc[k]
  endif
endfor ; end k loop

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