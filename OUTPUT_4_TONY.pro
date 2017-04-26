; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; NOv. 13, 2012
; This program outputs the Nitrogen specifc MOZ4 outputs to Tony Prenni
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro OUTPUT_4_TONY

close, /all

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOVEMBER2012\SPECIATE\GLOB2012_MOZ4_11082012.txt'
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOVEMBER2012\SPECIATE\TONY_MOZ4_11132012.txt'

openw, 5, outfile

printf, 5, 'DAY,LATI,LONGI,CO2,CO,NO,NO2,NH3,HCN,CH3CN,PM25,OC,BC,PM10'  ; 11
form='(I6,13(",",D20.10))'


; Open input file and get the needed variables
	    intemp=ascii_template(infile)
      fire=read_ascii(infile, template=intemp)
        ; Emissions are in kg/km2/day

;  1    2   3      4    5     6    7  8  9  10 11  12  13  14  15   16     17     18     19     20    21    22   23   24   25   26     27       28       29      30    31     32     33   34   35   36  37  38   39   40      41   42 43  44  45     46
; DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2' 

    longi = fire.field05
    lati= fire.field04
    day = fire.field01
    jday = day
;    time = fire.field04
;    lct = fire.field05
;    genveg = fire.field06
	  CO2 = fire.field07
		CO = fire.field08
		OC = fire.field42
		BC = fire.field43
		PM25 = fire.field41
		PM10 = fire.field29 ; Added 08/19/2010
;		NOX = fire.field17
		NO = fire.field10
		NO2 = fire.field11
		NH3 = fire.field13
;		SO2 = fire.field21
;		VOC = fire.field23
;		CH4 = fire.field15
;		H2 = fire.field16 ; added 09/29/2010
;		area = fire.field11 ; added 03/10/2011; should be in m2
    HCN = fire.field38
    CH3CN = fire.field39
   	numfires = n_elements(day)
		nfires = numfires

    
;-------------------------------
; DO LOOP OVER ALL FIRES
;-------------------------------
for i = 0L,numfires-1 do begin

; CLIP OUT ONLY CONUS FOR 2011 FIRES
latmin = 15.
latmax = 55.
longmin = -126.
longmax = -65.
if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt longmax or longi[i] lt longmin) then goto, skipfire
daymin = 122
daymax = 275
if day[i] gt daymax or day[i] lt daymin then goto, skipfire

; printf, 5, 'DAY,LATI,LONGI,CO2,CO,NO,NO2,NH3,HCN,CH3CN,PM25,OC,BC,PM10'  ; 11

printf, 5, format = form, day[i], lati[i], longi[i], CO2[i], CO[i], NO[i], NO2[i], NH3[i], HCN[i], CH3CN[i], $
      PM25[i], OC[i], BC[i], PM10[i]
      


; 

skipfire:

endfor ; end of i loop


; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
