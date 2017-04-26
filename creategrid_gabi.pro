; This program is to create a comma-delimited text file
; for GIS of the CMAQ domain for the EPA STAR project with Tan and Janda
; Created May 12, 2004
; Edited on May 25, 2007. This past version assumed that the lower left corner was the center of the grid cell
; Changed so that the coordinates (-2628, -1980) are the lower left, not the center

; Edited to create a file for Gabi (09/28/2012)
; Edited to create a file for Gabi (02/07/2014)

pro creategrid_gabi

close, /all

openw, 1, 'E:\Data2\wildfire\COLORADO\GABI\domain_grid_09282012.txt'

;The  Denver 12k grid definition is:
;origin (southwest corner) at  (-2388000, -948000) 
;239  by 206 cells (i x j)

gridsize = 12000
nrows = 206
ncols = 239

lon=fltarr(ncols+2)
lat=fltarr(nrows+2)

lon[0]=-2388000.-6000. ; creating an extra layer of grid cells
lat[0]=-948000.-6000.	; these are the center of the outer grid cell

; set up the latitudes
for i = 1,ncols+1 do begin
	lon[i]=lon[i-1]+gridsize
endfor
; Set up longitude
for j = 1,nrows+1 do begin
	lat[j]=lat[j-1]+gridsize
endfor

; Print to output file
printf, 1, 'Longitude,latitude'
for i=0,ncols+1 do begin
	for j = 0,nrows+1 do begin
		printf, 1, lon[i], ',',lat[j]
	endfor
endfor

close, /all

end
