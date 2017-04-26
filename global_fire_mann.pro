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
; 
; MAY 05, 2014
; - ran to only output Indonesian region
; 
; MAY 21, 2014
; - Edited code to read in files for CA and to run emission estimates for Mike Mann
;   * reading in area and point ID
;   * can use GLC or LCT
;   * no dates
;   
; *********************************************************************************************

pro global_fire_MANN


close, /all

 t0 = systime(1) ;Procedure start time in seconds

 yearnum= 2013
 FAC = 0.5 ; Factor to apply to duplicate tropical fires 
 Globcover = 0 ; chose 1 for yes, 0 for no
 
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
;    fuelin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\fuelloads.csv'
;    fuelin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\fuelloads_new10192009.csv'; Updated 10/19/2009
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
 ;   emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\emisfactor.csv'
 ;   emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\EFS_10202009.csv' ; New file created 10/20/2009
 ;   emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\Updated_EFs_01182010.csv' ; New file created 01/18/2010
 ;  emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\FINAL_EFS_02132010.csv' ; New file created 02/13/2010
 ;   emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\FINAL_EFS_06182010.csv' ; New file created 06/18/2010  (same as above except for NOx in boreal forest        
   emisin = 'E:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_Inputs\FINAL_EFS_08182010.csv' ; New file created 08/18/2010 (same as above, now includes PM10)
 
 ;   emisin = 'E:\Data2\wildfire\TEXAS\FIRE_2008\MODEL_INPUTS\NEW_EFS_06242013.csv' ; Input file created 06/24/2013 and first used here July 31, 2013
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

           outfile = 'E:\Data2\wildfire\MIKE_MANN\Christine Fire Outputs\FIRE_EMISS_OUTPUTS\CA_EMIS_1976_2001B_05212014.txt'

     openw, 6, outfile
     print, 'opened output file: ', outfile
     printf, 6, 'lat,lon,FID_fireco,POINTID,lct,genLC,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
     form = '(F25.7,",",F25.7,",",4(I10,","),22(D25.10,","))'
 
    ; Print an output log file
    logfile = 'E:\Data2\wildfire\MIKE_MANN\Christine Fire Outputs\FIRE_EMISS_OUTPUTS\LOG_CA_EMIS_1976_2001B_05212014.txt'
       openw, 9, logfile
       print, 'SET UP OUTPUT FILES'
;***************************************************************************************

; ****************************************************************************
; FIRE AND LAND COVER INPUT FILE
;   (this file should be created within ArcGIS)
; ****************************************************************************
    ; path for input file
;     inpath='D:\Data2\wildfire\AMAZE\MODIS_RR\global_april_aug2008\global_model\'
    ; input fire file
    ; 

  infile = 'E:\Data2\wildfire\MIKE_MANN\Christine Fire Outputs\INPUT_FILE\INPUTS\firecount_1976_2000_INPUT.csv' 
  

; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)
    		print, 'Finished reading input file'

; FIELDS IN INPUT FILE
; 1          2        3        4    5   6    7   8     9          10    11
; FID_fc76_0,POINTID,GRID_CODE,LCT,GLC,TREE,HERB,BARE,Region_num, long, lat

        fid = map.field01
        pointid = map.field02
        area1 = map.field03
        tree = map.field06*1.0
        herb = map.field07*1.0
        bare = map.field08*1.0
        lct = map.field04 
        globreg = map.field09
        lat = map.field11
        lon = map.field10
       
; IF READING IN GLC, remap to the LCT classes (MAY 21, 2014)
count1 = n_elements(lat)
if globcover eq 1 then begin
      lct = map.field05
  for i = 0L,count1-1 do begin
      if lct[i] eq 1 then lct[i] = 13
      if lct[i] eq 2 then lct[i] = 12
      if lct[i] eq 3 or lct[i] eq 6 then lct[i] = 10
      if lct[i] eq 4 then lct[i] = 5
      if lct[i] eq 5 then lct[i] = 6
      if lct[i] eq 7 then lct[i] = 4
      if lct[i] eq 8 then lct[i] = 9
      if lct[i] eq 9 then lct[i] = 16
      if lct[i] eq 10 then lct[i] = 15
      if lct[i] eq 11 then lct[i] = 0            
   endfor              
endif

  print, 'Finished Reading Input file'
; Added 08/25/08: removed values of -9999 from VCF inputs
	misstree = where(tree lt 0)
	if misstree[0] ge 0 then tree(misstree) = 0.0
	missherb = where(herb lt 0)
	if missherb[0] ge 0 then herb(missherb) = 0.0
	missbare = where(bare lt 0)
	if missbare[0] ge 0 then bare(missbare) = 0.0

; Calculate the total cover from the VCF product
        totcov = tree+herb+bare
        missvcf = where(totcov lt 98.)
  	    if missvcf[0] eq -1 then nummissvcf =0 else nummissvcf = n_elements(missvcf)

; ***************************************************************************************
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

; ****************************************************************************************
; ADDED JAY's code on 02.23.2009
; *********************************************************************

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
for j =0L,nfires-1 do begin ; edited this to have ngoodfires instead of nfires on 02.23.2009


; ##################################################
;   QA PROCEDURES FIRST
; ##################################################

; 1a) Skip any fires in Antarctica
       if globreg[j] eq 0 then begin
       ;  printf, 9, 'Fire number:',j,' removed. Globveg = 0 (antarctica/coastline)'
          antarc = antarc+1
          goto, skipfire
        endif
; 2) Remove fires with no LCT assignment or in water bodies or snow/ice assigned by LCT
    if lct[j] ge 17 or lct[j] le 0 or lct[j] eq 15 then begin ; Added Snow/Ice on 10/20/2009
      ; printf, 9, 'Fire number:',j,' removed. LCT = ', lct[j]
       lct0 = lct0 + 1
       goto, skipfire
    endif
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
;    reassign cover values based on LCT assignment
       if totcov[j] ge 240. or totcov[j] lt 1. or bare[j] eq 100 then begin ; this also include where VCF see water (values = 253)
          allbare = allbare+1
         if lct[j] ge 15 then begin
         ; printf, 9, 'Fire number:',j,' removed. either 100% bare of VCF = 253 and LCT = ', lct[j]
          goto, skipfire ; Skip fires that are all bare and have no LCT vegetation
         endif
         if lct[j] le 5 then begin    ; Assign forest to the pixel
          tree[j] = 60.
          herb[j] = 40.
          bare[j] = 0.
         endif
         if lct[j] ge 6 and lct[j] le 8 or lct[j] eq 11 or lct[j] eq 14 then begin    ; Assign woody savanna to the pixel
          tree[j] = 50.
          herb[j] = 50.
          bare[j] = 0.
         endif
         if lct[j] eq 9 or lct[j] eq 10 or lct[j] eq 12 or lct[j] eq 13 or lct[j] eq 16 then begin  ; Assign grassland to the pixel
          tree[j] = 20.
          herb[j] = 80.
          bare[j] = 0.
         endif
       endif

; ######################################################
; Assign Generic land cover to fire based on
;   global location and lct information
; ######################################################

; Generic land cover codes () are as follows:
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
;    
; 10/20/2009: Changed the generic vegetation assignments according to new EF table. 


; 1) Grasslands and Savanna
    if lct[j] eq 9 or lct[j] eq 10 or lct[j] eq 11 or lct[j] eq 14 or lct[j] eq 16 then begin
        genveg = 1
        goto, endveg
    endif
; 2) Woody Savanna
    if lct[j] ge 6 and lct[j] le 8 then begin
        genveg = 2
        goto, endveg
    endif
; 3) Croplands
    if lct[j] eq 12 then begin
        genveg = 9
        goto, endveg
    endif
; 4) Urban
    if lct[j] eq 13 then begin ; then assign genveg based on VCF cover in the pixel and reset the lct value (for emission factors)
        urbnum = urbnum+1
        if tree[j] lt 40 then begin
            genveg = 1        ; grasslands
            lct[j] = 10       ; set to grassland
         goto, endveg
       endif
        if tree[j] ge 40 and tree[j] lt 60 then begin
            genveg = 2  ; woody savannas
            lct[j] = 8 ; set to woody savanna
            goto, endveg
        endif
        if tree[j] ge 60 then begin                  ; assign forest based on latitude
            genveg = 4
            lct[j] = 5 ; set to mixed forest
            goto, endveg
        endif
    endif
; 5) Forests (based on latitude)
    if lct[j] eq 2 then genveg = 3 ; Tropical Forest
    if lct[j] eq 4 then genveg = 4 ; Temperate Forest
    if lct[j] eq 1 or lct[j] eq 3 or lct[j] eq 5 then genveg = 4   ; Needleleaf forests

endveg:

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
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)

; ####################################################
; Estimate Area burned (km2) using the VCF product
; ####################################################
        area= area1[j]
        
; ####################################################
; Assign Fuel Loads based on Generic land cover
;   and global region location
;   units are in g dry mass/m2
; ####################################################

    reg = globreg[j]-1   ; locate global region, get index
    if reg[0] eq -1 then begin
       printf, 9, 'Fire number:',j,' removed. Something is WRONG with global regions and fuel loads. Globreg =', globreg[j]
       goto, skipfire
    endif

; April 08, 2009: Edited this to say "Bmass1" not "Bmass"
; 	Bmass now gets calculated as a function of tree cover, too.
    if genveg eq 9 then bmass1 = 500.
    if genveg eq 1 then bmass1 = grfuel[reg]
    if genveg eq 2 then bmass1 = wsfuel[reg]
    if genveg eq 3 then bmass1 = tffuel[reg]
    if genveg eq 4 then bmass1 = tefuel[reg]
    if genveg eq 5 then bmass1 = bffuel[reg]
    if genveg eq 0 then begin
       printf, 9, 'Fire number:',j,' removed. Something is WRONG with generic vegetation. genveg = 0'
       genveg0 = genveg0 + 1
       goto, skipfire
    endif
    
   if bmass1 eq -1 then begin
        printf, 9, 'Fire number:',j,' removed. bmass assigned -1! 
        printf, 9, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        print, 'Fire number:',j,' removed. bmass assigned -1!
        print, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        bmass0 = bmass0+1
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
       CF3 = exp(-0.013*(tree[j]/100.))     ; Apply to all herbaceous fuels
       CF1 = 0.30                   ; Apply to all coarse fuels in woodlands
                                    ; From Ito and Penner [2004]
    endif
    If (tree[j] le 40) then begin       ;GRASSLAND
       CF3 = 0.98 ;Range is between 0.44 and 0.98 - Assumed UPPER LIMIT!
    endif
; *******************************************************************************************
; Calculate the Mass burned of each classification (herbaceous, woody, and forest)
; These are in units of kg dry matter/m2
; Bmass is the total burned biomass
; Mherb is the Herbaceous biomass burned
; Mtree is the Woody biomass burned

    pctherb = herb[j]/100.
    pcttree = tree[j]/100.
    if genveg eq 9 then herbbm = bmass1 else herbbm = grfuel[reg]
    coarsebm = bmass1
; NOT INCLUDING STUMP WOOD RIGHT NOW
; Bmass = biomass burned in fire

;  Grasslands
if tree[j] le 40 then begin
    Bmass = (pctherb*herbbm*CF3)+(pcttree*herbbm*CF3)
    ; Assumed here that litter biomass = herbaceous biomass and that the percent tree
    ;   in a grassland cell contributes to fire fuels... CHECK THIS!!!
    ; Assuming here that the duff and litter around trees burn
endif
; Woodlands
if (tree[j] gt 40) and (tree[j] le 60) then begin
       Bmass = (pctherb*herbbm*CF3) + (pcttree*(herbbm*CF3+coarsebm*CF1))
endif
; Forests
if tree[j] gt 60 then begin
       Bmass = (pctherb*herbbm*CF3) + (pcttree*(herbbm*CF3+coarsebm*CF1))
endif

; ####################################################
; Assign Emission Factors based on Generic land cover
; ####################################################
    ; assign index for emission factors
;    if genveg eq 1 or genveg eq 2 then index = 0 ; grasslands & savannas
;    if genveg eq 3 then index = 1 ; tropical forests
;    if genveg eq 4 then index = 2 ; extratropical forests
;    if genveg eq 9 then index = 3 ; Crops
;    if genveg eq 5 then index = 4 ; Boreal Forests, added 10/19/2009

; OCTOBER 20, 2009
; Reassigned emission factors based on LCT, not genveg for new emission factor table
    if lct[j] eq 1 then index = 0
    if lct[j] eq 2 then index = 1 
    if lct[j] eq 3 then index = 2
    if lct[j] eq 4 then index = 3
    if lct[j] eq 5 then index = 4
    if lct[j] eq 6 then index = 5
    if lct[j] eq 7 then index = 6
    if lct[j] eq 8 then index = 7
    if lct[j] eq 9 then index = 8
    if lct[j] eq 10 then index = 9
    if lct[j] eq 11 then index = 10
    if lct[j] eq 12 then index = 11
    if lct[j] eq 14 then index = 12
    if lct[j] eq 16 then index = 13

; ####################################################
; Calculate Emissions
; ####################################################
; Emissions = area*BE*BMASS*EF
    ; Convert units to consistent units
     area = area*1.0e6 ; convert km2 --> m2
     bmass = bmass/1000. ; convert g dm/m2 to kg dm/m2

    ; Calculate emissions (kg)
; #######READ THIS ###########
; CALCULATE EMISSIONS kg/day
; NOV. 25, 2009: Added the multiplication of the factor for the tropics. Assigned ealier in the code, 
;     where the tropics are doubled. 
       CO2 = CO2EF[index]*area*bmass/1000.
       CO = COEF[index]*area*bmass/1000.
       CH4 = CH4EF[index]*area*bmass/1000.
       NMHC = NMHCEF[index]*area*bmass/1000.
       NMOC = NMOCEF[index]*area*bmass/1000.
       H2 = H2EF[index]*area*bmass/1000.
       NOX = NOXEF[index]*area*bmass/1000.
       NO = NOEF[index]*area*bmass/1000.
       NO2 = NO2EF[index]*area*bmass/1000.
       SO2 = SO2EF[index]*area*bmass/1000.
       PM25 = PM25EF[index]*area*bmass/1000.
       TPM = TPMEF[index]*area*bmass/1000.
       TPC = TCEF[index]*area*bmass/1000.
       OC = OCEF[index]*area*bmass/1000.
       BC = BCEF[index]*area*bmass/1000.
       NH3 = NH3EF[index]*area*bmass/1000.
       PM10 = PM10EF[index]*area*bmass/1000.

bmassburn = bmass*area ; kg burned
BMASStotal = bmassburn+BMASStotal ; kg

if genveg eq 3 then begin
    TOTTROP = TOTTROP+bmassburn
    TOTTROParea = TOTTROPAREA+area
endif
if genveg eq 4 then begin
    TOTTEMP = TOTTEMP+bmassburn
    TOTTEMParea = TOTTEMParea+area
endif
if genveg eq 5 then begin
  TOTBOR = TOTBOR+bmassburn
  TOTBORarea = TOTBORarea+area
endif
if genveg eq 2 then begin
  TOTSHRUB = TOTSHRUB+bmassburn
  TOTSHRUBarea = TOTSHRUBarea+area
endif
if genveg eq 9 then begin
  TOTCROP = TOTCROP+bmassburn
  TOTCROParea = TOTCROParea+area
  TOTCROPCO = TOTCROPCO + CO
  TOTCROPPM25 = TOTCROPPM25 + PM25
  
endif
if genveg eq 1 then begin
  TOTGRAS = TOTGRAS+bmassburn
  TOTGRASarea = TOTGRASarea+area
endif


 ; units being output are in kg/day/fire
; ####################################################
; Print to Output file
; ####################################################
; 'FID_fireco,POINTID,lct,genLC,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
;   printf, 6, 'lat,lon,FID_fireco,POINTID,lct,genLC,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
;     form = '(D25.10,",",D25.10,",",4(I10,","),22(D25.10,","))'
;                       lat,   lon,   FID_fireco,POINTID,lct,  genLC, pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10'
printf,6,format = form, lat[j],lon[j],fid[j],pointid[j],lct[j],genveg,tree[j],herb[j], $
       bare[j],area,bmass,CO2,CO,CH4,H2,NOX,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10
;print, format = form, lat[j],lon[j],fid[j],pointid[j],lct[j],genveg,globreg[j],tree[j],herb[j], $
;       bare[j],area,bmass,CO2,CO,CH4,H2,NOX,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10


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
printf, 9, 'The total number of fires input was:', nfires
printf, 9, ''
printf, 9, 'The number of urban fires: ', urbnum
printf, 9, 'The number of fires removed for overlap:', overlapct
printf, 9, ' The number of fires skipped due to lct<= 0 or lct > 17:', lct0
printf, 9, ' The number of fires skipped due to Global Region = Antarctica:', antarc
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
printf, 9, 'Global Totals (m2) of area per vegetation type'
printf, 9, 'TOTAL AREA BURNED (m2),', AREATOTAL
printf, 9, 'Total Temperate Forests (m2),', TOTTEMParea
printf, 9, 'Total Tropical Forests (m2),', TOTTROParea
printf, 9, 'Total Boreal Forests (m2),', TOTBORarea
printf, 9, 'Total Shrublands/Woody Savannah(m2),', TOTSHRUBarea
printf, 9, 'Total Grasslands/Savannas (m2),', TOTGRASarea
printf, 9, 'Total Croplands (m2),', TOTCROParea
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