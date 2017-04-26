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
; August 29, 2007: Edited to output area and biomass burned (based on old regional code)
; 		renamed program and edited so that it only has annual totals, not monthly

pro summary_lu_Area_BB


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
pathout = 'D:\Data2\wildfire\Mercury\Modelout\NEW_08292007\'


; OPEN INPUT FILE
 input=ascii_template(infile)
 data=read_ascii(infile, template=input)
; j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state
; j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,ADMIN_NAME,
 day1 = data.field04
 LU = data.field05
 CO21 = data.field12
 CO1 = data.field13
 PM251 = data.field15
 state = data.field25
 Hg1 = data.field23
 cntry = data.field24
 lat = data.field03
 area = data.field10
 BB= data.field11


; Set output file
outfile2 = pathout + 'Emis_LU_Hgsumm_'+year+'_BB_AREA.txt'

openw, 2, outfile2

printf, 2, 'LUType,Total_Area(km2), BB_Burned(ton)'
form = '(A20,2(",",D20.5))'


fd = 0

; Do Loop over the General land cover classes
for k = 0,5 do begin
    if k eq 0 then begin
       LUtype = 'BroadTempTropForest '
        firest = where(LU eq 1 or LU eq 2 or LU eq 3 or LU eq 29)
    endif
    if k eq 1 then begin
        LUtype = 'NeedleForest        '
        firest = where((LU eq 4 or LU eq 5 or LU eq 20))
    endif
    if k eq 2 then begin
        LUtype = 'MixForest           '
        firest = where(LU eq 6 or LU eq 7 or LU eq 8)
    endif
    if k eq 3 then begin
        LUtype = 'Shrub               '
        firest = where(LU eq 9 or LU eq 10 or LU eq 11 or LU eq 12)
    endif
    if k eq 4 then begin
        LUtype = 'Grass               '
        firest = where((LU ge 13 and LU le 17) or (LU ge 21 and LU le 28))
    endif
    if k eq 5 then begin
        LUtype = 'Crops               '
        firest = where((LU ge 18 and LU le 19))
    endif

    if firest[0] lt 0 then begin
        print, 'No Fires in LU', k, ' AT ALL!!?'
		goto, skipstate
    endif

	; now sum up area and biomass for all of the fires that fall within that general LCC
	num = n_elements(firest)
	area_sum = 0.0
	bb_sum = 0.0

	for i = 0L,num-1 do begin
		bbtot = bb[firest[i]]*area[firest[i]]*1.e6/1000.
		area_sum = area_sum+area[firest[i]]
		bb_sum = bb_sum+bbtot
	endfor


printf, 2, format = form, LUtype, area_sum,BB_sum
skipstate:
endfor ; end k loop


print, 'ALL FINISHED!!'
close, /all
end
