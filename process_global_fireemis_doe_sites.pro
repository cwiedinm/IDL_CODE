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
; NOVEMBER 21, 2011
;   - Edited to process daily files for Dan Jaffee
;   
; April 04, 2012
; - Edited for DOE Sites
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

pro process_global_fireemis_DOE_sites
t0 = systime(1) ;Procedure start time in seconds
close, /all  

for j = 0,9 do begin
close, /all
path = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2012\DOE\'
if j eq 0 then begin ; 2002
      infile = path+'DAILY_FIREEMIS_GLOB_2002_DOEclip_04042012.csv'
      output1 = path+'DOE_2002_LITTLEROCK.txt'
endif
if j eq 1 then begin ; 2003
      infile = path+'DAILY_FIREEMIS_GLOB_2003_DOEclip_04042012.csv'
      output1 = path+'DOE_2003_LITTLEROCK.txt'
endif
if j eq 2 then begin ; 2004
      infile = path+'DAILY_FIREEMIS_GLOB_2004_DOEclip_04042012.csv'
      output1 = path+'DOE_2004_LITTLEROCK.txt'
endif
if j eq 3 then begin ; 2005
      infile = path+'DAILY_FIREEMIS_GLOB_2005_DOEclip_04042012.csv'
      output1 = path+'DOE_2005_LITTLEROCK.txt'
endif
if j eq 4 then begin ; 2006
      infile = path+'DAILY_FIREEMIS_GLOB_2006_DOEclip_04042012.csv'
      output1 = path+'DOE_2006_LITTLEROCK.txt'
endif
if j eq 5 then begin ; 2007
      infile = path+'DAILY_FIREEMIS_GLOB_2007_DOEclip_04042012.csv'
      output1 = path+'DOE_2007_LITTLEROCK.txt'
endif
if j eq 6 then begin ; 2008
      infile = path+'DAILY_FIREEMIS_GLOB_2008_DOEclip_04042012.csv'
      output1 = path+'DOE_2008_LITTLEROCK.txt'
endif
if j eq 7 then begin ; 2009
      infile = path+'DAILY_FIREEMIS_GLOB_2009_DOEclip_04042012.csv'
      output1 = path+'DOE_2009_LITTLEROCK.txt'
endif
if j eq 8 then begin ; 2010
      infile = path+'DAILY_FIREEMIS_GLOB_2010_DOEclip_04042012.csv'
      output1 = path+'DOE_2010_LITTLEROCK.txt'
endif
if j eq 9 then begin ; 2011
      infile = path+'DAILY_FIREEMIS_GLOB_2011_DOEclip_04042012.csv'
      output1 = path+'DOE_2011_LITTLEROCK.txt'
endif
    
openw, 1, output1


printf, 1, 'day, num_fire_counts, CO2, CO, PM2.5, NMOC'

; INPUT FILES FROM JAN. 29, 2010
; Emissions are in kg/km2/day
print,'Reading: ',infile

nfires = nlines(infile)-1
lon = fltarr(nfires)
lat = fltarr(nfires)
day = intarr(nfires)
jday = intarr(nfires)
co = fltarr(nfires)
co2 = fltarr(nfires)
pm25 = fltarr(nfires)
nmoc = fltarr(nfires)

openr,ilun,infile,/get_lun
sdum=' '
readf,ilun,sdum
print,sdum
vars = Strsplit(sdum,',',/extract)
nvars = n_elements(vars)

for i=0,nvars-1 do print,i,': ',vars[i]
  data1 = fltarr(nvars)

;  0    1         2       3   4   5     6      
; day latitude  longitude CO2 CO  PM2.5 NMOC

for k=0L,nfires-1 do begin
  readf,ilun,data1
  lon[k] = data1[2]
  lat[k] = data1[1]
  day[k] = data1[0]
  co2[k] = data1[3]
  co[k] = data1[4]
  pm25[k] = data1[5]
  nmoc[k] = data1[6]
endfor ; End k loop
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'


for k = 1,365 do begin
 today = where(day eq k) 
  
 PASCO = where(lat[today] gt (41.7) and lat[today] lt (50.73) and lon[today] lt (-112.63) and lon[today] gt (-125.6))
 IDFALL = where(lat[today] gt (38.9) and lat[today] lt (48.0) and lon[today] lt (-105.85) and lon[today] gt (-118.22))
 RENO = where(lat[today] gt (35.0) and lat[today] lt (44.03) and lon[today] lt (-113.98) and lon[today] gt (-125.63))
 NASHVILLE = where(lat[today] gt (31.66) and lat[today] lt (40.67) and lon[today] lt (-81.21) and lon[today] gt (-92.33))
 LITTLEROCK = where(lat[today] gt (30.24) and lat[today] lt (39.23) and lon[today] lt (-86.81) and lon[today] gt (-97.75))

  numfirestoday = n_elements(LITTLEROCK)
  LITTLEROCK_CO = total(CO[today[LITTLEROCK]])
  LITTLEROCK_CO2 = total(CO2[today[LITTLEROCK]])
  LITTLEROCK_PM25 = total(PM25[today[LITTLEROCK]])
  LITTLEROCK_NMOC = total(NMOC[today[LITTLEROCK]])
 
; Get CO, NOx, PM2.5 for each area
 if LITTLEROCK[0] eq -1 then begin
    numfirestoday = 0
    LITTLEROCK_CO = 0.
    LITTLEROCK_CO2 = 0.
    LITTLEROCK_PM25 = 0.
    LITTLEROCK_NMOC = 0.
 endif
      form = '(I4,",",I7,4(",",D26.13))'
      printf, 1, format = form, k, numfirestoday, LITTLEROCK_CO2, LITTLEROCK_CO, LITTLEROCK_PM25, LITTLEROCK_NMOC

endfor ; end of k loop


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