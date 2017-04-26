; This is to process the monthly sum files for each year
; from Ed Hyer's AOD from smoke
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
pro process_yearly_summary_HYERaod

close, /all

dir = 'E:\Data2\wildfire\COLORADO\Fires2012\HYER\MONTHLY_SUMMARY\'
;for i = 0,6 do begin ; loop over each year
 i = 6
  if i eq 0  then year = '2005'
  if i eq 1 then year = '2006'
  if i eq 2 then year = '2007'
  if i eq 3 then year = '2008'
  if i eq 4 then year = '2009'
  if i eq 5 then year = '2010'
  if i eq 6 then year = '2011'
  print, 'Processing year:', year
  ; set up arrays
  AODmonth = fltarr(8681,13)
  lati = fltarr(8681)
  longi = fltarr(8681)
  
  
  for j =0,11 do begin ; loop over each month
    if j lt 9 then month ='0'+ strtrim(j+1,2)
    if j gt 9 then month = strtrim(j,2)
    if year eq '2011' and j ge 10 then goto, skipmonth
    infile = dir+'Year'+year+'_month'+month+'.txt'  
    print,'Reading: ',infile
 
      nfires = nlines(infile)
      longi = fltarr(nfires)
      lati = fltarr(nfires)
      aodsmoke = fltarr(nfires)


     openr,ilun,infile,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
       for m=0,nvars-1 do print,m,': ',vars[m]
       data1 = fltarr(nvars) 

;  0     1       2       
;  LON, LAT, totalsmokeAOD
          for n=1L,nfires-1 do begin
          readf,ilun,data1
          longi[n] = data1[0]
          lati[n] = data1[1]
          aodsmoke[n] = data1[2]
 
          ;assign new arrays
          AODmonth[n,j]= aodsmoke[n]
          
          endfor ; end n loop
          close,ilun
          free_lun,ilun
          skipmonth:

  endfor ; end of j loop
    ; Calculate annual total AOD
    for m = 0,nfires-1 do begin
      AODmonth[m,12] = total(AODmonth[m,*])
      ; total(AODmonth[n,0],AODmonth[n,1],AODmonth[n,2],AODmonth[n,3],AODmonth[n,4],AODmonth[n,5],AODmonth[n,6],AODmonth[n,7],AODmonth[n,8],AODmonth[n,9],AODmonth[n,10],AODmonth[n,11])
    endfor ; end of m loop
  ; Print out the file for the year
  outfile =    dir+'Year'+year+'_summary.txt' 
  openw, 1, outfile
  printf, 1, 'LAT, LONG, JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, TOTAL'
  form = '(F25.10,14(",",F25.10))'
  for n = 1,nfires-1 do begin
    printf, 1, format = form, lati[n], longi[n], AODmonth[n,0], AODmonth[n,1], AODmonth[n,2], AODmonth[n,3], AODmonth[n,4], AODmonth[n,5], AODmonth[n,6],$
                AODmonth[n,7], AODmonth[n,8], AODmonth[n,9], AODmonth[n,10], AODmonth[n,11], AODmonth[n,12]
  endfor
  close, /all
  print, 'Finished writing year:', year
;  endfor ; end of i loop
      print, 'END OF PROGRAM'
 end ; End of program