; This calculates the 8 year average 
; of percent reduction
; created 11/30/2009

pro create_regrid_percred

close, /all


; Neeed to read in all output files and then average over the co2 for each grid

file1= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2001_PERC.txt'
inload3=ascii_template(file1)
datain=read_ascii(file1, template=inload3)
id = datain.field1
lat = datain.field2
lon = datain.field3
co22001NORX = datain.field4
co22001RX = datain.field5
percred2001 = datain.field6

file2= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2002_PERC.txt'
inload3=ascii_template(file2)
datain2=read_ascii(file2, template=inload3)
co22002NORX = datain2.field4
co22002RX = datain2.field5
percred2002 = datain2.field6

file3= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2003_PERC.txt'
inload3=ascii_template(file3)
datain3=read_ascii(file3, template=inload3)
co22003NORX = datain3.field4
co22003RX = datain3.field5
percred2003 = datain3.field6

file4= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2004_PERC.txt'
inload3=ascii_template(file4)
datain4=read_ascii(file4, template=inload3)
co22004NORX = datain4.field4
co22004RX = datain4.field5
percred2004 = datain4.field6

file5= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2005_PERC.txt'
inload3=ascii_template(file5)
datain5=read_ascii(file5, template=inload3)
co22005NORX = datain5.field4
co22005RX = datain5.field5
percred2005 = datain5.field6

file6= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2006_PERC.txt'
inload3=ascii_template(file6)
datain6=read_ascii(file6, template=inload3)
co22006NORX = datain6.field4
co22006RX = datain6.field5
percred2006 = datain6.field6

file7= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2007_PERC.txt'
inload3=ascii_template(file7)
datain7=read_ascii(file7, template=inload3)
co22007NORX = datain7.field4
co22007RX = datain7.field5
percred2007 = datain7.field6

file8= 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\regrid_2008_PERC.txt'
inload3=ascii_template(file8)
datain8=read_ascii(file8, template=inload3)
co22008NORX = datain8.field4
co22008RX = datain8.field5
percred2008 = datain8.field6

; OUTFILE
outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\PROCESS\AVERAGE_REGRID_PERC.txt'
openw, 1, outfile
printf, 1, 'ID, LAT, LONG, AVECO2NORXton, AVECO2RXton, AVEPERCRED'
form = '(I10,5(",",F25.12))'

num = n_elements(co22001NORX)
aveco2NOrx = fltarr(num)
Aveco2RX = fltarr(num)
Avepercred=fltarr(num)

for i = 0L,num-1 do begin
    NORX = [co22001NORX[i],co22002NORX[i],co22003NORX[i],co22004NORX[i],co22005NORX[i],co22006NORX[i],co22007NORX[i],co22008NORX[i]]
    RX = [co22001RX[i],co22002RX[i],co22003RX[i],co22004RX[i],co22005RX[i],co22006RX[i],co22007RX[i],co22008RX[i]]
    PERCRED = [percred2001[i],percred2002[i],percred2003[i],percred2004[i],percred2005[i],percred2006[i],percred2007[i],percred2008[i]] 
    aveco2NORX[i] = mean(NORX)/1000.
    AVECO2RX[i] = mean(RX)/1000.
    AVEPERCRED[i] = mean(percred)
    printf, 1, format = form, ID[i],LAT[i], LON[i], AVECO2NORX[i], AVECO2RX[i],AVEPERCRED[i]
endfor

close, /all
end
