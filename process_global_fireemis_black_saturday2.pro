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
; AUGUST 10, 2011
; - edited for US only
; 
; SEPTEMBER 25, 2011
;   - Edited for Clare Murpy's region in Austrailia  
;   
; FEBRUARY 10, 2012
; * Edited for 2009 files only
; * edited to process MOZ4 file, not basic fire emission file
; * Changed region for output
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

pro process_global_fireemis_Black_saturday2
t0 = systime(1) ;Procedure start time in seconds
close, /all

; DEFINE REGION TO CLIP
; HERE : 
; table below from 1 February 2009 to 28 February 2009 between 34.5˚S to 48˚S, 135˚E - 165˚E?
latmin = -44.
latmax = -34
lonmin = 135.0
lonmax = 165.0

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2011\MAY2011\SPECIATE\MOZ4\GLOB_JAN-NOV2009_05062011_MOZ4.txt'
output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2012\PROCESS\BLACKSAT\DAILY_FIREEMIS_GLOB_JAN-NOV2009_BLACKSAT_02102012.txt'
openw, 1, output1

printf, 1, 'Emissions for BLACK SATURDAY FIRES only from '+infile
printf, 1, 'longi,lat,day,genLC,area,bmass,CO2,CO,CH4,NOx,NO,NO2,NH3,SO2,OC,BC,CH3OH,CH2O,CH3CHO,HCOOH,C2H4,TOLUENE,HCN,C2H6,C2H2,C3H6,CH3CN'
form = '(D20.10,",",D20.10,",",(2(I10,",")),23(D25.10,","))'

;  1    2   3     4    5    6    7   8  9  10 11  12  13  14  15   16     17     18     19     20   21     22   23   24   25   26     27       28       29      30    31     32     33   34   35   36  37  38  39    40      41   42 43 44   45    46
;DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2' 
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
voc = fltarr(nfires)
ch4 = fltarr(nfires)
area = fltarr(nfires)
ch3oh = fltarr(nfires)
ch2o= fltarr(nfires)
ch3cho= fltarr(nfires)
hcooh= fltarr(nfires)
c2h4= fltarr(nfires)
toluene= fltarr(nfires)
hcn= fltarr(nfires)
ch3cn= fltarr(nfires)
c2h6= fltarr(nfires)
c2h2= fltarr(nfires)
c3h6= fltarr(nfires)

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)


;  1    2   3     4    5    6    7   8  9  10 11  12  13  14  15   16     17     18     19     20   21     22   23   24   25   26     27       28       29      30    31     32     33   34   35   36  37  38  39    40      41   42 43 44   45    46
;DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2' 

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[4]
  lati[k] = data1[3]
  day[k] = data1[0]
  jday[k] = day[k]
  genveg[k] = data1[2]
  area[k] = data1[5]
  co2[k] = data1[6]
  co[k] = data1[7]
  oc[k] = data1[41]
  bc[k] = data1[42]
  nox[k] = data1[]
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
  globreg[k] = data1[6]
  nmoc[k] = data1[22]
  tpc[k] = data1[27]
  
; PRINT OUT IN ANOTHER FILE THE FIRES ONLY FROM THE REGION DEFINED ABOVE
  if lati[k] gt latmin and lati[k] lt latmax and longi[k] gt lonmin and longi[k] lt lonmax then begin
;                              'longi,lat,day,          lct,genLC,globreg,         area,   bmass,   CO2,CO,CH4,NOx,
      printf, 1, format = form, longi[k],lati[k],day[k],lct[k],genveg[k],globreg[k],area[k],bmass[k],CO2[k],CO[k],CH4[k],NOx[k],$
;                             NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10
                            NO[k],NO2[k],NH3[k],SO2[k],NMHC[k],NMOC[k],PM25[k],TPM[k],OC[k],BC[k],TPC[k],PM10[k]
  endif
endfor ; end k loop
close, /all
close,ilun
free_lun,ilun
close, /all
print, 'Finished with file # ', j+1
print, 'Closing ', infile

;endfor ; End of j loop over the different input files

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