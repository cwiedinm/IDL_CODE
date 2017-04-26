pro process_deeter_Co_amazon

close, /all

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2013\DEETER\AMAZON_dailyemis_SEPT2008.txt'
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\APRIL2013\DEETER\AMAZON_grid_SEPT2008.txt'

openw, 1, outfile
printf, 1, 'LAT, LONG, COkg'
form = '(F9.3,",",F9.3,",",D20.10)'
infuel=ascii_template(infile)
fuel=read_ascii(infile, template=infuel)

lat = fuel.field3
lon = fuel.field4
CO = fuel.field5

lat1 = -25.
lon1 = -80.

numlon = 80
numlat = 60
COgrid = fltarr(numlat,numlon)
COnow = 0.0

For i = 0,numlat-1 do begin
  for j = 0,numlon-1 do begin
    latmin = lat1 +((i*0.5))
    latmax = lat1 +((i+1)*0.5)
    lonmin = lon1 +(j*0.5)
    lonmax = lon1 + ((j+1)*0.5) 
    grid = where(lat gt latmin and lat le latmax and lon gt lonmin and lon le lonmax)
    if grid[0] eq -1 then COnow = 0.00000
    if grid[0] gt -1 then COnow = total(CO[grid]) ; Output in kg
    printf,1,format=form, latmin+0.25, lonmin+0.25,COnow
    COnow = 0.0
 endfor
endfor

close, /all
end
