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
;  May 04, 2012
;  - edited to output DAILY fire emissions (All, not total) for CALIFORNIA
;     for Rachel (so only 2007-2009)
;     
;  AUGUST 13, 2013
;  - Edited to process the TEXAS emissions files
;  
;  OCTOBER 2, 2013
;  - Edited to only print out the default version and the NOX species
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

pro process_TEXAS_FIRE_EMISS_SCENARIOS_domain_NOX
t0 = systime(1) ;Procedure start time in seconds
close, /all

year = 2008

for j = 0,0 do begin ; do same processing for every file
  close, /all
  inpath = 'E:\Data2\wildfire\TEXAS\FIRE_2008\MODEL_OUTPUT\'
  if j eq 0 then begin ; 
      infile = inpath + 'FINNv1_TX_default_06252013.txt'
      output1 = inpath + 'FINNv1_TX_default_06252013_SUMMARY_NOX.txt'
  endif
  if j eq 1 then begin ; 
      infile = inpath + 'FINNv1_TX_default_GLOBCOVER_06252013.txt'
      output1 = inpath + 'FINNv1_TX_default_GLOBCOVER_06252013_SUMMARY.txt'
  endif
  if j eq 2 then begin ; 
      infile = inpath + 'FINNv1_TX_default_HIGHemis_06252013.txt'
      output1 = inpath + 'FINNv1_TX_default_HIGHemis_06252013_SUMMARY.txt'
  endif
  if j eq 3 then begin ; 
      infile = inpath + 'FINNv1_TX_default_LOWemis_06252013.txt'
      output1 = inpath + 'FINNv1_TX_default_LOWemis_06252013_SUMMARY.txt'
  endif
  if j eq 4 then begin ; 
      infile = inpath + 'FINNv1_TX_default_newemis_06252013.txt'
      output1 = inpath + 'FINNv1_TX_default_newemis_06252013_SUMMARY.txt'
  endif
  if j eq 5 then begin ; 
      infile = inpath + 'FRMS2008_FCCS.txt'
      output1 = inpath + 'FRMS2008_FCCS_SUMMARY.txt'
  endif
  if j eq 6 then begin ; 
      infile = inpath + 'SMARTFIRE_default2008.txt'
      output1 = inpath + 'SMARTFIRE_default2008_SUMMARY.txt'
  endif
    
openw, 1, output1

printf, 1, 'MOnthly Total Emissions from '+infile
printf, 1, 'state, month, npoints,NO, NO2, NOX'
form = '(A25,",",I4,",",I8,3(",",D25.10))'
  

; INPUT FILES FROM JAN. 29, 2010
;  longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR, state
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
state = strarr(nfires) 

intemp=ascii_template(infile)
data1=read_ascii(infile, template=intemp)
;openr,ilun,infile,/get_lun
;sdum=' '
;readf,ilun,sdum
;print,sdum
;vars = Strsplit(sdum,',',/extract)
;nvars = n_elements(vars)
;for i=0,nvars-1 do print,i,': ',vars[i]
;  data1 = fltarr(nvars)
;;
;;;  0    1   2   3    4   5       6      7         8        9      10   11   12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28    29     30
;
;;
;  1    2   3   4    5   6       7      8         9       10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30     31
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR, state

;FCCS FIle
; 1    2    3   4    5    6    7     8        9    10   11    12  13 14  15 16  17 18  19  20  21   22   23   24  25 26 27  28   29     30
;longi,lat,day,TIME,fccs,lct,genLC,pcttree,pctherb,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR,STATE

; SMARTFIRE FILE
; 1     2    3    4    5  6   7      8      9        10      11     12   13    14  15 16  17 18  19 20  21  22  23   24   25   26  27 28 29  30
;state,longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR

;for k=0L,nfires-1 do begin
;  readf,ilun,data1
;;  oc[k] = data1[25]
;;  bc[k] = data1[26]
;;  nox[k] = data1[16]
;;  nh3[k] = data1[19]
;;  so2[k] = data1[20]
  
;;  tpm[k] = data1[24]
;;  no[k] = data1[17]
;;  NO2[k] = data1[18]
;;  nmhc[k] = data1[21]
;;  voc[k] =  data1[22]
;;  ch4[k] = data1[14]
;;  pm10[k] = data1[28]
if j ge 0 and j le 4 then begin 
  longi = data1.field01
  lati = data1.field02
  day = data1.field03
  co = data1.field14
  pm25 = data1.field24
  state = data1.field31
  no = data1.field18
  no2 = data1.field19
  nox = data1.field17
endif
if j eq 5 then begin
   longi = data1.field01
   lati = data1.field02
   day = data1.field03
   co = data1.field13
   pm25 = data1.field23
   state = data1.field30
endif
if j eq 6 then begin
   longi = data1.field02
   lati = data1.field03
   day = data1.field04
   co = data1.field15
   pm25 = data1.field25
   state = data1.field01  
endif
 state= strtrim(state)
 
;
;endfor
;close,ilun
;free_lun,ilun

print, 'finished reading in input file and assigning arrays'

numfires = n_elements(longi)

for i = 0,11 do begin
        month = i+1
         if month eq 1 then begin 
            daystart = 1
            dayend = 31
         endif
         if month eq 2 then begin 
            daystart = 32
            dayend = 60
         endif
         if month eq 3 then begin 
            daystart = 61
            dayend = 91
         endif
         if month eq 4 then begin 
            daystart = 92
            dayend = 121
         endif
         if month eq 5 then begin 
            daystart = 122
            dayend = 152
         endif
         if month eq 6 then begin 
            daystart = 153
            dayend = 182
         endif
         if month eq 7 then begin 
            daystart = 183
            dayend = 213
         endif
         if month eq 8 then begin 
            daystart = 214
            dayend = 244
         endif
         if month eq 9 then begin 
            daystart = 245
            dayend = 274
         endif
         if month eq 10 then begin 
            daystart = 275
            dayend = 305
         endif
         if month eq 11 then begin 
            daystart = 306
            dayend = 335
         endif
         if month eq 12 then begin 
            daystart = 336
            dayend = 366
         endif
         ntotdays = 366
         monthnow = where(day ge daystart and day le dayend)
         print, 'month = ', month
         if monthnow[0] eq -1 then begin
                print, 'no fires in month ', month, ' and file ', infile
                goto, skip20
         endif
         ;
         ; Get totals by state
         statename = strarr(18)
         statename = ['Texas', 'New Mexico','Arizona', 'California', 'Utah', 'Louisiana', 'Oklahoma', 'Colorado','Wyoming', 'Montana', 'Idaho', 'Washington', 'Oregon', 'Nevada', 'Kansas', 'South Dakota', 'Mississippi', 'Arkansas']
         nstates = n_elements(statename)
         for k = 0,nstates-1 do begin  ; Do loop over state names
              COtotal = 0.0
              PMtotal = 0.0
              NOtotal = 0.0
              NO2total = 0.0
              NOXtotal = 0.0              
              firenow = where(state eq statename[k])
              if firenow[0] eq -1 then begin
                print, 'no fires in month ', month, ' and state ', statename[k]
                goto, skip21
              endif
              COtotal = total(co[monthnow[firenow]])
              PMtotal = total(pm25[monthnow[firenow]])
              NOtotal = total(no[monthnow[firenow]])
              NO2total = total(no2[monthnow[firenow]])
              NOXtotal = total(nox[monthnow[firenow]])
               
              ;
; printf, 1, 'state, month, npoints,NO, NO2, NOX'
;form = '(A25,",",I4,",",I8,3(",",D25.10))' 
            printf, 1, format = form, statename[k] ,month,n_elements(firenow),NOtotal,NO2total,NOXtotal
              skip21:
       endfor ; End loop over states

skip20:
endfor ; end month loop

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