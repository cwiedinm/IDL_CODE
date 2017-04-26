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
; DECEMBER 01, 2015
; - processed the global 2014 and 2015 files that I created today
; 
; JANUARY 27, 2016
; - Edited to run with JJ's FINNv2 files
; 
; MARCH 28-29, 2016
; - Edited to run with Paola's file
; 
;
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_MOZART_PAOLA_03292016

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
year = 2015
firstday =1
lastday =365

infile = 'E:\Data2\wildfire\FINN\FINNv2\MARCH2016\PAOLA\FINNmod2015_subdivided_scen1_03292016.txt'
outfile = 'E:\Data2\wildfire\FINN\FINNv2\MARCH2016\PAOLA\FINN2beta_Paola_Scen1_MOZ4_03292016b.txt'

checkfile = 'E:\Data2\wildfire\FINN\FINNv2\MARCH2016\PAOLA\LOG_FINN2beta_Paola_Scen1_MOZ4_03292016b.txt'
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

; These are the headers from JJ's file (from the FINNv2 output) 
; 1      2   3       4    5  6   7    8     9      10    11      12  13    14       15       16     17  18    19 20  21  22  23   24   25   26 27 28     29    30
; longi,lat,polyid,fireid,jd,glc,lct,fccs,fccs_cdl,tceq,tceq_cdl,esa,genLC,pcttree,pctherb,pctbare,area,bmass,CO,NOx,NH3,SO2,NMOC,PM25,PM10,OC,BC,month,scen,scenuse,lctorig,glcorig,fccsorig,fccscdlorig,tceqorig,tceqcdlorig,esaorig,state

    longi = fire.field01
    lati= fire.field02
    day = fire.field05
    jday = day
 ;   time = fire.field05 ; No time in output files from FINNv2
    lct = fire.field07 
    genveg = fire.field13
;	  CO2 = fire.field13
		CO = fire.field19
		OC = fire.field26
		BC = fire.field27
		PM25 = fire.field24
		PM10 = fire.field25 ; Added 08/19/2010
		NOX = fire.field20
;		NO = fire.field20
;		NO2 = fire.field19
		NH3 = fire.field21
		SO2 = fire.field22
		VOC = fire.field23
;		CH4 = fire.field15
;		H2 = fire.field16 ; added 09/29/2010
		area = fire.field17 ; added 03/10/2011; should be in m2

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

; CLIP OUT 
;latmin = -90.
;latmax = 90.
;longmin = -180.
;longmax =180.
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
	; 01/27/2016: Set CO2, CH4, H2, NO, and NO2 to zero (since not in FINNv2 output)
	   	CO2emis[i]=0.0 
    	COemis[i]=CO[i]*1000./28.01
    	CH4emis[i]=0.0
     	NH3emis[i]=NH3[i]*1000/17.03
    	NOemis[i] = NOx[i]*1000/30.01 ; set to NOX emissions from FINNv2
    	NO2emis[i] = 0.0
    	SO2emis[i]=SO2[i]*1000/64.06
    	H2emis[i] = 0.0
    	
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
	 print,'SKIP: fire = ',i+1,' and day: ',jday[i],' not included.
	 goto, skipfire
endif

; Print to output file
; 
; NEW FORMAT
;	                       DAY,    TIME,  GENVEG,    LATI,   LONGI,   AREA    CO2,       CO,        H2,         NO,       NO2,        SO2,       NH3,       CH4         VOC
printf, 5, format = form, day[i],1000,genveg[i],lati[i],longi[i],area[i],CO2emis[i],COemis[i],H2emis[i], NOemis[i],NO2emis[i], SO2emis[i],NH3emis[i],CH4emis[i], VOCemis[i], $
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




; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
