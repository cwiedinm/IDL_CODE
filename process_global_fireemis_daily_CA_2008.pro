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
; June 13, 2011
; - edited to pull out area for xiaoyan for 2007 modeling
; 
; OCTOBER 28, 2011
; - edited this code to pull out emissions for fires in CA only
; 
; JANUARY 12, 2012
; - Edited this code to include also vegetation type and biomass burned for Sarika
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

pro process_global_fireemis_daily_CA_2008

t0 = systime(1) ;Procedure start time in seconds
close, /all

; REWROTE CODE FOR Original fire emissions file
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MARCH2011\GLOB_MAY-SEPT2008_03252011_correctLCT.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2012\CARB\DAILY_FIREEMIS_MAY-SEPT2008_CAonly_01122011.txt’
;  endif
   
openw, 1, output1

printf, 1, 'Daily Emissions from '+infile

;1      2   3   4    5    6      7        8        9       10     11  12    13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29   30    
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'; Emissions are in kg/km2/day

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
lct = intarr(nfires)
burnarea= fltarr(nfires)
bmass = fltarr(nfires)

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

;       0: LONGI
;       1: LAT
;       2: DAY
;       3: TIME
;       4: LCT
;       5: GENLCT
;       6: GLOBREG
;       7: PCT_TREE
;       8: PCT_HERB
;       9: PCT_BARE
;      10: AREA
;      11: BMASS
;      12: CO2
;      13: CO
;      14: CH4
;      15: H2
;      16: NOX
;      17: NO
;      18: NO2
;      19: NH3
;      20: SO2
;      21: NMHC
;      22: NMOC
;      23: PM25
;      24: TPM
;      25: OC
;      26: BC
;      27: TPC
;      28: PM10

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  lct[k] = data1[4]
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
  burnarea[k] = data1[10]
  bmass[k] = data1[11]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'

form = '(I4,",",I4,",",I4,19(",",F25.10))'
printf, 1, 'day,lct,genveg,longi,lat,CO2,CO,CH4,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,PM10,BURNAREA,BMASS'

; SET TIME AND DAYS FOR OUTPUT FILE
daymin = 151 ; MAY 31
daymax = 273 ; SEPT 31

latmin = 30.
latmax = 43. 
lonmin = -125.
lonmax =-113.

numfires = n_elements(voc)
for i =0,numfires-1 do begin
if day[i] lt daymin or day[i] gt daymax then goto, skipfire
if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt lonmax or longi[i] lt lonmin) then goto, skipfire

printf, 1, format = form, day[i],lct[i],genveg[i],longi[i],lati[i],co2[i],co[i],ch4[i],nox[i],no[i],no2[i],nh3[i],so2[i], $
           nmhc[i],voc[i],pm25[i],tpm[i],oc[i],bc[i],pm10[i],burnarea[i],bmass[i]

skipfire:
endfor

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