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

pro CLIP_global_daily_emis_TexasItaqclip2
t0 = systime(1) ;Procedure start time in seconds
close, /all


output1 = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\ITAQ\Process\DAily_CO_emiss_12kmDomain.txt'
openw, 1, output1
printf, 1, 'day,Y2002,Y2003,Y2004,Y2005,Y2006,Y2007,Y2008,Y2009,Y2010,Y2011,Y2012'
form = '(I6,11(",",D25.10))'

COtot = fltarr(365,11)

indir = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\ITAQ\Process\'

for j = 0,10 do begin 
  if j eq 0 then begin ; 2002
      year = 2002
      infile = indir+'NACA_DailyEmiss_ident_2002.txt'
  endif
  if j eq 1 then begin ; 2003
      year = 2003
      infile = indir+'NACA_DailyEmiss_ident_2003.txt'
  endif
  if j eq 2 then begin ; 2004
    year = 2004
      infile = indir+'NACA_DailyEmiss_ident_2004.txt'
  endif
  if j eq 3 then begin ; 2005
      year = 2005
      infile = indir+'NACA_DailyEmiss_ident_2005.txt'
  endif
  if j eq 4 then begin ; 2006
    year = 2006
      infile = indir+'NACA_DailyEmiss_ident_2006.txt'
  endif
  if j eq 5 then begin ; 2007
      year = 2007
      infile = indir+'NACA_DailyEmiss_ident_2007.txt'
  endif
  if j eq 6 then begin ; 2008
      year = 2008
      infile = indir+'NACA_DailyEmiss_ident_2008.txt'
  endif
  if j eq 7 then begin ; 2009
    year = 2009
      infile = indir+'NACA_DailyEmiss_ident_2009.txt'
  endif
  if j eq 8 then begin ; 2010
    year = 2010
      infile = indir+'NACA_DailyEmiss_ident_2010.txt'
  endif
  if j eq 9 then begin ; NEW 2011 (03/2012)
    year = 2011
      infile = indir+'NACA_DailyEmiss_ident_2011.txt'
  endif
  if j eq 10 then begin ; 2012
    year = 2012
      infile = indir+'NACA_DailyEmiss_ident_2012.txt'
  endif
    
yearnum = year

print, 'Year = ', year
print,'Reading: ',infile


;  1    2         3   4        5         6     7  8    9   10   11         12        13         14         15         16        17         18       19       20        21  22   23
;FID_,FID_NACA_D,day,genveg,latitude,Longitude,CO,PM25,NOX,VOC,FID_admin0,FIPS_ADMIN,GMI_ADMIN,ADMIN_NAME,FIPS_CNTRY,GMI_CNTRY,CNTRY_NAME,POP_ADMIN,TYPE_ENG,TYPE_LOC,SQKM,SQMI,COLOR_MAP
; Emissions are in kg/km2/day

        intemp=ascii_template(infile)
        data1=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(data1.field01)
        print, 'Finished reading input file'


  longi = data1.field06
  lati = data1.field05
  day = data1.field03
  co = data1.field07
  pm25 = data1.field08
  voc =  data1.field09
  admin =data1.field14
  cntry = data1.field17

        
print, 'finished reading in input file and assigning arrays'
ndays = max(day)   
print, 'Ndays = ', ndays
print, 'Number of fires = ', n_elements(day)
numfires = n_elements(day)
numdays = ndays-1


for l = 0,364 do begin ; sum over days for each year
 ;      today = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'New Mexico' or admin eq 'Colorado' or admin eq 'Wyoming' or admin eq 'Montana' or admin eq 'Idaho' or admin eq 'Washington' or admin eq 'Oregon' or admin eq 'California' or admin eq 'Arizona' or admin eq 'Nevada' or admin eq 'Utah'))
 ;      today = where(day ge monthset[l] and day lt monthset[l+1] and (cntry eq 'Guatemala' or cntry eq 'Belize' or cntry eq 'Honduras' or cntry eq 'Nicaragua' or cntry eq 'Costa Rica' or cntry eq 'Panama'))
 ;     today = where(day ge monthset[l] and day lt monthset[l+1] and (admin eq 'California'))
      today = where(day eq l+1 and lati ge 22.5 and lati le 40.5 and longi ge -113. and longi le -84.)
       COtot[l,j] = total(co[today])
 endfor ; end l loop
endfor ; End of j loop over the different input files

; PRINT OUTPUT FILE
 for k = 0,364 do begin
      printf, 1, format = form, k+1, COtot[k,0],COtot[k,1],COtot[k,2],COtot[k,3],COtot[k,4],COtot[k,5],COtot[k,6],COtot[k,7],COtot[k,8],COtot[k,9],COtot[k,10]
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