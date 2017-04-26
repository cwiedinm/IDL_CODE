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
;February 12, 2013
;- edited to clip North and central America only
;
;JUNE 05, 2015
;-edited to process the FINNv1.5 files
;
;July 15, 2015
;- Edited to include Great plains output and Mexico
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
print, 'done'
return,nl
end
;-------------------------------

pro CLIP_global_month_emis_TexasItaqclip3
t0 = systime(1) ;Procedure start time in seconds
close, /all


output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_SEUS_FL_SC_GA_AL.txt'
openw, 1, output1
printf, 1, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
form = '(I6,13(",",D25.10))'
print, 'Opened output file: ', output1

output2 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_SEUS_MS_ARK_LA.txt'
openw, 2, output2
printf, 2, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
print, 'Opened output file: ', output2

output3 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_Texas.txt'
openw, 3, output3
printf, 3, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
print, 'Opened output file: ', output3

output4 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_WESTUS.txt'
openw, 4, output4
printf, 4, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
print, 'Opened output file: ', output4

output5 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_GREATPLAINS.txt'
openw, 5, output5
printf, 5, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
print, 'Opened output file: ', output5

output6 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\ANNUAL_REGIONAL_TOTALS\Monthly_CO_emiss_MEXICO.txt'
openw, 6, output6
printf, 6, 'month,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012,Y2013,Y2014'
print, 'Opened output file: ', output6


COtot = fltarr(12,13)
COtot2 = fltarr(12,13)
COtot3 = fltarr(12,13)
COtot4 = fltarr(12,13)
COtot5 = fltarr(12,13) 
COtot6 = fltarr(12,13)

indir = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\JUN_2015\NACA\'

for j = 0,12 do begin 
  if j eq 0 then begin ; 2002
      year = 2002
      infile = indir+'Finnv15_2002_06032015_identity.csv'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
      infile = indir+'Finnv15_2003_06032015_identity.csv'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
      infile = indir+'Finnv15_2004_06032015_identity.csv'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
      infile = indir+'Finnv15_2005_06032015_identity.csv'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
      infile = indir+'Finnv15_2006_06032015_identity.csv'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
      infile = indir+'Finnv15_2007_06032015_identity.csv'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
      infile = indir+'Finnv15_2008_06032015_identity.csv'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
      infile = indir+'Finnv15_2009_06032015_identity.csv'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
      infile = indir+'Finnv15_2010_06032015_identity.csv'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
      infile = indir+'Finnv15_2011_06032015_identity.csv'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = indir+'Finnv15_2012_06032015_identity.csv'
  endif
  if j eq 11 then begin ; 2013
    year = 2013
      infile = indir+'Finnv15_2013_06032015_identity.csv'
  endif
  if j eq 12 then begin ; 2014
    year = 2014
      infile = indir+'Finnv15_2014_06032015_identity.csv'
  endif
    
yearnum = year

print, 'Year = ', year
print,'Reading: ',infile





;nfires = nlines(infile)-1
;longi = fltarr(nfires)
;lati = fltarr(nfires)
;day = intarr(nfires)
;genveg = intarr(nfires)
;co = fltarr(nfires)
;pm25 = fltarr(nfires)
;
;openr,ilun,infile,/get_lun
;sdum=' '
;readf,ilun,sdum
;print,sdum
;vars = Strsplit(sdum,',',/extract)
;nvars = n_elements(vars)
;for i=0,nvars-1 do print,i,': ',vars[i]
;  data1 = fltarr(nvars)
;;  1         2    3      4        5       6   7      8          9    10      11      12     13      14         15        16        17         18       19       20        21  22   23
;;FID_Finnv1,day,genveg,latitude,longitude,CO,PM2_5,FID_admin_,NAME,COUNTRY,ISO_CODE,ISO_CC,ISO_SUB,ADMINTYPE,DISPUTED,NOTES,AUTONOMOUS,COUNTRYAFF,CONTINENT,Land_Type,Land_Rank,perHeatDay
;; Emissions are in kg/km2/day
;for k=0L,nfires-1 do begin
;  readf,ilun,data1
;  longi[k] = data1[4]
;  lati[k] = data1[3]
;  day[k] = data1[1]
;  genveg[k] = data1[2]
;  co[k] = data1[5]
;  pm25[k] = data1[6]
;endfor
;close,ilun
;free_lun,ilun

        
 
;  1         2    3      4        5       6   7      8          9    10      11      12     13      14         15        16        17         18       19       20        21  22   23
;FID_Finnv1,day,genveg,latitude,longitude,CO,PM2_5,FID_admin_,NAME,COUNTRY,ISO_CODE,ISO_CC,ISO_SUB,ADMINTYPE,DISPUTED,NOTES,AUTONOMOUS,COUNTRYAFF,CONTINENT,Land_Type,Land_Rank,perHeatDay

; Emissions are in kg/km2/day

        intemp=ascii_template(infile)
        data1=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(data1.field01)
        print, 'Finished reading input file'


  longi = data1.field05
  lati = data1.field04
  day = data1.field02
  co = data1.field06
  pm25 = data1.field07
  admin =data1.field09
  cntry = data1.field10
        
        
print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
print, "Miniumum Latitude = ",min(lati)
print, "Miniumum Longitude = ",min(longi)
;print, "Miniumum GENVEG = ",min(GENVEG)


numfires = n_elements(day)

; Set up months/days 
monthset = intarr(13)
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
  
 for l = 0,11 do begin ; sum over months for each year
 
      today = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'Florida' or admin eq 'Georgia' or admin eq 'South Carolina' or admin eq 'Mississippi'))
      today2 = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'Arkansas' or admin eq 'Mississippi' or admin eq 'Louisiana'))
      today3 = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'Texas'))
      today4 = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'New Mexico' or admin eq 'Colorado' or admin eq 'Wyoming' or admin eq 'Montana' or admin eq 'Idaho' or admin eq 'Washington' or admin eq 'Oregon' or admin eq 'California' or admin eq 'Arizona' or admin eq 'Nevada' or admin eq 'Utah'))
      today6= where(day ge monthset[l] and day lt monthset[l+1] and (cntry eq 'Mexico'))
      today5 = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'North Dakota' or admin eq 'South Dakota' or admin eq 'Nebraska' or admin eq 'Kansas' or admin eq 'Oklahoma'))
 ;      today = where(day ge monthset[l] and day lt monthset[l+1] and (cntry eq 'Canada') and (longi lt -101.))
 ;     today = where(day ge monthset[l] and day lt monthset[l+1] and lati ge 22.5 and lati le 40.5 and longi ge -113. and longi le -84.)
 ;       today = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'Louisiana'))
       COtot[l,j] = total(co[today]); SEUS: FL, GA, SC, AL
       COtot2[l,j] = total(co[today2]) ; SEUS: ARK/MS/LA
       COtot3[l,j] = total(co[today3]) ; Texas
       COtot4[l,j] = total(co[today4]) ; West US
       COtot5[l,j] = total(co[today5]) ; Great Plains
       COtot6[l,j] = total(co[today6]) ; Mexico
       
 endfor ; end l loop
endfor ; End of j loop over the different input files

; PRINT OUTPUT FILE
  for k = 0,11 do begin
      printf, 1, format = form, k+1, COtot[k,0],COtot[k,1],COtot[k,2],COtot[k,3],COtot[k,4],COtot[k,5],COtot[k,6],COtot[k,7],COtot[k,8],COtot[k,9],COtot[k,10],COtot[k,11],COtot[k,12]
      printf, 2, format = form, k+1, COtot2[k,0],COtot2[k,1],COtot2[k,2],COtot2[k,3],COtot2[k,4],COtot2[k,5],COtot2[k,6],COtot2[k,7],COtot2[k,8],COtot2[k,9],COtot2[k,10],COtot2[k,11],COtot2[k,12]
      printf, 3, format = form, k+1, COtot3[k,0],COtot3[k,1],COtot3[k,2],COtot3[k,3],COtot3[k,4],COtot3[k,5],COtot3[k,6],COtot3[k,7],COtot3[k,8],COtot3[k,9],COtot3[k,10],COtot3[k,11],COtot3[k,12]
      printf, 4, format = form, k+1, COtot4[k,0],COtot4[k,1],COtot4[k,2],COtot4[k,3],COtot4[k,4],COtot4[k,5],COtot4[k,6],COtot4[k,7],COtot4[k,8],COtot4[k,9],COtot4[k,10],COtot4[k,11],COtot4[k,12]
      printf, 5, format = form, k+1, COtot5[k,0],COtot5[k,1],COtot5[k,2],COtot5[k,3],COtot5[k,4],COtot5[k,5],COtot5[k,6],COtot5[k,7],COtot5[k,8],COtot5[k,9],COtot5[k,10],COtot5[k,11],COtot5[k,12]
      printf, 6, format = form, k+1, COtot6[k,0],COtot6[k,1],COtot6[k,2],COtot6[k,3],COtot6[k,4],COtot6[k,5],COtot6[k,6],COtot6[k,7],COtot6[k,8],COtot6[k,9],COtot6[k,10],COtot6[k,11],COtot6[k,12]
 endfor
 
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