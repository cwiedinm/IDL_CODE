; ****************************************************************************
; GLOBAL FIRE EMISSIONS ESTIMATES FOR MOZART MODEL
; This program will calculate global daily fire emisisons
; This is the prototype for the MIRAGE and INTEX campaigns
; Developed by Christine Wiedinmyer, December 30, 2005
;
;Inputs to this model include 1 file with overlaid data:
; 1) Fire detections/locations/times from Rapid Response web site
; 2) MODIS Land Cover Type (MOD12C, using the IGBP land cover classification
;    available online at http://edcdaac.usgs.gov/modis/mod12c1v4.asp)
; 3) VCF % tree and % herbaceous data
; 4) Model domains for the MOZART and WRF-Chem simulations
;
; The emission factors, fuel laodings, and combustion efficiency are read into
;  the program from external files. The values are based on values from
;   with the exception of croplands, where the fuel loading and emission
;   factors are taken from Wiedinmyer et al., submitted to AE.
; January 3, 2006: Checked all calculations and assignments by hand and they look
;   OK (see Check_outputs.xls)
; January 16, 2006: Running with 7-day file for North America to compare with the
;   North American model
; June 6, 2006: Edited the order of the variables read in to check for inaccuracies
;   in the tree and herb fractions!
; August 25, 2008: Edited program to create emission estimates for the AMAZE program
; 	downloaded the MODIS RR  June 18, 2008. Processed input file with global GIS model
; 	on August 25, 2008. Included the CONFIDENCE in the model input file (edited code here
; 	to remove all fires with CONF < 20
; September 18, 2008: rerunning MODIS RR for jan-april2008 due to problems with the original
;	files.
; October 02, 2008: Rerunning all emissions for January-April 2008 and for April-August 2008
; 	because first run estiamtes are 5 times higher than those from GFED. Today, only using
; 	detections from AQUA
; February 23-24, 2009: Editing the code to update to version 2.0 of the fire emissions model. These
; 	updates include:
; 		- moving the removal of the confidence < 20 earlier in the code
; 		- adding in Jay's code to get rid of overlapping fires
; 		- adding in the date and time in the output file (format = 2008-01-30,1830)
; 			NOTE: Printing out UTC time and JD (not local day/time)
; March 13, 2009; Running with the two files from 2008 (global files, one for JAN-APRIL and the
; 			second for MAY - SEPT)
; March 31, 2009: Created a sample input file (with 4 points) that I can use to check the output
; April 08, 2009: Checked the global model outputs with the regional model outputs. Global model is much higher
; 				than regional model outputs. Need to edit code to reduce the amount of Biomass burned
; 				and take into account the amount of vegetation at the surface (from the VCF)
; 		Edited this code for the following
;  		- changed the biomass that is output so that it is the burned biomass, not the total input
; 		- included the CF (combustion efficiency) calculation from regional model
; 		- also, assigns herbaceous fuels are automatically the grs fuel for the region. The coarse fuel
; 			is the fuel for the generic land cover
; JUNE 04, 2009: Updating code to test new LCT data
; 		- On June 04, added LCT2 to 2008 global input files (saved to D:\Data2\wildfire\MODEL_INPUTS\GLOBAL\2008\NEWLCT\)
; 		- Edited this code to read in new LCT values (not old ones).
; 		- Ran code. The extension on these files are 06040209 and newcode3
; JUNE 05, 2009:
; 		- Rerun the original (newcode2) and the newcode3 with new LCT values; put in new directory
; 		- New files have the extension "origLCT" and "NewLCT"
; JUNE 29, 2009:
; 		- Added PM2.5 and TPM to output file
; 		- Reran for the new LCT files (from June 05, 2009) (input field 13)
; JULY 02, 2009:
; 		- Edited to run the AUS/NZ files (changed input fields)
; AUGUST 12, 2009
; 		- Edited to Run Oct-Dec 2008
; 		- Edited to Run Jan-April 2009
;		- Edited to Run Jan-April 2007
; 		- Edited to Run May-Sept 2007
; 		- Edited to Run Oct-Dec 2007
; August 17, 2009
; 		- Edited to run May-Jul 2009
; SEPTEMBER 29, 2009
;   - Edited to run new 2003 fire emissions for Europe for Alma
;   
; OCTOBER 16, 2009
;   - Editing code to duplicate the fires in the tropics fof jd+1 (before removal of overlaps)
;   - running a test case (F:\Data2\wildfire\EPA_EI\MODEL\IDL_CODE\TEST2009\)
; OCTOBER 19-20, 2009: 
;   - Checked that code is running correctly (in tropics)
;   - updated emission factor and fuel loading tables
;   - Changed the number of emission factors assigned to generic land cover types
;   - Updated the output file to reflect all new chemical species
; OCTOBER 21-22, 209
;   - Rerun Global emissions for 2007
;   - rerun jan-april 2008
;   - rerun may-sep 2008
;   - Finish rerunning 2008 and the 2009 files
;  TO RUN: 
;   1) edit yearnum
;   2) edit input file name
;   3) edit output file and log file
;   4) make sure that the fields of the input file are read in correctly
;   5) make sure that the dates are read in properly   
; NOVEMBER 20, 2009: 
;   - found mistake in the correction for the tropical fires (was using the wrong days). Corrected 
;     (see line with today's date). NEED TO RERUN ALL GLOBAL!!!
;   - Rerun January-April 2009 for Louisa
; NOVEMBER 25, 2009
;   - Setting up a factor (FAC) to run for the duplicate tropical fires (added on Oct. 16, 2009)
;   - 
; DECEMBER 07, 2009
;  - set up and ran with 2003 Australia/NZ inputs for Clare
;     --> using a 0.5 FAC  
;  - running 2003 Austrailia/NZ case and resetting confidence levels to 25 for all
;  - Also ran changing the scale (from Jay's code component) from 2 to 1
; DECEMBER 08-09, 2009
;  - got a new file for 2003 Australian fires from Minnie and ran new input file
;  - ran with scale 1.5
;  - ran with updating the fuel loading for Austrailia (didn't make a big difference)
;  - Rerunning 2007-2009 fire detections 
;  - added correction for biomass assignment of boreal forest in Southern Asia
; DECEMBER 11, 2009
;   - noticed that CO2 emissions are wrong. Checking and found that the values weren't being divided by 1000. 
;   - Corrected. So, any CO2 emissions calculated in the past few days need to be divided by 1000. 
;   - added a section to skip the doubling of the tropical fires if none in input file
; JANUARY 05, 2010
;   - added option to use GLOBCOVER land use instead of LCT
; JANUARY 18-26, 2010
;   - changed emission factor input file (this was updated today)
;   - changed fuel loading file (this was updated today)
;   - Set Globcover to 0 
;   - in the removing overlaps section, I am first sorting by areasav- and then removing... (as in Jay's Original code)
;   - Added global totals to the log file
; FEBRUARY 15, 2010
;   - Updated Emission Factors - FINAL File; edited code accordingly
;   - Re ran emissions 2006-2008
; APRIL 30-MAY 02, 2010
;   - Run Jan-Nov2009 and Dec 2009
; JUNE 14, 2010
;   - Edited code so that AG. Fuel loading in Brazil is 1.1 kg/m2 (based on Elliott Campbell)
;   - Checked code
;   - Reran for paper
; JUNE 18, 2010
;   - realized EFs for some of the species and ecosystems were incorrect. 
;   - made a new EF file for the code. 
; JULY 01, 2010
;   - started rerunning mode for paper
; AUGUST 12, 2010
;   - Ran 2003 emissions for Jami
; AUGUST 17-18, 2010
;   - ran 2009 emissions
; August 18, 2010
;   - Added PM10 emission factors to input and output files.  
;   - Reran 2009 emissions
; August 24, 2010
;   - Edited code to output area burned by land cover type (in check file)
;   - Ran 2005 Emissions 
; September 07, 2010 
;   - running a test    
;   - Rerun 2007
; September 08, 2010
;   - Rerun 2008, 2009
; September 09, 2010
;   - Run 2010 emissions
; October 11, 2010
;   - Ran 2006 emisisons for GLOBCOVER 
; March 24, 2011
;   - Rerunninng 2008 emissions - the ones ran before were cut off!!
;   - Running the 2008 file using LCT and LCT2 to see difference (LCT2 is incorrect!!) 
;   April 03, 2011
;   - running new file for 2010 (in two parts). 
;   
; MAY 03-05, 2011
;   - running the 2011 file for Paul Palmer et al. 
; MAY 10, 2011
;   - running 2002 emisisons
; MAY 12, 2011
;   - running 2003 emissions
; JUNE 21, 2011
;   - edited to include total area in output LOG file
;   - rerun 2005 for a check 
; OCTOBER 04, 2011
;   - Running January - Sept 28, 2011 fire emissions (created input today, too)  
; FEBRUARY 15, 2012
; - Running several versions of the output for the Black Saturday fires
; MARCH 14, 2012
;   - Edited part of Jay's code to reverse sorting order
;   - Running full year of 2011
; JULY 24, 2012
;   - Edited to run 2012 through June 2012
;   - added 2012 for leap year
;  AUGUST 17, 2012
;   - edited to run the CONUS US through July 2012 (Judi at NWF)
; SEPTEMBER 10, 210
;   - edited to run 2012 through August 
; SEPTEMBER 17, 2012
;   - Ran 2007 entire year
;   - Ran 2008 entire year  
; NOVEMBER 08, 2012 
;   -  Ran Jan. 01 - Nov. 01, 2012 
; FEBRUARY 25-26, 2012
;   - Running entire year for 2012
; JUNE 18, 2013
; - running 2013
; JULY 31, 2013
; - Running Jan - July 2013 (input file created 07/31/2013
; - Updated Emission factor file
; DECEMBER 05, 2013
; - Running Jan-Nov. 2013 (input file created on 12/05/2013)
;***********************************************************************************************
;***********************************************************************************************
; APRIL 30, 2014
; - TOOK global Fire (last saved 12/2013) and edited for VIIRS Indonesia Project
; - Edited to 
;   * read in different input file
;   * chose LCT or GLC generic vegetation classes
;   * Removed TROPICS removal missed coverage 
;   * Removed code to remove overlaps from original code
;   * Removed some of the QA processes
;   * For fires with bad VCF - changed the assignment to forest, shrub, or grass
;   * removed re-assignment to genveg classes (already in input files) 
;   * set area to area read in input file (m2) 
;   * ** For this run only, set globreg to 11 (Southern Asia)
;   * hardwired the biomass/fuel loadings in the code for Southern Asia ONLY
;   
; NOVEMBER 21, 2014
; - Updated Emission factor file for FINNv1.5
; - Edtied output file to include interactive name for GLC/LCT
; - Edited yearnum in beginning to 2014
; - Edited (Corrected) CF3 for woodlands 
; *********************************************************************************************

pro global_fire_viirs2

close, /all

 t0 = systime(1) ;Procedure start time in seconds

 yearnum= 2014
 FAC = 0.5 ; Factor to apply to duplicate tropical fires 

; USE GLOBCOVER OR LCT INPUTS? ; 4/30/2014
 Globcover = 0 ; chose 1 for yes, 0 for no
 if Globcover eq 1 then landcover = 'GLC'
 if Globcover eq 0 then landcover = 'LCT'
 
 
; Calculating the total biomass burned in each genveg for output file 
; Added 08/24/2010
 TOTTROP = 0.0
 TOTTEMP = 0.0
 TOTBOR = 0.0
 TOTSHRUB = 0.0
 TOTCROP = 0.0
 TOTGRAS = 0.0
 
; Calculating total area in each genveg for output log file
; added 06/21/2011
 TOTTROParea = 0.0
 TOTTEMParea = 0.0
 TOTBORarea = 0.0
 TOTSHRUBarea = 0.0
 TOTCROParea = 0.0
 TOTGRASarea = 0.0
; 
; 
; CALCULATING TOTAL CO and PM2.5 for crops
 TOTCROPCO = 0.0
 TOTCROPPM25 = 0.0
; ****************************************************************************
; ASSIGN FUEL LOADS, EMISSION FACTORS FOR GENERIC LAND COVERS AND REGIONS
;   - created tables to be read in, instead of hardwiring the values here
; 08/25/08: Edited pathways here
; 10/19/2009: created new input files
; ****************************************************************************
;;   READ IN FUEL LOADING FILE
    fuelin = 'E:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\Fuel_LOADS_NEW012010.csv' ; Updated 01/18/2010
    infuel=ascii_template(fuelin)
    fuel=read_ascii(fuelin, template=infuel)
;   Set up fuel arrays
       globreg2 = fuel.field1
       tffuel = fuel.field2  ;tropical forest fuels
       tefuel = fuel.field3  ;temperate forest fuels
       bffuel = fuel.field4  ;boreal forest fuels
       wsfuel = fuel.field5  ;woody savanna fuels
       grfuel = fuel.field6  ;grassland and savanna fuels
       ; NOTE: Fuels read in have units of g/m2 DM

;   READ IN EMISSION FACTOR FILE
    ;emisin = 'E:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_Inputs\FINAL_EFS_08182010.csv' ; New file created 08/18/2010 (same as above, now includes PM10)
    emisin = 'E:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_Inputs\FINAL_EFS_06202014.csv' ; NEW FILE created and Added on 11/21/2014
    ; emisin = 'E:\Data2\wildfire\TEXAS\FIRE_2008\MODEL_INPUTS\NEW_EFS_06242013.csv' ; Input file created 06/24/2013 and first used here July 31, 2013
    inemis=ascii_template(emisin)
    emis=read_ascii(emisin, template=inemis)
;   Set up Emission Factor Arrays
 
; FINAL FILE 08/18/2010
;  1     2            3            4   5   6   7    8    9      10  11    12  13  14  15  16  17  18  19    20
; LCT Type  Descript  CO2 CO  CH4 NMOC  H2  NOXasNO SO2 PM25  TPM TPC OC  BC  NH3 NO  NO2 NMHC  PM10

       lctemis = emis.field01   ; LCT Type (Added 10/20/2009)
       vegemis = emis.field02   ; generic vegetation type --> this is ignored in model
       CO2EF = emis.field04     ; CO2 emission factor
       COEF = emis.field05     ; CO emission factor
       CH4EF = emis.field06     ; CH4 emission factor
       NMHCEF = emis.field19    ; NMHC emission factor
       NMOCEF = emis.field07    ; NMOC emission factor (added 10/20/2009)
       H2EF = emis.field08      ; H2 emission factor
       NOXEF = emis.field09     ; NOx emission factor
       NOEF = emis.field17      ; NO emission factors (added 10/20/2009)
       NO2EF = emis.field18     ; NO2 emission factors (added 10/20/2009)
       SO2EF = emis.field10     ; SO2 emission factor
       PM25EF = emis.field11    ; PM2.5 emission factor
       TPMEF = emis.field12     ; TPM emission factor
       TCEF = emis.field13      ; TC emission factor
       OCEF = emis.field14      ; OC emission factor
       BCEF = emis.field15      ; BC emission factor
       NH3EF = emis.field16     ; NH3 emission factor
       PM10EF = emis.field20    ; PM10 emission factor (added 08/18/2010)

print, "Finished reading in fuel and emission factor files"

; ****************************************************************************
; OUTPUT FILE
; ****************************************************************************
     outfile = 'E:\Data2\wildfire\INDONESIA\OUTPUT\JAN2015\OUTPUT_'+landcover+'_v21_atm_rev3_01072015.txt'

     openw, 6, outfile
     print, 'opened output file: ', outfile
     printf, 6, 'longi,lat,TIME,day,peat,grass,shrub,tropfor,tempfor,borfor,crop,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
     form = '(D20.10,",",D20.10,",",A10,",",(11(I10,",")),2(D20.10,","),17(D25.10,","))'
 
    ; Print an output log file
    logfile = 'E:\Data2\wildfire\INDONESIA\OUTPUT\JAN2015\LOG_OUTPUT_'+landcover+'_v21_atm_rev3_01072015.txt'
       openw, 9, logfile
       print, 'SET UP OUTPUT FILES'


; ****************************************************************************
; FIRE AND LAND COVER INPUT FILE
; ****************************************************************************

  infile = 'E:\Data2\wildfire\INDONESIA\INPUT\INPUT_01072015\input_for_finn_101814_v21_atm_rev3.csv' 
  
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)
    		print, 'Finished reading input file'

; FIELDS IN INPUT FILE
; 2013 VIIRS Fire Input (created April 28, 2014 by TOM)
;1      2    3   4     5       6          7         8        9      10    11    12    13    14    15    16    17    18    19    20    21    22    23
;DATE TIME  LAT LONG  AREA  COMBTEMP  PERCTREE  PERCHERB  PERCBARE  LCT1  LCT2  LCT3  LCT4  LCT5  LCT6  GLC1  GLC2  GLC3  GLC4  GLC5  GLC6  PEAT1 PEAT2
        date = map.field01
        time = map.field02
        lat = map.field03
        lon = map.field04
        area1 = map.field05
        temp = map.field06
        tree = map.field07*1.0
        herb = map.field08*1.0
        bare = map.field09*1.0
        peat = map.field22*1.0

; GENERIC Vegetation Classifications
;    1 grasslands and savanna = LCT2 = GLC2
;    2 woody savanna/shrublands = LCT3 = GLC3
;    3 tropical forest = LCT4 = GLC4
;    4 temperate forest = LCT5 = GLC5
;    5 boreal forest
;    6 croplands = LCT6 = GLC6
; 2013 VIIRS Fire Input (created April 28, 2014 by TOM)
;1      2    3   4     5       6          7         8        9      10    11    12    13    14    15    16    17    18    19    20    21    22    23
;                                                                   water grass shrub trop  temp  crop  water grass shrub trop  temp  crop
;DATE TIME  LAT LONG  AREA  COMBTEMP  PERCTREE  PERCHERB  PERCBARE  LCT1  LCT2  LCT3  LCT4  LCT5  LCT6  GLC1  GLC2  GLC3  GLC4  GLC5  GLC6  PEAT1 PEAT2

;USING LCT
if globcover eq 0 then begin
  grass = map.field11*1.0
  shrub = map.field12*1.0
  tropfor = map.field13*1.0
  tempfor = map.field14*1.0
;  borfor = map.field14*1.0
  crop = map.field15*1.0
endif

; USING GLC
if globcover eq 1 then begin
  grass = map.field17*1.0
  shrub = map.field18*1.0
  tropfor = map.field19*1.0
  tempfor = map.field20*1.0
;  borfor = map.field20*1.0
  crop = map.field21*1.0
endif

borfor = 0.0 ; Assume 0 for Indonesia


; Total Number of fires input in original input file
      ngoodfires = n_elements(date)
		
Print, 'The total number of fires in is: ', ngoodfires
print, 'Finished Reading Input file'

; Added 08/25/08: removed values of -9999 from VCF inputs
	misstree = where(tree lt 0)
	if misstree[0] ge 0 then tree(misstree) = 0.0
	missherb = where(herb lt 0)
	if missherb[0] ge 0 then herb(missherb) = 0.0
	missbare = where(bare lt 0)
	if missbare[0] ge 0 then bare1(missbare) = 0.0

; Calculate the total cover from the VCF product
        totcov = tree+herb+bare
        missvcf = where(totcov lt 98.)
  	    if missvcf[0] eq -1 then nummissvcf =0 else nummissvcf = n_elements(missvcf)

; ***************************************************************************************
; JULIAN DATE: Calculate the julian day for the fire detections
       numfire1 = ngoodfires
       jd = intarr(numfire1)
       
;!!!!!!!!!!! EDIT THIS SECTION FOR THE CORRECT DATE FORMAT!!!
; APRIL 30, 2014: 
; DATE in input file has format 5/24/2013
for i = 0L,numfire1-1 do begin
         parts =  strsplit(date[i],'/',/extract)
         day = fix(parts[1])
         month = fix(parts[0])
 
if yearnum ne 2008 or yearnum ne 2004 or yearnum ne 2012 then begin
         ; set julian date (NOT a leap year)
         if month eq 1 then daystart = 0
         if month eq 2 then daystart = 31
         if month eq 3 then daystart = (28+31)
         if month eq 4 then daystart = 90
         if month eq 5 then daystart = 120
         if month eq 6 then daystart = 151
         if month eq 7 then daystart = 181
         if month eq 8 then daystart = 212
         if month eq 9 then daystart = 243
         if month eq 10 then daystart = 273
         if month eq 11 then daystart = 304
         if month eq 12 then daystart = 334
         ntotdays = 365
endif
if yearnum eq 2008 or yearnum eq 2004 or yearnum eq 2012 then begin
        ; set julian date (leap year)
         if month eq 1 then daystart = 0
         if month eq 2 then daystart = 31
         if month eq 3 then daystart = 60
         if month eq 4 then daystart = 91
         if month eq 5 then daystart = 121
         if month eq 6 then daystart = 152
         if month eq 7 then daystart = 182
         if month eq 8 then daystart = 213
         if month eq 9 then daystart = 244
         if month eq 10 then daystart = 274
         if month eq 11 then daystart = 305
         if month eq 12 then daystart = 335
         ntotdays = 366
endif
          jd[i] = day+daystart
endfor
print, 'Finished calculating Julian Dates'
   
; *******************************************************************************
; Set up Counters
;   These are identifying how many fires are in urban areas,
;   or have unidentified VCF or LCT values -->
;   purely for statistics and quality assurance purposes
        lct0 = 0L
        spixct = 0L
        antarc = 0L
        allbare = 0L
        genveg0 = 0L
        bmass0 = 0L
        vcfcount = 0L
        vcflt50 = 0L
        confnum = 0L ; added 08/25/08
        overlapct = 0L ; added 02/29/2009
        urbnum = 0L ; added 10/20/2009

; Set totals to 0.0
     CO2total = 0.0
     COtotal = 0.0
     CH4total = 0.0
     NMHCtotal = 0.0
     NMOCtotal = 0.0
      H2total = 0.0
      NOXtotal = 0.0
      NOtotal = 0.0
      NO2total = 0.0
      SO2total = 0.0
      PM25total = 0.0
      TPMtotal = 0.0
      TPCtotal = 0.0
      OCtotal = 0.0
      BCtotal = 0.0
      NH3total = 0.0
      PM10total = 0.0
      AREAtotal = 0.0 ; added 06/21/2011
      BMASStotal= 0.0 ; Addded 06/21/2011

      
; ****************************************************************************
; START LOOP OVER ALL FIRES: CALCULATE EMISSIONS
; ****************************************************************************
print, 'Starting to Calculate Emissions'

; Start loop over all fires in input file
for j =0L,ngoodfires-1 do begin ; edited this to have ngoodfires instead of nfires on 02.23.2009
;
; ##################################################
;   QA PROCEDURES FIRST
; ##################################################
;
; 3) Correct for VCF product issues
;   3a) First, correct for GIS processing errors:
;    Scale VCF product to sum to 100.
        if totcov[j] gt 101. and totcov[j] lt 240. then begin
           vcfcount = vcfcount+1
           tree[j] = tree[j]*100./totcov[j]
           herb[j] = herb[j]*100./totcov[j]
           bare[j] = bare[j]*100./totcov[j]
           totcov[j] = bare[j] +herb[j] + tree[j]
        endif
        if totcov[j] lt 99. and totcov[j] ge 50. then begin
           vcfcount = vcfcount+1
           tree[j] = tree[j]*100./totcov[j]
           herb[j] = herb[j]*100./totcov[j]
           bare[j] = bare[j]*100./totcov[j]
           totcov[j] = bare[j] +herb[j] + tree[j]
        endif
       ;Second, If no data are assigned to the grid, then scale up, still
        if (totcov[j] lt 50. and totcov[j] ge 1.) then begin
            vcflt50  = vcflt50+1
            tree[j] = tree[j]*100./totcov[j]
            herb[j] = herb[j]*100./totcov[j]
            bare[j] = bare[j]*100./totcov[j]
            totcov[j] = bare[j] +herb[j] + tree[j]
        endif
;   3b) Fires with 100% bare cover or VCF not identified or total cover is 0,-9999:
;    reassign cover values based on LCT or GLC assignment
        if totcov[j] ge 240. or totcov[j] lt 1. or bare[j] eq 100 then begin ; this also include where VCF see water (values = 253)
          allbare = allbare+1
          totcov2 = grass[j]+shrub[j]+tropfor[j]+tempfor[j]+crop[j]
          forfrac = (tempfor[j]+tropfor[j])/totcov2
          shrubfrac = shrub[j]/totcov2
          grassfrac = (grass[j]+crop[j])/totcov2
          if forfrac gt shrubfrac and forfrac gt grassfrac then begin    ; Assign forest to the pixel
            tree[j] = 60.
            herb[j] = 40.
            bare[j] = 0.
          endif
         if shrubfrac gt forfrac and shrubfrac gt grassfrac  then begin    ; Assign woody savanna to the pixel
            tree[j] = 50.
            herb[j] = 50.
            bare[j] = 0.
         endif
         if grassfrac gt forfrac and grassfrac gt shrubfrac then begin  ; Assign grassland to the pixel
            tree[j] = 20.
            herb[j] = 80.
            bare[j] = 0.
         endif
       endif

; ####################################################
; Assign Burning Efficiencies based on Generic
;   land cover (Hoezelmann et al. [2004] Table 5
; ####################################################
; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and svanna
;    2 = woody savanna
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    6 = croplands -- NOTE: In files I created on OCt. 2014 --- GENVEG  6 = CROPLANDS!!!!
;    0 = no vegetation (should have been removed by now- but just in case...)

; ####################################################
; Assign Area from input file (m2)
; ####################################################
  area = area1[j]

; ####################################################
; Assign Fuel Loads based on Generic land cover
;   and global region location
;   units are in g dry mass/m2
; ####################################################
; Setting Region To 10 (although since the biomass loadings are set below in the code, this doesn't matter too much). 
    reg = 10   ; locate global region, get index
    if reg[0] eq -1 then begin
       printf, 9, 'Fire number:',j,' removed. Something is WRONG with global regions and fuel loads. Globreg =', globreg[j]
       goto, skipfire
    endif

  
; *****************************************************************************************
; April 08, 2009: Copied code from Regional model to better simulate the combustion efficiency
; 	and overall biomass burned.

; ASSIGN CF VALUES (Combustion Factors)
    if (tree[j] gt 60) then begin      ;FOREST
    ; Values from Table 3 Ito and Penner [2004]
        CF1 = 0.30          ; Live Woody
        CF3 = 0.90          ; Leafy Biomass
        CF4 = 0.90          ; Herbaceous Biomass
        CF5 = 0.90          ; Litter Biomass
        CF6 = 0.30          ; Dead woody
    endif
    if (tree[j] gt 40) and (tree[j] le 60) then begin   ;WOODLAND
;       CF3 = exp(-0.013*(tree[j]/100.))     ; Apply to all herbaceous fuels
       CF3 = exp(-0.013*(tree[j]))     ; CORRECTED, 11/26/2014
       CF1 = 0.30                   ; Apply to all coarse fuels in woodlands
                                    ; From Ito and Penner [2004]
    endif
    If (tree[j] le 40) then begin       ;GRASSLAND
       CF3 = 0.98 ;Range is between 0.44 and 0.98 - Assumed UPPER LIMIT!
    endif

;*******************************************************************************
; Set up BMASS INPUTS (converted from g/m2 to kg/m2)
; MAY 01, 2014: FOR SOUTHERN ASIA ONLY

  bmassgr = 1445./1000. ; Grassland
  bmasssh = 5028./1000. ; shrublands
  bmasstro = 27969./1000. ; tropical forest
  bmasstem = 14629./1000. ; temperate forest
  bmassbor = 0.0 /1000.; boreal forest ... none expected in Indonesia
  bmasscro = 500./1000. ; croplands
;*******************************************************************************
; *******************************************************************************************
; Calculate the Mass burned of each classification (herbaceous, woody, and forest)
; These are in units of kg dry matter/m2
; Bmass is the total burned biomass
; Mherb is the Herbaceous biomass burned
; Mtree is the Woody biomass burned

    pctherb = herb[j]/100.
    pcttree = tree[j]/100.
    herbbm = bmassgr ; Biomass of grassland
 
;  Grasslands/croplands
if tree[j] le 40 then begin
    Bmass1 = (grass[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3))
    Bmass2 = (shrub[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3)) ; SHRUB
    Bmass3 = (tropfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3))  ; TROP FOR
    Bmass4 = (tempfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3))  ; TEMP FOR
;    Bmass5 = (borfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3)); BOR FOR
    Bmass6 = (crop[j]/100.)*((pctherb*bmasscro*CF3)+(pcttree*bmasscro*CF3))  ; CROP
Endif
; Woodlands
if (tree[j] gt 40) and (tree[j] le 60) then begin
    Bmass1 = (grass[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3))  ; GRASSLAND
    Bmass2 = (shrub[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasssh*CF1))) ;SHRUB
    Bmass3 = (tropfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasstro*CF1)))  ; TROP FOR
    Bmass4 = (tempfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasstem*CF1)))  ; TEMP FOR
;    Bmass5 = (borfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmassbor*CF1))); BOR FOR
    Bmass6 = (crop[j]/100.)*((pctherb*bmasscro*CF3)+(pcttree*bmasscro*CF3))  ; CROP
endif
; Forests
if tree[j] gt 60 then begin
    Bmass1 = (grass[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*herbbm*CF3))  ; GRASSLAND
    Bmass2 = (shrub[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasssh*CF1))) ; SHRUB
    Bmass3 = (tropfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasstro*CF1)))  ; TROP FOR
    Bmass4 = (tempfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmasstem*CF1)))  ; TEMP FOR
;    Bmass5 = (borfor[j]/100.)*((pctherb*herbbm*CF3)+(pcttree*(herbbm*CF3+bmassbor*CF1))); BOR FOR
    Bmass6 = (crop[j]/100.)*((pctherb*bmasscro*CF3)+(pcttree*bmasscro*CF3))  ; CROP
endif

; ####################################################
; Assign Emission Factors based on Generic land cover
; ####################################################
    ; assign index for emission factors - Edited 05/02/2014
;    index = 8 ; grasslands & savannas
;    index = 6 ; shrublands
;    index = 1 ; tropical forests
;    index = 3 ; extratropical forests
;    index = 11 ; Crops
;    index = 2 ; Boreal Forests, added 10/19/2009
; ####################################################
; Calculate Emissions
; ####################################################


; CALCULATE EMISSIONS kg/day
       CO2 = area/1000.*(CO2EF[8]*bmass1+CO2EF[6]*bmass2+CO2EF[1]*bmass3+CO2EF[3]*bmass4+CO2EF[11]*bmass6)
       CO = area/1000.*(COEF[8]*bmass1+COEF[6]*bmass2+COEF[1]*bmass3+COEF[3]*bmass4+COEF[11]*bmass6)
       CH4 = area/1000.*(CH4EF[8]*bmass1+CH4EF[6]*bmass2+CH4EF[1]*bmass3+CH4EF[3]*bmass4+CH4EF[2]*0.0+CH4EF[11]*bmass6)
       NMOC = area/1000.*(NMOCEF[8]*bmass1+NMOCEF[6]*bmass2+NMOCEF[1]*bmass3+NMOCEF[3]*bmass4+NMOCEF[2]*0.0+NMOCEF[11]*bmass6)
       NMHC = area/1000.*(NMHCEF[8]*bmass1+NMHCEF[6]*bmass2+NMHCEF[1]*bmass3+NMHCEF[3]*bmass4+NMHCEF[2]*0.0+NMHCEF[11]*bmass6)
       H2 = area/1000.*(H2EF[8]*bmass1+H2EF[6]*bmass2+H2EF[1]*bmass3+H2EF[3]*bmass4+H2EF[2]*0.0+H2EF[11]*bmass6)
       
       NOX = area/1000.*(NOxEF[8]*bmass1+NOxEF[6]*bmass2+NOxEF[1]*bmass3+NOxEF[3]*bmass4+NOxEF[2]*0.0+NOxEF[11]*bmass6)
       NO = area/1000.*(NOEF[8]*bmass1+NOEF[6]*bmass2+NOEF[1]*bmass3+NOEF[3]*bmass4+NOEF[2]*0.0+NOEF[11]*bmass6)
       NO2 = area/1000.*(NO2EF[8]*bmass1+NO2EF[6]*bmass2+NO2EF[1]*bmass3+NO2EF[3]*bmass4+NO2EF[2]*0.0+NO2EF[11]*bmass6)
       SO2 = area/1000.*(SO2EF[8]*bmass1+SO2EF[6]*bmass2+SO2EF[1]*bmass3+SO2EF[3]*bmass4+SO2EF[2]*0.0+SO2EF[11]*bmass6)
       PM25 = area/1000.*(PM25EF[8]*bmass1+PM25EF[6]*bmass2+PM25EF[1]*bmass3+PM25EF[3]*bmass4+PM25EF[2]*0.0+PM25EF[11]*bmass6)
       TPM = area/1000.*(TPMEF[8]*bmass1+TPMEF[6]*bmass2+TPMEF[1]*bmass3+TPMEF[3]*bmass4+TPMEF[2]*0.0+TPMEF[11]*bmass6)
       TPC = area/1000.*(TCEF[8]*bmass1+TCEF[6]*bmass2+TCEF[1]*bmass3+TCEF[3]*bmass4+TCEF[2]*0.0+TCEF[11]*bmass6)
       OC = area/1000.*(OCEF[8]*bmass1+OCEF[6]*bmass2+OCEF[1]*bmass3+OCEF[3]*bmass4+OCEF[2]*0.0+OCEF[11]*bmass6)
       BC = area/1000.*(BCEF[8]*bmass1+BCEF[6]*bmass2+BCEF[1]*bmass3+BCEF[3]*bmass4+BCEF[2]*0.0+BCEF[11]*bmass6)
       NH3 = area/1000.*(NH3EF[8]*bmass1+NH3EF[6]*bmass2+NH3EF[1]*bmass3+NH3EF[3]*bmass4+NH3EF[2]*0.0+NH3EF[11]*bmass6)
       PM10 = area/1000.*(PM10EF[8]*bmass1+PM10EF[6]*bmass2+PM10EF[1]*bmass3+PM10EF[3]*bmass4+PM10EF[2]*0.0+PM10EF[11]*bmass6)

bmassburn = area*(bmass1+bmass2+bmass3+bmass4+0.0+bmass6) ; kg burned
BMASStotal = bmassburn+BMASStotal ; kg

;if genveg eq 3 then begin
;    TOTTROP = TOTTROP+bmass3
;    TOTTROParea = TOTTROPAREA+area
;endif
;if genveg eq 4 then begin
;    TOTTEMP = TOTTEMP+bmass4
;    TOTTEMParea = TOTTEMParea+area
;endif
;if genveg eq 5 then begin
;  TOTBOR = TOTBOR+0.0
;  TOTBORarea = TOTBORarea+area
;endif
;if genveg eq 2 then begin
;  TOTSHRUB = TOTSHRUB+bmass2
;  TOTSHRUBarea = TOTSHRUBarea+area
;endif
;if genveg eq 9 then begin
;  TOTCROP = TOTCROP+bmass6
;  TOTCROParea = TOTCROParea+area
;  TOTCROPCO = TOTCROPCO + CO
;  TOTCROPPM25 = TOTCROPPM25 + PM25
;  
;endif
;if genveg eq 1 then begin
;  TOTGRAS = TOTGRAS+bmass1
;  TOTGRASarea = TOTGRASarea+area
;endif


 ; units being output are in kg/day/fire
; ####################################################
; Print to Output file
; ####################################################

;printf, 6, '           longi, lat,   TIME,   day,  peat,   genLC1, genLC2, genLC3, genLC4, genLC5, genLC6, pcttree,pctherb,pctbare,
if CO2 eq 0.0 then goto, skipfire

printf,6,format = form, lon[j],lat[j],time[j],jd[j],peat[j],grass[j],shrub[j],tropfor[j],tempfor[j],0.0,crop[j],tree[j],herb[j],bare[j], $
      ;area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
       area,bmassburn,CO2,CO,CH4,H2,NOX,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10


; Calculate Global Sums
     CO2total = CO2+CO2total
     COtotal = CO+COtotal
     CH4total = CH4+CH4total
     NMHCtotal = NMHC+NMHCtotal
     NMOCtotal = NMOC+NMOCtotal
     H2total = H2total+H2
     NOXtotal = NOXtotal+NOx
     NOtotal = NO+NOtotal
     NO2total = NO2total+NO2
     SO2total = SO2total+SO2
     PM25total = PM25total+PM25
     TPMtotal = TPMtotal+TPM
     TPCtotal = TPC+TPCtotal
     OCtotal = OCtotal+OC
     BCtotal = BCtotal+BC
     NH3total = NH3total+NH3
     PM10total = PM10total+PM10
    AREAtotal = AREAtotal+area ; m2         
       
; ####################################################
; End loop over Fires
; ####################################################

skipfire:
endfor ; End loop over fires

    t1 = systime(1)-t0
; PRINT SUMMARY TO LOG FILE
printf, 9, ' '
printf, 9, 'The time to do this run was: '+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
printf, 9, ' This run was done on: ', SYSTIME()
printf, 9, ' '
printf, 9, 'The Input file was: ', infile
printf, 9, 'The emissions file was: ', emisin
printf, 9, 'The fuel load file was: ', fuelin
printf, 9, ' '
;printf, 9, 'The total number of fires input was:', numorig
;printf, 9, 'the total number of fires removed with confience < 20:', numorig-nconfgt20
printf, 9, ''
;printf, 9, 'the total number of fires in the tropics was: ', numadd
printf, 9, 'The number of fires processed (ngoodfires):', ngoodfires
printf, 9, ''
;printf, 9, 'The number of urban fires: ', urbnum
;printf, 9, 'The number of fires removed for overlap:', overlapct
;printf, 9, ' The number of fires skipped due to lct<= 0 or lct > 17:', lct0
;printf, 9, ' The number of fires skipped due to Global Region = Antarctica:', antarc
printf, 9, ' The number of fires skipped due to 100% bare cover:', allbare
printf, 9, ' The number of fires skipped due to problems with genveg:', genveg0
printf, 9, ' The number of fires skipped due to bmass assignments:', bmass0
printf, 9, ' The number of fires scaled to 100:', vcfcount
printf, 9, ' The number of fires with vcf < 50:', vcflt50
printf, 9, 'Total number of fires skipped:', spixct+lct0+antarc+allbare+genveg0+bmass0+confnum
printf, 9, ''
; Added this section 08/24/2010
printf, 9, 'Global Totals (Tg) of biomass burned per vegetation type'
printf, 9, 'GLOBAL TOTAL (Tg) biomass burned (Tg),', BMASStotal/1.e9
printf, 9, 'Total Temperate Forests (Tg),', TOTTEMP/1.e9
printf, 9, 'Total Tropical Forests (Tg),', TOTTROP/1.e9
printf, 9, 'Total Boreal Forests (Tg),', TOTBOR/1.e9
printf, 9, 'Total Shrublands/Woody Savannah(Tg),', TOTSHRUB/1.e9
printf, 9, 'Total Grasslands/Savannas (Tg),', TOTGRAS/1.e9
printf, 9, 'Total Croplands (Tg),', TOTCROP/1.e9
printf, 9, ''
printf, 9, 'Global Totals (km2) of area per vegetation type'
printf, 9, 'TOTAL AREA BURNED (km2),', AREATOTAL
printf, 9, 'Total Temperate Forests (km2),', TOTTEMParea
printf, 9, 'Total Tropical Forests (km2),', TOTTROParea
printf, 9, 'Total Boreal Forests (km2),', TOTBORarea
printf, 9, 'Total Shrublands/Woody Savannah(km2),', TOTSHRUBarea
printf, 9, 'Total Grasslands/Savannas (km2),', TOTGRASarea
printf, 9, 'Total Croplands (km2),', TOTCROParea
printf, 9, ''
printf, 9, 'TOTAL CROPLANDS CO (kg),', TOTCROPCO
printf, 9, 'TOTAL CROPLANDS PM2.5 (kg),', TOTCROPPM25
printf, 9, ''
printf, 9, 'GLOBAL TOTALS (Tg)'
printf, 9, 'CO2 = ', CO2total/1.e9
printf, 9, 'CO = ', COtotal/1.e9
printf, 9, 'CH4 = ', CH4total/1.e9
printf, 9, 'NMHC = ', NMHCtotal/1.e9
printf, 9, 'NMOC = ', NMOCtotal/1.e9
printf, 9, 'H2 = ', H2total/1.e9
printf, 9, 'NOx = ', NOXtotal/1.e9
printf, 9, 'NO = ', NOtotal/1.e9
printf, 9, 'NO2 = ', NO2total/1.e9
printf, 9, 'SO2 = ', SO2total/1.e9
printf, 9, 'PM2.5 = ', PM25total/1.e9
printf, 9, 'TPM = ', TPMtotal/1.e9
printf, 9, 'TPC = ', TPCtotal/1.e9
printf, 9, 'OC = ', OCtotal/1.e9
printf, 9, 'BC = ', BCtotal/1.e9
printf, 9, 'NH3 = ', NH3total/1.e9
printf, 9, 'PM10 = ', PM10total/1.e9
printf, 9, ''

; ***************************************************************
;           END PROGRAM
; ***************************************************************
    t1 = systime(1)-t0
    print,'Fire_emis> End Procedure in   '+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
    junk = check_math() ;This clears the math errors
    print, ' This run was done on: ', SYSTIME()
    close,/all   ;make sure ALL files are closed
end