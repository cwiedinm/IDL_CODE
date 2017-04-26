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

pro process_global_fireemis_Black_saturday
t0 = systime(1) ;Procedure start time in seconds
close, /all

; for j = 8,8 do begin ; j loop is over outputs for 2005-2011. 

; ONLY do 2009 for CLAIRE

 j = 8
 
close, /all

  if j eq 0 then begin ; 2005
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2010\GLOB_2005_08242010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_2005_USA_08102011.txt'
endif
  if j eq 1 then begin ; 2006
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2010\GLOB_2006_09032010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_2006_USA_08102011.txt'
  endif
  if j eq 2 then begin ; JAN-APR 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-APR2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_JAN-APR2007_USA_08102011.txt'
  endif
  if j eq 3 then begin ; MAY-SEPT 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_MAY-SEPT2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_MAY-SEPT2007_USA_08102011.txt'
  endif
  if j eq 4 then begin ; OCT-DEC 2007
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2007_09072010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_OCT-DEC2007_USA_08102011.txt'
  endif
  if j eq 5 then begin ; JAN-APR 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-APR2008_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_JAN-APR2008_USA_08102011.txt'
  endif
  if j eq 6 then begin ; MAY-SEPT 2008
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_MAY-SEPT2008_03252011_correctLCT.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_MAY-SEPT2008_USA_08102011.txt'
  endif
  if j eq 7 then begin ; OCT-DEC 2008
      infile ='E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2008_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_OCT-DEC2008_USA_08102011.txt'
  endif
  if j eq 8 then begin ; JAN-NOV 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_JAN-NOV2009_09082010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2011\PROCESS\BLACK_SAT\DAILY_FIREEMIS_GLOB_JAN-NOV2009_BLACKSAT_09252011.txt'
  endif
  if j eq 9 then begin ; DEC 2009
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_DEC2009_09092010.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_DEC2009_USA_08102011.txt'
  endif
  if j eq 10 then begin ; JAN-JUN29 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_JAN-JUN2010_04042011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_JAN-JUN29_2010_USA_08102011.txt'
  endif
  if j eq 11 then begin ; JUN30-DEC 2010
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2011\GLOB_JUN-DEC2010_04042011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_JUN30-DEC2010_USA_08102011.txt'   
  endif
  if j eq 12 then begin ; JAN-APR 2011
      infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MAY2011\GLOB_JAN-APR2011_05042011.txt'
      output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2011\PROCESS\USA\DAILY_FIREEMIS_GLOB_JAN-APR2011_USA_08102011.txt'     
  endif
  
  
openw, 1, output1

printf, 1, 'Emissions for BLACK SATURDAY FIRES only from '+infile
printf, 1, 'longi,lat,day,lct,genLC,globreg,area,bmass,CO2,CO,CH4,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
form = '(D20.10,",",D20.10,",",(4(I10,",")),2(D20.10,","),16(D25.10,","))'

; DEFINE REGION TO CLIP
; HERE : 
; table below from 4th February 2009 to 11th March 2009 between 34.5˚S to 48˚S, 135˚E - 165˚E?
latmin = -48.
latmax = -34.5
lonmin = 135.0
lonmax = 165.0

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
lct = fltarr(nfires)
area = fltarr(nfires)
bmass = fltarr(nfires)
globreg = fltarr(nfires)
nmoc = fltarr(nfires)
tpc = fltarr(nfires)


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
for k=0L,nfires-1 do begin
  readf,ilun,data1
  longi[k] = data1[0]
  lati[k] = data1[1]
  day[k] = data1[2]
  jday[k] = day[k]
  lct[k] = data1[4]
  genveg[k] = data1[5]
  area[k] = data1[10]
  bmass[k] = data1[11]
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