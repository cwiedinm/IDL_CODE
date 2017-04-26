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

pro process_global_fireemis_daily_US2007
t0 = systime(1) ;Procedure start time in seconds
close, /all

; REWROTE CODE FOR SAPRC99 SPECIATED EMISSIONS

      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2011\SPECIATE\SAPRC99\GLOB_MAY-SEPT2007_05022011_SAPRC99.txt'
      output1 = 'E:\Data2\wildfire\AMC_XJ2011\EMISSIONS\DAILY_FIREEMIS_XJgrid_MAY-SEPT2007_06132011.txt'
;  endif
   
openw, 1, output1

printf, 1, 'Daily Emissions from '+infile


;1    2    3       4    5     6   7  8  9  10  11  12  13  14  15   16   17   18   19   20   21   22   23   24   25     26      27   28  29   30    31       32  33   34      35   36
;DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,NO,NO2,SO2,NH3,CH4,VOC,ACET,ALK1,ALK2,ALK3,ALK4,ALK5,ARO1,ARO2,BALD,CCHO,CCO_OH,ETHENE,HCHO,HCN,HCOOH,HONO,ISOPRENE,MEK,MEOH,METHACRO,MGLY,MVK,OLE1,OLE2,PHEN,PROD2,RCHO,RNO3,TRP1,OC,BC,PM25,PM10
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


;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR

; 1 2 3 4 5 6 7 8 9 10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47
;AY TIME  GENVEG  LATI  LONGI AREA  CO2 CO  NO  NO2 SO2 NH3 CH4 VOC ACET  ALK1  ALK2  ALK3  ALK4  ALK5  ARO1  ARO2  BALD  CCHO  CCO_OH  ETHENE  HCHO  HCN HCOOH HONO  ISOPRENE  MEK MEOH  METHACRO  MGLY  MVK OLE1  OLE2  PHEN  PROD2 RCHO  RNO3  TRP1  OC  BC  PM25  PM10
;       0: DAY
;       1: TIME
;       2: GENVEG
;       3: LATI
;       4: LONGI
;       5: AREA
;       6: CO2
;       7: CO
;       8: NO
;       9: NO2
;      10: SO2
;      11: NH3
;      12: CH4
;      13: VOC
;      14: ACET
;      15: ALK1
;      16: ALK2
;      17: ALK3
;      18: ALK4
;      19: ALK5
;      20: ARO1
;      21: ARO2
;      22: BALD
;      23: CCHO
;      24: CCO_OH
;      25: ETHENE
;      26: HCHO
;      27: HCN
;      28: HCOOH
;      29: HONO
;      30: ISOPRENE
;      31: MEK
;      32: MEOH
;      33: METHACRO
;      34: MGLY
;      35: MVK
;      36: OLE1
;      37: OLE2
;      38: PHEN
;      39: PROD2
;      40: RCHO
;      41: RNO3
;      42: TRP1
;      43: OC
;      44: BC
;      45: PM25
;      46: PM10

for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[4]
  lati[k] = data1[3]
  day[k] = data1[0]
  jday[k] = day[k]
  genveg[k] = data1[2]
  co2[k] = data1[6]
  co[k] = data1[7]
  oc[k] = data1[43]
  bc[k] = data1[44]
  nox[k] = data1[9]
  nh3[k] = data1[11]
  so2[k] = data1[10]
  pm25[k] = data1[45]
  tpm[k] = data1[45]
  no[k] = data1[8]
  NO2[k] = data1[9]
  nmhc[k] = data1[13]
  voc[k] =  data1[13]
  ch4[k] = data1[12]
  pm10[k] = data1[46]
endfor
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'

form = '(I4,",",15(F25.10,","))'

ndays = max(day)   
count = ndays-1

; MEXICO DAILY TOTALS
; LAT > 43.3N and LAT < 51; -120.6 < LONG < -106)
printf, 1, 'AREA TOTALS (kg Species)'
Printf, 1, 'JD,CO2,CO,NOX,NO,NO2,NH3,SO2,VOC,NMHC,CH4,PM25,OC,BC,TPM,PM10'
for i = 0,count do begin
  today = where(jday eq i AND (lati ge 43.3 and lati le 51. and longi gt -120.6 and longi lt -106.))
  if today[0] lt 0 then begin
  CO2in = 0.0
  COin = 0.0
  NOXin = 0.0
  NOin = 0.0
  NO2in = 0.0
  NH3in = 0.0
  SO2in = 0.0
  VOCin = 0.0
  NMHCin = 0.0
  CH4in = 0.0
  PM25in = 0.0
  OCin = 0.0
  BCin = 0.0
  TPMin = 0.0
  PM10in = 0.0
  endif
  if today[0] ge 0 then begin
  CO2in = total(CO2[today])
  COin = total(CO[today])
  NOXin = total(NOX[today])
  NOin = total(NO[today])
  NO2in = total(NO2[today])
  NH3in = total(NH3[today])
  SO2in = total(SO2[today])
  VOCin = total(VOC[today])
  NMHCin = total(NMHC[today])
  CH4in = total(CH4[today])
  PM25in = total(PM25[today])
  OCin = total(OC[today])
  BCin = total(BC[today])
  TPMin = total(TPM[today])
  PM10in = total(PM10[today])
  endif
  printf, 1, format = form, i, CO2in,COin,NOXin,NOin,NO2in,NH3in,SO2in,VOCin,NMHCin,CH4in,PM25in,OCin,BCin,TPMin, PM10in
  skip20:
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