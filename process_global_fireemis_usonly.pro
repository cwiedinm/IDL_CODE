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
;OCTOBER 20 2014
;- edited to sum over all of VOC for FINNv1.5
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

pro process_global_fireemis_USonly
t0 = systime(1) ;Procedure start time in seconds
close, /all

for j = 0,12 do begin ; j loop is over outputs for 2002-2011. 
close, /all
pathin = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\'

  if j eq 0 then begin ; 2002
      year = 2002
      infile = pathin+'GLOBAL_FINNv15_2002_06202014.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
      infile = pathin+'GLOBAL_FINNv15_2003_06242014.txt'
  endif
  if j eq 2 then begin ; 2004
      year = 2004
      infile = pathin+'GLOBAL_FINNv15_2004_06252014.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
      infile = pathin+'GLOBAL_FINNv15_2005_06252014.txt'
  endif
  if j eq 4 then begin ; 2006
      year = 2006
      infile = pathin+'GLOBAL_FINNv15_2006_06262014.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
      infile = pathin+'GLOBAL_FINNv15_2007_06252014.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
      infile = pathin+'GLOBAL_FINNv15_2008_06252014.txt'
  endif
  if j eq 7 then begin ; 2009
      year = 2009
      infile = pathin+'GLOBAL_FINNv15_2009_06252014.txt'
  endif
  if j eq 8 then begin ; 2010
      year = 2010
      infile = pathin+'GLOBAL_FINNv15_2010_06262014.txt'
  endif
  if j eq 9 then begin ; 2011
      year = 2011
      infile = pathin+'GLOBAL_FINNv15_2011_06272014.txt'
  endif
  if j eq 10 then begin ; JAN-JUN29 2010
  year = 2012
      infile = pathin+'GLOBAL_FINNv15_2012_06282014.txt'
  endif
  if j eq 11 then begin ; JUN30-DEC 2010
  year = 2013
      infile = pathin+'GLOBAL_FINNv15_2013_06202014.txt'
  endif
 
  
  
openw, 1, output1

printf, 1, 'Emissions for USA only from '+infile
printf, 1, 'longi,lat,day,lct,genLC,globreg,area,bmass,CO2,CO,CH4,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
form = '(D20.10,",",D20.10,",",(4(I10,",")),2(D20.10,","),16(D25.10,","))'

; DEFINE REGION TO CLIP
; HERE : CONTINENTAL US ONLY
latmin = 25.0
latmax = 50.0
lonmin = -126.0
lonmax = -65

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