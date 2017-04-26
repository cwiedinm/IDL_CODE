; Create a grid text file
; code written 12/05/2016
; 

pro create_grid_text

close, /all

openw, 1, 'E:\Data1\GIS_STUFF\GIS_tools\GISData\CHINA\text_0.1degree_grid.txt'
printf, 1, 'Latitude, Longitude'

; Making file for China
lonmin = 70.
latmin = 17.0

lonmax = 136.
latmax  = 56.0

numlat = (latmax -latmin)*10.
numlon = (lonmax - lonmin)*10.



for i = 0,numlon do begin
  for j = 0,numlat do begin
    printf, 1, latmin+(j*0.1), ",",lonmin+(i*0.1)
  endfor
endfor


close, /all

end