; This program will calculate monthly totals per land cover type
; ReWriting this program on 02/02/2007 because
; results from ACCESS were weird.
; Monthly sums are in kg/month
; Edited January 24, 2007 to include Hg in output summaries (and edited states file
;   to include all 50 states)
; Now prints out a file for each compound in a better format
;

pro summary_LU_reg

close, /all



; Set input file
path = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\Output_JAN2007\FINAL_OUTPUT_Files\'
; 2002
infile = path + 'Modelout_2002_01292007_admin.txt'
; 2003
;infile = path + 'Modelout_2003_01242007Hg_b.txt'
;2004
;infile = path + 'Modelout_2004_01242007Hg_b.txt'
;2005
;infile = path + 'Modelout_2005_GLC_Feb09_2007.txt'
;2006
;infile = path + 'Modelout_2006_GLC_01242007Hg.txt'

; Edited States file to include all 50 states
instate = 'D:\Data2\EPA_EI\Brad_files\2006_RSAC_10022006\Model_output\states.csv'

year = '2002'

; OPEN INPUT FILE
 input=ascii_template(infile)
 data=read_ascii(infile, template=input)
; j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state
; j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,ADMIN_NAME,
 day1 = data.field04
 LU1 = data.field05
 CO21 = data.field12
 CO1 = data.field13
 PM251 = data.field15
 state = data.field25
 Hg1 = data.field23
cntry = data.field24

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

; Chose EPA region and year to run...
; Can only chose 4, 6, 8, 9, 10
; Make sure that you edit which input files to bring in (above)
for p = 0, 4 do begin
    if p eq 0 then begin
       ext = 'Reg4'
       region = 4
    endif
    if p eq 1 then begin
      ext = 'Reg6'
       region = 6
    endif
    if p eq 2 then begin
      ext = 'Reg8'
       region = 8
    endif
    if p eq 3 then begin
      ext = 'Reg9'
       region = 9
    endif
    if p eq 4 then begin
      ext = 'Reg10'
       region = 10
    endif

; Set output file
outfile = path +'Emis_LU_CO_summ_'+year+'_'+ext+'.txt'
outfile2 = path + 'Emis_LU_Hg_summ_'+year+'_'+ext+'.txt'

openw, 1, outfile
printf, 1, 'LUtype,JanCO,FebCO,MarCO,AprCO,MayCO,JunCO,JulCO,AugCO,SepCO,OctCO,NovCO,DecCO'
form = '(A20,12(",",D20.5))'

openw, 2, outfile2
printf, 2, 'LUType,JanHg,FebHg,MarHg,AprHg,MayHg,JunHg,JulHg,AugHg,SepHg,OctHg,NovHg,DecHg'

; open STATE file
;inst = ascii_template(instate)
;statein = read_ascii(instate, template=inst)
;stlist = statein.field2
;numstates = n_elements(stlist)


if region eq 4 then begin
    us = where(state eq 'Alabama' or state eq 'Florida' or state eq 'Georgia' $
       or state eq 'Kentucky' or state eq 'Mississippi' or state eq 'North Carolina' $
       or state eq 'South Carolina' or state eq 'Tennessee')
endif
if region eq 6 then begin
    us = where(state eq 'Louisiana' or state eq 'Arkansas' or state eq 'Oklahoma' or $
        state eq 'New Mexico' or state eq 'Texas')
endif
if region eq 8 then begin
    us = where(state eq 'Colorado' or state eq 'Montana' or state eq 'North Dakota' or $
       state eq 'South Dakota' or state eq 'Utah' or state eq 'Wyoming')
endif
if region eq 9 then begin
    us = where(state eq 'California' or state eq 'Arizona' or state eq 'Nevada')
endif
if region eq 10 then begin
    us = where(state eq 'Washington' or state eq 'Oregon' or state eq 'Idaho')
endif

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
printf, 2, format = form, LUtype, sumHg[0],sumHg[1],sumHg[2],sumHg[3],sumHg[4],sumHg[5],$
    sumHg[6],sumHg[7],sumHg[8],sumHg[9],sumHg[10],sumHg[11]

         sumCO2 = 0.
         sumco = 0.
         sumpm25 = 0.
         sumhg = 0.
skipstate:
endfor ; end k loop

close, /all
day = 0
LU  = 0
CO2 = 0
CO = 0
PM25 = 0
Hg = 0
us = 0

endfor
print, 'ALL FINISHED!!'

end
