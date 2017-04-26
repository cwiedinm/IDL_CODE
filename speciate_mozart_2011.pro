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
; FEBRUARY 04, 2010
;   - updated MOZART4 speciation table
;   - included HCN and CH3CN
; FEBRUARY 10-12, 2010
;   - Updated MOZ4 speciation table (after discussion with Louisa and John O. 
;   - Rerun 2008 files for Louisa
; FEBRUARY 13-14, 2010
;   - updated the MOZ4 speciation table based on new EFs from Sheryl. 
;   - Re-speciated 2008 emissions files (created today)
; AUGUSR 18-19, 2010
;   - edited to use a new speciation table (F:\Data2\wildfire\EMISSIONS_PAPER2009\SPECIATION\ MOZ4_VOC_Speciateb.csv)
;   - Now includes HCOOH and C2H2 (edited code to include these species)
;   - Now input files include PM10 emissions
;   - Ran for 2009.    
;   
; SEPTEMBER 17, 2010
;  - edited to include total VOC emissions in output files (kg/day)
;  - need to rerun for all files again!
;  
; SEPTEMBER 29, 2010
;   - edited to include H2 in the output file
;   - re-running all files
; NOVEMBER 29, 2010
;   - speciation tables don't include GLYOXAL anymore (MOZ4_VOC_Speciatec.csv)
;   - edited code to remove GLYOXAL
; MARCH 10, 2011
;   - Edited code to include area burned in output    
; MARCH 25, 2011
;   - Edited to run the new May-Sept. 2008 Emissions file. 
; APRIL 18, 2011
;   - reran all files with new format for WRF-chem processor (includes area in output)
;   - edited code to get rid of last day
; May 15, 2011
;   - ran through 2002
;   - Ran through 2003
;   - ran through 2004
; May 16, 2011
;   - Ran through 2011
; October 05, 2011
;   - ran through the speciation for Jan-Sept. 28, 2011
;     * clipped only fires that were in the CONUS
;     
; OCTOBER 28, 2011
; - RAN for entire globe for Gabi (JAN-SEPT 2011)
; 
; DECEMBER 30, 2011
; - cleaned up a little for Stacy
;
;MARCH 15, 2012
; - Edited to speciate the 2011 entire year emissions file
; 
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_MOZART_2011

close, /all

;****************************************************************************************************
; CONVERSION FACTOR TABLE FOR VOCs
      convert ='E:\Data2\wildfire\EMISSIONS_PAPER2009\SPECIATION\MOZ4_VOC_Speciatec.csv' ; edited on 11/29/2010 does not include GLYOXAL!!
      intemp2=ascii_template(convert)
      speciate=read_ascii(convert, template=intemp2)

; This file reads in the factors to apply to the VOC number to speciate to the MOZART4 species
; Takes fire emissions (kg/km2/day) and converts to mole species/km2/day
; Savanna TropFor Temperate Forest  AgResid BOREAL  Shrublands

    sav = speciate.field2
    tropfor = speciate.field3
    tempfor = speciate.field4
    ag = speciate.field5
    boreal = speciate.field6
    shrub = speciate.field7
 
 ; The list of MOZART species in that file are: 
;BIGALD
;BIGALK
;BIGENE
;C10H16
;C2H4
;C2H5OH
;C2H6
;C3H6
;C3H8
;CH2O
;CH3CHO
;CH3CN
;CH3COCH3
;CH3COCHO
;CH3COOH
;CH3OH
;CRESOL
;GLYALD
;HCN
;HYAC
;ISOP
;MACR
;MEK
;MVK
;NO
;TOLUENE
;HCOOH
;C2H2
; this is the new list for November 29, 2010 --> Removed Glyoxal

;*************************************************************************************************
year = 2011
firstday =1 
lastday = 365

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\SPECIATE\GLOBAL_2011_MOZ4_03162012.txt'

checkfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\SPECIATE\LOG_GLOBAL_2011_MOZ4_03162012.txt'' 
; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
openw, 5, outfile

; NEW WAY (March 10, 2011)
printf, 5, 'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'  ; 11
form='(I6,",",I6,",",I6,",",43(D20.10,","))'


openw, 2, checkfile

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
		H2 = fire.field16 ; added 09/29/2010
		area = fire.field11 ; added 03/10/2011; should be in m2

   	numfires = n_elements(day)
		nfires = numfires

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
  	PM10emis = fltarr(numfires)
  	H2emis = fltarr(numfires) ; added 09/29/2010
  	
; Set up speciated VOC arrays
BIGALDemis =  fltarr(numfires)
BIGALKemis =  fltarr(numfires)
BIGENEemis =  fltarr(numfires)
C10H16emis =  fltarr(numfires)
C2H4emis =  fltarr(numfires)
C2H5OHemis =  fltarr(numfires)
C2H6emis =  fltarr(numfires)
C3H6emis =  fltarr(numfires)
C3H8emis =  fltarr(numfires)
CH2Oemis =  fltarr(numfires)
CH3CHOemis =  fltarr(numfires)
CH3COCH3emis =  fltarr(numfires)
CH3COCHOemis =  fltarr(numfires)
CH3COOHemis =  fltarr(numfires)
CH3OHemis =  fltarr(numfires)
CRESOLemis =  fltarr(numfires)
GLYALDemis =  fltarr(numfires)
HYACemis =  fltarr(numfires)
ISOPemis =  fltarr(numfires)
MACRemis =  fltarr(numfires)
MEKemis =  fltarr(numfires)
MVKemis =  fltarr(numfires)
NOemis =  fltarr(numfires)
HCNemis =  fltarr(numfires)
CH3CNemis =  fltarr(numfires)
TOLUENEemis =  fltarr(numfires)
HCOOHemis = fltarr(numfires) ; Added 08/19/2010
C2H2emis = fltarr(numfires) ; Added 08/19/2010
    
;-------------------------------
; DO LOOP OVER ALL FIRES
; Convert VOC species and output most in mole/km2/day
;-------------------------------
for i = 0L,numfires-1 do begin

; CLIP OUT ONLY CONUS FOR 2011 FIRES
;   DONE ON OCT. 05, 2011 for Yarwood
;latmin = 10.
;latmax = 55.
;longmin = -126.
;longmax = -65.
;if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt longmax or longi[i] lt longmin) then goto, skipfire

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
    	H2emis[i] = H2[i]*1000/2.02  ; Added 09/29/2010
    	
; NOX, VOC, and PM  emissions kept in kg/day/km2 (Not converted)
;      NOX_emis[i]=NOX[i] 
      VOCemis[i]=VOC[i]
      OCemis[i]=OC[i]
      BCemis[i]= BC[i]
      PM25emis[i]=PM25[i]
      PM10emis[i]=PM10[i] ; Added 08/19/2010
      
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
if genveg[i] eq 6 or genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP

; Tropical Forests (genveg = 3):
if (genveg[i] eq 1) then convert2MOZ4 = sav
if (genveg[i] eq 2) then convert2MOZ4 = shrub
if (genveg[i] eq 3) then convert2MOZ4 = tropfor
if (genveg[i] eq 4) then convert2MOZ4 = tempfor
if (genveg[i] eq 5) then convert2MOZ4 = boreal
if (genveg[i] eq 9) then convert2MOZ4 = ag

; Speciate VOC emissoins. VOC is in kg and the output of this is mole MOZ4 species
;0 BIGALD
;1 BIGALK
;2 BIGENE
;3 C10H16
;4 C2H4
;5 C2H5OH
;6 C2H6
;7 C3H6
;8 C3H8
;9 CH2O
;10  CH3CHO
;11  CH3CN
;12  CH3COCH3
;13  CH3COCHO
;14  CH3COOH
;15  CH3OH
;16  CRESOL
;17  GLYALD
;18  HCN
;19  HYAC
;20  ISOP
;21  MACR
;22  MEK
;23  MVK
;24  NO
;25  TOLUENE
;26  HCOOH  (added 08/19/2010)
;27  C2H2 (added 08/19/2010)

	         BIGALDemis[i] = VOC[i]*convert2MOZ4[0]
           BIGALKemis[i] = VOC[i]*convert2MOZ4[1]
           BIGENEemis[i] = VOC[i]*convert2MOZ4[2]
           C10H16emis[i] = VOC[i]*convert2MOZ4[3]
           C2H4emis[i] = VOC[i]*convert2MOZ4[4]
           C2H5OHemis[i] = VOC[i]*convert2MOZ4[5]
           C2H6emis[i] = VOC[i]*convert2MOZ4[6]
           C3H6emis[i] = VOC[i]*convert2MOZ4[7]
           C3H8emis[i] = VOC[i]*convert2MOZ4[8]
           CH2Oemis[i] = VOC[i]*convert2MOZ4[9]
           CH3CHOemis[i] = VOC[i]*convert2MOZ4[10]
           CH3COCH3emis[i] = VOC[i]*convert2MOZ4[12]
           CH3COCHOemis[i] = VOC[i]*convert2MOZ4[13]
           CH3COOHemis[i] = VOC[i]*convert2MOZ4[14]
           CH3OHemis[i] = VOC[i]*convert2MOZ4[15]
           CRESOLemis[i] = VOC[i]*convert2MOZ4[16]
           GLYALDemis[i] = VOC[i]*convert2MOZ4[17]
           ;GLYOXALemis[i] = VOC[i]*convert2MOZ4[18]
           HYACemis[i] = VOC[i]*convert2MOZ4[19]
           ISOPemis[i] = VOC[i]*convert2MOZ4[20]
           MACRemis[i] = VOC[i]*convert2MOZ4[21]
           MEKemis[i] = VOC[i]*convert2MOZ4[22]
           MVKemis[i] = VOC[i]*convert2MOZ4[23]
           NOemis[i] = VOC[i]*convert2MOZ4[24]+NOemis[i]
           HCNemis[i] = VOC[i]*convert2MOZ4[18]
           CH3CNemis[i] = VOC[i]*convert2MOZ4[11]
           TOLUENEemis[i] = VOC[i]*convert2MOZ4[25]
           HCOOHemis[i] = VOC[i]*convert2MOZ4[26]
           C2H2emis[i] =  VOC[i]*convert2MOZ4[27]

if C2H6emis[i] eq 0 then begin
	 print,'fire = ',i+1,' and day: ',jday[i],' not included.
	 goto, skipfire
endif

; Print to output file
; 
; NEW FORMAT
;	                       DAY,    TIME,  GENVEG,    LATI,   LONGI,   AREA    CO2,       CO,        H2,         NO,       NO2,        SO2,       NH3,       CH4         VOC
printf, 5, format = form, day[i],time[i],genveg[i],lati[i],longi[i],area[i],CO2emis[i],COemis[i],H2emis[i], NOemis[i],NO2emis[i], SO2emis[i],NH3emis[i],CH4emis[i], VOCemis[i], $
; BIGALD,       BIGALK,       BIGENE,       C10H16,       C2H4,       C2H5OH,       C2H6,       C3H6,       C3H8,       CH2O,
	BIGALDemis[i],BIGALKemis[i],BIGENEemis[i],C10H16emis[i],C2H4emis[i],C2H5OHemis[i],C2H6emis[i],C3H6emis[i],C3H8emis[i],CH2Oemis[i], $
; CH3CHO,       CH3COCH3,       CH3COCHO,       CH3COOH,       CH3OH,       CRESOL,       GLYALD,       
	CH3CHOemis[i],CH3COCH3emis[i],CH3COCHOemis[i],CH3COOHemis[i],CH3OHemis[i],CRESOLemis[i],GLYALDemis[i], $
; HYAC,       ISOP,       MACR,       MEK,       MVK,       HCN,       CH3CN,       TOLUENE,       PM25,       OC,       BC
  HYACemis[i],ISOPemis[i],MACRemis[i],MEKemis[i],MVKemis[i],HCNemis[i],CH3CNemis[i],TOLUENEemis[i],PM25emis[i],OCemis[i],BCemis[i], $
; PM10,   HCOOH,      C2H2'    
  PM10emis[i], HCOOHemis[i], C2H2emis[i]
  

skipfire:

endfor ; end of i loop

printf, 2, ' Original from fire emissions model before speciation'
printf, 2, 'The total CO2 emissions (moles, Tg) = ',  total(CO2emis), ",",total(CO2)/1.e9
printf, 2, 'The total CO emissions (moles, Tg) =  ',  total(COemis), ",",total(CO)/1.e9
printf, 2, 'The total NO emissions (moles, Tg) =  ',  total(NOemis), ",",total(NO)/1.e9
printf, 2, 'The total NOx emissions (Tg) = ', total(NOX)/1.e9 
printf, 2, 'The total NO2 emissions (moles, Tg) = ',  total(NO2emis), ",",total(NO2)/1.e9
printf, 2, 'The total SO2 emissions (moles, Tg) = ',  total(SO2emis), ",",total(SO2)/1.e9
printf, 2, 'The total NH3 emissions (moles, Tg) = ',  total(NH3emis), ",",total(NH3)/1.e9
printf, 2, 'The total H2 emissions (moles, Tg) = ',  total(H2emis), ",",total(H2)/1.e9
printf, 2, 'The total VOC emissions (Tg) =',  total(VOC)/1.e9
printf, 2, 'The total OC emissions (Tg) =',  total(OCemis)/1.e9
printf, 2, 'The total BC emissions (Tg) =',  total(BCemis)/1.e9
printf, 2, 'The total PM10 emissions (Tg) = ', total(PM10emis)/1.e9
printf, 2, 'The total PM2.5 emissions (Tg) = ', total(PM25emis)/1.e9
Printf, 2, ' '
Printf, 2, 'SUMMARY FROM MOZART4 speciation'
printf, 2, 'The total BIGENE emissio (moles) =',  total(BIGENEemis)
printf, 2, 'The total C2H6 emissions (moles) =',  total(C2H6emis), ', and in Tg = ', total(C2H6emis)*30.07/1.e12
printf, 2, 'The total MEK emissions (moles) =',  total(MEKemis)
printf, 2, 'The total TOLUENE emiss (moles) =',   total(TOLUENEemis), ', and in Tg = ', total(TOLUENEemis)*90.1/1.e12
printf, 2, 'The total CH2O emissions (moles) =',  total(CH2Oemis), ', and in Tg = ', total(CH2Oemis)*30.3/1.e12
printf, 2, 'The total HCOOH emissions (moles) =', total(HCOOHemis), ', and in Tg = ', total(HCOOHemis)*47.02/1.e12
printf, 2, 'The total C2H2 emissions (moles) = ', total(C2H2emis), ', and in Tg = ', total(C2H2emis)*26.04/1.e12
printf, 2, 'The total GLYALD emissions (moles) = ', total(GLYALDemis)
printf, 2, 'The total ISOPRENE emissions (moles) = ', total(ISOPemis), ', and in Tg = ', total(ISOPemis)*68.12/1.e12
printf, 2, 'The total HCN emissions (moles) = ', total(HCNemis), ', and in Tg = ', total(HCNemis)*27.025/1.e12
printf, 2, 'The total CH3CN emissions (moles) = ', total(CH3CNemis), ', and in Tg = ', total(CH3CNemis)*41.05/1.e12
printf, 2, 'The total CH3OH emissions (moles) = ', total(CH3OHemis), ', and in Tg = ', total(CH3OHemis)*32.04/1.e12
printf, 2, 'The total C2H4 emissions (moles) = ', total(C2H4emis), ', and in Tg = ', total(C2H4emis)*28.05/1.e12
printf, 2, ''

           sum1 = total(BIGALDemis)
           sum2 = total(BIGALKemis)
           sum3 = total(BIGENEemis)
           sum4 = total(C10H16emis)
           sum5 = total(C2H4emis)
           sum6 = total(C2H5OHemis)
           sum7 = total(C2H6emis)
           sum8 = total(C3H6emis)
           sum9 = total(C3H8emis)
           sum10 = total(CH2Oemis)
           sum11 = total(CH3CHOemis)
           sum12 = total(CH3COCH3emis)
           sum13 = total(CH3COCHOemis)
           sum14 = total(CH3COOHemis)
           sum15 = total(CH3OHemis)
           sum16 = total(CRESOLemis)
           sum17 = total(GLYALDemis)
           ;sum18 = total(GLYOXALemis)
           sum19 = total(HYACemis)
           sum20 = total(ISOPemis)
           sum21 = total(MACRemis)
           sum22= total(MEKemis)
           sum23 = total(MVKemis)
           sum24 = total(HCNemis)
           sum25 = total(CH3CNemis)
           sum26 = total(TOLUENEemis)
           sum27 = total(HCOOHemis)
           sum28 = total(C2H2emis)


sumall = sum1+sum2+sum3+sum4+sum5+sum6+sum7+sum8+sum9+sum10+sum11+sum12+sum13+sum14+ $
         sum15+sum16+sum17+sum19+sum20+sum21+sum22+sum23+sum24+sum25+sum26+sum27+sum28

printf, 2, ''
printf, 2, 'The total sum of MOZART4 VOC species (moles) including HCOOH and C2H2 = ', sumall
printf, 2, ''
printf, 2, ''

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
printf, 2, 'PM20, ', total(PM10)/1.e9

; WESTERN U.S. 
westUS = where(lati gt 24. and lati lt 49. and longi gt -125. and longi lt -100.)   
printf, 2, 'Western US (Gg Species)'
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
printf, 2, 'PM10, ',  total(PM10[westUS])/1.e6

; EASTERN U.S. 
eastUS = where(lati gt 24. and lati lt 49. and longi gt -100. and longi lt -60.)   
printf, 2, 'Eastern US (Gg Species)'
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
printf, 2, 'PM10, ',  total(PM10[eastUS])/1.e6

; CANADA/AK 
CANAK = where(lati gt 49. and lati lt 70. and longi gt -170. and longi lt -55.)   
printf, 2, 'Canada/Alaska (Gg Species)'
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
printf, 2, 'PM10, ',  total(PM10[CANAK])/1.e6


; Mexico and Central America 
MXCA = where(lati gt 10. and lati lt 28. and longi gt -120. and longi lt -65.)   
printf, 2, 'Mexico/Central America (Gg Species)'
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
printf, 2, 'PM10, ',  total(PM10[MXCA])/1.e6

; BEIJING (For Helen WORTON)
; 32°-45°N, 108°-124°E?
BEJ = where(lati gt 32. and lati lt 45. and longi gt 108. and longi lt 124.)   
printf, 2, 'Beijing Area for Helen Worton (Gg Species)'
printf, 2, 'CO2, ', total(CO2[BEJ])/1.e6
printf, 2, 'CO, ', total(CO[BEJ])/1.e6
printf, 2, 'NOX, ', total(NOX[BEJ])/1.e6
printf, 2, 'NO, ', total(NO[BEJ])/1.e6
printf, 2, 'NO2, ', total(NO2[BEJ])/1.e6
printf, 2, 'NH3, ', total(NH3[BEJ])/1.e6
printf, 2, 'SO2, ', total(SO2[BEJ])/1.e6
printf, 2, 'VOC, ', total(VOC[BEJ])/1.e6
printf, 2, 'CH4, ', total(CH4[BEJ])/1.e6
printf, 2, 'OC, ', total(OC[BEJ])/1.e6
printf, 2, 'BC, ', total(BC[BEJ])/1.e6
printf, 2, 'PM2.5, ', total(PM25[BEJ])/1.e6
printf, 2, 'PM10, ',  total(PM10[BEJ])/1.e6


; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
