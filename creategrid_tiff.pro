; This program is to create a comma-delimited text file
; for GIS of the CMAQ domain for the EPA STAR project with Tan and Janda
; Created May 12, 2004
; Edited on May 25, 2007. This past version assumed that the lower left corner was the center of the grid cell
; Changed so that the coordinates (-2628, -1980) are the lower left, not the center

; Edited to create a file for Gabi (09/28/2012)
; Edited to create a file for Gabi (02/07/2014)
; Edited to create a file for Tiff (05/02/2014)

pro creategrid_tiff

close, /all

openw, 1, 'E:\Data3\MIKEH_EPA\TIFF\MCIP\domain_grid_05022014.txt'


NCOLS = 459 ;
NROWS = 299 ;
;    :P_ALP = 33. ;
;    :P_BET = 45. ;
;    :P_GAM = -97. ;
;    :XCENT = -97. ;
;    :YCENT = 40. ;
XORIG = -2556000. ;
YORIG = -1728000. ;
XCELL = 12000 ;
YCELL = 12000 ;


gridsize = XCELL
nrows = 299
ncols = 459

lon=fltarr(ncols+2)
lat=fltarr(nrows+2)

lon[0]=XORIG-(XCELL/2) ; creating an extra layer of grid cells
lat[0]=YORIG-(YCELL/2) ; these are the center of the outer grid cell

; set up the latitudes
for i = 1,ncols+1 do begin
	lon[i]=lon[i-1]+gridsize
endfor
; Set up longitude
for j = 1,nrows+1 do begin
	lat[j]=lat[j-1]+gridsize
endfor

; Print to output file
printf, 1, 'X, Y, Longitude,latitude'
for i=0,ncols+1 do begin
	for j = 0,nrows+1 do begin
		printf, 1, i, ',', j, ',', lon[i], ',',lat[j]
	endfor
endfor

close, /all

end
