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
;- 
; *********************************************************************************************

pro global_fire_v15NA


close, /all

 t0 = systime(1) ;Procedure start time in seconds

 yearnum= 2012
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
; ****************************************************************************
;   READ IN FUEL LOADING FILE
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
  ; emisin = 'E:\Data2\wildfire\TEXAS\FIRE_2008\MODEL_INPUTS\NEW_EFS_06242013.csv' ; Input file created 06/24/2013 and first used here July 31, 2013
    emisin = 'E:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_Inputs\FINAL_EFS_06202014.csv' ; NEW FILE created and Added on 

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

    outfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\GLOBAL_FINNv15_2014MDT_07092014.txt'

    openw, 6, outfile
     print, 'opened output file: ', outfile
     printf, 6, 'longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'
     form = '(D20.10,",",D20.10,",",(8(I10,",")),2(D20.10,","),17(D25.10,","),F6.3)'
 
    ; Print an output log file
    logfile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OUTPUTS2014\JUNE2014\LOG_GLOBAL_FINNv15_2014MDT_07092014.txt'
    openw, 9, logfile
    print, 'SET UP OUTPUT FILES'
;***************************************************************************************

; ****************************************************************************
; FIRE AND LAND COVER INPUT FILE
;   (this file should be created within ArcGIS)
; ****************************************************************************

  infile = 'E:\Data2\wildfire\MODIS\DOWNLOADS_JUNE2014\DOWNLOADS_JUNE092014\CreateInfiles\INPUTFILES\INPUT_2014MDT_06272014.csv' 
  
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)
    		print, 'Finished reading input file'

; FIELDS IN INPUT FILE
; 2013 Fire Input (created 12/10/2013)
;1  2 3 4        5         6    7      8        9        10        11  12  13   14   15   16 
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2002
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2003
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2004
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2005
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2006
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2007
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2008
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2009
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2010
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2011
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2012
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
;2013
;ID,X,Y,LATITUDE,LONGITUDE,SCAN,TRACK,ACQ_DATE,ACQ_TIME,CONFIDENCE,GLC,LCT,TREE,HERB,BARE,Region_num
        lat1 = map.field04
        lon1 = map.field05
        spix1 = map.field06
        tpix1 = map.field07 ; TRACK, added on 02.23.2009
        date1 = map.field08
        time1 = map.field09 ; Added 02.24.2009
        CONF = map.field10    ; ADDED 08/25/08
        tree1 = map.field13*1.0
        herb1 = map.field14*1.0
        bare1 = map.field15*1.0
        lct1 = map.field12 
        globreg1 = map.field16
        glc1 = map.field11 ; Added June 20, 2014


       


; Total Number of fires input in original input file
      numorig = n_elements(globreg1)
      
; First, get rid of all fires with confidence less than 20%
; Added on 02.23.2009
; ***EDIT % CONFIDENCE!!!! 
		goodfires= where(conf gt 20)
		ngoodfires = n_elements(goodfires)
		
Print, 'The total number of fires in is: ', numorig
print, 'The total number of fires with confidence > 20: ', ngoodfires
percentremov = (numorig - ngoodfires)/numorig
Print, 'The percent removed for conf < 20 = ', percentremov*100, '%'
		nconfgt20 = n_elements(goodfires) ; For log file at the end
		lat2 =lat1(goodfires)
		lon2 = lon1(goodfires)
		date2 = date1(goodfires)
		spix2 = spix1(goodfires)
		tpix2 = tpix1(goodfires)
		tree2 = tree1(goodfires)
		herb2 = herb1(goodfires)
		bare2 = bare1(goodfires)
		lct2 = lct1(goodfires)
		globreg2 = globreg1(goodfires)
		time2 = time1(goodfires)
		glc2 = glc1(goodfires)


       print, 'Finished Reading Input file'
; Added 08/25/08: removed values of -9999 from VCF inputs
	misstree = where(tree2 lt 0)
	if misstree[0] ge 0 then tree2(misstree) = 0.0
	missherb = where(herb2 lt 0)
	if missherb[0] ge 0 then herb2(missherb) = 0.0
	missbare = where(bare2 lt 0)
	if missbare[0] ge 0 then bare2(missbare) = 0.0

; Calculate the total cover from the VCF product
        totcov = tree2+herb2+bare2
        missvcf = where(totcov lt 98.)
  	    if missvcf[0] eq -1 then nummissvcf =0 else nummissvcf = n_elements(missvcf)

; ***************************************************************************************
; JULIAN DATE: Calculate the julian day for the fire detections
       numfire1 = ngoodfires
       jd2 = intarr(numfire1)
       
;!!!!!!!!!!! EDIT THIS SECTION FOR THE CORRECT DATE FORMAT!!!

; For dates with the format: 3/1/2007
;for i = 0L,numfire1-1 do begin
;         parts =  strsplit(date2[i],'/',/extract)
;         day = fix(parts[1])
;         month = fix(parts[0])
; 

; For Dates with the format:  2013-02-01
For i = 0L,numfire1-1 do begin
    parts =  strsplit(date2[i],'-',/extract) ; ***** EDIT FOR DATE FORMAT!! ********
    day = fix(parts[2])
    month = fix(parts[1])

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
  endfor
  print, 'Finished calculating Julian Dates'
; *******************************************************************************************************************
; OCTOBER 16, 2009: For Tropics, where satellite coverage isn't daily, spread fires over 48 hours (starting at 24Z)
;    from 30N to 30S; using advice fom Jay's code
;    Create duplicates of the fires for 2-day periods in this region. If there are overlaps- then these will be removed in
;    the next section. 
;    Changed the names of arrays above (added '2' to the end of them above- so that I can use the original names here)

; Identify Tropics: 
 tropics = where(lat2 gt -30. and lat2 lt 30.)

if tropics[0] eq -1 then begin   ; Added this section on Dec. 11, 2009 for regions not in the tropics. 
  lat=[lat2]
  lon=[lon2]
  spix=[spix2]
  tpix=[tpix2]
  tree=[tree2]
  herb=[herb2]
  bare=[bare2]
  lct=[lct2]
  globreg=[globreg2]
  time=[time2]
  jd = [jd2]
  glc = [glc2]
  factortrop = fltarr(numfire1)
  factortrop[*]= 1.0
  goto, skiptropics 
endif  
 
 numadd = 0
 numadd = n_elements(tropics)
 printf, 9, 'The original number of fires is: ', numfire1
 printf, 9, 'The number of fires added (because in tropics) is:', numadd
 
 newfires = numfire1+numadd ; add the additional fires to the 
 ; Set up a factor to multiply emissions in the doubled tropical fires. 
 factortrop1 = fltarr(numfire1) ; this is for the multiplication of the duplicate fires in tropics. NOV. 25, 2009
 factortrop2 = fltarr(numadd)
 factortrop1[*] = 1.0
 
; Create new arrays with only the data from the tropics
    lat3 =lat2(tropics)
    lon3 = lon2(tropics)
    spix3 = spix2(tropics)
    tpix3 = tpix2(tropics)
    tree3 = tree2(tropics)
    herb3 = herb2(tropics)
    bare3 = bare2(tropics)
    lct3 = lct2(tropics)
    globreg3 = globreg2(tropics)
    time3 = time2(tropics)
    totcov2=totcov(tropics)
    glc3 = glc2(tropics)
    jd3=intarr(numadd)
    
; Set the day of the new file to the jd+1 (include the next day...)
for i = 0L,numadd-1 do begin
  jd3[i]=jd2[tropics[i]]+1 ; corrected this on NOVEMBER 20, 2009
  factortrop2[i] =FAC ; Set up the factor to apply to the secondary tropical fires 
endfor

; Put the new files together into single arrays
  lat=[lat2,lat3]
  lon=[lon2,lon3]
  spix=[spix2,spix3]
  tpix=[tpix2,tpix3]
  tree=[tree2,tree3]
  herb=[herb2,herb3]
  bare=[bare2,bare3]
  lct=[lct2,lct3]
  globreg=[globreg2,globreg3]
  time=[time2,time3]
  jd = [jd2,jd3]
  totcov=[totcov,totcov2]
  factortrop = [factortrop1,factortrop2]  
  glc = [glc1,glc2]
  
  ngoodfires = n_elements(jd)
  print, 'finished doubling up the tropics'
  print, 'the new number of fires = ', ngoodfires
  printf, 9, 'the new number of fires = ', ngoodfires
  
skiptropics: ; Added 12/11/2009
    
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

; ****************************************************************************************
; ADDED JAY's code on 02.23.2009
; *********************************************************************
; JAY'S CODE FORE REMOVING DOUBLE DETECTIONS
;	added to fire emissions model v4.pro in November 2008
; 	Copied into this global model 02.23.2009 and edited accordingly
 	print, "Removing overlapping detections"

;  FROM JAY'S CODE (11/03/2008)
  scale = 2.0 ; Point Response Function: scale effective pixel size
; 
; First, set up flag array for each fire. Those that are overlaps will be assigned a value
; 	of -999 to be removed/skipped later on. Initially set to 1
	flag = intarr(ngoodfires)
	flag[*] = 1

; 	Set up parameters
		rearthkm=6371.
		dtor=!pi/180.
		earinc=23.5

	; Sort, to consider detects in order of largest to smallest pixel size
	; Uncommented this section on 01/18/2010
;		 areasav = tpix * spix ; this is in km2 (size of pixel)
;		 index21 = sort(areasav) ; tested sorting by this on 02.20.2009- but not needed.
	   areasav = tpix * spix ; this is in km2 (size of pixel)
     index21 = reverse(sort(areasav)) ; EDITED on 03/14/2012 (from 02/10/2012) to have the fires go from largest to smallest
	  ; Sort by size of pixel
	  	datesav=jd[index21] ; UTC day/time (02.24.2009)
  		latsav=lat[index21]
  		lonsav=lon[index21]
  		crosstracksav=tpix[index21]
  		alongtracksav=spix[index21]
  		lat=lat[index21]
      lon=lon[index21]
      spix=spix[index21]
      tpix=tpix[index21]
      tree=tree[index21]
      herb=herb[index21]
      bare=bare[index21]
      lct=lct[index21]
      globreg=globreg[index21]
      time=time[index21]
      jd=jd[index21]
      totcov = totcov[index21]
      factortrop = factortrop[index21]
      glc = glc[index21]

  ; reproject center of pixel
    xearth = fltarr(ngoodfires)
		yearth = fltarr(ngoodfires)
      	xearth=rearthkm*lonsav*dtor*cos(latsav*dtor)
      	yearth=rearthkm*latsav*dtor


  ; Loop over days. For each day, determine if a fire has any multiple detects, Flag multiple detects
	for m=1,ntotdays do begin ; do over each day of the year
		  	today = where(datesav eq m) ; pick out all fires that occur on selected julian day
		  	if today[0] eq -1 then goto, skipfire1 ; skip this day if no fires on that day
		  	 numfirestoday = n_elements(today)
		  	 
  			; Loop over all fires for that day
  			for n=0L,numfirestoday-1 do begin
  			;	print, 'n=,', n
  					if flag[today[n]] eq -999 then goto, skipfire2 ;skip fires already flagged on that day

     				;Crude accounting for Point Response Function: scale effective pixel size
    				crosstrack=crosstracksav[today[n]]*scale
    				alongtrack=alongtracksav[today[n]]*scale


    			; calculate lower and upper bounds of pixel for overlap
			      	  dxdump = xearth[today[n]]+0.5*crosstrack
            		dydump = yearth[today[n]]+0.5*alongtrack
            		dxdumm = xearth[today[n]]-0.5*crosstrack
            		dydumm = yearth[today[n]]-0.5*alongtrack

					; find any other fires that fall within these bounds
					overlap = where(yearth[today] ge  dydumm and yearth[today] le dydump and xearth[today] ge dxdumm and xearth[today] le dxdump)
					if overlap[0] lt 0 then goto, skipfire1 ; something wrong? should at least overlap fire being looked at
					notsamefire = where(overlap gt n)
          			if notsamefire[0] gt -1 then flag[today[overlap[notsamefire]]] = -999 ; don't go back and reset earlier flag to -999
			skipfire2:
  			endfor ;End of loop over detects n for select day
		skipfire1:
	endfor		; End loop over days

print, 'Finished calculating overlapping fires'
    t1 = systime(1)-t0
    print,'Time done in'+ $
       strtrim(string(fix(t1)/60,t1 mod 60, $
       format='(i3,1h:,i2.2)'),2)+'.'
    junk = check_math() ;This clears the math errors
    print, ' This run was done on: ', SYSTIME()

; Sort fires in order of JD
    index2=sort(jd)
    lat=lat[index2]
    lon=lon[index2]
    spix=spix[index2]
    tpix=tpix[index2]
    tree=tree[index2]
    herb=herb[index2]
    bare=bare[index2]
    lct=lct[index2]
    globreg=globreg[index2]
    time=time[index2]
    jd=jd[index2]
    totcov = totcov[index2]
    factortrop = factortrop[index2]
    flag = flag[index2]
    glc = glc[index2]


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
; REMOVAL (1)
; ADDING THE REMOVAL OF OVERLAPPING FIRES (02.23.2009)
; OVERLAPS:  don't calculate fires that have been flagged in the overlap process
	if flag[j] eq -999 then begin
		overlapct = overlapct + 1
		goto, skipfire
	endif

; 1a) Skip any fires in Antarctica
       if globreg[j] eq 0 then begin
       ;  printf, 9, 'Fire number:',j,' removed. Globveg = 0 (antarctica/coastline)'
          antarc = antarc+1
          goto, skipfire
        endif

; GLC Classes (JUNE 20, 2014)
; 1, Artificial Surfaces
;2, Cropland
;3, Grassland
;4, Tree Covered Areas
;5, Shrubs Covered Areas
;6, Herbaceous vegetation, aquatic or regularly flooded
;7, Mangroves
;8, Sparse vegetation
;9, Baresoil
;10, Snow and glaciers
;11, Waterbodies


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
;    6 = temperate evergreen forest : ADDED on JUNE 20, 2014


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
       if lat[j] ge -30 and lat[j] le 30 then genveg = 3 else genveg = 4
    endif
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
;    6 = temperate evergreen needleleaf forests (added 06/20/2014)
;    

; ####################################################
; Estimate Area burned (km2) using the VCF product
; ####################################################
; 10/19/2009: Per Jay's code (Soja pers. comm), Assume fires in grass/savannah are smaller, use 0.75km2 (Soja pers comm
     if genveg eq 1 or genveg eq 9 then area = 0.75 else area = 1.0 ; Units = km2
;        area = 1.0 ; Units = km2
; Adjust this to fraction of the pixel that is not bare
        area= area*((100.-bare[j])/100.)
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
    if genveg eq 9 then begin
      ; JUNE 20, 2014 -- FIX
      ; Set all fuel loadings in croplands to 1200.
      ; (Average value of fuel loadings from Akagi et al. 2011)
            bmass1= 1200.       
    ;For Brazil from Elliott Campbell, 06/14/2010
      if (lon[j] le -47.323 and lon[j] ge -49.156) and (lat[j] le -20.356 and lat[j] ge -22.708) then begin
            bmass1= 1100. 
      endif
    endif
    if genveg eq 1 then bmass1 = grfuel[reg]
    if genveg eq 2 then bmass1 = wsfuel[reg]
    if genveg eq 3 then bmass1 = tffuel[reg]
    if genveg eq 4 or genveg eq 6 then bmass1 = tefuel[reg] ; Added in new genveg eq 6 here (06/20/2014)
    if genveg eq 5 then bmass1 = bffuel[reg]
    if genveg eq 0 then begin
       printf, 9, 'Fire number:',j,' removed. Something is WRONG with generic vegetation. genveg = 0'
       genveg0 = genveg0 + 1
       goto, skipfire
    endif
    
    ; DEC. 09, 2009: Added correction 
    ; Assign boreal forests in Southern Asia the biomass density of the temperate forest for the region
    if genveg eq 5 and globreg[j] eq 11 then bmass1 = tefuel[reg]
    
    if bmass1 eq -1 then begin
        printf, 9, 'Fire number:',j,' removed. bmass assigned -1! 
        printf, 9, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        print, 'Fire number:',j,' removed. bmass assigned -1!
        print, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        bmass0 = bmass0+1
       goto, skipfire
    endif
 
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
    coarsebm = bmass1
    herbbm = grfuel[reg]

if genveg eq 9 then herbbm = 1200.


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

;if lon[j] eq -70.094 then STOP

; ####################################################
; Assign Emission Factors based on Generic land cover
; ####################################################
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
    if genveg eq 6 then index = 14 ; Added this on 06/20/2014 to account for temperate evergreen forests
    
; ####################################################
; Calculate Emissions
; ####################################################
; Emissions = area*BE*BMASS*EF
    ; Convert units to consistent units
     area = area*1.0e6 ; convert km2 --> m2
     bmass = bmass/1000. ; convert g dm/m2 to kg dm/m2

; Calculate emissions (kg)
; CALCULATE EMISSIONS kg/day
; NOV. 25, 2009: Added the multiplication of the factor for the tropics. Assigned ealier in the code, 
;     where the tropics are doubled. 
       CO2 = CO2EF[index]*area*bmass/1000.*(factortrop[j])
       CO = COEF[index]*area*bmass/1000.*(factortrop[j])
       CH4 = CH4EF[index]*area*bmass/1000.*(factortrop[j])
       NMHC = NMHCEF[index]*area*bmass/1000.*(factortrop[j])
       NMOC = NMOCEF[index]*area*bmass/1000.*(factortrop[j])
       H2 = H2EF[index]*area*bmass/1000.*(factortrop[j])
       NOX = NOXEF[index]*area*bmass/1000.*(factortrop[j])
       NO = NOEF[index]*area*bmass/1000.*(factortrop[j])
       NO2 = NO2EF[index]*area*bmass/1000.*(factortrop[j])
       SO2 = SO2EF[index]*area*bmass/1000.*(factortrop[j])
       PM25 = PM25EF[index]*area*bmass/1000.*(factortrop[j])
       TPM = TPMEF[index]*area*bmass/1000.*(factortrop[j])
       TPC = TCEF[index]*area*bmass/1000.*(factortrop[j])
       OC = OCEF[index]*area*bmass/1000.*(factortrop[j])
       BC = BCEF[index]*area*bmass/1000.*(factortrop[j])
       NH3 = NH3EF[index]*area*bmass/1000.*(factortrop[j])
       PM10 = PM10EF[index]*area*bmass/1000.*(factortrop[j])
;	   bmass = bmass*BE ; changed this on 04/08/2009, so actual biomass burned is output; commented on 04/09/2009

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
; NEW PRINT STATEMENT 10/20/2009
; 'longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC'
printf,6,format = form, lon[j],lat[j],jd[j],time[j],lct[j],genveg,globreg[j],tree[j],herb[j], $
       bare[j],area,bmass,CO2,CO,CH4,H2,NOX,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,Factortrop[j]


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
printf, 9, 'The total number of fires input was:', numorig
printf, 9, 'the total number of fires removed with confience < 20:', numorig-nconfgt20
printf, 9, ''
printf, 9, 'the total number of fires in the tropics was: ', numadd
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