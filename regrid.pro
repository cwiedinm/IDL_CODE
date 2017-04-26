; THis program is written to process the output from Matt & My Paper
; onto a grid. 
; November 25, 2009

pro regrid

close, /all

infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\FIREEMIS_2008_RX.txt'
inload3=ascii_template(infile)
datain=read_ascii(infile, template=inload3)
; j,longi,lat,day,LANDFIRE,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state,FED
lat = datain.field03
lon = datain.field02
co2 = datain.field13

outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2008_RX.txt'
openw, 1, outfile
printf, 1, 'ID, LAT, LONG, CO2total'
form = '(I9,3(",",F25.15))'

; Grid starts at grid number zero, lat: 31.017; Long -124.983
; increases by X first (long) then by lat
; has 690 columns and 570 rows
; increase by 0.033 degrees at each step

xorig = -124.983
yorig = 31.017
delta = 0.033
id = 0L

print, 'Starting Loop'

for i = 0,689 do begin
 for j = 0,569 do begin
      xcent = xorig+i*0.033
      ycent = yorig+j*0.033
      ingrid = where((lat ge (ycent-(0.033/2))) and (lat lt ycent+(0.033/2)) and (lon ge (xcent-(0.033/2))) and (lon lt (xcent+(0.033/2))))
      if ingrid[0] eq -1 then begin
        co2tot = 0.0
        printf, 1, format = form, id, ycent, xcent, co2tot
        goto, skip
      endif
      co2tot= total(co2[ingrid])
      printf, 1, format = form, id, ycent, xcent, co2tot
      skip:
      id = id+1
  endfor
endfor

print, 'id = ', id

close, /all
print, 'The End'
end

       
     