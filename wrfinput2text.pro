; This file will read in a wrfinput file and create a text file with the 
; xlat and xlong data for reading into GIS. 
; Created August 31, 2010
; Edited 10/2/2010 to process Oivind's file

pro wrfinput2text
close, /all


;filename = 'F:\Data2\wildfire\Jeff_LEE\ASIA\wrfinput_d01'
filename = 'F:\Data2\wildfire\WRFCHEM\OIVIND\wrfinput_d01.nc'
nc_id=ncdf_open(filename)
ncdf_varget,nc_id,'XLAT',XLAT
ncdf_varget,nc_id,'XLONG',XLONG
ncdf_close,nc_id

; NOTE: XLAT and XLONG will have the index [columns, rows]

n_columns = n_elements(XLAT[*,0])
n_rows = n_elements(XLAT[0,*])

count = 0

openw, 1, 'F:\Data2\wildfire\WRFCHEM\OIVIND\wrfinput_d01_text.txt'
printf, 1, 'GRIDID, X, Y, LATITUDE, LONGITUDE'
form = '(I10,",",I5,",",I5,",",F20.10,",",F20.10)'

for i = 0,n_columns-1 do begin
  for j = 0,n_rows-1 do begin
    count = count+1
    printf, 1, format = form, count, i+1,j+1,XLAT[i,j],XLONG[i,j]
  endfor
endfor


close, /all
end
