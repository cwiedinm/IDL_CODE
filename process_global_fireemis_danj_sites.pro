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

pro process_global_fireemis_danj_sites
t0 = systime(1) ;Procedure start time in seconds
close, /all  

for j = 0,9 do begin
close, /all
path = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOVEMBER2011\DANJ\'
if j eq 0 then begin ; 2002
      infile = path+'DAILY_FIREEMIS_GLOB_2002_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2002_ GOTH.txt'
endif
if j eq 1 then begin ; 2003
      infile = path+'DAILY_FIREEMIS_GLOB_2003_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2003_ GOTH.txt'
endif
if j eq 2 then begin ; 2004
      infile = path+'DAILY_FIREEMIS_GLOB_2004_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2004_ GOTH.txt'
endif
if j eq 3 then begin ; 2005
      infile = path+'DAILY_FIREEMIS_GLOB_2005_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2005_ GOTH.txt'
endif
if j eq 4 then begin ; 2006
      infile = path+'DAILY_FIREEMIS_GLOB_2006_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2006_ GOTH.txt'
endif
if j eq 5 then begin ; 2007
      infile = path+'DAILY_FIREEMIS_GLOB_2007_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2007_ GOTH.txt'
endif
if j eq 6 then begin ; 2008
      infile = path+'DAILY_FIREEMIS_GLOB_2008_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2008_ GOTH.txt'
endif
if j eq 7 then begin ; 2009
      infile = path+'DAILY_FIREEMIS_GLOB_2009_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2009_ GOTH.txt'
endif
if j eq 8 then begin ; 2010
      infile = path+'DAILY_FIREEMIS_GLOB_2010_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2010_ GOTH.txt'
endif
if j eq 9 then begin ; 2011
      infile = path+'DAILY_FIREEMIS_GLOB_2011_DANJ_11212011.csv'
      output1 = path+'IMPROVE_2011_ GOTH.txt'
endif
    
openw, 1, output1


printf, 1, 'day, CO_1deg, CO_5deg, CO_10deg, NOx_1deg, NOx_5deg, NOx_10deg, PM25_1deg, PM25_5deg, PM25_10deg'
form = '(I10,",",9(D25.10,","))'

; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; Emissions are in kg/km2/day

print,'Reading: ',infile

nfires = nlines(infile)-1
lon = fltarr(nfires)
lat = fltarr(nfires)
day = intarr(nfires)
jday = intarr(nfires)
co = fltarr(nfires)
nox = fltarr(nfires)
no = fltarr(nfires)
no2 = fltarr(nfires)
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

;  0    1    2  3    4  5   6   7      8     
;longi  lat day CO  NOx NO  NO2 NMOC  PM25

for k=0L,nfires-1 do begin
  readf,ilun,data1
  lon[k] = data1[0]
  lat[k] = data1[1]
  day[k] = data1[2]
  co[k] = data1[3]
  nox[k] = data1[4]
  pm25[k] = data1[8]
  no[k] = data1[5]
  NO2[k] = data1[6]
  nmoc[k] = data1[7]
endfor ; End k loop
close,ilun
free_lun,ilun

print, 'finished reading in input file and assigning arrays'


for k = 1,365 do begin
 today = where(day eq k) 
  
 GOTH1deg = where(lat[today] gt (38.9564-0.5) and lat[today] lt (38.9564+0.5) and lon[today] lt (-106.9858 + 0.5) and lon[today] gt (-106.9858-0.5))
 GOTH5deg= where(lat[today] gt (38.9564-2.5) and lat[today] lt (38.9564+2.5) and lon[today] lt (-106.9858 + 2.5) and lon[today] gt (-106.9858-2.5))
 GOTH10deg = where(lat[today] gt (38.9564-5.) and lat[today] lt (38.9564+5.) and lon[today] lt (-106.9858 + 5.) and lon[today] gt (-106.9858-5.))  

 RKYMTN1deg = where(lat[today] gt (40.2778-0.5) and lat[today] lt (40.2778+0.5) and lon[today] lt (-105.5453 + 0.5) and lon[today] gt (-105.5453-0.5))
 RKYMTN5deg= where(lat[today] gt (40.2778-2.5) and lat[today] lt (40.2778+2.5) and lon[today] lt (-105.5453 + 2.5) and lon[today] gt (-105.5453-2.5))
 RKYMTN10deg = where(lat[today] gt (40.2778-5.) and lat[today] lt (40.2778+5.) and lon[today] lt (-105.5453 + 5.) and lon[today] gt (-105.5453-5.))  

 MESVER1deg = where(lat[today] gt (37.1983-0.5) and lat[today] lt (37.1983+0.5) and lon[today] lt (-108.4903 + 0.5) and lon[today] gt (-108.4903-0.5))
 MESVER5deg= where(lat[today] gt (37.1983-2.5) and lat[today] lt (37.1983+2.5) and lon[today] lt (-108.4903 + 2.5) and lon[today] gt (-108.4903-2.5))
 MESVER10deg = where(lat[today] gt (37.1983-5.) and lat[today] lt (37.1983+5.) and lon[today] lt (-108.4903 + 5.) and lon[today] gt (-108.4903-5.))  
 
 YELSTO1deg = where(lat[today] gt (44.5597-0.5) and lat[today] lt (44.5597+0.5) and lon[today] lt (-110.4006 + 0.5) and lon[today] gt (-110.4006-0.5))
 YELSTO5deg= where(lat[today] gt (44.5597-2.5) and lat[today] lt (44.5597+2.5) and lon[today] lt (-110.4006 + 2.5) and lon[today] gt (-110.4006-2.5))
 YELSTO10deg = where(lat[today] gt (44.5597-5.) and lat[today] lt (44.5597+5.) and lon[today] lt (-110.4006 + 5.) and lon[today] gt (-110.4006-5.))  
 
 PINBRI1deg = where(lat[today] gt (42.9288-0.5) and lat[today] lt (42.9288+0.5) and lon[today] lt (-109.788 + 0.5) and lon[today] gt (-109.788-0.5))
 PINBRI5deg= where(lat[today] gt (42.9288-2.5) and lat[today] lt (42.9288+2.5) and lon[today] lt (-109.788 + 2.5) and lon[today] gt (-109.788-2.5))
 PINBRI10deg = where(lat[today] gt (42.9288-5.) and lat[today] lt (42.9288+5.) and lon[today] lt (-109.788 + 5.) and lon[today] gt (-109.788-5.))  
 
 CENT1deg = where(lat[today] gt (41.3642-0.5) and lat[today] lt (41.3642+0.5) and lon[today] lt (-106.2399 + 0.5) and lon[today] gt (-106.2399-0.5))
 CENT5deg= where(lat[today] gt (41.3642-2.5) and lat[today] lt (41.3642+2.5) and lon[today] lt (-106.2399 + 2.5) and lon[today] gt (-106.2399-2.5))
 CENT10deg = where(lat[today] gt (41.3642-5.) and lat[today] lt (41.3642+5.) and lon[today] lt (-106.2399 + 5.) and lon[today] gt (-106.2399-5.))  
 
 COM1deg = where(lat[today] gt (43.4606-0.5) and lat[today] lt (43.4606+0.5) and lon[today] lt (-113.555 + 0.5) and lon[today] gt (-113.555-0.5))
 COM5deg= where(lat[today] gt (43.4606-2.5) and lat[today] lt (43.4606+2.5) and lon[today] lt (-113.555 + 2.5) and lon[today] gt (-113.555-2.5))
 COM10deg = where(lat[today] gt (43.4606-5.) and lat[today] lt (43.4606+5.) and lon[today] lt (-113.555 + 5.) and lon[today] gt (-113.555-5.))  

 CANLAN1deg = where(lat[today] gt (38.4586-0.5) and lat[today] lt (38.4586+0.5) and lon[today] lt (-109.8211 + 0.5) and lon[today] gt (-109.8211-0.5))
 CANLAN5deg= where(lat[today] gt (38.4586-2.5) and lat[today] lt (38.4586+2.5) and lon[today] lt (-109.8211 + 2.5) and lon[today] gt (-109.8211-2.5))
 CANLAN10deg = where(lat[today] gt (38.4586-5.) and lat[today] lt (38.4586+5.) and lon[today] lt (-109.8211 + 5.) and lon[today] gt (-109.8211-5.))  
 
 GREBAS1deg = where(lat[today] gt (39.0053-0.5) and lat[today] lt (39.0053+0.5) and lon[today] lt (-114.2158 + 0.5) and lon[today] gt (-114.2158-0.5))
 GREBAS5deg= where(lat[today] gt (39.0053-2.5) and lat[today] lt (39.0053+2.5) and lon[today] lt (-114.2158 + 2.5) and lon[today] gt (-114.2158-2.5))
 GREBAS10deg = where(lat[today] gt (39.0053-5.) and lat[today] lt (39.0053+5.) and lon[today] lt (-114.2158+ 5.) and lon[today] gt (-114.2158-5.))  
 
 GLAC1deg = where(lat[today] gt (48.5103-0.5) and lat[today] lt (48.5103+0.5) and lon[today] lt (-113.9956 + 0.5) and lon[today] gt (-113.9956-0.5))
 GLAC5deg= where(lat[today] gt (48.5103-2.5) and lat[today] lt (48.5103+2.5) and lon[today] lt (-113.9956 + 2.5) and lon[today] gt (-113.9956-2.5))
 GLAC10deg = where(lat[today] gt (48.5103-5.) and lat[today] lt (48.5103+5.) and lon[today] lt (-113.9956 + 5.) and lon[today] gt (-113.9956-5.))  

  GOTH1deg_CO = total(CO[today[GOTH1deg]])
  GOTH5deg_CO = total(CO[today[GOTH5deg]])
  GOTH10deg_CO = total(CO[today[GOTH10deg]])
  GOTH1deg_NOX = total(NOx[today[GOTH1deg]])
  GOTH5deg_NOX = total(NOX[today[GOTH5deg]])
  GOTH10deg_NOx = total(NOX[today[GOTH10deg]])
  GOTH1deg_PM25 = total(PM25[today[GOTH1deg]])
  GOTH5deg_PM25 = total(pm25[today[GOTH5deg]])
  GOTH10deg_PM25 = total(PM25[today[GOTH10deg]])
 
 
 ; Get CO, NOx, PM2.5 for each area
 if GOTH1deg[0] eq -1 then begin
    GOTH1deg_CO = 0.
    GOTH1deg_NOX = 0.
    GOTH1deg_PM25 =0.
 endif
 if GOTH5deg[0] eq -1 then begin
   GOTH5deg_CO = 0.
   GOTH5deg_NOX = 0.
   GOTH5deg_PM25 = 0.
  endif
 if GOTH10deg[0] eq -1 then begin
  GOTH10deg_CO = 0.
  GOTH10deg_NOx = 0.
  GOTH10deg_PM25 = 0
 endif
 
      printf, 1, format = form, k,  GOTH1deg_CO,  GOTH5deg_CO,  GOTH10deg_CO, $
                GOTH1deg_NOX,   GOTH5deg_NOX,  GOTH10deg_NOx,  GOTH1deg_PM25, $
                GOTH5deg_PM25,  GOTH10deg_PM25

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