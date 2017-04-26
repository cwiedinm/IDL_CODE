; This program will calculate monthly totals per land cover type
; ReWriting this program on 02/02/2007 because
; results from ACCESS were weird.
; Monthly sums are in kg/month
; Edited January 24, 2007 to include Hg in output summaries (and edited states file
;   to include all 50 states)
; Now prints out a file for each compound in a better format
; Edited on March 12, 2007 to put all summaries for each region into the same file
; 	Summarizes by EPA Regions
; Edited on April 23, 2007 to read in the newest emissions files from April 16, 2007
;   but AK isn't in the emissions output files!
; Edited on April 24 to include summaries of the NICC regions
; May 09, 2007: Edited path of output files and changed names of input files


pro summary_LU_NICC_reg


close, /all
 ext = ' '
 year = ' '
read, 'what year are you processing:', year1
	yeari = FIX(year1)
	year = 	String(yeari)
	year = STRTRIM(year,2)

read, 'what are you processing (AVE = 1, MAX = 2, MIN = 3)?:', range
	if range eq 1 then ext = 'AVE'
	if range eq 2 then ext = 'MAX'
	if range eq 3 then ext = 'MIN'

; Set input file
path = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\Output_MAY07\'
; There are now 3 files for each year: AVE, MIN, and MAX (April 16/2007)
if year1 eq 2002 then begin
; 2002
		if range eq 1 then infile = path + 'Modelout_2002_GLC_MAY082007_HgAVE.txt'	; AVE
		if range eq 2 then infile = path + 'Modelout_2002_GLC_MAY082007_HgMAX.txt'	; MAX
		if range eq 3 then infile = path + 'Modelout_2002_GLC_MAY082007_HgMIN.txt'	; MIN
endif
; 2003
if year1 eq 2003 then begin
		if range eq 1 then infile = path + 'Modelout_2003_GLC_MAY082007_HgAVE.txt'		; AVE
		if range eq 2 then infile = path + 'Modelout_2003_GLC_MAY082007_HgMAX.txt'		; MAX
		if range eq 3 then infile = path + 'Modelout_2003_GLC_MAY082007_HgMIN.txt'		; MIN
endif
; 2004
if year1 eq 2004 then begin
		if range eq 1 then infile = path + 'Modelout_2004_GLC_MAY082007_HgAVE.txt'		; AVE
		if range eq 2 then infile = path + 'Modelout_2004_GLC_MAY082007_HgMAX.txt'		; MAX
		if range eq 3 then infile = path + 'Modelout_2004_GLC_MAY082007_HgMIN.txt'		; MIN
endif
; 2005
if year1 eq 2005 then begin
		if range eq 1 then infile = path + 'Modelout_2005_GLC_MAY082007_HgAVE.txt'		; AVE
		if range eq 2 then infile = path + 'Modelout_2005_GLC_MAY082007_HgMAX.txt'		; MAX
		if range eq 3 then infile = path + 'Modelout_2005_GLC_MAY082007_HgMIN.txt'		; MIN
endif
; 2006
if year1 eq 2006 then begin
		if range eq 1 then infile = path + 'Modelout_2006_GLC_MAY082007_HgAVE.txt'		; AVE
		if range eq 2 then infile = path + 'Modelout_2006_GLC_MAY082007_HgMAX.txt'		; MAX
		if range eq 3 then infile = path + 'Modelout_2006_GLC_MAY082007_HgMIN.txt'		; MIN
endif

; Edited States file to include all 50 states
instate = 'D:\Data2\wildfire\EPA_EI\Brad_files\2006_RSAC_10022006\Model_output\states.csv'

; Set output file
pathout = 'D:\Data2\wildfire\Mercury\Modelout\NEW_050807\regional_output\'


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
 lat = data.field03

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

; Set output file
outfile2 = pathout + 'Emis_LU_Hgsumm_'+year+'_'+ext+'_NICCregions.txt'

openw, 2, outfile2

; Chose NICC region and year to run...
; Can only chose 1-10 (including AK)
; Make sure that you edit which input files to bring in (above)
for p = 0, 9 do begin
    if p eq 0 then begin
       ext = 'Eastern'
       region = 1
    endif
    if p eq 1 then begin
      ext = 'Southeastern'
       region = 2
    endif
    if p eq 2 then begin
      ext = 'RockyMountain'
       region = 3
    endif
    if p eq 3 then begin
      ext = 'NorthernRockies'
       region = 4
    endif
    if p eq 4 then begin
      ext = 'EastBasin'
       region = 5
    endif
	if p eq 5 then begin
      ext = 'WestBasin'
       region = 6
    endif
	if p eq 6 then begin
      ext = 'California'
       region = 7
    endif
    if p eq 7 then begin
      ext = 'Northwest'
       region = 8
    endif
    if p eq 8 then begin
      ext = 'Southwest'
       region = 9
    endif
    if p eq 9 then begin
      ext = 'Alaska'
       region = 10
    endif



printf, 2, 'Region ', ext
printf, 2, 'LUType,JanHg,FebHg,MarHg,AprHg,MayHg,JunHg,JulHg,AugHg,SepHg,OctHg,NovHg,DecHg'
form = '(A20,12(",",D20.5))'
; open STATE file
;inst = ascii_template(instate)
;statein = read_ascii(instate, template=inst)
;stlist = statein.field2
;numstates = n_elements(stlist)


if region eq 1 then begin	; Eastern
    us = where(state eq 'Connecticut' or state eq 'Delaware' or state eq 'Illinois' $
       or state eq 'Indiana' or state eq 'Iowa' or state eq 'Maine' $
       or state eq 'Maryland' or state eq 'Massachusetts' or state eq 'Michigan' $
       or state eq 'Minnesota' or state eq 'Missouri' or state eq 'New Hampshire' $
       or state eq 'New Jersey' or state eq 'New York' or state eq 'Ohio' $
       or state eq 'Pennsylvania' or state eq 'Rhode Island' or state eq 'Vermont' $
       or state eq 'West Virginia' or state eq 'Wisconsin')
endif
if region eq 2 then begin	; Southeastern
    us = where(state eq 'Alabama' or state eq 'Arkansas' or state eq 'Florida' or $
        state eq 'Georgia' or state eq 'Kentucky' or state eq 'Louisiana' $
  		or state eq 'Mississippi' or state eq 'North Carolina' or state eq 'Oklahoma' $
        or state eq 'South Carolina' or state eq 'Tennessee' or state eq 'Texas' $
        or state eq 'Virginia')
endif
if region eq 3 then begin	; Rocky Mountains
    us = where(state eq 'Colorado' or state eq 'Kansas' or state eq 'Nebraska' or $
       state eq 'South Dakota' or state eq 'Wyoming')
endif
if region eq 4 then begin	; Northern Rockies
       us = where(state eq 'Idaho' or state eq 'Montana' or state eq 'North Dakota')
endif
if region eq 5 then begin	; East Basin
    us = where(state eq 'Utah')
endif
if region eq 6 then begin	; West Basin
    us = where(state eq 'Nevada')
endif
if region eq 7 then begin	; California
    us = where(state eq 'California')
endif
if region eq 8 then begin	; Northwest
    us = where(state eq 'Washington' or state eq 'Oregon')
endif
if region eq 9 then begin	; Southwest
    us = where(state eq 'Arizona' or state eq 'New Mexico')
endif
if region eq 10 then begin	; Alaska
    us = where(cntry eq 'United States' and lat gt 50.0)
endif



day = day1[us]
LU  = LU1[us]
CO2 = CO21[us]
CO = CO1[us]
PM25 = pm251[us]
Hg = Hg1[us]


fd = 0
; Do a loop over the different generic LU categories
		 sumpm25 = fltarr(12)
         sumHg = fltarr(12)
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

	hgmonth = hg[firest]
; Loop around each LU and sum over states
		sumpm25 = fltarr(12)
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
;            sumCO[i] = 0.0
;            sumpm25[i] = 0.0
;            sumCO2[i] = 0.0
            sumHg[i] = 0.0
            goto, skipmonth
    endif
 ;           COnow = COmonth[firesnow]
 ;           pm25now = pm25month[firesnow]
 ;           co2now = co2month[firesnow]
            hgnow = hgmonth[firesnow]
            ; calculate totals
 ;             sumCO2[i] = total(CO2now)
 ;             sumCO[i] = total(COnow)
 ;             sumpm25[i] = total(PM25now)
              sumHg[i] = total(hgnow)
skipmonth:
endfor

; print to output file
;printf, 1, format = form, LUtype,sumCO[0],sumCO[1],sumCO[2],sumCO[3],sumCO[4],sumCO[5],$
;    sumCO[6],sumCO[7],sumCO[8],sumCO[9],sumCO[10],sumCO[11]
printf, 2, format = form, LUtype, sumHg[0],sumHg[1],sumHg[2],sumHg[3],sumHg[4],sumHg[5],$
    sumHg[6],sumHg[7],sumHg[8],sumHg[9],sumHg[10],sumHg[11]

         sumCO2 = 0.
         sumco = 0.
         sumpm25 = 0.
         sumhg = 0.
skipstate:
endfor ; end k loop


day = 0
LU  = 0
CO2 = 0
CO = 0
PM25 = 0
Hg = 0
us = 0
printf, 2, ''

endfor
print, 'ALL FINISHED!!'
close, /all
end
