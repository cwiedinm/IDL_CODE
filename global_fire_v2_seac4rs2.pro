; ****************************************************************************
; GLOBAL FIRE EMISSIONS ESTIMATES FACFOR MOZART MODEL
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
; *****************************************************************
; ***********UPDATE TO v1.5****************************************
;  JUNE 20, 2014
; - renamed this file from global_fire to global_fire_v15
; - Changed/updated emissions factor file
; - Deleted a lot of old commented lines (mostly input/output files used in the past)
; - included glc being read in and processed in the input file
; - Added temperate evergreen forest to generic land cover classes
; - Fixed bug with crop lands... all fuel loadings for croplands (except sugar cane) is set to 1200. g/m2 (Akagi et al. 2011)
; - When LCT is bare/snow  - use GLC to define land cover (did not change code for urban)
; 
; 
; RUNS June 20, 2014
;
; OCTOBER 30, 2014
; - Renamed global_fire_v15_NA global_fire_v15_TXprj
; - Set to run year 2012
; - read in separate fuel loading files for lct, glc, fccs, fccs_cdl, tceq, tceq_cdl
; - Changed the emission factor file read in
; - edited to read in the land cover codes of all of the different maps (e.g., fccs, fccs_Cdl, tceq, tceq_cdl)
; - rearranged some of the checks
; - added option for different cases in the beginning, which determine the land covers and fuel loadings to use.
; - Edited code to have non-manual read in of input (fuel loading and emission factor) files 
; - NOTE: USER MUST EDIT SCENARIO AND DATE (for output file name) AT THE BEGINNING OF THE CODE
; 
; **********************************************************************************************
; ; ***********UPDATE TO v2.0****************************************
; MARCH 05-11, 2015
; (NOTE: UPDATES by Christine denoted in code by "cw")
; - This is the file sent to me from YO (in email dated 11/27/2014)
;    ** The file is called "global_fire_v15_txprj.pro"
;    ** renaming it today "global_fire_v2_txprj.pro"
; - Got rid of the removal of files with confidence < 20 (This will already be taken care of in input processing)
; - Added area to the input file and all further
; - Removed Jay's code to remove overlapping fires
; - Included a field for the esa_cci value to be read in
; - Updated the format of the input file: 
;   ** Removed State, Time, TPIX/SPIX from the inputs read in and processed
; - Changed the extent of the tropical region from 30 degrees to 23.5 degrees (consistent with what YO had)
; - included polyid and fireid in output file
;
; APRIL 15-22, 2015
; - Corrected the ESA Scenario (which had a problem with the urban/bare areas)
; - removed doubling over tropical regions (taken care of in the new FINN GIS pre-processor)
; - Removed the fraction of bare from area burned estimate
; - in the TCEQ and FCCS data to which genveg --> 0, changed to new land cover depending on tree/herb cover
;   (see notes in scenarios) 
;   
;   April 22, 2014
;   reanamed for SEACR4S2 to include 2013 SEAC4RS input file that I created .
; ****************************************************************************************************************
;+
function nlines,file,help=help
;       =====>> LOOP THROUGH FILE COUNTING LINES
;
tmp = ' '
nl = 0L
on_ioerror,NOASCII
if n_elements(file) eq 0 then file = pickfile()
openr,lun,file,/get_lun
while not eof(lun) do begin
  readf,lun,tmp
  nl = nl + 1L
  endwhile
close,lun
free_lun,lun
NOASCII:
return,nl
end
;
function isa_generic,var,typ
; calls isa() http://www.exelisvis.com/docs/ISA.html with keyword
; if 'n', test /number
; if 'i', test /integer
; if 'f', test /float
; if 's', test /string
  if typ.StartsWith('n', /fold_case) then return, isa(var, /number)
  if typ.StartsWith('i', /fold_case) then return, isa(var, /integer)
  if typ.StartsWith('f', /fold_case) then return, isa(var, /float)
  if typ.StartsWith('s', /fold_case) then return, isa(var, /string)
  print, 'unexpected typename: ', typ
  stop
end
;-------------------------------
;-------------------------------
;-------------------------------
;-------------------------------
;-------------------------------

; yk_undo: takes one argument scen, the scenario ID [1,2,3,4,5,6]
; yk_undo: also, i made runner procedure at the end, so renamed this code.
; yk_undo: when returning code to christine, undo these changes.
;pro global_fire_v15_TXprj

pro global_fire_v2_SEAC4RS2, scen=scen, infile=infile, simid=simid

  ; yk_undo:  extra frill to dealing with proc arguments   
  if not keyword_set(scen) then scen=1
  if not keyword_set(infile) then infile='E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\outputs\2012_NA_lrg_7p3rasters_v9c_try1\2012_NA_lrg_7p3rasters_v9c_try1.csv'

  ; yk_undo: simid, simulation identifier, becomes begining part of output/log file
  ; yk_undo: output file name will be
  ;     (simid)_(scename)_(todaydate).csv
 
  ; yk_undo:  I prefer to use relative directory...
  ; cw edited path, 03/02/2015
  rootdir = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\'

close, /all

 t0 = systime(1) ;Procedure start time in seconds

 yearnum= 2013
 FAC = 0.5 ; Factor to apply to duplicate tropical fires 
; SUBDIVIDED INPUT FILE 
; infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\outputs\2012_NA_7p3rasters_v9c_try1\2012_NA_7p3rasters_v9c_try1.csv'

; UNDIVIDED INPUT FILE
; infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\outputs\2012_NA_lrg_7p3rasters_v9c_try1\2012_NA_lrg_7p3rasters_v9c_try1.csv'

; SEAC4RS input file
infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\code\TEST04152015\MOD2013_FINN_input_File_04162015.csv'  

; ##########################################################################
; USER INPUTS --- EDIT DATE AND SCENARIO HERE
; ##########################################################################
if not keyword_set(simid) then simid='mod2013'

; yk: incrementing version number
;todaydate = '_11192014B' ; this is for naming the output file
todaydate = '_04222015' ; this is for naming the output file

; yk_undo: turned off hard-wired scenario
; USER SHOULD UNCOMMENT THE SCENARIO AND SCENARIO NAME FOR THE RUN BEING DONE
; Scenario name is for the output file name
;  
; ; DEFINE SCENARIOS
 ; CASE #1: ALL LCT
 ;     scen = 1
 ;     scename = 'scen1'
; ; CASE #2: ALL GLC
;     scen = 2
;     scename = 'scen2'
; ; CASE #3: FCCS & LCT
;      scen = 3
;      scename = 'scen3'
; ; CASE #4: FCCS/CDL& LCT
;      scen = 4
;      scename = 'scen4'
;; ; CASE #5: TCEQ, FCCS, LCT
;     scen = 5
;     scename = 'scen5'
;; ; CASE #6: TCEQ/CDL, FCCS/CDL, LCT
;     scen = 6     
;     scename = 'scen6'
; CASE # 7: ESA CCI 
     scen = 7
     scename = 'scen7'
;     
; yk: scenario name, set based on procedure argument
      scename = 'scen' + string(scen, format='(i1)')
      print, scename
; ##########################################################################
; ##########################################################################
 
 
 
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
; ****************************************************************************
; 11/14/201
; Edited to read in separate Fuel loadings files for each land cover
; NOTE: 11/19/2014: Biomass in input files already have units of kg/m2  
;READ IN FUEL LOADING FILE for LCT
; yk_undo:  file/path
    fuelinlct = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\LCTFuelLoad.csv'
;    fuelinlct = filepath('../input/LCTFuelLoad.csv', root_dir=rootdir)
;    
;    infuellct=ascii_template(fuelinlct)
;    fuellct=read_ascii(fuelinlct, template=infuellct)

      nfuelinlct = nlines(fuelinlct)-1
      treelct = fltarr(nfuelinlct)
      herblct = fltarr(nfuelinlct)
      fuellctnum = intarr(nfuelinlct)

      openr,ilun,fuelinlct,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = make_array(nvars)

      for k=0L,nfuelinlct-1 do begin
          readf,ilun,data1
          fuellctnum[k] = data1[0]
          treelct[k] = data1[1]
          herblct[k] = data1[2]
      endfor
      close,ilun
      free_lun,ilun

;   Set up fuel arrays
;       fuellctnum = fuellct.field1
;       treelct = fuellct.field3
;       herblct = fuellct.field4

;READ IN FUEL LOADING FILE for GLC
; yk_undo:  file/path
    fuelinglc = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\GLCFuelLoad.csv'
;    fuelinglc = filepath('../input/GLCFuelLoad.csv', root_dir=rootdir)
;    infuelglc=ascii_template(fuelinglc)
;    fuelglc=read_ascii(fuelinglc, template=infuelglc)

      nfuelinglc = nlines(fuelinglc)-1
      treeglc = fltarr(nfuelinglc)
      herbglc = fltarr(nfuelinglc)
      fuelglcnum = intarr(nfuelinglc)

      openr,ilun,fuelinglc,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelinglc-1 do begin
          readf,ilun,data1
          fuelglcnum[k] = data1[0]
          treeglc[k] = data1[1]
          herbglc[k] = data1[2]
      endfor
      close,ilun
      free_lun,ilun

;   Set up fuel arrays for GLC Fuels
;       fuelglcnum = fuelglc.field1
;       treeglc = fuelglc.field3
;       herbglc = fuelglc.field4

;READ IN FUEL LOADING FILE for ESA (added 03/11/2015, CW
; yk_undo:  file/path
    fuelinesa = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\ESAFuelLoad.csv'
;    fuelinesa = filepath('../input/ESAFuelLoad.csv', root_dir=rootdir)
;    infuelesa=ascii_template(fuelinesa)
;    fuelesa=read_ascii(fuelinesa, template=infuelesa)

      nfuelinesa = nlines(fuelinesa)-1
      treeesa = fltarr(nfuelinesa)
      herbesa = fltarr(nfuelinesa)
      fuelesanum = intarr(nfuelinesa)

      openr,ilun,fuelinesa,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelinesa-1 do begin
          readf,ilun,data1
          fuelesanum[k] = data1[0]
          treeesa[k] = data1[1]
          herbesa[k] = data1[2]
      endfor
      close,ilun
      free_lun,ilun
      


;READ IN FUEL LOADING FILE for FCCS
; yk_undo:  file/path
    fuelinfccs = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\FCCSFuelLoad.csv'
;    fuelinfccs = filepath('../input/FCCSFuelLoad.csv', root_dir=rootdir)
;    infuelfccs=ascii_template(fuelinfccs)
;    fuelfccs=read_ascii(fuelinfccs, template=infuelfccs)

      nfuelinfccs = nlines(fuelinfccs)-1
      treefccs = fltarr(nfuelinfccs)
      herbfccs = fltarr(nfuelinfccs)
      fuelfccsnum = intarr(nfuelinfccs)
      fccsgenveg = intarr(nfuelinfccs)
      
      openr,ilun,fuelinfccs,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelinfccs-1 do begin
          readf,ilun,data1
          fuelfccsnum[k] = data1[0]
          fccsgenveg[k] = data1[1]
          treefccs[k] = data1[2]
          herbfccs[k] = data1[3]
      endfor
      close,ilun
      free_lun,ilun

;   Set up fuel arrays
;     fuelfccsnum = fuelfccs.field1
;     fccsgenveg = fuelfccs.field3
;     treefccs = fuelfccs.field4
;     herbfccs = fuelfccs.field5

;READ IN FUEL LOADING FILE for FCCSCDL
; yk_undo:  file/path
    fuelinfccscdl = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\FCCSCDLFuelLoad.csv'
;    fuelinfccscdl = filepath('../input/FCCSCDLFuelLoad.csv', root_dir=rootdir)
;   infuelfccscdl=ascii_template(fuelinfccscdl)
;   fuelfccscdl=read_ascii(fuelinfccscdl, template=infuelfccscdl)

      nfuelinfccscdl = nlines(fuelinfccscdl)-1
      treefccscdl = fltarr(nfuelinfccscdl)
      herbfccscdl = fltarr(nfuelinfccscdl)
      fuelfccscdlnum = intarr(nfuelinfccscdl)
      fccscdlgenveg = intarr(nfuelinfccscdl)
      
      openr,ilun,fuelinfccscdl,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelinfccscdl-1 do begin
          readf,ilun,data1
          fuelfccscdlnum[k] = data1[0]
          fccscdlgenveg[k] = data1[1]
          treefccscdl[k] = data1[2]
          herbfccscdl[k] = data1[3]
      endfor
      close,ilun
      free_lun,ilun


;   Set up fuel arrays
;       fuelfccscdlnum = fuelfccscdl.field1
;       fccscdlgenveg = fuelfccscdl.field3
;       treefccscdl = fuelfccscdl.field4
;       herbfccscdl = fuelfccscdl.field5

;READ IN FUEL LOADING FILE for TCEQ
; yk_undo:  file/path
    fuelintceq = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\TCEQFuelLoad.csv'
    ;fuelintceq = filepath('../input/TCEQFuelLoad.csv', root_dir=rootdir)
;    infueltceq=ascii_template(fuelintceq)
;    fueltceq=read_ascii(fuelintceq, template=infueltceq)

      nfuelintceq = nlines(fuelintceq)-1
      treetceq = fltarr(nfuelintceq)
      herbtceq = fltarr(nfuelintceq)
      fueltceqnum = intarr(nfuelintceq)
      tceqgenveg = intarr(nfuelintceq)
      
      openr,ilun,fuelintceq,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelintceq-1 do begin
          readf,ilun,data1
          fueltceqnum[k] = data1[0]
          tceqgenveg[k] = data1[1]
          treetceq[k] = data1[2]
          herbtceq[k] = data1[3]
      endfor
      close,ilun
      free_lun,ilun

;   Set up fuel arrays
;       fueltceqnum = fueltceq.field1
;       tceqgenveg = fueltceq.field3
;       treetceq = fueltceq.field4
;       herbtceq = fueltceq.field5

;READ IN FUEL LOADING FILE for TCEQCDL
; yk_undo:  file/path
    fuelintceqcdl = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\TCEQCDLFuelLoad.csv'
;    fuelintceqcdl = filepath('../input/TCEQCDLFuelLoad.csv', root_dir=rootdir)
;    infueltceqcdl=ascii_template(fuelintceqcdl)
;    fueltceqcdl=read_ascii(fuelintceqcdl, template=infueltceqcdl)

      nfuelintceqcdl = nlines(fuelintceqcdl)-1
      treetceqcdl = fltarr(nfuelintceqcdl)
      herbtceqcdl = fltarr(nfuelintceqcdl)
      fueltceqcdlnum = intarr(nfuelintceqcdl)
      tceqcdlgenveg = intarr(nfuelintceqcdl)
      
      openr,ilun,fuelintceqcdl,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nfuelintceqcdl-1 do begin
          readf,ilun,data1
          fueltceqcdlnum[k] = data1[0]
          tceqcdlgenveg[k] = data1[1]
          treetceqcdl[k] = data1[2]
          herbtceqcdl[k] = data1[3]
      endfor
      close,ilun
      free_lun,ilun

;   Set up fuel arrays
;       fueltceqcdlnum = fueltceqcdl.field1
;       tceqcdlgenveg = fueltceqcdl.field2
;       treetceqcdl = fueltceqcdl.field4
;       herbtceqcdl = fueltceqcdl.field5

       

; *****************************************************************************************     
;   READ IN EMISSION FACTOR FILE
; ***************************************************************************************** 

; yk_undo:  file/path
    emisin = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\EmissionFactors11192014.csv'
;    emisin = filepath('../input/EmissionFactors11192014.csv', root_dir=rootdir)

 ;   inemis=ascii_template(emisin)
 ;   emis=read_ascii(emisin, template=inemis)
;   Set up Emission Factor Arrays
 
; FINAL FILE 08/18/2010
;  1          2             3   4   5     6   7   8     9     10  11 
; Generic Land cover code   CO  Nox NMOC  NH3 SO2 PM2.5 PM10  OC  BC


     nemisin = nlines(emisin)-1
      vegemis = intarr(nemisin)   ; GENERIC VEGETATION CODE (1-15)
       COEF = fltarr(nemisin)   ; CO emission factor
       NOXEF = fltarr(nemisin)   ; NOx emission factor
       NMOCEF = fltarr(nemisin) 
       NH3EF = fltarr(nemisin)      ; NH3 emission factor
       SO2EF = fltarr(nemisin)      ; SO2 emission factor
       PM25EF = fltarr(nemisin)     ; PM2.5 emission factor
       PM10EF = fltarr(nemisin)     ; PM10 emission factor (added 08/18/2010)
       OCEF = fltarr(nemisin)       ; OC emission factor
       BCEF = fltarr(nemisin)       ; BC emission factor
      
      openr,ilun,emisin,/get_lun
      sdum=' '
      readf,ilun,sdum
      print,sdum
      vars = Strsplit(sdum,',',/extract)
      nvars = n_elements(vars)
      for i=0,nvars-1 do print,i,': ',vars[i]
        data1 = fltarr(nvars)

      for k=0L,nemisin-1 do begin
          readf,ilun,data1
          vegemis[k] = data1[0]
          COEF[k] = data1[1]
          NOXEF[k] = data1[2]
          NMOCEF[k] = data1[3]
          NH3EF[k] = data1[4]
          SO2EF[k] = data1[5]
          PM25EF[k] = data1[6]
          PM10EF[k] = data1[7]
          OCEF[k] = data1[8]
          BCEF[k] = data1[9]
      endfor
      close,ilun
      free_lun,ilun

print, "Finished reading in fuel and emission factor files"

; ****************************************************************************
; OUTPUT FILE
; ****************************************************************************
; yk_undo:  file/path
    outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\APR_2015\SEAC4RS\FINNv2_'+ scename+'_'+ simid + '_'+ todaydate+'.txt'
;outfile = filepath('../MODEL_OUTPUTS/' + simid + '_'+scename+todaydate+'.txt', root_dir=rootdir)

     openw, 6, outfile
     print, 'opened output file: ', outfile
  
     printf, 6, 'longi,lat,polyid,fireid,day,lct,esa,genLC,pcttree,pctherb,pctbare,area,bmass,CO,NOx,NH3,SO2,NMOC,PM25,PM10,OC,BC,' ; 04/20/2015

; yk_undo: not only i added extra field, i made folating point expression to use scientific notation with shorter field.  undo this
;;     form = '(D20.10,",",D20.10,",",(8(I10,",")),14(D25.10,","),2(",",i2))'
     form = '(e14.6,",",e14.6,",",(6(I9,",")),14(e14.6,","))' ; 04/20/2015

 
    ; Print an output log file
; yk_undo:  file/path
    logfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS_2015\APR_2015\SEAC4RS\LOG_FINNv2_'+ scename+'_'+ simid + '_'+ todaydate+'.txt'
;    logfile = filepath('../MODEL_OUTPUTS/' + simid + '_log_' + scename+todaydate+'.txt', root_dir=rootdir)
    openw, 9, logfile
    print, 'SET UP OUTPUT FILES'
;***************************************************************************************

; ****************************************************************************
; FIRE AND LAND COVER INPUT FILE
; ****************************************************************************

; yk_undo:  file/path
; yk_undo:  i made infile to be set near the top of code, or as proc argument
;infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\TEST_INFILE_11172014.csv' 
;infile = filepath(infile, root_dir=rootdir)

; test infile, cw, 03/05/2015
; infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\CODE_INPUTS\TEST_input_03112015.csv'
  
; New file tested 04/15/2015
; infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\outputs\2012_NA_lrg_7p3rasters_v9c_try1.csv'
  
; INFILE FROM YO- 
; infile = 'E:\Data2\wildfire\TEXAS\NEW_PROJECT_2014\DOWNLOADS_APRIL2015\gis_tool\gis_tool\outputs\2012_NA_lrg_7p3rasters_v9c_try1\2012_NA_lrg_7p3rasters_v9c_try1.csv'  
  
  
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
        


; Get the number of fires in the file
        nfires = n_elements(map.field01)
    		print, 'Finished reading input file'


; 04/20/2015
; 1     2        3       4       5    6   7    8    9    10  11  12      13    
; DATE,POLYID,FIREID,FIRELAT,FIRELON,AREA,TREE,HERB,BARE,LCT,ESA,pct_LCT,pct_ESA


        polyid1 = map.field02
        fireid1 = map.field03
        
        lat1 = map.field04
        lon1 = map.field05
        date1 = map.field01
        area1 = map.field06 ; CW: Added March 05, 2015  -- NEED set the field
 
        tree1 = map.field07*1.0
        herb1 = map.field08*1.0
        bare1 = map.field09*1.0
 
        lct1 = map.field10 
        esa1 = map.field11 ; CW added March 05, 2015 
        glc1 = map.field11
        fccs1 = map.field11
        fccscdl1 = map.field11
        tceq1 = map.field11
        tceqcdl1 = map.field11
        
              
; Total Number of fires input in original input file
      numorig = n_elements(lct1)
      
;; First, get rid of all fires with confidence less than 20%
;; Added on 02.23.2009
; 03/05/2015: CW Commented out!! Confidence is already taken into account in GIS processor
;		goodfires= where(conf gt 20)
;		ngoodfires = n_elements(goodfires)
		
Print, 'The total number of fires in is: ', numorig
print, 'Finished Reading Input file'

; Added 08/25/08: removed values of -9999 from VCF inputs
; CW: Updated 03/05/2015 

	misstree = where(tree1 lt 0)
	if misstree[0] ge 0 then tree1(misstree) = 0.0
	missherb = where(herb1 lt 0)
	if missherb[0] ge 0 then herb1(missherb) = 0.0
	missbare = where(bare1 lt 0)
	if missbare[0] ge 0 then bare1(missbare) = 0.0

; Calculate the total cover from the VCF product
        totcov = tree1+herb1+bare1
        missvcf = where(totcov lt 98.)
  	    if missvcf[0] eq -1 then nummissvcf =0 else nummissvcf = n_elements(missvcf)

; ***************************************************************************************
; JULIAN DATE: Calculate the julian day for the fire detections
       numfire1 = numorig ; Changed this cw
       jd2 = intarr(numfire1)
; yk: save month for diagnosis
       mo2 = intarr(numfire1)
       dy2 = intarr(numfire1)
       
;!!!!!!!!!!! EDIT THIS SECTION FOR THE CORRECT DATE FORMAT!!!

; For dates with the format: 3/1/2007
for i = 0L,numfire1-1 do begin
         parts =  strsplit(date1[i],'/',/extract)
         day = fix(parts[1])
         month = fix(parts[0])
 
; For Dates with the format:  2013-02-01
;For i = 0L,numfire1-1 do begin
;    parts =  strsplit(date1[i],'-',/extract) ; ***** EDIT FOR DATE FORMAT!! ********
;    day = fix(parts[2])
;    month = fix(parts[1])

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
          jd2[i] = day+daystart
; yk: save month for diagnosis
          mo2[i] = month
          dy2[i] = day
  endfor
  print, 'Finished calculating Julian Dates'
; *******************************************************************************************************************
; OCTOBER 16, 2009: For Tropics, where satellite coverage isn't daily, spread fires over 48 hours (starting at 24Z)
;    from 30N to 30S; using advice fom Jay's code
;    Create duplicates of the fires for 2-day periods in this region. If there are overlaps- then these will be removed in
;    the next section. 
;    Changed the names of arrays above (added '2' to the end of them above- so that I can use the original names here)

; Identify Tropics: 
 ;tropics = where(lat1 gt -23.5 and lat1 lt 23.5) ; CW changed from 30 degrees to 23.5 degrees (03/11/2015)

;if tropics[0] eq -1 then begin   ; Added this section on Dec. 11, 2009 for regions not in the tropics. 
  fireid = [fireid1]
  polyid = [polyid1]
  
  lat=[lat1]
  lon=[lon1]
  tree=[tree1]
  herb=[herb1]
  bare=[bare1]
  lct=[lct1]

  jd = [jd2]
; yk: save month for diagnosis
  mo = [mo2]
  dy = [dy2]
  glc = [glc1]
  fccs = [fccs1]
  fccscdl = [fccscdl1]
  tceq = [tceq1]
  tceqcdl = [tceqcdl1]

  area = [area1]
  esa = [esa1]
  factortrop = fltarr(numfire1)
  factortrop[*]= 1.0
;  goto, skiptropics 
;endif  
; 
; numadd = 0
; numadd = n_elements(tropics)
; printf, 9, 'The original number of fires is: ', numfire1
; printf, 9, 'The number of fires added (because in tropics) is:', numadd
; 
; newfires = numfire1+numadd ; add the additional fires to the 
; ; Set up a factor to multiply emissions in the doubled tropical fires. 
; factortrop1 = fltarr(numfire1) ; this is for the multiplication of the duplicate fires in tropics. NOV. 25, 2009
; factortrop2 = fltarr(numadd)
; factortrop1[*] = 1.0
; 
;; Create new arrays with only the data from the tropics
;    polyid3 = polyid1(tropics)
;    fireid3 = fireid1(tropics)
;
;    lat3 =lat1(tropics)
;    lon3 = lon1(tropics)
;
;    tree3 = tree1(tropics)
;    herb3 = herb1(tropics)
;    bare3 = bare1(tropics)
;    lct3 = lct1(tropics)
;
;    totcov2=totcov(tropics)
;
;    glc3 = glc1(tropics)
;    fccs3 = fccs1(tropics)
;    fccscdl3 = fccscdl1(tropics)
;    tceq3 = tceq1(tropics)
;    tceqcdl3 = tceqcdl1(tropics)
;
;    area3 = area1(tropics)    
;    esa3 = esa1(tropics)
;    jd3=intarr(numadd)
;; yk: save month for diagnosis
;    mo3=intarr(numadd)
;    
;; Set the day of the new file to the jd+1 (include the next day...)
;for i = 0L,numadd-1 do begin
;  jd3[i]=jd2[tropics[i]]+1 ; corrected this on NOVEMBER 20, 2009
;  ; yk: get month of following day
;  caldat, (julday(mo2[i], dy2[i], yearnum) + 1), xmo
;  mo3[i] = xmo
;  factortrop2[i] =FAC ; Set up the factor to apply to the secondary tropical fires 
;endfor
;
;; Put the new files together into single arrays
;  polyid = [polyid1,polyid3]
;  fireid = [fireid1,fireid3]
;
;  lat=[lat1,lat3]
;  lon=[lon1,lon3]
;
;  tree=[tree1,tree3]
;  herb=[herb1,herb3]
;  bare=[bare1,bare3]
;  lct=[lct1,lct3]
;
;  jd = [jd2,jd3]
;; yk: save month for diagnosis
;  mo = [mo2, mo3]
;  totcov=[totcov,totcov2]
;  factortrop = [factortrop1,factortrop2]  
;  glc = [glc1,glc3]
;  fccs = [fccs1,fccs3]
;  fccscdl = [fccscdl1,fccscdl3]
;  tceq = [tceq1,tceq3]
;  tceqcdl = [tceqcdl1,tceqcdl3]
;
;  area = [area1, area3]
;  esa = [esa1,esa3]
;     
;skiptropics: ; Added 12/11/2009

  ngoodfires = n_elements(jd)
;  print, 'finished doubling up the tropics'
;  print, 'the new number of fires = ', ngoodfires
;  printf, 9, 'the new number of fires = ', ngoodfires
  
    
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
        

; Sort fires in order of JD
    index2=sort(jd)
    lat=lat[index2]
    lon=lon[index2]

    polyid = polyid[index2]
    fireid = fireid[index2]

    tree=tree[index2]
    herb=herb[index2]
    bare=bare[index2]
    lct=lct[index2]

    jd=jd[index2]
; yk: save month for diagnosis
    mo=mo[index2]
    totcov = totcov[index2]
    factortrop = factortrop[index2]
    glc = glc[index2]
    fccs = fccs[index2]
    fccscdl = fccscdl[index2]
    tceq = tceq[index2]
    tceqcdl = tceqcdl[index2]

    area = area[index2]
    esa = esa[index2]
    
    ; yk: for qa, hold onto original land cover values
    lctorig=lct[*]
    glcorig=glc[*]
    tceqorig=tceq[*]
    tceqcdlorig=tceqcdl[*]
    
    ; yk: scenuse; actual algorithm being used when falling back to, eg. LCT, for various rasons
    scenuse=intarr(ngoodfires)
    scenuse[*]=-99
 

; Set totals to 0.0
     COtotal = 0.0
     NMOCtotal = 0.0
     NOXtotal = 0.0
     SO2total = 0.0
     PM25total = 0.0
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

; 2) Remove fires with no LCT assignment or in water bodies or snow/ice assigned by LCT
    if lct[j] ge 17 or lct[j] le 0 or lct[j] eq 15 then begin ; Added Snow/Ice on 10/20/2009
       ; JUNE 20, 2014: use GLC dataset to assign a landcover before skipping
       if glc[j] eq 2 then begin ; croplands
          lct[j] = 12
          goto, next1
       endif
       if glc[j] eq 3 then begin ; grasslands
          lct[j] = 10
          goto, next1
       endif
       if glc[j] eq 4 then begin ; trees - assign mix forest 
          lct[j] = 5
          goto, next1
       endif
       if glc[j] eq 5 then begin ; Shrublands 
          lct[j] = 6
          goto, next1
       endif
       if glc[j] eq 6 then begin ; permanent wetlands
          lct[j] = 11
          goto, next1
       endif
       ; If no good GLC replacement, then skip
       lct0 = lct0 + 1
       goto, skipfire
    endif
next1:



; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;  GO THROUGH THE DIFFERENT SCENARIOS
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;yk: make sure that genveg got assigned somewhere for whatever mechanism.  
genveg = -9999

;###################################################################################################
;###################################################################################################
; SCENARIO #5 = TCEQ, FCCS, LCT
;###################################################################################################
;###################################################################################################
if scen eq 5 then begin
  ; yk: record which algorithm used
  scenuse[j] = 5
  ; yk: if no valid LC type specified, switch to fccs
  if tceq[j] lt 1 or tceq[j] gt 36 then begin
    goto, scenario3  ; go to the fccs
  endif
  ; yk: overwrite tceqcdl if its urban (2-5) or water (1), based on tree cover 
  ; cw added bare to this as well. 
  if where(tceq[j] eq [2,3,4,5,1,6]) ne -1  then begin
    case 1 of
      tree[j] lt 40:  tceq[j] = 7; herbaceous natural
      (tree[j] ge 40) and (tree[j] lt 60): tceq[j] = 25; mixed shrub
      tree[j] ge 60: tceq[j] = 16; mixed forest
    endcase
  endif
  ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
  covertype = where(fueltceqnum eq tceq[j], /null)
  genveg = tceqgenveg[covertype]
  treeload = treetceq[covertype]
  herbload = herbtceq[covertype]
endif  ; END OF SCENARIO #5

;###################################################################################################
;###################################################################################################
; SCENARIO #6 = TCEQ/CDL, FCCS/CDL, LCT
;###################################################################################################
;###################################################################################################
if scen eq 6 then begin
  ; yk: record which algorithm used
  scenuse[j] = 6
  ; yk: if no valid LC type specified, switch to fccs_cdl
  if tceqcdl[j] lt 1 or tceqcdl[j] gt 254 then begin
    goto, scenario4  ; go to the fccs_cdl
  endif
  ; yk: overwrite tceqcdl if its urban (102-105, 161-164) or water (101 and 156) or aquaculture(92), based on tree cover
  ; cw added tceqcdl = 106 to this list
  ; cw added tceqdcl = 166 (barren) to this list
  if where(tceqcdl[j] eq [102,103,104,105,106,161,162,163,164,166,101,156, 92]) ne -1  then begin
    case 1 of
      tree[j] lt 40:  tceqcdl[j] = 107; herbaceous natural
      (tree[j] ge 40) and (tree[j] lt 60): tceqcdl[j] = 125; mixed shrub
      tree[j] ge 60: tceqcdl[j] = 116; mixed forest
    endcase
  endif
  ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
  covertype = where(fueltceqcdlnum eq tceqcdl[j], /null)
  genveg = tceqcdlgenveg[covertype]
  treeload = treetceqcdl[covertype]
  herbload = herbtceqcdl[covertype]
endif  ; END OF SCENARIO #6

;###################################################################################################
;###################################################################################################
; SCENARIO #3 = FCCS & LCT
;###################################################################################################
;###################################################################################################
if scen eq 3 then begin
  scenario3:
  ; yk: record which algorithm used
  scenuse[j] = 3
  ; yk: if no valid LC type specified, switch to lct
  if fccs[j] gt 458 or fccs[j] le 0 then begin ; if FCCS is not available, go to use the LCT
    goto, scenario1                            ; CW changed the values of this to include all values outside of the FCCS table (03/11/2015)
  endif
  ; yk: no natural vegetatoin (0) or water (900) switches to lct as well
  if where(fccs[j] eq [0, 900]) ne -1 then begin
    goto, scenario1
  endif
  ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
  covertype = where(fuelfccsnum eq fccs[j], /null)
  genveg = fccsgenveg[covertype]
  treeload = treefccs[covertype]
  herbload = herbfccs[covertype]
endif ; END SCENARIO #3

;###################################################################################################
;###################################################################################################
; SCENARIO #4 = FCCS/CDL& LCT
;###################################################################################################
;###################################################################################################
if scen eq 4 then begin
  scenario4:
  ; yk: record which algorithm used
  scenuse[j] = 4
  ; yk: if no valid LC type specified, switch to lct
  if fccscdl[j] gt 1299 or fccscdl[j] le 0 then begin ; if FCCS is not available, go to use the LCT
    goto, scenario1
  endif
  ; yk: no natural vegetatoin (0) or water (900) switches to lct as well
  if where(fccscdl[j] eq [0, 900]) ne -1 then begin ;
    goto, scenario1
  endif
  ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
  covertype = where(fuelfccscdlnum eq fccscdl[j], /null)
  genveg = fccscdlgenveg[covertype]
  treeload = treefccscdl[covertype]
  herbload = herbfccscdl[covertype]
endif  ; END OF SCENARIO #4

;###################################################################################################
;###################################################################################################
; SCENARIO #1 = LCT ONLY
;###################################################################################################
;###################################################################################################

if scen eq 1 then begin
; ######################################################
; Assign Generic land cover to fire based on
;   global location and lct information
; ######################################################

    scenario1:
    ; yk: record which algorithm used
    scenuse[j] = 1

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
            if lat[j] gt 50 then begin               ; 10/19/2009: Changed the latitude border to 50degrees N (from 60 before) and none in S. Hemisphere
            genveg = 5
            lct[j] = 1  ; set to evergreen needleleaf forest 
            goto, endveg
        endif else begin
            if lat[j] ge -30 and lat[j] le 30 then genveg = 3 else genveg = 4
            lct[j] = 5 ; set to mixed forest
            goto, endveg
        endelse
        endif
    endif
; 5) Forests (based on latitude)
    if lct[j] eq 2 then genveg = 3 ; Tropical Forest
    if lct[j] eq 4 then genveg = 4 ; Temperate Forest
    if lct[j] eq 1 then begin  ; Evergreen Needleleaf forests (06/20/2014 Changed this)
       if lat[j] gt 50. then genveg = 5 else genveg = 6   ; 6/20/2014: Changed this 
       goto, endveg                                      ; Assign Boreal for Lat > 50; Evergreen needlelead for all else
    endif
    if lct[j] eq 3 then begin  ; deciduous Needleleaf forests -- June 20, 2014: Left LCT = 3 same as old code. ONLY Changed Evergreen needleleaf forests
       if lat[j] gt 50. then genveg = 5 else genveg = 4   ; 10/19/2009: Changed the latitude border to 50degrees N (from 60 before) and none in S. Hemisphere
       goto, endveg                                      ; Assign Boreal for Lat > 50; Temperate for all else
    endif
    if lct[j] eq 5 then begin ; Mixed Forest, Assign Fuel Load by Latitude
       if lat[j] gt 50 then begin  ; 10/19/2009: Changed the latitude border to 50degrees N (from 60 before) and none in S. Hemisphere
         genveg = 5
         goto, endveg
       endif
       ; yk: tropics -23.5 to +23.5
       if lat[j] ge -23.5 and lat[j] le 23.5 then genveg = 3 else genveg = 4
    endif
endveg:
; GET FUEL LOADING       
       ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
       covertype = where(fuellctnum eq lct[j], null)
       treeload = treelct[covertype] 
       herbload = herblct[covertype]

endif ; END OF IF SCENARIO = 1 

;###################################################################################################
;###################################################################################################
; SCENARIO #2 = GLC ONLY
;###################################################################################################
;###################################################################################################
if scen eq 2 then begin
scenario2:
; yk: record which algorithm used
scenuse[j] = 2
;1) Urban, water, glaciers, etc. 
; yk: artifical surface=1, water=11, snow/glacier=10
; yk: also found that there are 0 occasionally, looks like processing error.
; yk: i let them to rely on modis VCF to select LC type
    if glc[j] eq 1 or glc[j] eq 10 or glc[j] eq 11 or glc[j] eq 0 then begin ; then assign genveg based on VCF cover in the pixel and reset the lct value (for emission factors)
        ; yk: glc=1 is the only urban
        if glc[j] eq 1 then urbnum = urbnum+1
        if tree[j] lt 40 then begin
            genveg = 1        ; grasslands
            glc[j] = 3       ; set to grassland
         goto, endveg2
        endif
        if tree[j] ge 40 and tree[j] lt 60 then begin
            genveg = 2  ; woody savannas
            glc[j] = 5 ; set to shrublands
            goto, endveg2
        endif
        if tree[j] ge 60 then begin                  ; assign forest based on latitude
            genveg = 5
            glc[j] = 4  ; set to evergreen needleleaf forest 
            goto, endveg2
        endif 
     endif ; end urban, glc = 1
;2) Sparse vegegation and bare soil
   if glc[j] eq 8 or glc[j] eq 9 then genveg = 1 ; assign bare ground and sparse vegetation to Grasslands

;3) Grasslands 
  if glc[j] eq 3 or glc[j] eq 6 then genveg = 1

;4) Croplands
  if glc[j] eq 2 then genveg = 9

;5) Shrubs
  if glc[j] eq 5 then genveg = 2

;6) Forests/Trees
  if glc[j] eq 4  then begin
     if lat[j] gt 50. then genveg = 5
     ; yk: tropics -23.5 to +23.5
     if lat[j] gt 23.5 and lat[j] le 50 then genveg = 4
     if lat[j] le 23.5 then genveg = 3
     ; yk: FIXME whatabout sourthern hemisphere?
  endif       
  ; yk: mangrove
  if glc[j] eq 7 then genveg = 3
 endveg2:
; GET FUEL LOADING       
       ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
       covertype = where(fuelglcnum eq glc[j], /null)
       treeload = treeglc[covertype] 
       herbload = herbglc[covertype]
endif ; END OF SCENARIO #2

;###################################################################################################
;###################################################################################################
; SCENARIO #7 = ESA ONLY
;###################################################################################################
;###################################################################################################
if scen eq 7 then begin
  scenario7:
  ; yk: record which algorithm used
  scenuse[j] = 7

; 1) Grasslands and Savanna
     if esa[j] eq 110 or esa[j] eq 130 or esa[j] eq 140 or esa[j] eq 150 or esa[j] eq 153 then begin
        genveg = 1
        goto, endveg3
    endif
; 2) Woody Savanna
    if esa[j] eq 40 or esa[j] eq 152 or esa[j] eq 180 or (esa[j] ge 120 and esa[j] le 122) then begin
        genveg = 2
        goto, endveg3
    endif
; 3) Croplands
    if esa[j] ge 10 and esa[j] le 30 then begin
        genveg = 9
        goto, endveg3
    endif
; 4) Urban
    if esa[j] ge 190 or esa[j] le 0 then begin ; then assign genveg based on VCF cover in the pixel
        if esa[j] eq 190 then urbnum = urbnum+1
        if tree[j] lt 40 then begin
            genveg = 1        ; grasslands
            esa[j] = 130 ; set to grasslands
         goto, endveg3
       endif
        if tree[j] ge 40 and tree[j] lt 60 then begin
            genveg = 2  ; woody savannas
            esa[j]= 110 ; mosaic herbaceou s and tree/shrub
            goto, endveg3
        endif
        if tree[j] ge 60 then begin  ; assign all forests as mixed forests                
              genveg = 4
              esa[j] = 90
            goto, endveg3
        endif
    endif ; END URBAN LOGIC
    
; 5) Forests (based on latitude)
    if esa[j] eq 50 then genveg = 3 ; Tropical Forest
    if esa[j] ge 70 and esa[j] le 82 then begin  ; Needleleaf forests
       if lat[j] gt 50. then genveg = 5 else genveg = 6   ; 6/20/2014: Changed this 
       goto, endveg3                                      ; Assign Boreal for Lat > 50; Evergreen needlelead for all else
    endif
    if (esa[j] ge 60 and esa[j] le 62) OR esa[j] eq 90 or esa[j] eq 100 or esa[j] eq 160 or esa[j] eq 170 then begin  ; Broadlead deciduous, mixed, coastal
       if lat[j] gt 50. then begin 
          genveg = 5
         goto, endveg3
       endif 
       if lat[j] lt 23.5 then genveg = 3 else genveg = 4   ; 10/19/2009: Changed the latitude border to 50degrees N (from 60 before) and none in S. Hemisphere
       goto, endveg3                                       ; Assign Boreal for Lat > 50; Temperate for 23.5 - 50 degrees, Tropical for < 23.5
    endif
endveg3:
; GET FUEL LOADING       
       ; yk: added /null flag for where, in order to avoid accidentally using -1 as index
       covertype = where(fuelesanum eq esa[j], null)
       treeload = treeesa[covertype] 
       herbload = herbesa[covertype]

endif ; END OF SCENARIO 7

;###################################################################################################
;###################################################################################################

; ####################################################
; Assign Burning Efficiencies based on Generic
;   land cover (Hoezelmann et al. [2004] Table 5
; ####################################################
; Generic land cover codes (genveg) are as follows:
;1 grassland
;2 shrub
;3 Tropical Forest
;4 Temperate Forest
;5 Boreal Forest
;6 Temperate Evergreen Forest
;7 Pasture
;8 Rice
;9 Crop (generic)
;10  Wheat
;11  Cotton
;12  Soy
;13  Corn
;14  Sorghum
;15  Sugar Cane


; ####################################################
; AREA BURNED NOW READ IN - (KM2)
; ####################################################

; *****************************************************************************************
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
      ; yk: fixed based on Ito 2004
      ; CF3 = exp(-0.013*(tree[j]/100.))     ; Apply to all herbaceous fuels
       CF3 = exp(-0.013*tree[j])     ; Apply to all herbaceous fuels
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
    coarsebm = treeload
    herbbm = herbload

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
; NOVEMBER 14, 2014
; yk: make sure i have expected value for genveg
;if where(genveg eq [1:15]) eq -1 then begin
;  if where(genveg[0] eq [1:15]) eq -1 then begin
;    print,'Fire_emis> ERROR genveg not set correctly: '
;    print,' scen (orig/used): ', scen, scenuse[j]
;    print,' lc_orig(M/G/F/FC/T/TC): ', [lctorig[j], glcorig[j],fccs[j],  fccscdl[j], tceqorig[j], tceqcdlorig[j]]
;    print,' lc_new (M/G/F/FC/T/TC): ', [lct[j], glc[j],fccs[j],  fccscdl[j], tceq[j], tceqcdl[j]]
;    print,' tree: ', tree[j]
;    print,' genveg: ', genveg
;    print,'Fire_emis> ERROR stopping...'
;    stop
;  endif
;endif

; CHRISTINE EDITING YO'S CODE THAT ISN"T COMPILING
;if where(genveg eq [1:15]) eq -1 then begin
  if genveg eq -1 or genveg eq 0 then begin
    print,'Fire_emis> ERROR genveg not set correctly: '
    print,' scen (orig/used): ', scen, scenuse[j]
    print,' lc_orig(M/G/F/FC/T/TC): ', [lctorig[j], glcorig[j],fccs[j],  fccscdl[j], tceqorig[j], tceqcdlorig[j]]
    print,' lc_new (M/G/F/FC/T/TC): ', [lct[j], glc[j],fccs[j],  fccscdl[j], tceq[j], tceqcdl[j]]
    print,' tree: ', tree[j]
    print,' genveg: ', genveg
    print,'Fire_emis> ERROR stopping...'
    stop
  endif
;endif


; Reassigned emission factors based on NEW GENVEG, not genveg for new emission factor table
    if genveg eq 1 then index = 0
    if genveg eq 2 then index = 1 
    if genveg eq 3 then index = 2
    if genveg eq 4 then index = 3
    if genveg eq 5 then index = 4
    if genveg eq 6 then index = 5
    if genveg eq 7 then index = 6
    if genveg eq 8 then index = 7
    if genveg eq 9 then index = 8
    if genveg eq 10 then index = 9
    if genveg eq 11 then index = 10
    if genveg eq 12 then index = 11
    if genveg eq 13 then index = 12
    if genveg eq 14 then index = 13
    if genveg eq 15 then index = 14 
    
; ####################################################
; Calculate Emissions
; ####################################################
; Emissions = area*BE*BMASS*EF
    ; Convert units to consistent units
     areanow = area[j]*1.0e6 ; convert km2 --> m2

;     ; cw: 04/22/2015 - remove bare fraction from total area
     areanow = areanow - (areanow*(bare[j]/100.0)) ; remove bare area from being burned (04/21/2015)
; 
; NOTE: 11/19/2014: Biomass in input files already have units of kg/m2
;     bmass = bmass/1000. ; convert g dm/m2 to kg dm/m2




; Calculate emissions (kg)
; CALCULATE EMISSIONS kg/day
; NOV. 25, 2009: Added the multiplication of the factor for the tropics. Assigned ealier in the code, 
;     where the tropics are doubled. 
       CO = COEF[index]*areanow*bmass/1000.*(factortrop[j])
       NMOC = NMOCEF[index]*areanow*bmass/1000.*(factortrop[j])
       NOX = NOXEF[index]*areanow*bmass/1000.*(factortrop[j])
       SO2 = SO2EF[index]*areanow*bmass/1000.*(factortrop[j])
       PM25 = PM25EF[index]*areanow*bmass/1000.*(factortrop[j])
       OC = OCEF[index]*areanow*bmass/1000.*(factortrop[j])
       BC = BCEF[index]*areanow*bmass/1000.*(factortrop[j])
       NH3 = NH3EF[index]*areanow*bmass/1000.*(factortrop[j])
       PM10 = PM10EF[index]*areanow*bmass/1000.*(factortrop[j])

bmassburn = bmass*areanow ; kg burned
BMASStotal = bmassburn+BMASStotal ; kg

if genveg eq 3 then begin
    TOTTROP = TOTTROP+bmassburn
    TOTTROParea = TOTTROPAREA+areanow
endif
if genveg eq 4 then begin
    TOTTEMP = TOTTEMP+bmassburn
    TOTTEMParea = TOTTEMParea+areanow
endif
if genveg eq 5 then begin
  TOTBOR = TOTBOR+bmassburn
  TOTBORarea = TOTBORarea+areanow
endif
if genveg eq 2 then begin
  TOTSHRUB = TOTSHRUB+bmassburn
  TOTSHRUBarea = TOTSHRUBarea+areanow
endif
if genveg ge 9 then begin
  TOTCROP = TOTCROP+bmassburn
  TOTCROParea = TOTCROParea+areanow
  TOTCROPCO = TOTCROPCO + CO
  TOTCROPPM25 = TOTCROPPM25 + PM25
endif
if genveg eq 1 then begin
  TOTGRAS = TOTGRAS+bmassburn
  TOTGRASarea = TOTGRASarea+areanow
endif


 ; units being output are in kg/day/fire
; ####################################################
; Print to Output file
; ####################################################
; NEW PRINT STATEMENT 10/20/2009
; yk: extra diagnositic field following the 'state' field
;longi,lat,polyid,fireid,day,TIME,glc,lct,fccs,fccs_cdl,tceq,tceq_cdl,genLC,pcttree,pctherb,pctbare,area,bmass,CO,NOx,NH3,SO2,NMOC,PM25,PM10,OC,BC,state
; Print updated 4/22/2015
printf,6,format = form, lon[j],lat[j],polyid[j],fireid[j],jd[j],lct[j],esa[j],genveg,tree[j],herb[j], $
       bare[j],areanow,bmass,CO,NOX,NH3,SO2,NMOC,PM25,PM10,OC,BC
       

; Calculate Global Sums
     COtotal = CO+COtotal
     NMOCtotal = NMOC+NMOCtotal
     NOXtotal = NOXtotal+NOx
     SO2total = SO2total+SO2
     PM25total = PM25total+PM25
     OCtotal = OCtotal+OC
     BCtotal = BCtotal+BC
     NH3total = NH3total+NH3
     PM10total = PM10total+PM10
    AREAtotal = AREAtotal+areanow ; m2         
       
; ####################################################
; End loop over Fires
; ####################################################

skipfire:
endfor ; End loop over fires



 ; Calculate Regional Sums
; WESTERN U.S. 
westUS = where(lat gt 38. and lat lt 50. and lon lt (255-360) and lon gt (235-360))   
print, 'NW (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 
westUS = where(lat gt 30. and lat lt 38. and lon lt (255-360) and lon gt (236-360))   
print, 'SW (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 
westUS = where(lat gt 25. and lat lt 38. and lon lt (266-360) and lon gt (255-360))   
print, 'TX (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 
; WESTERN U.S. 
westUS = where(lat gt 38. and lat lt 50. and lon lt (275-360) and lon gt (255-360))   
print, 'UMW (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 
; WESTERN U.S. 
westUS = where(lat gt 38. and lat lt 48. and lon lt (294-360) and lon gt (275-360))   
print, 'NE (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 
; WESTERN U.S. 
westUS = where(lat gt 25. and lat lt 38. and lon lt (284-360) and lon gt (266-360))   
print, 'SE (Tg Species)'
print, 'CO, ', total(CO[westUS])/1.e9
print, 'AREA (km2) ', total(area[westUS])
print, 'AREA (acres) ', total(area[westUS])*247.105
print, ' ' 




    t1 = systime(1)-t0
; PRINT SUMMARY TO LOG FILE
printf, 9, ' '
printf, 9, 'The time to do this run was: '+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
printf, 9, ' This run was done on: ', SYSTIME()
printf, 9, ' '
printf, 9, 'The Input file was: ', infile
printf, 9, 'The Output file was: ', outfile
printf, 9, ' '
printf, 9, 'The SCENARIO in this run was: ', scename
printf, 9, ' '

printf, 9, 'The emissions file was: ', emisin
printf, 9, ' '
printf, 9, 'The total number of fires input was:', numorig
;printf, 9, 'the total number of fires removed with confience < 20:', numorig-nconfgt20
printf, 9, ''
;printf, 9, 'the total number of fires in the tropics was: ', numadd
printf, 9, 'The number of fires processed (ngoodfires):', ngoodfires
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
printf, 9, 'CO = ', COtotal/1.e9
printf, 9, 'NMOC = ', NMOCtotal/1.e9
printf, 9, 'NOx = ', NOXtotal/1.e9
printf, 9, 'SO2 = ', SO2total/1.e9
printf, 9, 'PM2.5 = ', PM25total/1.e9
printf, 9, 'OC = ', OCtotal/1.e9
printf, 9, 'BC = ', BCtotal/1.e9
printf, 9, 'NH3 = ', NH3total/1.e9
printf, 9, 'PM10 = ', PM10total/1.e9
printf, 9, ''

; ***************************************************************
;           END PROGRAM
; ***************************************************************
    t1 = systime(1)-t0
    print,'Fire_emis> ' + scename + ' done.'
    print,'Fire_emis> infile was ' + infile
    print,'Fire_emis> End Procedure in   '+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
    junk = check_math() ;This clears the math errors
    print, ' This run was done on: ', SYSTIME()
    close,/all   ;make sure ALL files are closed
end

; yk_undo: runner routine, since i am lazy
;pro global_fire_v15_TXprj
;  ;x_global_fire_v15_TXprj, scen=6
;  ;x_global_fire_v15_TXprj, scen=4, infile='short.csv', simid='short'
;  for scen=1,6 do   x_global_fire_v15_TXprj, scen=scen 
;end
