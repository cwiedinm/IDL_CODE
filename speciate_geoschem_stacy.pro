; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; This program will read in the output file from the fire model, and create
; NetCDF file for Gaby
; She needs the emissions summed for each month and put onto a 1 degree resolution
;
; The extent of my North American domain is:
;    latitude: 10.03 to 70.32
;    longitude: -164.98 to -54.999
; So, her file will start with a grid centered on
;    latitude:10.5
;    longitude:-164.5
; and will end on a grid centered on:
;    latitude:70.5
;    longitude:-55.5
; Program Created November 23-24, 2004 by Christine
;
; Dec. 13, 2004: Edited this program to also include speciated VOC emissions
;   using scaling factors from Louisa (used in MOZART)
; 	ALso- for 2004: have to only have 9 months! - need to fix later
;
; FEb. 11, 2008: Edited for North American Fire emissions for California Fire 2007 study
; Feb. 23, 2009: Edited so that it speciates the emissions and outputs a text file for Gab
; 		Running with 2008 emission estimates
; APRIL 29, 2009: Editing to take the NEW 2008 EMission estimates that were created on 04/24/2009
; MAY 14, 2009: Editing to make newest 2008 estimates with new fire detections for 05/14/2009
; MAY 19, 2009: Ran with Xiaoyan's fire emissions for 2002
; JULY 02, 2009:
; 			- saved from speciate_MOZART to speciate_MOZART_AUSNZ
; 			- Saved to D:\Data2\wildfire\EPA_EI\MODEL\IDL_CODE
; 			- edited to read in the AUS/NZ fire emissions and output speciated text file
; NOVEMBER 18, 2009: 
;       - Edited this file to process global emisisons for Louisa to run the new MOZART 
;         simulations for Claire's presentation
; NOVEMBER 25, 2009
; JANUARY 29, 2010
;     - Edited to use new MOZART speciation profile developed 01/28/2010
; 
; FEBRUARY 03, 2010
;     - edited to speciate to GEOS-CHEM 
; FEBRUARY 16, 2010
;   - Created new GEOS-chem speciation table
;   - Added in HCN
;   - Added regional totals to end of file
;   - reran 2007 May-sept for Richard
; MAY 02-03, 2011
;    - Edited to include area in output file, not to have an extra  day, and not to have overlapping days in the output files
;    - Ran 2010 and 2011 for Paul Palmer and group
; MAY 04, 2011
;   - Ran 2005-2009
; May 15, 2010
;   - Ran 2002-2004  
; May 16, 2011
;   - ran Jan-Apr 2011
; 
;   
;   DECEMBER 30, 2011
;   - cleaned up a little for STACY
;   
; SEPTEMBER 11, 2012
; - Ran for 2012 Emissions from January through August
; 
; JUly 31, 2013
; - Edited to run with new speciation table (created in the last week)
; - Ran with the file for Jan-July 2013
; 
; APRIL 22, 2014
; - Ran 2012 file for Peter Wind of Norway
; 
; July 08, 2014
; - reran 2012 and 2013 for Peter Wind of Norway
; - EDITED for new version 1.5 that includes genveg = 6 (temperate evergreen needleleaf trees)
; 
; DECEMBER 01, 2015
; - edited to run the newly created 2014 and 2015 FINNv1.5 files
; 
; MAY 25, 2016
; - Edited to run FINNv1.5 2015 files (that was created January 2015)
; 
; NOVEMBER 03, 2016
; - edited to run the FINNv1.5 2016 file that I created on Nov. 02
; - Edited to run the FINNv1.5 2015 file that I created in September 2016
; 
; April 02, 2017
; - Edited to process the newly made 2014 FINNv1.5 files
; 
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_geoschem_stacy
close, /all

;****************************************************************************************************
; CONVERSION FACTOR TABLE FOR VOCs
;      convert ='E:\Data2\wildfire\EMISSIONS_PAPER2009\SPECIATION\GEOS-chem_VOC_speciate.csv' ; Original speciation file
       convert = 'E:\Data2\wildfire\SPECIATION\Update_July2013\Geos_chem_speciation_table.csv' ; File created July 2013
      intemp2=ascii_template(convert)
      speciate=read_ascii(convert, template=intemp2)

; This file reads in the factors to apply to the VOC number to speciate to the MOZART4 species
; Takes fire emissions (kg/km2/day) and converts to mole species/km2/day
    sav = speciate.field2
    tropfor = speciate.field3
    tempfor = speciate.field4
    ag = speciate.field5
    boreal = speciate.field6
    shrub = speciate.field7
 
 ; The list of GEOSCHEM species in that file are (07/31/13): 
;ACET
;ALD2
;ALK4
;BENZ
;C2H2
;C2H4
;C2H6
;C3H8
;CH2O
;GLYC
;GLYX
;HAC
;MEK
;MGLY
;PRPE
;TOLU
;XYLE
;NO

;*************************************************************************************************
year = 2014
firstday =1 
lastday = 365

Infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2017\APRIL2017\FINNv1.5_2014_redo_04022017.txt'
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2017\APRIL2017\SPECIATED\GLOBAL_FINNv15_2014_GEOSCHEM_04032017.txt'
checkfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SPECIATE\LOG_GLOBAL_FINNv15_2014_GEOSCHEM_04032017.txt'

; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
; Edited 07/31/2013 to export the changed GEOS-chem VOCs
openw, 5, outfile
printf, 5, 'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,NO,NO2,SO2,NH3,CH4,ACET,ALD2,ALK4,BENZ,C2H2,C2H4,C2H6,C3H8,CH2O,GLYC,GLYX,HAC,MEK,MGLY,PRPE,TOLU,XYLE,OC,BC,PM25'
form='(I6,",",I6,",",I6,30(",",D20.10))'

openw, 2, checkfile

; Open input file and get the needed variables
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
		area = fire.field11 ; added 05/02/2011; should be in m2

   	numfires = n_elements(day)
		nfires = numfires

print, "FINISHED READING INPUT FILE"
print, 'Input file = ', infile
print, 'First day = ', min(day)
print, 'Last day = ', max(day)

; Set up output Arrays
    CO2emis = fltarr(numfires)
    COemis = fltarr(numfires)
    NOXemis = fltarr(numfires)
    VOCemis = fltarr(numfires)
    SO2emis = fltarr(numfires)
    NH3emis = fltarr(numfires)
    PM25emis = fltarr(numfires)
    OCemis = fltarr(numfires)
    CH4emis = fltarr(numfires)
  	BCEMIS = fltarr(numfires)
  	NOemis = fltarr(numfires)
  	NO2emis = fltarr(numfires)

; Set up speciated VOC arrays
  ACETemis=fltarr(numfires) 
  ALD2emis= fltarr(numfires)
  ALK4emis=fltarr(numfires)
  BENZemis=fltarr(numfires)
  C2H2emis=fltarr(numfires)
  C2H4emis=fltarr(numfires)
  C2H6emis=fltarr(numfires)
  C3H8emis=fltarr(numfires)
  CH2Oemis=fltarr(numfires)
  GLYCemis=fltarr(numfires)
  GLYXemis=fltarr(numfires)
  HACemis=fltarr(numfires)
  MEKemis= fltarr(numfires)
  MGLYemis= fltarr(numfires)
  PRPEemis=fltarr(numfires)
  TOLUemis = fltarr(numfires)
  XYLEemis = fltarr(numfires)

numskipfires = 0
;-------------------------------
; DO LOOP OVER ALL FIRES
; Convert VOC species and output most in mole/km2/day
;-------------------------------
for i = 0L,numfires-1 do begin

; Skip fires on last day
; for leap years
if year eq 2000 or year eq 2004 or year eq 2008 or year eq 2012 then begin
  if day[i] gt 366 then begin
       print,'year = ',year,' and day: ',jday[i],' not included.
       goto, skipfire
  endif
endif
; For non-leap years
if year ne 2000 and year ne 2004 and year ne 2008 and year ne 2012 then begin
  if day[i] gt 365 then begin
       print,'year = ',year,' and day: ',jday[i],' not included.
       goto, skipfire
  endif
endif

; Make sure only include days of the months in the file (for WRF-CHEM)
if day[i] gt lastday or day[i] lt firstday then goto, skipfire


	; Convert orignial emissions converted to mole/km2/day
	   	CO2emis[i]=CO2[i]*1000./44.01  
    	COemis[i]=CO[i]*1000./28.01
    	CH4emis[i]=CH4[i]*1000./16.04
     	NH3emis[i]=NH3[i]*1000/17.03
    	NOemis[i] = NO[i]*1000/30.01 ; added 11/18/2009
    	NO2emis[i] = NO2[i]*1000/46.01
    	SO2emis[i]=SO2[i]*1000/64.06
 
; NOX, VOC, and PM  emissions kept in kg/day/km2 (Not converted)
;      NOX_emis[i]=NOX[i] 
;      VOC_emis[i]=VOC[i]
      OCemis[i]=OC[i]
      BCemis[i]= BC[i]
      PM25emis[i]=PM25[i]
      
; GENERIC LAND COVER CLASSES
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
;
; STOP if no recognizable GenLC is in there
;if genveg[i] eq 6 or genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP
; 07/09/2014: now include genveg = 6
if genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP

; Tropical Forests (genveg = 3):
if (genveg[i] eq 1) then convert2GEOCH = sav
if (genveg[i] eq 2) then convert2GEOCH = shrub
if (genveg[i] eq 3) then convert2GEOCH = tropfor
if (genveg[i] eq 4) then convert2GEOCH = tempfor
if (genveg[i] eq 5) then convert2GEOCH = boreal
if (genveg[i] eq 9) then convert2GEOCH = ag
; 07/09/2014 - Added genveg = 6
if (genveg[i] eq 6) then convert2GEOCH = tempfor

; Speciate VOC emissions. VOC is in kg and the output of this is mole GEOS-CHEM Emissions species
	         ACETemis[i] = VOC[i]*convert2GEOCH[0]
           ALD2emis[i] = VOC[i]*convert2GEOCH[1]
           ALK4emis[i] = VOC[i]*convert2GEOCH[2]
           BENZemis[i] = VOC[i]*convert2GEOCH[3]
           C2H2emis[i] = VOC[i]*convert2GEOCH[4]
           C2H4emis[i] = VOC[i]*convert2GEOCH[5]
           C2H6emis[i] = VOC[i]*convert2GEOCH[6]
           C3H8emis[i] = VOC[i]*convert2GEOCH[7]
           CH2Oemis[i] = VOC[i]*convert2GEOCH[8]
           GLYCemis[i] = VOC[i]*convert2GEOCH[9]
           GLYXemis[i] = VOC[i]*convert2GEOCH[10]
           HACemis[i] = VOC[i]*convert2GEOCH[11]
           MEKemis[i] = VOC[i]*convert2GEOCH[12]
           MGLYemis[i] = VOC[i]*convert2GEOCH[13]
           PRPEemis[i] = VOC[i]*convert2GEOCH[14]
           TOLUemis[i] = VOC[i]*convert2GEOCH[15]
           XYLEemis[i] = VOC[i]*convert2GEOCH[16]
           NOemis[i] = VOC[i]*convert2GEOCH[17]+NOemis[i]

if C2H6emis[i] eq 0 then begin
	 print,'fire = ',i+1,' and day: ',jday[i],' not included.
	 numskipfires = numskipfires+1
	 goto, skipfire
endif


; Print to output file
;         DAY,TIME,GENVEG,LATI,LONGI,CO2,CO,NO,NO2,SO2,NH3,CH4,ACET,ALD2,ALK4,C2H6,C3H8,CH2O,ISOP,MEK,PRPE,OC,BC,PM25' 
;	                       DAY,    TIME,   GENVEG,   LATI,   LONGI,   AREA,   CO2,       CO,       NO,       NO2,        SO2,       NH3,       CH4
;                        'DAY,   TIME,   GENVEG,   LATI,   LONGI,   AREA,   CO2,       CO,       NO,       NO2,        SO2,       NH3,       CH4,
printf, 5, format = form, day[i],time[i],genveg[i],lati[i],longi[i],area[i],CO2emis[i],COemis[i],NOemis[i],NO2emis[i], SO2emis[i],NH3emis[i],CH4emis[i],$
; ACET,       ALD2,       ALK4,       BENZ,       C2H2,       C2H4,       C2H6,       C3H8,       CH2O,       GLYC,       GLYX,       HAC,       MEK,       MGLY,       PRPE,
	ACETemis[i],ALD2emis[i],ALK4emis[i],BENZemis[i],C2H2emis[i],C2H4emis[i],C2H6emis[i],C3H8emis[i],CH2Oemis[i],GLYCemis[i],GLYXemis[i],HACemis[i],MEKemis[i],MGLYemis[i],PRPEemis[i], $
; TOLU,       XYLE,   OC,       BC,       PM25'
  TOLUemis[i],XYLEemis[i],OCemis[i],BCemis[i],PM25emis[i] 

skipfire:

endfor ; end of i loop

printf, 2, ' '
printf, 2, 'The input file was: ', infile
printf, 2, 'The speciation file was: ', convert
printf, 2, ' '
Printf, 2, 'SUMMARY FROM GEOS-CHEM speciation'
printf, 2, 'The total CO2 emissions (moles, Tg) = ',  total(CO2emis), ",",total(CO2)/1.e9
printf, 2, 'The total CO emissions (moles, Tg) =  ',  total(COemis), ",",total(CO)/1.e9
printf, 2, 'The total NO emissions (moles, Tg) =  ',  total(NOemis), ",",total(NO)/1.e9
printf, 2, 'The total NO emissions (Tg) = ', total(NO)/1.e9, ' Original from fire emissions model before speciation'
printf, 2, 'The total NO2 emissions (moles, Tg) = ',  total(NO2emis), ",",total(NO2)/1.e9
printf, 2, 'The total SO2 emissions (moles, Tg) = ',  total(SO2emis), ",",total(SO2)/1.e9
printf, 2, 'The total ALK4 emissio (moles) =',  total(ALK4emis)
printf, 2, 'The total C2H6 emissions (moles) =',  total(C2H6emis)
printf, 2, 'The total MEK emissions (moles) =',  total(MEKemis)
printf, 2, 'The total ACET emissions (moles) =',  total(ACETemis)
printf, 2, 'The total C3H8 emiss (moles) =',   total(C3H8emis)
printf, 2, 'The total CH2O emissions (moles) =',  total(CH2Oemis)
printf, 2, 'The total OC emissions (Tg) =',  total(OCemis)/1.e9
printf, 2, 'The total BC emissions (Tg) =',  total(BCemis)/1.e9
printf, 2, ''
printf, 2, 'The total VOC emissions (Tg) =',  total(VOC)/1.e9
printf, 2, 'The number of skopped fires = ', numskipfires
printf, 2, 'The total number of fires = ',numfires

print, 'The number of skopped fires = ', numskipfires
print, 'The total number of fires = ',numfires


; TOTAL GEOS-CHEM SPECIES
sum1 = total(ACETemis)
sum2 = total(ALD2emis)
sum3 = total(ALK4emis)
sum6 = total(BENZemis)
sum9 = total(C2H2emis)
sum10 = total(C2H4emis)
sum4 = total(C2H6emis)
sum5 = total(C3H8emis)
sum6 = total(CH2Oemis)
sum11 = total(GLYCemis)
sum12 = total(GLYXemis)
sum13 = total(HACemis)
sum7 = total(MEKemis)
sum14 = total(MGLYemis)
sum8 = total(PRPEemis)
sum15 = total(TOLUemis)
sum16 = total(XYLEemis)

sumall = sum1+sum2+sum3+sum4+sum5+sum6+sum7+sum8+sum9+sum10+sum11+sum12+sum13+sum14+sum15+sum16

printf, 2, 'The total sum of GEOS-CHEM VOC species (moles)  = ', sumall
printf, 2, ''
printf, 2, 'The total VOC species (moles) assuming 60 g/mole = ',total(VOC)*1000./60.

printf, 2, ''

; **************************** REGIONAL SUMS *******************************
Printf, 2, 'GLOBAL TOTALS (Tg Species)'
Printf, 2, 'CO2, ', total(CO2)/1.e9
printf, 2, 'CO, ', total(CO)/1.e9
printf, 2, 'NOX, ', total(NOX)/1.e9
printf, 2, 'NO, ', total(NO)/1.e9
printf, 2, 'NO2, ', total(NO2)/1.e9
printf, 2, 'NH3, ', total(NH3)/1.e9
printf, 2, 'SO2, ', total(SO2)/1.e9
printf, 2, 'VOC, ', total(VOC)/1.e9
printf, 2, 'CH4, ', total(CH4)/1.e9
printf, 2, 'OC, ', total(OC)/1.e9
printf, 2, 'BC, ', total(BC)/1.e9
printf, 2, 'PM2.5, ', total(PM25)/1.e9
printf, 2, 'HCHO, ', total(CH2Oemis)/1.e9
printf, 2, 'ACETONE, ', total(ACETemis)/1.e9


; WESTERN U.S. 
westUS = where(lati gt 24. and lati lt 49. and longi gt -124. and longi lt -100.)   
printf, 2, 'Western US (Mg Species)'
printf, 2, 'CO2, ', total(CO2[westUS])/1.e6
printf, 2, 'CO, ', total(CO[westUS])/1.e6
printf, 2, 'NOX, ', total(NOX[westUS])/1.e6
printf, 2, 'NO, ', total(NO[westUS])/1.e6
printf, 2, 'NO2, ', total(NO2[westUS])/1.e6
printf, 2, 'NH3, ', total(NH3[westUS])/1.e6
printf, 2, 'SO2, ', total(SO2[westUS])/1.e6
printf, 2, 'VOC, ', total(VOC[westUS])/1.e6
printf, 2, 'CH4, ', total(CH4[westUS])/1.e6
printf, 2, 'OC, ', total(OC[westUS])/1.e6
printf, 2, 'BC, ', total(BC[westUS])/1.e6
printf, 2, 'PM2.5, ', total(PM25[westUS])/1.e6
printf, 2, 'HCHO, ', total(CH2Oemis[westUS])/1.e9
printf, 2, 'ACETONE, ', total(ACETemis[westUS])/1.e9


; EASTERN U.S. 
eastUS = where(lati gt 24. and lati lt 49. and longi gt -100. and longi lt -60.)   
printf, 2, 'Eastern US (Mg Species)'
printf, 2, 'CO2, ', total(CO2[eastUS])/1.e6
printf, 2, 'CO, ', total(CO[eastUS])/1.e6
printf, 2, 'NOX, ', total(NOX[eastUS])/1.e6
printf, 2, 'NO, ', total(NO[eastUS])/1.e6
printf, 2, 'NO2, ', total(NO2[eastUS])/1.e6
printf, 2, 'NH3, ', total(NH3[eastUS])/1.e6
printf, 2, 'SO2, ', total(SO2[eastUS])/1.e6
printf, 2, 'VOC, ', total(VOC[eastUS])/1.e6
printf, 2, 'CH4, ', total(CH4[eastUS])/1.e6
printf, 2, 'OC, ', total(OC[eastUS])/1.e6
printf, 2, 'BC, ', total(BC[eastUS])/1.e6
printf, 2, 'PM2.5, ', total(PM25[eastUS])/1.e6
printf, 2, 'HCHO, ', total(CH2Oemis[eastUS])/1.e9
printf, 2, 'ACETONE, ', total(ACETemis[eastUS])/1.e9


; CANADA/AK 
CANAK = where(lati gt 49. and lati lt 70. and longi gt -170. and longi lt -55.)   
printf, 2, 'Canada/Alaska (Mg Species)'
printf, 2, 'CO2, ', total(CO2[CANAK])/1.e6
printf, 2, 'CO, ', total(CO[CANAK])/1.e6
printf, 2, 'NOX, ', total(NOX[CANAK])/1.e6
printf, 2, 'NO, ', total(NO[CANAK])/1.e6
printf, 2, 'NO2, ', total(NO2[CANAK])/1.e6
printf, 2, 'NH3, ', total(NH3[CANAK])/1.e6
printf, 2, 'SO2, ', total(SO2[CANAK])/1.e6
printf, 2, 'VOC, ', total(VOC[CANAK])/1.e6
printf, 2, 'CH4, ', total(CH4[CANAK])/1.e6
printf, 2, 'OC, ', total(OC[CANAK])/1.e6
printf, 2, 'BC, ', total(BC[CANAK])/1.e6
printf, 2, 'PM2.5, ', total(PM25[CANAK])/1.e6
printf, 2, 'HCHO, ', total(CH2Oemis[CANAK])/1.e9
printf, 2, 'ACETONE, ', total(ACETemis[CANAK])/1.e9


; Mexico and Central America 
MXCA = where(lati gt 10. and lati lt 28. and longi gt -120. and longi lt -65.)   
printf, 2, 'Mexico/Central America (Mg Species)'
printf, 2, 'CO2, ', total(CO2[MXCA])/1.e6
printf, 2, 'CO, ', total(CO[MXCA])/1.e6
printf, 2, 'NOX, ', total(NOX[MXCA])/1.e6
printf, 2, 'NO, ', total(NO[MXCA])/1.e6
printf, 2, 'NO2, ', total(NO2[MXCA])/1.e6
printf, 2, 'NH3, ', total(NH3[MXCA])/1.e6
printf, 2, 'SO2, ', total(SO2[MXCA])/1.e6
printf, 2, 'VOC, ', total(VOC[MXCA])/1.e6
printf, 2, 'CH4, ', total(CH4[MXCA])/1.e6
printf, 2, 'OC, ', total(OC[MXCA])/1.e6
printf, 2, 'BC, ', total(BC[MXCA])/1.e6
printf, 2, 'PM2.5, ', total(PM25[MXCA])/1.e6
printf, 2, 'HCHO, ', total(CH2Oemis[MXCA])/1.e9
printf, 2, 'ACETONE, ', total(ACETemis[MXCA])/1.e9


; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
