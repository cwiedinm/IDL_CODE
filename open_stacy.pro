; Open Stacy's file and create one that I can read in GIS

pro open_stacy

close, /all

;STACY's domain (03.17.2011)
path = 'F:\Data2\wildfire\WRFCHEM\STACY\BIG_GRID\CHECK_03222011\'
filename = path+'Stacy_output.nc'

nc_id=ncdf_open(filename)
ncdf_varget,nc_id,'MEAN_FCT_AGEF',MEAN_FCT_AGEF
ncdf_varget,nc_id,'MEAN_FCT_AGGR',MEAN_FCT_AGGR
ncdf_varget,nc_id,'MEAN_FCT_AGSV',MEAN_FCT_AGSV
ncdf_varget,nc_id,'MEAN_FCT_AGTF',MEAN_FCT_AGTF
ncdf_close,nc_id

numx = 159 
numy = 149

gridcode = 0

openw, 1, path+'Stacy_out_GIS.txt'
printf, 1, 'GRIDCODE, AGEF,AGGR, AGSV, AGTF'

for i = 0,numx-1 do begin
  for j = 0,numy-1 do begin
    gridcode = gridcode+1
    printf, 1, gridcode,",", MEAN_FCT_AGEF[i,j],",",MEAN_FCT_AGGR[i,j],",",MEAN_FCT_AGSV[i,j],",",MEAN_FCT_AGTF[i,j]
  endfor
endfor

close, /all

end
  

