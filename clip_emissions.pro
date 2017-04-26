; This file is created to just clip the overall emissions files
; to smaller regions
; Chreated 09/15/2010

pro clip_emissions

close, /all

infile ='F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_OCT-DEC2008_09082010.txt' 
outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\CLIP\GLOB_OCT-DEC2008_09082010_CLIP.txt' 


; Set up output file for Ed Tai, 09/15/2010
openw, 5, outfile
printf, 5, 'LONG,LAT,DAY,CO,NO,NO2,NH3,SO2,NMOC,PM25,PM10'
form='(D20.10,",",D20.10,",",I5,8(",",D20.10))'

; Open input file and get the needed variables
; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18  19 20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
      intemp=ascii_template(infile)
      fire=read_ascii(infile, template=intemp)
        ; Emissions are in kg/km2/day

; Edited these fields on NOV. 18, 2009
    longi = fire.field01
    lati= fire.field02
    day = fire.field03
    jday = day
    time = fire.field04
    lct = fire.field05
    genveg = fire.field06
    CO2 = fire.field13
    CO = fire.field14
    OC = fire.field26
    BC = fire.field27
    PM25 = fire.field24
    PM10 = fire.field29 ; Added 08/19/2010
    NOX = fire.field17
    NO = fire.field18
    NO2 = fire.field19
    NH3 = fire.field20
    SO2 = fire.field21
    VOC = fire.field23
    CH4 = fire.field15

    nfires = n_elements(day)

; set extent of area that is to be clipped out
latmin = 20.
latmax = 60.
longmin = -125.
longmax = -50.

; Set days to export
daymin = 0.
daymax = 365.


Printf, 5, 'This file is clipped to the region of:'
printf, 5, 'LAT = ', latmin,' to ', latmax, ' and LONG =', longmin, ' to ', longmax
printf, 5, ' '
printf, 5, 'LONG and LAT are in decimal degrees; DAY is the day of the year'
printf, 5, 'Emisisons are in kg species per day'
printf, 5, 'File Created by Christine Wiedinmyer, 09/15/2010'
printf, 5, ' '
 
counter = nfires-1

for i = 0L,counter do begin
 if (lati[i] lt latmin or lati[i] gt latmax or longi[i] lt longmin or longi[i] gt longmax or day[i] lt daymin or day[i] gt daymax) then goto, skipfire
;printf, 5, 'longi,lat,day,CO,NO,NO2,NH3,SO2,NMOC,PM25,PM10'
;form='(D20.10,",",D20.10,",",I5,8(",",D20.10))'
 printf, 5, format = form, longi[i],lati[i],day[i],CO[i],NO[i],NO2[i],NH3[i],SO2[i],VOC[i],PM25[i],PM10[i]
skipfire:
endfor

close, /all
print, 'The End!!'
end
