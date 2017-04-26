; Edited on 03/18/2010 do make file for Gabi and Anne
; Edited on 02/03/2011 for Gabi's new domains
; Edited on 03/17/2011 for Stacy's domain
; Edited on 03/18/2011 for the big Stacy domain (including southern Mexico)
; Edited on 04/20/2011 for IOWA 60km domain

pro create_modeldomain

close, /all

;path = 'D:\Data2\wildfire\Gabi_Pfister\Fire_Emis2008\Model_Domains\
; path = 'F:\Data2\wildfire\Gabi_Pfister\ANNE_B\'
;path = 'F:\Data2\wildfire\Gabi_Pfister\CA_2008\'
; path = 'F:\Data2\wildfire\Gabi_Pfister\DOMAINS_FEB2011\'
;path = 'F:\Data2\wildfire\WRFCHEM\STACY\BIG_GRID\CHECK_03222011\'
path = 'E:\Data2\wildfire\WRFCHEM\IOWA\'
; 
; 12km domain
;filename = path+'wrfinput_d01.CA.12km'
; 4km domain
;filename = path+'wrfinput_d01.CA.4km'
; Rajesh's domain
; filename=path+'wrfinput_d01'
; ANNE B's domain (03.18.2010)
;filename = path+'wrfinput_d02.nc'

; STACY's domain (03.17.2011)
; Iowa file domain

filename = path+'wrfinput_d01b.nc'

nc_id=ncdf_open(filename)
ncdf_varget,nc_id,'XLAT',XLAT
ncdf_varget,nc_id,'XLONG', XLONG
ncdf_close,nc_id

; IOWA domain_01
numx = 249
numy = 249

; STACY DOMAIN_01
;numx = 159
;numy = 149
;
; 
; 12km domain
;numx= 149
;numy = 139

; 4km domain
; numx = 329
; numy = 309

; Rajesh Domain
; numx = 99
; numy= 99

; Ann Domain
;numx = 199
;numy = 129

;Gabi domain 01
;numx = 159
;numy = 149

; Gabi domain 02
;numx = 144
;numy = 180

;d01 has dimensions 139x119
;d02 has dimensions 144x180. 

;numx = 144
;numy = 180

openw, 1, path + 'wrf_domain01_points.txt'
printf, 1, 'GRIDCODE, I, J, LAT, LONG, TROPFOR, TEMPFOR, SHRUB, GRASS'
form = '(I9,",",I5,",",I5,",",F20.08,",",F20.8,",",F20.08,",",F20.8,",",F20.08,",",F20.8)'

gridcode = 0L

for i = 0,numx-1 do begin ; LONG
	for j = 0,numy-1 do begin  ; LAT
		gridcode = gridcode + 1
		printf, 1, format=form, gridcode, i+1,j+1, XLAT[i,j], XLONG[i,j],0.0,0.0,0.0,0.0
	endfor
endfor

close, /all

end