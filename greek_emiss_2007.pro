; This file extracts only what Solene wants for the 2007 Greek Fires 
; From the fire emissions file
; This code written 12/14/2011
; Christine Wiedinmyer

pro Greek_emiss_2007

close, /all

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_MAY-SEPT2007_09072010.txt'
; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18 19  20  21  22   23   24   25  26 27 28  29    30
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR
; Emissions are in kg/km2/day

    inputfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\GLOB_MAY-SEPT2007_09072010.txt'
    inemis=ascii_template(inputfile)
    map=read_ascii(inputfile, template=inemis)
    
        lat1 = map.field02
        lon1 = map.field01 
        day = map.field03
        time = map.field04
        lct = map.field05
        co = map.field14
        pm25 = map.field24 
        nox = map.field17
        so2 = map.field21 
        nh3 = map.field20
        nmoc = map.field23
        
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\DECEMBER2011\SOLENE\Fire_Emis_Greece_KOSTAS_2007.txt'
openw, 1, outfile
printf, 1, 'LAT, LONG, DAY, LCT, CO, PM2.5, NOX, SO2, NH3, NMOC'
form = '(F20.10,",",F20.10,",",I4,",",I4,6(",",F20.10))'

numfires = n_elements(lat1)

for i = 0,numfires-1 do begin
  if lat1[i] lt 30. or lat1[i] gt 49. or lon1[i] lt 11. or lon1[i] gt 36. then goto, skipfire

  printf, 1, format= form, lat1[i],lon1[i],day[i],lct[i],co[i],pm25[i],nox[i],so2[i],nh3[i],nmoc[i]
  skipfire:
endfor

close, /all

end
