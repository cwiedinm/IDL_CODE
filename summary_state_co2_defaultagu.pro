; This program will calculate monthly totals per land cover type
; ReWriting this program on 02/02/2007 because
; results from ACCESS were weird.
; Monthly sums are in kg/state/month
; Edited January 24, 2007 to include Hg in output summaries (and edited states file
;   to include all 50 states)
; Now prints out a file for each compound in a better format
; Edited back on Feb. 09, 2007
; Edited on March 27, 2007 to include a CO2 emissions output file, changed pathways
; APril 16, 2007: This program actually prints out the monthly total emissions
;	 for each state. Editing today to call the most recent output files from
; 	the emissions modeling (from 04/05/07) Also edited to take in any year and AVE, MAX or MIN files
; Edited May 01, 2007 to process only CO2 emissions (for Jason and My paper).
; May 08 - edited the files to be read in. Changed outpaths, changed so that both CO2 and Hg are calculated
; 	output files (Hg and CO2) are sent to different places
; December 09, 2008: Processing new fire estimates for AGU conference


pro summary_state_CO2_defaultAGU

close, /all
 ext = ' '
 year = ' '
read, 'what year are you processing:', year1
	year = String(year1)
	year = STRTRIM(year,2)

; read, 'what are you processing (AVE = 1, MAX = 2, MIN = 3)?:', range
	range = 1
	ext = 'dec102008_default'

; Set input file
; path = 'C:\WORK\FIRE\Fire_EMIS_122008\MODEL_OUTPUT\' ; for laptop
path = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\'

; There are now 3 files for each year: AVE, MIN, and MAX (April 16/2007)

; 2002
if year1 eq 2002 then infile = path + 'Modelout_test_2002_12102008_default.txt'
; 2003
if year1 eq 2003 then infile = path + 'Modelout_test_2003_12102008_default.txt'
; 2004
if year1 eq 2004 then infile = path + 'Modelout_test_2004_12102008_default.txt'
; 2005
if year1 eq 2005 then infile = path + 'Modelout_test_2005_12102008_default.txt'
; 2006
if year1 eq 2006 then infile = path + 'Modelout_test_2006_12102008_default.txt'
;2007
if year1 eq 2007 then infile = path + 'Modelout_test_2007_12102008_default.txt'

; Edited States file to include all 50 states
;instate = 'C:\WORK\FIRE\Fire_EMIS_122008\default_infiles\states.csv' ; for laptop
instate = 'D:\Data2\wildfire\EPA_EI\MODEL\default_infiles\states.csv'

; Set output file
; pathout = 'C:\WORK\FIRE\Fire_EMIS_122008\MODEL_OUTPUT\PROCESS\' ; for laptop
pathout = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\PROCESS\'

outfile = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\PROCESS\CO2\Emis_state_CO2_summ_USonly'+year+ext+'.txt'

outfile2 = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\PROCESS\CO\Emis_state_CO_summ_USonly'+year+ext+'.txt'

outfile3 = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\PROCESS\PM25\Emis_state_PM25_summ_USonly'+year+ext+'.txt'

openw, 1, outfile
printf, 1, 'State,JanCO2,FebCO2,MarCO2,AprCO2,MayCO2,JunCO2,JulCO2,AugCO2,SepCO2,OctCO2,NovCO2,DecCO2'
form = '(A20,12(",",D20.5))'

openw, 2, outfile2
printf, 2, 'State,JanCO,FebCO,MarCO,AprCO,MayCO,JunCO,JulCO,AugCO,SepCO,OctCO,NovCO,DecCO'

openw, 3, outfile3
printf, 3, 'State,JanPM25,FebPM25,MarPM25,AprPM25,MayPM25,JunPM25,JulPM25,AugPM25,SepPM25,OctPM25,NovPM25,DecPM25'

; open STATE file
inst = ascii_template(instate)
statein = read_ascii(instate, template=inst)
stlist = statein.field2
numstates = n_elements(stlist)

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
; j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state, FED
 day = data.field04
; LU1 = data.field05
 CO2 = data.field12
 CO = data.field13
 PM25 = data.field15
 state = data.field25
 Hg = data.field23
 cntry = data.field24

 lat = data.field03

;us = where(cntry eq 'United States')
;day = day1[us]
;LU  = LU1[us]
;CO2 = CO21[us]
;CO = CO1[us]
;PM25 = pm251[us]
;Hg = Hg1[us]


fd = 0
; Do a loop over the different states
for k = 0,numstates-1 do begin
 firest = where(state eq stlist[k])
       if firest[0] lt 0 then begin
        print, 'No Fires in', k, ' AT ALL!!?'
        goto, skipstate
       endif

    COmonth = CO[firest] ;these are the emissions for a given state
    pm25month = pm25[firest]
    co2month = co2[firest]
    hgmonth = hg[firest]

       ; Loop around each month and sum over states
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
            print, 'No fires in state ', stlist[k],' in month of ', monthnum
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
printf, 1, format = form, stlist[k],sumCO2[0],sumCO2[1],sumCO2[2],sumCO2[3],sumCO2[4],sumCO2[5],$
    sumCO2[6],sumCO2[7],sumCO2[8],sumCO2[9],sumCO2[10],sumCO2[11]
printf, 2, format = form, stlist[k], sumCO[0],sumCO[1],sumCO[2],sumCO[3],sumCO[4],sumCO[5],$
    sumCO[6],sumCO[7],sumCO[8],sumCO[9],sumCO[10],sumCO[11]
printf, 3, format = form, stlist[k], sumpm25[0],sumpm25[1],sumpm25[2],sumpm25[3],sumpm25[4],sumpm25[5],$
    sumpm25[6],sumpm25[7],sumpm25[8],sumpm25[9],sumpm25[10],sumpm25[11]


         sumCO2 = 0.
         sumco = 0.
         sumpm25 = 0.
         sumhg = 0.
skipstate:
endfor ; end k loop
; Next - do Alaska!!! Since name isn't in the fire emissions model output file.
 	firest = where(cntry eq 'United States' and lat ge 52.0)
       if firest[0] lt 0 then begin
        print, 'No Fires in Alaska AT ALL!!?'
        goto, skipstate2
       endif

		COmonth = CO[firest] ;these are the emissions for Alaska
	    pm25month = pm25[firest]
	    co2month = co2[firest]
	    hgmonth = hg[firest]

       ; Loop around each month and sum over states
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
            print, 'No fires in state Alaska in month of ', monthnum
            sumCO[i] = 0.0
            sumpm25[i] = 0.0
            sumCO2[i] = 0.0
            sumHg[i] = 0.0
            goto, skipmonth2
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
skipmonth2:
endfor
; print to output file

form2 = '("Alaska",12(",",D20.5))'
printf, 1, format = form2, sumCO2[0],sumCO2[1],sumCO2[2],sumCO2[3],sumCO2[4],sumCO2[5],$
    sumCO2[6],sumCO2[7],sumCO2[8],sumCO2[9],sumCO2[10],sumCO2[11]
printf, 2, format = form, sumCO[0],sumCO[1],sumCO[2],sumCO[3],sumCO[4],sumCO[5],$
    sumCO[6],sumCO[7],sumCO[8],sumCO[9],sumCO[10],sumCO[11]
printf, 3, format = form, sumpm25[0],sumpm25[1],sumpm25[2],sumpm25[3],sumpm25[4],sumpm25[5],$
    sumpm25[6],sumpm25[7],sumpm25[8],sumpm25[9],sumpm25[10],sumpm25[11]

        sumCO2 = 0.
         sumco = 0.
         sumpm25 = 0.
         sumhg = 0.
skipstate2:
close, /all

print, 'ALL FINISHED!!'

end
