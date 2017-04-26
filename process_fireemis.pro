; THis program will do analysis on the fire emissions files created in January 2010
; Created 01/30/2010
; 
; MAY 03, 2010
;   - edited to process the Emission Estimates made in February 2010 and May 2010
;   - includes global regions and daily output
; 

pro process_fireemis

close, /all

infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JAN2010\GLOB_2006_01262010.txt'
output = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JAN2010\PROCESS\FIREEMIS_GLOB_2006_PROCESS_JEROME.txt'

openw, 1, output

print, 1, 'All Emissions 2006, processed Feb. 2010, '+infile

; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18  19 20  21  22   23   24   25  26 27 28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,FACTOR
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
    NOX = fire.field17
    NO = fire.field18
    NO2 = fire.field19
    NH3 = fire.field20
    SO2 = fire.field21
    VOC = fire.field23
    CH4 = fire.field15
    NMHC = fire.field22
    TPM = fire.field25

    
Printf, 1, 'GLOBAL TOTALS (Tg Species)'
Printf, 1, 'CO2, ', total(CO2)/1.e9
Printf, 1, 'CO, ', total(CO)/1.e9
Printf, 1, 'NOX, ', total(NOX)/1.e9
Printf, 1, 'NO, ', total(NO)/1.e9
Printf, 1, 'NO2, ', total(NO2)/1.e9
Printf, 1, 'NH3, ', total(NH3)/1.e9
Printf, 1, 'SO2, ', total(SO2)/1.e9
Printf, 1, 'VOC, ', total(VOC)/1.e9
Printf, 1, 'CH4, ', total(CH4)/1.e9
Printf, 1, 'OC, ', total(OC)/1.e9
Printf, 1, 'BC, ', total(BC)/1.e9
Printf, 1, 'PM2.5, ', total(PM25)/1.e9
Printf, 1, 'TPM, ', , total(TPM)/1.e9
Printf, 1, 'NMHC, ', , total(NMHC)/1.e9

; WESTERN U.S. 
westUS = where(lati gt 24. and lati lt 49. and longi gt -124. and longi lt -100.)   
Printf, 1, 'Western US (Mg Species)'
Printf, 1, 'CO2, ', total(CO2[westUS])/1.e6
Printf, 1, 'CO, ', total(CO[westUS])/1.e6
Printf, 1, 'NOX, ', total(NOX[westUS])/1.e6
Printf, 1, 'NO, ', total(NO[westUS])/1.e6
Printf, 1, 'NO2, ', total(NO2[westUS])/1.e6
Printf, 1, 'NH3, ', total(NH3[westUS])/1.e6
Printf, 1, 'SO2, ', total(SO2[westUS])/1.e6
Printf, 1, 'VOC, ', total(VOC[westUS])/1.e6
Printf, 1, 'CH4, ', total(CH4[westUS])/1.e6
Printf, 1, 'OC, ', total(OC[westUS])/1.e6
Printf, 1, 'BC, ', total(BC[westUS])/1.e6
Printf, 1, 'PM2.5, ', total(PM25[westUS])/1.e6
Printf, 1, 'TPM, ', total(TPM[westUS])/1.e6
Printf, 1, 'NMHC, ', total(NMHC[westUS])/1.e6

; EASTERN U.S. 
eastUS = where(lati gt 24. and lati lt 49. and longi gt -100. and longi lt -60.)   
Printf, 1, 'Eastern US (Mg Species)'
Printf, 1, 'CO2, ', total(CO2[eastUS])/1.e6
Printf, 1, 'CO, ', total(CO[eastUS])/1.e6
Printf, 1, 'NOX, ', total(NOX[eastUS])/1.e6
Printf, 1, 'NO, ', total(NO[eastUS])/1.e6
Printf, 1, 'NO2, ', total(NO2[eastUS])/1.e6
Printf, 1, 'NH3, ', total(NH3[eastUS])/1.e6
Printf, 1, 'SO2, ', total(SO2[eastUS])/1.e6
Printf, 1, 'VOC, ', total(VOC[eastUS])/1.e6
Printf, 1, 'CH4, ', total(CH4[eastUS])/1.e6
Printf, 1, 'OC, ', total(OC[eastUS])/1.e6
Printf, 1, 'BC, ', total(BC[eastUS])/1.e6
Printf, 1, 'PM2.5, ', total(PM25[eastUS])/1.e6
Printf, 1, 'TPM, ', total(TPM[eastUS])/1.e6
Printf, 1, 'NMHC, ', total(NMHC[eastUS])/1.e6

; CANADA/AK 
CANAK = where(lati gt 49. and lati lt 70. and longi gt -170. and longi lt -55.)   
Printf, 1, 'Canada/Alaska (Mg Species)'
Printf, 1, 'CO2, ', total(CO2[CANAK])/1.e6
Printf, 1, 'CO, ', total(CO[CANAK])/1.e6
Printf, 1, 'NOX, ', total(NOX[CANAK])/1.e6
Printf, 1, 'NO, ', total(NO[CANAK])/1.e6
Printf, 1, 'NO2, ', total(NO2[CANAK])/1.e6
Printf, 1, 'NH3, ', total(NH3[CANAK])/1.e6
Printf, 1, 'SO2, ', total(SO2[CANAK])/1.e6
Printf, 1, 'VOC, ', total(VOC[CANAK])/1.e6
Printf, 1, 'CH4, ', total(CH4[CANAK])/1.e6
Printf, 1, 'OC, ', total(OC[CANAK])/1.e6
Printf, 1, 'BC, ', total(BC[CANAK])/1.e6
Printf, 1, 'PM2.5, ', total(PM25[CANAK])/1.e6
Printf, 1, 'TPM, ', total(TPM[CANAK])/1.e6
Printf, 1, 'NMHC, ', total(NMHC[CANAK])/1.e6

; Mexico and Central America 
MXCA = where(lati gt 10. and lati lt 28. and longi gt -120. and longi lt -65.)   
Printf, 1, 'Mexico/Central America (Mg Species)'
Printf, 1, 'CO2, ', total(CO2[MXCA])/1.e6
Printf, 1, 'CO, ', total(CO[MXCA])/1.e6
Printf, 1, 'NOX, ', total(NOX[MXCA])/1.e6
Printf, 1, 'NO, ', total(NO[MXCA])/1.e6
Printf, 1, 'NO2, ', total(NO2[MXCA])/1.e6
Printf, 1, 'NH3, ', total(NH3[MXCA])/1.e6
Printf, 1, 'SO2, ', total(SO2[MXCA])/1.e6
Printf, 1, 'VOC, ', total(VOC[MXCA])/1.e6
Printf, 1, 'CH4, ', total(CH4[MXCA])/1.e6
Printf, 1, 'OC, ', total(OC[MXCA])/1.e6
Printf, 1, 'BC, ', total(BC[MXCA])/1.e6
Printf, 1, 'PM2.5, ', total(PM25[MXCA])/1.e6
Printf, 1, 'TPM, ', total(TPM[MXCA])/1.e6
Printf, 1, 'NMHC, ', total(NMHC[MXCA])/1.e6

; Mexico City and areas 
;MCMA = where(lati gt 18.5 and lati lt 20.5 and longi gt -100. and longi lt -98.)  
;for i = 59,90 do begin
;today = where(day[MCMA] eq i)
;Printf, 1, 'Mexico City for Jerome, kg'
;Printf, 1, 'JD = ,', i+1
;Printf, 1, 'CO2, ', total(CO2[MCMA[today]])
;Printf, 1, 'CO, ', total(CO[MCMA[today]])
;Printf, 1, 'NOX, ', total(NOX[MCMA[today]])
;Printf, 1, 'NO, ', total(NO[MCMA[today]])
;Printf, 1, 'NO2, ', total(NO2[MCMA[today]])
;Printf, 1, 'NH3, ', total(NH3[MCMA[today]])
;Printf, 1, 'SO2, ', total(SO2[MCMA[today]])
;Printf, 1, 'VOC, ', total(VOC[MCMA[today]])
;Printf, 1, 'CH4, ', total(CH4[MCMA[today]])
;Printf, 1, 'OC, ', total(OC[MCMA[today]])
;Printf, 1, 'BC, ', total(BC[MCMA[today]])
;Printf, 1, 'PM2.5, ', total(PM25[MCMA[today]])  
; endfor 

print, 'The End!!'


close, /all
END