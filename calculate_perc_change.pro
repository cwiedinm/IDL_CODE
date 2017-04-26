; Calculate the % change for a year

pro calculate_perc_change

close, /all

; Neeed to read in all output files and then average over the co2 for each grid

file1= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2001_NORX.txt'
inload3=ascii_template(file1)
datain=read_ascii(file1, template=inload3)
id = datain.field1
lat = datain.field2
lon = datain.field3
co2a = datain.field4

file2= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2001_RX.txt'
inload3=ascii_template(file2)
datain2=read_ascii(file2, template=inload3)
co2b = datain2.field4

; OUTPUT FILE
outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2001_PERC.txt'
openw, 1, outfile
printf, 1, 'ID, LAT, LON, CO2NORX, CO2RX, PERCRED'
form = '(I10, 5(",",F25.10))'

num = n_elements(id)
percred = fltarr(num)

print, 'Starting loop'
for i = 0L,num-1 do begin
  percred[i] = ((co2b[i]-co2a[i])/(co2a[i]+0.0000000000001))*100.
  ;if percred[i] lt 1.e-3 then percred[i] = 0.0
  printf, 1, format= form, id[i],lat[i],lon[i],co2a[i],co2b[i],percred[i]
endfor

close, /all
end

  