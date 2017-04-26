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
; July 24, 2012
; - Ran 2012 emissions file
; 
; SEPTEMBER 11, 2012
; - Ran for the new 2012 Emissions (global)
; 
; DECEMBER 14, 2012
; - Ran for MEGAN BELA - clipped to her domain
; 
; FEBRUARY 25, 2012
; - ran entire year 2012
; 
; December 11, 2013
; - speciated 2012 and 2013 for Mark Flanner
; 
; Juine 02, 2014
; - Redid file for 2009 for Mijeong
; 
; JULY 10, 2014
; - Added Genveg = 6 to the speciation (set it equal to tempfor)
; - Ran Speciation for the new FINNv1.5 files
; 
; SEPTEMBER 22, 2014
; - Ran the speciation for the 2014 files for Louisa
; 
; MARCH 22, 2015
; - Ran entire 2014 file (created Feb_2015) 
; 
; 
; April 15, 2015
; - Ran again for 2013 FINNv1.5 file (that was created June 2014) 
; - Ran again for 2013 file - ONLY getting the AG fires!!! (NOTE -- Make sure go in and edit
; 
; 
; JUNE 23, 2015
; - edited to process 2014 file and clip out only the region Scott needs for his model
; 
; APRIL 01, 2016 
; - Edited to create a MOZART speciated file clipped to PAOLA's domain/episode
; 
; MAY 25, 2016
; - Edited to create the MOZART speciated FINNv1.5 2015 file
; 
; 
; OCTOBER 15, 2016
;  - edited to speciate the new 2016 files
;  
;  NOVEMBer 02, 2016
;  - edited (renamed from speciate_MOZART_FINNv15_2015 to speciate_MOZART_FINNv15_2016)
;  - set up to run the 2016 fires that I created on Nov. 02, 2016
;  
;  NOVEMBER 03, 2016
;  - edited and ran with 2015 global file created in September 2016
;  
;  NOVEMBER 07, 2016
;  - renamed speciate_mozart_finnv15_SEAC4RS.pro
;  - Edited to run with and without ag emissions for 2012, 2013, 2014
;  - Updated speciation file -- changed the number of species in the output 
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_mozart_finnv15_SEAC4RS

close, /all

;****************************************************************************************************
; CONVERSION FACTOR TABLE FOR VOCs
;      convert ='E:\Data2\wildfire\EMISSIONS_PAPER2009\SPECIATION\MOZ4_VOC_Speciatec.csv' ; edited on 11/29/2010 does not include GLYOXAL!!
      convert = 'E:\Data2\wildfire\SEAC4RS\EMISSIONS_CROP_PAPER\Updated_SPECIATION_11102016.csv' ; File created on 11/13/2016
      
      intemp2=ascii_template(convert)
      speciate=read_ascii(convert, template=intemp2)

; This file reads in the factors to apply to the VOC number to speciate to the MOZART4 species
; Takes fire emissions (kg/day) and converts to mole species/day
; HEADER: 
;SPECIES  SAVANNA TROPICAL  TEMPERATE BOREAL  SHRUB CROP

    sav = speciate.field2
    tropfor = speciate.field3
    tempfor = speciate.field4
    ag = speciate.field7
    boreal = speciate.field5
    shrub = speciate.field6
 
 ; The list of MOZART species in that file are: 
; ALKNIT
; APIN
; BENZENE
; BIGALD
; BIGALK
; BIGENE
; BPIN
; BZALD
; C2H2
; C2H4
; C2H5OH
; C2H6
; C3H6
; C3H8
; CH2O
; CH3CHO
; CH3CN
; CH3COCH3
; CH3COOH
; CH3OH
; CH3SCH3
; CRESOL
; GLYALD
; HCN
; HCOOH
; HYAC
; ISOP
; LIMON
; MACR
; MEK
; MGLY
; MVK
; MYRC
; NC4CHO
; NROG
; PHENOL
; TOLUENE
; XYLENE
; XYLOL


;*************************************************************************************************
year = 2014
year1 = '2014'
firstday =1
lastday =365


; DETERMINE if AG will be included

 withag = 1 ; include ag
 ;withag = 0 ; remove ag

if withag eq 1 then name = 'AG'
if withag eq 0 then name = 'NOAG'

;infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\FINNv1.5_2016_11022016.txt' ; ran on 11/02/2016
;infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\FINNv1.5_2015_09192016.txt' ; ran on 11/03/2016

; SEACRS Processing
if year eq 2012 then infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv1.5_2012_SEAC4RS_11102016.txt' ; 2012 file
if year eq 2013 then infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv1.5_2013_SEAC4RS_11102016.txt' ; 2013 file
if year eq 2014 then infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\FINNv1.5_2014_SEAC4RS_11102016.txt' ; 2014 file
if year eq 2015 then infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\SEPTEMBER2016\FINNv1.5_2015_09192016.txt' ; 2015 file

;outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SPECIATE\GLOBAL_FINNv15_2016_MOZ4_11022016.txt' ; Ran on 11/02/2016
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\SPECIATED\GLOBAL_FINNv15_'+year1+'_MOZ4_'+name+'_11152016.txt' ; Ran on 11/07/2016

checkfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2016\NOVEMBER2016\SEAC4RS\SPECIATED\LOG_GLOBAL_FINNv15_'+year1+'_MOZ4_'+name+'_11152016.txt'
; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
openw, 2, checkfile
printf, 2, 'The input file is: ', infile
printf, 2, 'The speciation file is: ',convert
printf, 2, 'The output file is: ', outfile
printf, 2, 'This file is: ', name
printf, 2, ' '


openw, 5, outfile

; NEW WAY (March 10, 2011)
;printf, 5, 'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'  ; 11

; NEW OUTPUT AS OF NOVEMBER 13, 2016
; ALKNIT  APIN  BENZENE BIGALD  BIGALK  BIGENE  BPIN  BZALD C2H2  C2H4  C2H5OH  C2H6  C3H6  C3H8  CH2O  CH3CHO  CH3CN CH3COCH3  CH3COOH CH3OH CH3SCH3 CRESOL  GLYALD  HCN HCOOH HYAC  ISOP  LIMON MACR  MEK MGLY  MVK MYRC  NC4CHO  NROG  PHENOL  TOLUENE XYLENE  XYLOL
printf, 5, 'DAY,TIME,GENVEG,LATI,LONGI,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,PM25,OC,BC,PM10,ALKNIT,APIN,BENZENE,BIGALD,BIGALK,BIGENE,BPIN,BZALD,C2H2,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3CN,CH3COCH3,CH3COOH,CH3OH,CH3SCH3,CRESOL,GLYALD,HCN,HCOOH,HYAC,ISOP,LIMON,MACR,MEK,MGLY,MVK,MYRC,NC4CHO,NROG,PHENOL,TOLUENE,XYLENE,XYLOL'
form='(I6,",",I6,",",I6,",",54(D20.10,","))'



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
ALKNITemis =  fltarr(numfires)
APINemis =  fltarr(numfires)
BENZENEemis = fltarr(numfires)
BIGALDemis =  fltarr(numfires)
BIGALKemis =  fltarr(numfires)
BIGENEemis =  fltarr(numfires)
BPINemis =  fltarr(numfires)
BZALDemis = fltarr(numfires)
C2H2emis =  fltarr(numfires)
C2H4emis =  fltarr(numfires)
C2H5OHemis =  fltarr(numfires)
C2H6emis =  fltarr(numfires)
C3H6emis =  fltarr(numfires)
C3H8emis =  fltarr(numfires)
CH2Oemis =  fltarr(numfires)
CH3CHOemis =  fltarr(numfires)
CH3CNemis = fltarr(numfires)
CH3COCH3emis =  fltarr(numfires)
CH3COOHemis =  fltarr(numfires)
CH3OHemis =  fltarr(numfires)
CH3SCH3emis = fltarr(numfires)
CRESOLemis =  fltarr(numfires)
GLYALDemis =  fltarr(numfires)
HCNemis = fltarr(numfires)
HCOOHemis = fltarr(numfires)
HYACemis =  fltarr(numfires)
ISOPemis =  fltarr(numfires)
LIMONemis = fltarr(numfires)
MACRemis =  fltarr(numfires)
MEKemis =  fltarr(numfires)
MGLYemis = fltarr(numfires)
MVKemis =  fltarr(numfires)
MYRCemis = fltarr(numfires)
NC4CHOemis = fltarr(numfires)
NROGemis = fltarr(numfires)
PHENOLemis = fltarr(numfires)
TOLUENEemis =  fltarr(numfires)
XYLENEemis = fltarr(numfires)
XYLOLemis = fltarr(numfires)
    
;-------------------------------
; DO LOOP OVER ALL FIRES
; Convert VOC species and output most in mole/km2/day
;-------------------------------
agcount = 0L
agcount2 = n_elements(where(genveg eq 9))

for i = 0L,numfires-1 do begin

; CLIP OUT 
;latmin = -21.
;latmax = 21.
;longmin = 75.
;longmax =155.
;if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt longmax or longi[i] lt longmin) then goto, skipfire

; DETERMINE IF REMOVE AG FIRES
; if removing ag fires, skipfire (11/07/2016)
  if genveg[i] eq 9 then begin
 ;     print, "ag fire"
      agcount = agcount+1
      if withag eq 0 then goto, skipfire
  endif



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
if genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP

; Tropical Forests (genveg = 3):
if (genveg[i] eq 1) then convert2MOZ4 = sav
if (genveg[i] eq 2) then convert2MOZ4 = shrub
if (genveg[i] eq 3) then convert2MOZ4 = tropfor
if (genveg[i] eq 4) then convert2MOZ4 = tempfor
if (genveg[i] eq 5) then convert2MOZ4 = boreal
if (genveg[i] eq 9) then convert2MOZ4 = ag
if (genveg[i] eq 6) then convert2MOZ4 = tempfor ; Added July 10, 2014

; Speciate VOC emissoins. VOC is in kg and the output of this is mole MOZ4 species
;0 ALKNIT 
;1 APIN
;2 BENZENE 
;3 BIGALD
;4 BIGALK
;5 BIGENE
;6 BPIN
;7 BZALD
;8 C2H2
;9 C2H4
;10 C2H5OH
;11 C2H6
;12 C3H6
;13 C3H8
;14 CH2O
;15 CH3CHO
;16 CH3CN
;17 CH3COCH3
;18 CH3COOH
;19 CH3OH
;20 CH3SCH3
;21 CRESOL
;22 GLYALD
;23 HCN
;24 HCOOH
;25 HYAC
;26 ISOP
;27 LIMON
;28 MACR  
;29 MEK 
;30 MGLY
;31 MVK
;32 MYRC
;33 NC4CHO
;34 NROG
;35 PHENOL
;36 TOLUENE
;37 XYLENE
;38 XYLOL
	         ALKNITemis[i] = VOC[i]*convert2MOZ4[0]
	         APINemis[i] = VOC[i]*convert2MOZ4[1]
           BENZENEemis[i] = VOC[i]*convert2MOZ4[2]
           BIGALDemis[i] = VOC[i]*convert2MOZ4[3]
           BIGALKemis[i] = VOC[i]*convert2MOZ4[4]
           BIGENEemis[i] = VOC[i]*convert2MOZ4[5]
           BPINemis[i] = VOC[i]*convert2MOZ4[6]
           BZALDemis[i] = VOC[i]*convert2MOZ4[7]
           C2H2emis[i] = VOC[i]*convert2MOZ4[8]
           C2H4emis[i] = VOC[i]*convert2MOZ4[9]
           C2H5OHemis[i] = VOC[i]*convert2MOZ4[10]
           C2H6emis[i] = VOC[i]*convert2MOZ4[11]
           C3H6emis[i] = VOC[i]*convert2MOZ4[12]
           C3H8emis[i] = VOC[i]*convert2MOZ4[13]
           CH2Oemis[i] = VOC[i]*convert2MOZ4[14]
           CH3CHOemis[i] = VOC[i]*convert2MOZ4[15]
           CH3CNemis[i] = VOC[i]*convert2MOZ4[16]
           CH3COCH3emis[i] = VOC[i]*convert2MOZ4[17]
           CH3COOHemis[i] = VOC[i]*convert2MOZ4[18]
           CH3OHemis[i] = VOC[i]*convert2MOZ4[19]
           CH3SCH3emis[i] = VOC[i]*convert2MOZ4[20]
           CRESOLemis[i] = VOC[i]*convert2MOZ4[21]
           GLYALDemis[i] = VOC[i]*convert2MOZ4[22]
           HCNemis[i] = VOC[i]*convert2MOZ4[23]
           HCOOHemis[i] = VOC[i]*convert2MOZ4[24]
           HYACemis[i] = VOC[i]*convert2MOZ4[25]
           ISOPemis[i] = VOC[i]*convert2MOZ4[26]
           LIMONemis[i] = VOC[i]*convert2MOZ4[27]
           MACRemis[i] = VOC[i]*convert2MOZ4[28]
           MEKemis[i] =  VOC[i]*convert2MOZ4[29]
           MGLYemis[i] =  VOC[i]*convert2MOZ4[30]
           MVKemis[i] =  VOC[i]*convert2MOZ4[31]
           MYRCemis[i] =  VOC[i]*convert2MOZ4[32]
           NC4CHOemis[i] =  VOC[i]*convert2MOZ4[33]
           NROGemis[i] =  VOC[i]*convert2MOZ4[34]
           PHENOLemis[i] =  VOC[i]*convert2MOZ4[35]
           TOLUENEemis[i] =  VOC[i]*convert2MOZ4[36]
           XYLENEemis[i] =  VOC[i]*convert2MOZ4[37]
           XYLOLemis[i] =  VOC[i]*convert2MOZ4[38]
           

if C2H6emis[i] eq 0 then begin
	 print,'fire = ',i+1,' and day: ',jday[i],' not included.
	 goto, skipfire
endif

; Print to output file
; 
; NEW FORMAT
;                         DAY,   TIME,   GENVEG,   LATI,   LONGI,   CO2,       CO,       H2,        NO,       NO2,        SO2,       NH3,       CH4,        NMOC,
printf, 5, format = form, day[i],time[i],genveg[i],lati[i],longi[i],CO2emis[i],COemis[i],H2emis[i], NOemis[i],NO2emis[i], SO2emis[i],NH3emis[i],CH4emis[i], VOCemis[i], $
;PM25,       OC,       BC,      PM10,        ALKNIT,      APIN,        BENZENE,      BIGALD,         BIGALK,      BIGENE,       BPIN,  
PM25emis[i],OCemis[i],BCemis[i],PM10emis[i],ALKNITemis[i],APINemis[i],BENZENEemis[i],BIGALDemis[i],BIGALKemis[i],BIGENEemis[i],BPINemis[i], $
BZALDemis[i],C2H2emis[i],C2H4emis[i],C2H5OHemis[i],C2H6emis[i],C3H6emis[i],C3H8emis[i],CH2Oemis[i],CH3CHOemis[i],CH3CNemis[i],CH3COCH3emis[i],CH3COOHemis[i],CH3OHemis[i],CH3SCH3emis[i],CRESOLemis[i],$
GLYALDemis[i],HCNemis[i],HCOOHemis[i],HYACemis[i],ISOPemis[i],LIMONemis[i],MACRemis[i],MEKemis[i],MGLYemis[i],MVKemis[i],MYRCemis[i],NC4CHOemis[i],NROGemis[i],PHENOLemis[i],TOLUENEemis[i],XYLENEemis[i],XYLOLemis[i]

skipfire:

endfor ; end of i loop
printf, 2, ' '
printf, 2, 'The input file was: ', infile
printf, 2, 'The speciation file was: ', convert
printf, 2, ' '
printf, 2, 'The total number of fires = ', nfires
printf, 2, 'The total number of agfires = ', agcount
printf, 2, 'The total number of agfires = ', agcount2


printf, 2, ' ' 
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
printf, 2, ''
; NON-AG FIRES
Printf, 2, 'GLOBAL TOTALS without AG fires includede (Tg Species)'
nonag = where(genveg ne 9)
printf, 2, 'CO2, ', total(CO2[nonag])/1.e9
printf, 2, 'CO, ', total(CO[nonag])/1.e9
printf, 2, 'NOX, ', total(NOX[nonag])/1.e9
printf, 2, 'NO, ', total(NO[nonag])/1.e9
printf, 2, 'NO2, ', total(NO2[nonag])/1.e9
printf, 2, 'NH3, ', total(NH3[nonag])/1.e9
printf, 2, 'SO2, ', total(SO2[nonag])/1.e9
printf, 2, 'VOC, ', total(VOC[nonag])/1.e9
printf, 2, 'CH4, ', total(CH4[nonag])/1.e9
printf, 2, 'OC, ', total(OC[nonag])/1.e9
printf, 2, 'BC, ', total(BC[nonag])/1.e9
printf, 2, 'PM2.5, ', total(PM25[nonag])/1.e9
printf, 2, 'PM10, ',  total(PM10[nonag])/1.e9
printf, 2, ''
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
printf, 2, ''
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
printf, 2, ''
; EASTERN U.S. NOAG
eastUS2 = where(lati gt 24. and lati lt 49. and longi gt -100. and longi lt -60. and genveg ne 9)
printf, 2, 'Eastern US without AG (Gg Species)'
printf, 2, 'CO2, ', total(CO2[eastUS2])/1.e6
printf, 2, 'CO, ', total(CO[eastUS2])/1.e6
printf, 2, 'NOX, ', total(NOX[eastUS2])/1.e6
printf, 2, 'NO, ', total(NO[eastUS2])/1.e6
printf, 2, 'NO2, ', total(NO2[eastUS2])/1.e6
printf, 2, 'NH3, ', total(NH3[eastUS2])/1.e6
printf, 2, 'SO2, ', total(SO2[eastUS2])/1.e6
printf, 2, 'VOC, ', total(VOC[eastUS2])/1.e6
printf, 2, 'CH4, ', total(CH4[eastUS2])/1.e6
printf, 2, 'OC, ', total(OC[eastUS2])/1.e6
printf, 2, 'BC, ', total(BC[eastUS2])/1.e6
printf, 2, 'PM2.5, ', total(PM25[eastUS2])/1.e6
printf, 2, 'PM10, ',  total(PM10[eastUS2])/1.e6
printf, 2, ''


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

printf, 2, ''
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
printf, 2, ''
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
