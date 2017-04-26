; Code to process Ed Hyer's AOD data
; The files are in monthly directories
; Each file is a 6 hour forecast
; The format of the name of the file is : 
;   YYYYMMDDHH_aod where HH is either 00, 06, 12, 18
;The file is a tab-delimited text file with the following fields: 
; LON, LAT, SULFATE AOD, DUST AOD, SMOKE AOD, SALT AOD, TOTAL AOD
; This program will: 
; a) clip out the continental US (or NA?)
; b) Sum up the daily and then the monthly AOD for each 1 degree x 1 degree cell
; c) output a file that I can use in GIS for a dissolve

; Created August 14, 2012

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

pro process_hyer_aod

close, /all

; Do an entire year 
year = '2005'
dirin = 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\'

; First, loop over each month: 
for i = 0,11 do begin
  print, 'Month being processed:', i+1
  ; Set up name of monthly directory
  if i eq 0 then begin 
      y = '01'
      ndays = 31
      nfiles = 124
  endif
  if i eq 1 then begin
      y = '02'
      ndays = 28
      nfiles = 112
  endif
  if i eq 2 then begin 
      y = '03'
      ndays = 31
      nfiles = 124
  endif
  if i eq 3 then begin
      y = '04'
      ndays = 30
      nfiles = 120
  endif
  if i eq 4 then begin 
      y = '05'
      ndays = 31
      nfiles = 124
  endif
  if i eq 5 then begin
      y = '06'
      ndays = 30
      nfiles = 120
  endif
  if i eq 6 then begin
      y = '07'
      ndays = 31
      nfiles = 124
  endif
  if i eq 7 then begin 
      y = '08'
      ndays = 31
      nfiles = 124
  endif
  if i eq 8 then begin
      y = '09'
      ndays = 30
      ;nfiles = 120
      nfiles = 120 ; for 2005
  endif
  if i eq 9 then begin 
      y = '10'
      ndays = 31
      nfiles = 124
  endif
  if i eq 10 then begin
      y = '11'
      ndays = 30
      nfiles = 120
  endif
  if i eq 11 then begin
      y = '12'
      ndays = 31
      nfiles = 124
  endif
  indir = dirin+year+y+'\'
  if i eq 10 and year eq '2011' then goto, skipmonth
; Set up monthly file array
; - total AOD for each grid in North America
; only to include longitude: -179.5 to -56.5 and latitude: 10 to 80
    aodtot = fltarr(8680, nfiles+1) ; for AOD for each, and the total
    lat2 = fltarr(8680)
    lon2 = fltarr(8680)
    
; Do loop over each file for the month i
      count = 0 ; to count the number of files in each directory
for j = 0,ndays-1 do begin
; For each day, there are 4 forecasts
  for k = 0,3 do begin
      if k eq 0 then hr = '00'
      if k eq 1 then hr = '06'
      if k eq 2 then hr = '12'
      if k eq 3 then hr = '18'
      if j lt 09 then day ='0'+ strtrim(j+1,2)
      if j gt 09 then day = strtrim(j,2)
      count = count+1
      ;2005010100_aod
      ; DEFINE INPUT FILE #1
      infile = indir+year+y+day+hr+'_aod'
      ; A few files are corrupted when I extracted them; these are skipped. 
      if infile eq 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\200508\2005080618_aod' then goto, skip
      if infile eq 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\200912\2009121706_aod' then goto, skip
      if infile eq 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\200912\2009122512_aod' then goto, skip
      if infile eq 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\201003\2010032512_aod' then goto, skip
      ; NOTE: NOvember 2011 is messed up!!! ; 
      ; 
      ; READ INPUT FILE
      ;print,'Reading: ',infile
      nfires = nlines(infile)
      longi = fltarr(nfires)
      lati = fltarr(nfires)
      aodsmoke = fltarr(nfires)
       openr,ilun,infile,/get_lun
; ***** There are no headers in this file, so I am commenting this section out
;       sdum=' '
;       readf,ilun,sdum
;       print,sdum
;       vars = Strsplit(sdum,' ',/extract)
;       nvars = n_elements(vars)
;       for m=0,nvars-1 do print,m,': ',vars[i]

            data1 = fltarr(7) ; there are 7 fields in each file
;  0     1       2          3         4         5         6
;  LON, LAT, SULFATE AOD, DUST AOD, SMOKE AOD, SALT AOD, TOTAL AOD
;   nfiles = 64800 (1 x 1 degree for globe)

          for n=0L,nfires-1 do begin
          readf,ilun,data1
          longi[n] = data1[0]
          lati[n] = data1[1]
         ; aodsulf[n] = data1[2]
         ; aoddust[n] = data1[3]
          aodsmoke[n] = data1[4]
         ; aodsalt[n] = data1[5]
         ; aodtotal[n] = data1[6]
          endfor ; end n loop
      close,ilun
      free_lun,ilun

      NA = where(longi gt -180. and longi lt -56. and lati gt 10. and lati lt 80.)
      num_NA = n_elements(NA)
      for p = 0,num_NA-1 do begin
          aodtot[p, count]= aodsmoke[NA[p]]
          lon2[p] = longi[NA[p]]
          lat2[p] = lati[NA[p]]
    
      endfor ; end p loop
      skip: 
endfor ; end of k loop (over 1 day)
endfor ; end of j loop (over days in the month)
      openw,1, 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\MONTHLY_SUMMARY\Year'+year+'_month'+y+'.txt'
      printf, 1, 'Longitude, Latitude,totalAOD '
      ;form = '(F12.6,",",F12.6,125(",",F15.10))'
      form = '(F12.6,",",F12.6,",",F15.10)'
      for q = 0,num_NA-1 do begin
          aodtot[q,nfiles] = total(aodtot[q,*])
          printf, 1, format = form, lon2[q],lat2[q],aodtot[q,nfiles]
      endfor ; end of q loop (to print for each month)
      close, 1
skipmonth:
endfor ; end of i loop (over months in the year)
print, 'END OF PROGRAM'
end ; end of program

