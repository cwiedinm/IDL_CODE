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
;     - Edited to speciate to SAPRC99  
; FEBRUARY 16, 2010
;     - recreated SAPR99_VOC_Speciate.csv
;     - Added regional totals to the log file
;     - Redid Jerome's MXCA file for 2006
; AUGUST 06, 2010
;     - checked the SAPRC_VOC_Speciate.csv and in teh final file  with Sheryl's final tables
;     - edited to do the latest 2008 emissions (from July 02, 2010)
; AUGUST 18, 2010
;   - ran the file for Jeff (2009 emissions- only output November 2009 for Asia)    
;  SEPTEMBER 20, 2010
;  - Edited to calculate biomass burned per veg type in the LOG file
;  - Start to run for global emissions 
; SEPTEMBER 21, 2010
;   - Edited region for the western US (expanded to -125)
;   - running through the emissions for 2005-2010    
;   
; DECEMBER 01, 2010
;   - Edited to update the speciation table without GLYOXAL
;   - **** MAKE sure that the entire globe is processed!!! ********
;   
; FEBRUARY 25, 2011
;   - edited to process the 2001-2004 North American files
;   - Ran through 2001-2004 NA emissions
; APRIL 19, 2011
;  - Edited to include area in output file
;  - Got rid of final day in the year
; MAY 02, 2011
; - Edited so that there are no overlapping days in the multiple files for one year
; MAY 15, 2011
; - Ran 2002
; - Ran 2003
; - Ran 2004
; MAY 16, 2011
; - Ran Jan-Apr 2011
; 
; OCTOBER 06, 2011
; - Ran Jan-Sept. 2011 for MiEun Park (clipping Asia domain only)
; 
; OCTOBER 28, 3011
; - Ran for Chris Loughner (UMD) for 2011 emissions for clipped US domain
; 
; DECEMBER 15, 2011: 
;   - ran for 2007 August fires in Greece for Kostas
;   
; DECEMBER 30, 2011
; - cleaned up a little for Stacy  
; 
; July 23-25, 2012
;   - Ran the 2012 (first half) emissions
;   - Ran entire 2011 year
;   
; September 11, 2012
;   - Ran 2012 through August
;   
; JUNE 2013 
; - Ran the fisrt half of 2013
; 
; JULY 16, 2014
; - edited to take FINNv1.5 files (added genveg = 6)
; - Ran the FINNv1.5 files
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_global_SAPRC99_stacy
close, /all

;****************************************************************************************************
; CONVERSION FACTOR TABLE FOR VOCs
      convert = 'E:\Data2\wildfire\EMISSIONS_PAPER2009\SPECIATION\SAPR99_VOC_Speciate_12012010.csv'
      intemp2=ascii_template(convert)
      speciate=read_ascii(convert, template=intemp2)

; This file reads in the factors to apply to the VOC number to speciate to the MOZART4 species
; Takes fire emissions (kg/km2/day) and converts to mole species/km2/day
;SAPRC99 Species,  Savanna, TropFor, Temperate Forest,  AgResid, BOREAL,  Shrublands

    sav = speciate.field2
    tropfor = speciate.field3
    tempfor = speciate.field4
    ag = speciate.field5
    boreal = speciate.field6
    shrub = speciate.field7
 
 ; The list of SAPRC99 species in that file are:  (fixing 09/21/2010)
;0 ACET
;1 ALK1
;2 ALK2
;3 ALK3
;4 ALK4
;5 ALK5
;6 ARO1
;7 ARO2
;8 BALD
;9 CCHO
;10  CCO_OH
;11  ETHENE
;12  GLY -- REMOVED on 12.01.2010
;13  HCHO
;14  HCN
;15  HCOOH
;16  HONO
;17  ISOPRENE
;18  MEK 
;19  MEOH
;20  METHACRO
;21  MGLY
;22  MVK 
;23  OLE1
;24  OLE2
;25  PHEN
;26  PROD2
;27  RCHO
;28  TRP1

;*************************************************************************************************
year = 2014
firstday = 1
lastday = 365

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2014MDT_07092014.txt'
;infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\MARCH2012\GLOBAL_2011_03142012.txt'
outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\SAPRC99\GLOBALv15_2014MDT_SAPRC99_07142014.txt'
checkfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\SPECIATED\SAPRC99\LOG\LOG_GLOBALv15_2014MDT_SAPRC99_07142014.txt

; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
openw, 5, outfile

; NEW WAY (04/13/2011) - to include area in output file... 
;                                                                          ACET ALK1 ALK2 ALK3 ALK4 ALK5 ARO1 ARO2 BALD CCHO CCO_OH ETHENE HCHO HCN HCOOH HONO ISOPRENE MEK MEOH METHACRO MGLY MVK OLE1 OLE2 PHEN PROD2 RCHO RNO3 TRP1
printf, 5, 'DAY,TIME,GENVEG,LATI,LONGI,AREA,CO2,CO,NO,NO2,SO2,NH3,CH4,VOC,ACET,ALK1,ALK2,ALK3,ALK4,ALK5,ARO1,ARO2,BALD,CCHO,CCO_OH,ETHENE,HCHO,HCN,HCOOH,HONO,ISOPRENE,MEK,MEOH,METHACRO,MGLY,MVK,OLE1,OLE2,PHEN,PROD2,RCHO,RNO3,TRP1,OC,BC,PM25,PM10'
form='(I6,",",I6,",",I6,44(",",D20.10))'

openw, 2, checkfile

; Open input file and get the needed variables
; INPUT FILES FROM SEPT, 2010
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
		NOX = fire.field17
		NO = fire.field18
		NO2 = fire.field19
		NH3 = fire.field20
		SO2 = fire.field21
		VOC = fire.field23
		CH4 = fire.field15
		PM10 = fire.field29

; Added sum for biomass loading... 
; september 20, 2010
  area = fire.field11
  bmass = fire.field12

   	numfires = n_elements(day)
		nfires = numfires

print, 'FINISHED READING INPUT FILE'

print, 'The min and max day number of this file is:'
print, max(day)
print, min(day)

; Calculating the total biomass burned in each genveg for output file 
; Added 09/20/2010
 TOTTROP = 0.0
 TOTTEMP = 0.0
 TOTBOR = 0.0
 TOTSHRUB = 0.0
 TOTCROP = 0.0
 TOTGRAS = 0.0

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
  	

; Set up speciated VOC arrays
ACETemis=fltarr(numfires) 
ALK1emis=fltarr(numfires)
ALK2emis=fltarr(numfires)
ALK3emis=fltarr(numfires)
ALK4emis=fltarr(numfires)
ALK5emis=fltarr(numfires)
ARO1emis=fltarr(numfires)
ARO2emis=fltarr(numfires)
BALDemis=fltarr(numfires)
CCHOemis=fltarr(numfires)
CCO_OHemis=fltarr(numfires)
ETHENEemis=fltarr(numfires)
;GLYemis=fltarr(numfires)
HCHOemis=fltarr(numfires)
HCNemis = fltarr(numfires)
HCOOHemis=fltarr(numfires)
HONOemis=fltarr(numfires)
ISOPRENEemis=fltarr(numfires)
MEKemis=fltarr(numfires)
MEOHemis=fltarr(numfires)
METHACROemis=fltarr(numfires)
MGLYemis=fltarr(numfires)
MVKemis=fltarr(numfires)
OLE1emis=fltarr(numfires)
OLE2emis=fltarr(numfires)
PHENemis=fltarr(numfires)
PROD2emis=fltarr(numfires)
RCHOemis=fltarr(numfires)
RNO3emis=fltarr(numfires)
TRP1emis=fltarr(numfires)
  
;-------------------------------
; DO LOOP OVER ALL FIRES
; Convert VOC species and output most in mole/km2/day
;-------------------------------
print, 'Input file = ', infile
print, 'First day = ', min(day)
print, 'Last day = ', max(day)

for i = 0L,numfires-1 do begin


; Only process fires for the days selected
if day[i] lt firstday or day[i] gt lastday then goto, skipfire
 
 ; ONLY DO FIRES THAT ARE WITHIN THE SET LAT/LON
; OCTOBER 28, 2011: Ran for 
; Lat: 15 -> 65 degrees
; Lon: -145 -> -45 degrees
;latmin = 32.
;latmax = 49.
;longmin = 11.
;longmax = 36.
;if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt longmax or longi[i] lt longmin) then goto, skipfire

;July 24, 2012: Ran for ME PARK (Korea_
; Lat: 5 -> 65 degrees
; Lon: 75 -> 165 degrees
;latmin = 5.
;latmax = 65.
;longmin = 75.
;longmax = 165.
;if (Lati[i] gt latmax or lati[i] lt latmin or longi[i] gt longmax or longi[i] lt longmin) then goto, skipfire
; 
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
;     NOX_emis[i]=NOX[i] 
      VOCemis[i]=VOC[i]
      OCemis[i]=OC[i]
      BCemis[i]= BC[i]
      PM25emis[i]=PM25[i]
      PM10emis[i]=PM10[i]
      
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

if (genveg[i] eq 1) then convert2SAPR99 = sav
if (genveg[i] eq 2) then convert2SAPR99 = shrub
if (genveg[i] eq 3) then convert2SAPR99 = tropfor
if (genveg[i] eq 4) then convert2SAPR99 = tempfor
if (genveg[i] eq 5) then convert2SAPR99 = boreal
if (genveg[i] eq 9) then convert2SAPR99 = ag
if (genveg[i] eq 6) then convert2SAPR99 = tempfor ; Added July 16, 2014

bmassburn = bmass[i]*area[i] ; kg burned
if genveg[i] eq 3 then TOTTROP = TOTTROP+bmassburn
if genveg[i] eq 4 then TOTTEMP = TOTTEMP+bmassburn
if genveg[i] eq 5 then TOTBOR = TOTBOR+bmassburn
if genveg[i] eq 2 then TOTSHRUB = TOTSHRUB+bmassburn
if genveg[i] eq 9 then TOTCROP = TOTCROP+bmassburn
if genveg[i] eq 1 then TOTGRAS = TOTGRAS+bmassburn
if genveg[i] eq 6 then TOTTEMP = TOTTEMP+bmassburn

; New Species List, 12.01.2010
;0 ACET
;1 ALK1
;2 ALK2
;3 ALK3
;4 ALK4
;5 ALK5
;6 ARO1
;7 ARO2
;8 BALD
;9 CCHO
;10  CCO_OH
;11  ETHENE
;12  HCHO
;13  HCN
;14  HCOOH
;15  HONO
;16  ISOPRENE
;17  MEK 
;18  MEOH
;19  METHACRO
;20  MGLY
;21  MVK 
;22  OLE1
;23  OLE2
;24  PHEN
;25  PROD2
;26  RCHO
;27  TRP1



; Speciate VOC emissions. VOC is in kg and the output of this is mole GEOS-CHEM Emissions species
ACETemis[i] = VOC[i]*convert2SAPR99[0] 
ALK1emis[i] = VOC[i]*convert2SAPR99[1]
ALK2emis[i] = VOC[i]*convert2SAPR99[2]
ALK3emis[i] = VOC[i]*convert2SAPR99[3]
ALK4emis[i] = VOC[i]*convert2SAPR99[4]
ALK5emis[i] = VOC[i]*convert2SAPR99[5]
ARO1emis[i] = VOC[i]*convert2SAPR99[6]
ARO2emis[i] = VOC[i]*convert2SAPR99[7]
BALDemis[i] = VOC[i]*convert2SAPR99[8]
CCHOemis[i] = VOC[i]*convert2SAPR99[9]
CCO_OHemis[i] = VOC[i]*convert2SAPR99[10]
ETHENEemis[i] = VOC[i]*convert2SAPR99[11]
HCHOemis[i] = VOC[i]*convert2SAPR99[12]
HCNemis[i] = VOC[i]*convert2SAPR99[13]
HCOOHemis[i] = VOC[i]*convert2SAPR99[14]
HONOemis[i] = VOC[i]*convert2SAPR99[15]
ISOPRENEemis[i] = VOC[i]*convert2SAPR99[16]
MEKemis[i] = VOC[i]*convert2SAPR99[17]
MEOHemis[i] = VOC[i]*convert2SAPR99[18]
METHACROemis[i] = VOC[i]*convert2SAPR99[19]
MGLYemis[i] = VOC[i]*convert2SAPR99[20]
MVKemis[i] = VOC[i]*convert2SAPR99[21]
OLE1emis[i] = VOC[i]*convert2SAPR99[22]
OLE2emis[i] = VOC[i]*convert2SAPR99[23]
PHENemis[i] = VOC[i]*convert2SAPR99[24]
PROD2emis[i] = VOC[i]*convert2SAPR99[25]
RCHOemis[i] = VOC[i]*convert2SAPR99[26]
TRP1emis[i] = VOC[i]*convert2SAPR99[27]

if ACETemis[i] eq 0 then begin
	 print,'fire = ',i+1,' and day: ',jday[i],' not included.
	 goto, skipfire
endif


; Print to output file
;                         DAY,   TIME,   GENVEG,   LATI,   LONGI,   area,   CO2,       CO,       NO,       NO2,        SO2,       NH3,       CH4,       VOC, 
printf, 5, format = form, day[i],time[i],genveg[i],lati[i],longi[i],area[i],CO2emis[i],COemis[i],NOemis[i],NO2emis[i], SO2emis[i],NH3emis[i],CH4emis[i], VOCemis[i],$
;ACET,       ALK1,       ALK2,       ALK3,       ALK4,       ALK5,       ARO1,       ARO2,       BALD,       CCHO,
 ACETemis[i],ALK1emis[i],ALK2emis[i],ALK3emis[i],ALK4emis[i],ALK5emis[i],ARO1emis[i],ARO2emis[i],BALDemis[i],CCHOemis[i], $
;CCO_OH,       ETHENE,       HCHO,       HCN,        HCOOH,       HONO,       ISOPRENE,       MEK,       MEOH, 
 CCO_OHemis[i],ETHENEemis[i],HCHOemis[i],HCNemis[i], HCOOHemis[i],HONOemis[i],ISOPRENEemis[i],MEKemis[i],MEOHemis[i],$
;METHACRO,       MGLY,       MVK,       OLE1,       OLE2,       PHEN,       PROD2,       RCHO,       RNO3,       TRP1 
 METHACROemis[i],MGLYemis[i],MVKemis[i],OLE1emis[i],OLE2emis[i],PHENemis[i],PROD2emis[i],RCHOemis[i],RNO3emis[i],TRP1emis[i],$
; OC,      BC,       PM25           PM10'  
  OCemis[i],BCemis[i],PM25emis[i], PM10emis[i] 

skipfire:

endfor ; end of i loop

Printf, 2, 'SUMMARY FROM SAPRC99 speciation'

Printf, 2, 'Emissions from fire emissions'
printf, 2, 'The total CO2 emissions (moles, Tg) = ',  total(CO2emis), ",",total(CO2)/1.e9
printf, 2, 'The total CO emissions (moles, Tg) =  ',  total(COemis), ",",total(CO)/1.e9
printf, 2, 'The total NO emissions (moles, Tg) =  ',  total(NOemis), ",",total(NO)/1.e9
printf, 2, 'The total NO emissions (Tg) = ', total(NO)/1.e9, ' Original from fire emissions model before speciation- should be the same as above'
printf, 2, 'The total NO2 emissions (moles, Tg) = ',  total(NO2emis), ",",total(NO2)/1.e9
printf, 2, 'The total SO2 emissions (moles, Tg) = ',  total(SO2emis), ",",total(SO2)/1.e9
printf, 2, 'The total OC emissions (Tg) =',  total(OCemis)/1.e9
printf, 2, 'The total BC emissions (Tg) =',  total(BCemis)/1.e9
printf, 2, 'The total VOC emissions (Tg) =',  total(VOCemis)/1.e9
printf, 2, 'The total PM2.5 emissions (Tg) =',  total(PM25emis)/1.e9
printf, 2, 'The total PM10 emissions (Tg) =',  total(PM10emis)/1.e9
printf, 2, ' ' 
Printf, 2, 'Speciated emissions'
printf, 2, 'The total ALK4 emissio (moles) =',  total(ALK4emis)
printf, 2, 'The total ETHENE emissions (moles) =',  total(ETHENEemis)
printf, 2, 'The total MEK emissions (moles) =',  total(MEKemis)
printf, 2, 'The total OLE1 emiss (moles) =',   total(OLE1emis)
printf, 2, 'The total CH2O emissions (moles) =',  total(HCHOemis)
printf, 2, 'The total MEOH emissions (moles) =',  total(MEOHemis)
printf, 2, 'The total ETHENE emissions (moles) =',  total(ETHENEemis)
printf, 2, 'The total ACET emissions (moles) =',  total(ACETemis)
;printf, 2, 'The total GLY emissions (moles) =',  total(GLYemis)
printf, 2, 'The total HONO emissions (moles) =',  total(HONOemis)
printf, 2, 'The total ISOPRENE emissions (moles) =',  total(ISOPRENEemis)
printf, 2, 'The total TRP1 emissions (moles) =',  total(TRP1emis)
printf, 2, 'The total HCN emissions (moles) =',  total(HCNemis)
printf, 2, ''



; TOTAL SAPR99 SPECIES
;ACETemis[i]  ALK1emis  ALK2emis  ALK3emis 3] ALK4emis 4] ALK5emis 5] ARO1emis 6] ARO2emis 7] BALDemis 8] CCHOemis 9] CCO_OHemis 10]  
;THENEemis 11]  GLYemis 12] HCHOemis 13]  HCOOHemis 14] HONOemis 15]  ISOPRENEemis 16]  MEKemis 17] MEOHemis 18]  METHACROemis 19]  
;MGLYemis 20]  MVKemis 21] OLE1emis 22]  OLE2emis 23]  PHENemis 24]  
;PROD2emis 25] RCHOemis 26]  RNO3emis 27]  TRP1emis 28]
sum1 = total(ACETemis)
sum2 = total(ALK1emis)
sum3 = total(ALK2emis)
sum4 = total(ALK3emis)
sum5 = total(ALK4emis)
sum6 = total(ALK5emis)
sum6 = total(ARO1emis)
sum7 = total(ARO2emis)
sum8 = total(BALDemis)
sum9 = total(CCHOemis)
sum10 = total(CCO_OHemis)
sum11 = total(ETHENEemis)
;sum12 = total(GLYemis)
sum13 = total(HCHOemis)
sum14 = total(HCOOHemis)
sum15 = total(HONOemis)
sum16 = total(ISOPRENEemis)
sum17 = total(MEKemis)
sum18 = total(MEOHemis)
sum19 = total(METHACROemis)
sum20 = total(MGLYemis)
sum21 = total(MVKemis)
sum22 = total(OLE1emis)
sum23 = total(OLE2emis)
sum24 = total(PROD2emis)
sum25 = total(RCHOemis)
sum26 = total(RNO3emis)
sum27 = total(TRP1emis)
sum28 = total(PHENemis)

sumall = sum1+sum2+sum3+sum4+sum5+sum6+sum7+sum8+sum9+sum10+sum11+sum13+sum14+ $
         sum15+sum16+sum17+sum18+sum19+sum20+sum21+sum22+sum23+sum24+sum25+sum26+sum27+sum28

printf, 2, 'The total sum of SAPRC99 species (moles) except NO = ', sumall
printf, 2, ''
printf, 2, ''

printf, 2, ''
; PRINT GLOBAL BIOMASS BURNED
printf, 2, 'Global Totals (Tg) of biomass burned per vegetation type'
printf, 2, 'Total Temperate Forests (Tg), ', TOTTEMP/1.e9
printf, 2, 'Total Tropical Forests (Tg),', TOTTROP/1.e9
printf, 2, 'Total Boreal Forests (Tg),', TOTBOR/1.e9
printf, 2, 'Total Shrublands/Woody Savannah(Tg),', TOTSHRUB/1.e9
printf, 2, 'Total Grasslands/Savannas (Tg),', TOTGRAS/1.e9
printf, 2, 'Total Croplands (Tg),', TOTCROP/1.e9
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
printf, 2, 'HCHO, ', total(HCHOemis)/1.e9
printf, 2, 'ISOPRENE, ', total(ISOPRENEemis)/1.e9
printf, 2, 'MEOH, ', total(MEOHemis)/1.e9


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
printf, 2, 'HCHO, ', total(HCHOemis[westUS])/1.e9
printf, 2, 'ISOPRENE, ', total(ISOPRENEemis[westUS])/1.e9
printf, 2, 'MEOH, ', total(MEOHemis[westUS])/1.e9


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
printf, 2, 'HCHO, ', total(HCHOemis[eastUS])/1.e9
printf, 2, 'ISOPRENE, ', total(ISOPRENEemis[eastUS])/1.e9
printf, 2, 'MEOH, ', total(MEOHemis[eastUS])/1.e9


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
printf, 2, 'HCHO, ', total(HCHOemis[CANAK])/1.e9
printf, 2, 'ISOPRENE, ', total(ISOPRENEemis[CANAK])/1.e9
printf, 2, 'MEOH, ', total(MEOHemis[CANAK])/1.e9


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
printf, 2, 'HCHO, ', total(HCHOemis[MXCA])/1.e9
printf, 2, 'ISOPRENE, ', total(ISOPRENEemis[MXCA])/1.e9
printf, 2, 'MEOH, ', total(MEOHemis[MXCA])/1.e9

; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
