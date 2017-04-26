; This program will calculate monthly totals per land cover type
; ReWriting this program on 02/02/2007 because
; results from ACCESS were weird.
; Monthly sums are in kg/state/month
; Edited January 24, 2007 to include Hg in output summaries (and edited states file
;   to include all 50 states)
; Now prints out a file for each compound in a better format
; DECEMBER 10, 2008: Edited for the AGU RX scenarios

pro summary_LU_AGU08

close, /all

; Set input file
path = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\'
infile = path+'Modelout_test_2002_12082008.txt' ; Default output
; infile = path + 'Modelout_test_2002_12092008_RX1.txt' ; RX1 file
; 2002
;infile = path + 'Modelout_2002_01292007_admin.txt'
; 2003
;infile = path + 'Modelout_2003_01242007Hg_b.txt'
;2004
;infile = path + 'Modelout_2004_01242007Hg_b.txt'
;2005
;infile = path + 'Modelout_2005_GLC_Feb09_2007.txt'
;2006
;infile = path + 'Modelout_2006_GLC_01242007Hg.txt'

; Edited States file to include all 50 states
instate = 'E:\wildfire\EPA_EI\Brad_files\2006_RSAC_10022006\Model_output\states.csv'
pathout = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\PROCESS\LU\'
; Set output file
outfile = pathout +'Emis_LU_CO_summ_2002_default.txt'
outfile2 = pathout + 'Emis_LU_CO2_summ_2002_default.txt'

openw, 1, outfile
printf, 1, 'LUtype,JanCO,FebCO,MarCO,AprCO,MayCO,JunCO,JulCO,AugCO,SepCO,OctCO,NovCO,DecCO'
form = '(A20,12(",",D20.5))'

openw, 2, outfile2
printf, 2, 'LUType,JanCO2,FebCO2,MarCO2,AprCO2,MayCO2,JunCO2,JulCO2,AugCO2,SepCO2,OctCO2,NovCO2,DecCO2'

; open STATE file
;inst = ascii_template(instate)
;statein = read_ascii(instate, template=inst)
;stlist = statein.field2
;numstates = n_elements(stlist)

; set up array with last day of each month
month = intarr(12)
month[0] = 31
month[1] = 59
month[2] = 90
month[3] = 120
month[4] = 151
month[5] = 181
month[6] = 212
month[7] = 243
month[8] = 273
month[9] = 304
month[10] = 334
month[11] = 365


; OPEN INPUT FILE
 input=ascii_template(infile)
 data=read_ascii(infile, template=input)
;j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state, FED
 day1 = data.field04
 LU1 = data.field05
 CO21 = data.field12
 CO1 = data.field13
 PM251 = data.field15
 state = data.field25
 Hg1 = data.field23
cntry = data.field24

; CHOSE ONLY WESTERN STATES (12/10/2008)
us = where((state eq 'Arizona') or (state eq 'California') or (state eq 'Colorado') or (state eq 'Idaho') or (state eq 'Montana') or $
		state eq 'Nevada' or state eq 'New Mexico' or state eq 'Oregon' or state eq 'Utah' or state eq 'Washington' or $
		state eq 'Wyoming')
day = day1[us]
LU  = LU1[us]
CO2 = CO21[us]
CO = CO1[us]
PM25 = pm251[us]
Hg = Hg1[us]


fd = 0
; Do a loop over the different generic LU categories
for k = 0,5 do begin
    if k eq 0 then begin
       LUtype = 'BroadTempTropForest'
        firest = where(LU eq 1 or LU eq 2 or LU eq 3 or LU eq 29)
    endif
    if k eq 1 then begin
        LUtype = 'NeedleForest'
        firest = where((LU eq 4 or LU eq 5 or LU eq 20))
    endif
    if k eq 2 then begin
        LUtype = 'MixForest'
        firest = where(LU eq 6 or LU eq 7 or LU eq 8)
    endif
    if k eq 3 then begin
        LUtype = 'Shrub'
        firest = where(LU eq 9 or LU eq 10 or LU eq 11 or LU eq 12)
    endif
    if k eq 4 then begin
        LUtype = 'Grass'
        firest = where((LU ge 13 and LU le 17) or (LU ge 21 and LU le 28))
    endif
    if k eq 5 then begin
        LUtype = 'Crops'
        firest = where((LU ge 18 and LU le 19))
    endif

    if firest[0] lt 0 then begin
        print, 'No Fires in LU', k, ' AT ALL!!?'
        goto, skipstate
    endif

    COmonth = CO[firest] ;these are the emissions for a given Generic LU type
    pm25month = pm25[firest]
    co2month = co2[firest]
    hgmonth = hg[firest]

       ; Loop around each LU and sum over states
         sumCO = fltarr(12)
         sumpm25 = fltarr(12)
         sumCO2 = fltarr(12)
         sumHg = fltarr(12)
for i = 0,11 do begin
    monthnum = i+1
    ; Identify which fires occured during this month
    if (i eq 0) then fd = 1
    if (i ne 0) then fd = (month[i-1]+1)
    firesnow = where(day[firest] ge fd and day[firest] le month[i])
    numfires1 = n_elements(firesnow)

    if firesnow[0] eq -1 then begin
            print, 'No fires in LU', k, ' in month of ', monthnum
            sumCO[i] = 0.0
            sumpm25[i] = 0.0
            sumCO2[i] = 0.0
            sumHg[i] = 0.0
            goto, skipmonth
    endif
            COnow = COmonth[firesnow]
            pm25now = pm25month[firesnow]
            co2now = co2month[firesnow]
            hgnow = hgmonth[firesnow]
            ; calculate totals
              sumCO2[i] = total(CO2now)
              sumCO[i] = total(COnow)
              sumpm25[i] = total(PM25now)
              sumHg[i] = total(hgnow)
skipmonth:
endfor
; print to output file
printf, 1, format = form, LUtype,sumCO[0],sumCO[1],sumCO[2],sumCO[3],sumCO[4],sumCO[5],$
    sumCO[6],sumCO[7],sumCO[8],sumCO[9],sumCO[10],sumCO[11]
printf, 2, format = form, LUtype, sumCO2[0],sumCO2[1],sumCO2[2],sumCO2[3],sumCO2[4],sumCO2[5],$
    sumCO2[6],sumCO2[7],sumCO2[8],sumCO2[9],sumCO2[10],sumCO2[11]

         sumCO2 = 0.
         sumco = 0.
         sumpm25 = 0.
         sumhg = 0.
skipstate:
endfor ; end k loop

close, /all

print, 'ALL FINISHED!!'

end
