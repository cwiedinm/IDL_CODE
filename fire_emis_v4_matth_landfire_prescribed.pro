 ; *********************************************************
 ; This program then calculates the fire emissions for
 ; North America for 2002
 ;
 ; Created by originally Christine, 05/13/03

 ; SEPTEMBER 15, 2004: Edited to only bring in 1 file  (that contain all points for 1 year)
 ;  The point data has been supplied by Brad Quayle at USFS.
 ;  In that table is also the underlying GLC code, LCT code, % tree, Herbaceous, and bare coverage
 ;  The emissions here are determined purely by these input Data
 ;  NO fuels information or FEPs algorithms will be used here!
 ;  All emissions factors, fuel loadings etc. wil be read in from outside files.
 ;  NOTHING is to be hardwired, if possible
 ; NOVEMBER 22-24, 2004: Edited by Christine to work with 2004 data
 ;  Edits are noted within the code; THIS VERSION DOES NOT INCLUDE FEPS CALCULATIONS!
 ; December 9, 2004; Edited code to include speciated VOC based on Louisa's code for MOZART
 ; December 13, 2004:
 ;      Am putting the speciated VOC eimssions in the Gabyfile.pro (since they are only scale factors
 ; March 02, 2005:
 ;    Editing fire module to include area-specific emissions factors (i.e. for Alaska)
 ;      NOT DONE YET
 ; April 6, 2005
 ;      edited emission factor table (for PM2.5) based on Chris Geron's Comments to the manuscript
 ; April 12, 2005: Edited to take care of GLC = -9999, VCF = 253, etc based on evaluation (see EXCEL sheet
 ;      in the folder with Brad's new data
 ;  checked output and all seems to be calculating properly
 ; July 26, 2005: This version was edited (from Version 5.9) to calculate the emissions for the U.S.
 ;  using the NFDRS data (reprocessed by Angie this week).
 ; August 24, 2005: Edited code for NFDRS
 ;   waiting on Canadian fuel loadings
 ; August 25, 2005: Still working on code to incorporate FCCS, Canadian Fuels, and NOAA MODIS fuels
 ;  Created input files in GIS: All shape files are in D:\Christine\WORK\wildfire\EPA_EI\ANGIE\July05\
 ; Sepetmber 1, 2005: redid the fuel loadings for the GLC class... now have total fuel loadings (ave., high and low)
 ;         have user chose which loads to run
 ;      fraction of hervaceous and woody fuels are the average of the values for the approproate class from the FCCS
 ;   *** Note: until today, the NFDRS fuel loads were too high by a factor of 10. This is corrected
 ;   *** Note: Today, changed the Fuel loadings and emission factors for the GLC classes
 ; September 2, 2005:
 ;      - redid the emission factors for the GLC classes (i.e. PM10 > PM2.5, changed CO2 EF for forest)
 ;      - rerun model with extension 090205 for drought and no drought scenario
 ;      - added extension for output files... so that it's consistent.
 ; September 6, 2005: Edited fuel loadings for temperate forests and rerun model
 ; September 14, 2005: Edited code to include calculations with FCCS Fuels
 ; September 15, 2005: Edited code to include calculations with MODIS-derived fuels (from XYZ, NOAA)
 ;       NOAA Fuels joined to model input files on 09/09/2005 by Christine
 ;       - results using NOAA FUELS are a factor of 100 low (biomass burned way too low)
 ;       - correcting how? Units were incorrect... fixed this in code
 ; May 10, 2006: runnig for he 2005 fire points that Brad just sent to me. Not running the inputs
 ;      with any other fuel loadings except the glc stuff;
 ; June 8, 2006: running the 2006 points that Brad sent to me, merged with the
 ;  reclassed VCF NA_ae4 rasters
 ; July 25, 2006: reran the 2006 data for Jerome (wasn't sure what was done on June 8 2006)
 ;   edited to do glc calculations only
 ; September 07, 2006: running the 2006 data downloaded from the RSAC for the Year to date
 ;   ***NOTE!!: Changed default glc type from grasslands to either forest, shrub or grass
 ;      depending on the tree cover
 ; September 22, 2006: Running with the RSAC downloads up through today (for project with
 ;      Schimel and Jason Neff
 ; October 02, 2006: running again with RSAC downloads up through today (for project
 ;      with Schimel and Neff). Note, changing output file name...
 ; January 11, 2007: Edited code to include HCN emissions (from Yokelson and others)
 ; January 23, 2007: Updated HCN Emission Factors and added CH3CN
 ; January 24, 2007: Updated with Hg Emission Factors from Hans
 ; April 04, 2007: Updated with new Hg Emissions from Hans. Have low, ave., and high emission factors
 ;  (finished editing 04/05/2007. Now have a choice of which Hg Emission factors to use
 ;  and it assigns the forested ecosystems at latitudes > 50N a boreal EF)
 ; MAy 08, 2007: on April 04, 2007, the fuel loading was set to the HIGH fuel loadings. So, all estimates in April were
 ; 		too high. I reset this to 1 today.
 ;		renamed the version to Fire_emisv2.pro
 ;		removed a lot of the comments to clean up code.
 ; September 10, 2007: Renamed this code Fire_emis_MC
 ; 			This is for year 2006, reprocessed the input file today
 ;			Fuel load set to ave; Hg emission factor set to AVE
 ; September 17, 2007: for fires in MC region (lat 19-20, long -98 - -100), new NOx, NH3, HCN EFs assigned to forests
 ; 		Fires with Confidence < 20 were removed
 ; October 26, 2007: Renamed this code v3 (version 3). Redid this to run for the week of ContUS fires (for the
 ; 		big CA fires). Edited code in several places for the input file (julday calculation, pathways and files,
 ; 		got rid of the confidence part (see above) b/c input file didn't include confidence.
 ; Feb. 07, 2008: Edited code to run the 2007 fire emissions for Gabi Pfister. INcluded the removal of fires
 ; 		with confidence < 20. Corrected for julian day/time
 ; 		edited order on input variables
 ; Sept. 05, 2008: Edited to rerun emissions for 2002-2006 for Bob Yokelson
 ;
 ; NOVEMBER 03, 2008: UPDATED TO VERSION 4.0 (really version 2.0 in release)
 ; 		- processing 1 year at a time
 ; 		- need to include Time Zone in input file
 ; 		- ADDED FRP to input/output files
 ; 		- Calculate day for LOCAL TIME Julian Day (edited code to automatically calculate new JD)
 ; 		- For this version, don't cut out any SPIX values
 ; 		- remove all fires with confidence < 20
 ; 		- Got rid of overlapping fires by identifying them (flag) and then skipping in emission calculation
 ; 		- Updated the emission factor file (12/03/2008) - not finalized, however
 ; 		- Allowed a field in the input file for federal land code (txt)
 ; December 08-09, 2008: reran emissions for 2002-2007 using this code. Beta version... fixed bugs in overlap detections
 ; DECEMBER 09, 2008: renamed this code to fire_emis_v4_RX.pro
 ;		- not editing this code for the sensitivities associated with RX burning instead of wildfires
 ; 		- only using the WESTERN US (to reduce processing time?)
 ; 		- chanegd the EF input files to reflect different EFs
 ; DECEMBER 10.2008- found a big bug where I was calculating index versus index2: corrected and rerun all
 ; 		- this code is now the default emissions code, but will only do the western U.S. (for 2008 AGU)
 ; FEBRUARY 04, 2009: This code is edited to do prescribed burning in the Western US with the landfire classes
 ; February 17, 2009: Continued editing code to do simulations for rx burning
 ; April 22, 2009: New runs for the redone fire emissions input files (which now have ALL of the LANDFIRE classes in them)
 ; 		- updated the emission factor file to NEW_GLC_EFs_02_23_2009.csv
 ; 		- edited the Combustion Efficiency assignment section based on the confirmed LANDFIRE classes from Matt on 04/22/2009
 ;APRIL 24, 2009:
 ; 		- Checked the calculations by hand- look OK (hoever, found a mistake in the 2008 input files and had to remake)
 ; 		- Running all years with and without Rx burning
 ;JUNE 02, 2009:
 ; 		- Outputs from this code in April did not include New Mexico because of the way in which the states were read in
 ; 			need to rerun so that New Mexico is included in the output.
 ; 		- Reran all years and put new output into D:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\
 ; 			all new output the same as those ran on April 24, 2009 except now New Mexico is in output.
 ; 		- Created a new 2008 input file (from the stuff made on May 14, 2009. Edited code- this new 2008 input file
 ; 			is similar to other years now. RAN new 2008 file.
 ;
 ; ******************************************************************************************************************

 pro Fire_Emis_v4_MattH_landfire_prescribed

 close, /all

 t0 = systime(1) ;Procedure start time in seconds
 ext = ' '
 year = ' '

; **************************************************************************************
; !!!! USER NEEDS TO EDIT HERE !!!!! (APRIL 22, 2009)
; USER interface questions to define run
 ;read, 'What year are you processing?', year
  year = '2008'
 ext='2008_RX'	;
 prevyear=year-1
 rxburn = 1 ; this is a flag to turn Rx burning on/off
 			; if this is 1, then Rx burning turned ON
 			; if this is 0, then default (Rx burn turned OFF)
;**************************************************************************************
; GET INPUT AND OUTPUT FILES
; **User Instructions: User must set pathways of the input and output files
;
; Input file path
	pathy = 'D:\Data2\wildfire\

; DECLARE INPUT FILE NAME
    ; infile = 'D:\Data2\wildfire\MODEL_INPUTS\REG_APR2009\GLC_TREE_HERB_BARE_ADMIN_TZ_FED_LANDFIRE_2007b.txt'; File run on April 22, 2009 (first as test)
	  infile = 'D:\Data2\wildfire\MODEL_INPUTS\REG_JUN2009\GLC_TREE_HERB_BARE_ADMIN_TZ_FED_LANDFIRE_2008.txt' ; Ran on June 02, 2009
    ; infile = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\CHECK\2006185_modelinputs_CAonly.csv'
    ; infile = 'C:\WORK\FIRE\Fire_EMIS_122008\INPUT_FILES\Fire_input_file_2002.txt'
; ******************************************************************
; **************************************************************************************
;                  OUTPUT FILES
; ******************************************************************
; OUTPUT file pathway

    path2 = 'D:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\MATTH_WESTUS\JUN02_2009\' ; changed output June 02, 2009

; PATH for test outputs...
;	path2 = 'D:\Data2\wildfire\AGU2008\MODEL_OUTPUT\CHECK\modelout\'
; Path for laptop
;	path2 = 'C:\WORK\FIRE\Fire_EMIS_122008\MODEL_OUTPUT\'
; Set up output file (comma delimited text file)

     outfile = 'FIREEMIS_'+ext+'.txt'
     openw, 6, path2+outfile
     print, 'opened ', path2+outfile
;                1   2    3   4    5       6     7        8        9     10   11   12   13  14  15   16   17 18  19  20  21   22  23   24  25    26    27
     printf, 6, 'j,longi,lat,day,LANDFIRE,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state,FED'
;            1       2          3          4-9          10-12            13-24        25-27
    form = '(I10,",",D20.10,",",D20.10,",",(6(I15,",")),3(D20.10,","),12(D25.10,","),3(A25,","))'

; Set up a file to check outputs
    checkfile = 'check_'+year+'_'+ext+'.txt'
    openw, 8, path2+checkfile
    printf, 8, 'j, GLCCode, tree, herb, bare, totcov, area, herbbm, coarsebm, Bmass'
    form2 = '(5(I5,","),5(D20.10,","))'
; Set up log file
    logfile = 'log_'+year+'_'+ext+'.txt'
    openw, 9, path2+logfile
; ****************************************************************************************
; Default files: emission factors, fuel loadings, etc.
; ****************************************************************************************
; What fuel loads do you want to use? (ave = 1, low = 2, high = 3):
       loadnum = 1 ; made this standard on April 04, 2007!!
       				; WRONG. On April 04, 2007, this was the high value (3)!
    			 	; changed this back to 1 on May 08, 2007... need to rerun.
;***************************************************************************************
     path4 = 'D:\Data2\wildfire\EPA_EI\MODEL\default_infiles\Orig_files\DEfault\'
; PATH for LAPTOP
;	path4 = 'C:\WORK\FIRE\Fire_EMIS_122008\default_infiles\Orig_files\DEfault\'
; FULE LOAD: Input Fuel loading files
    ; GLC fuel loadings: SIMPLE DEFAULT
      ; *************************
        ; NEW FUEL LOADS, SEPTEMBER 1, 2005, The loads have units kg/m2
           glcfuelload = path4+'New_glc_Fuel_loads2.csv'

;**** NEW EMISSION FACTOR FILES for APRIL 2007, including ranges of Hg EFs ****
;    if Hglev eq 1 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_AVE.csv' ; Average Hg EF
;    if Hglev eq 2 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_MIN.csv' ; MIN Hg EF
;    if Hglev eq 3 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_MAX.csv' ; MIN Hg EF

; NEW EMISSION FACTORS December 03, 3008
; This file contains some updates in the CO2 and CO emission factors based on
; 	new table from Andi Andreae and Urbanski chapter
; 	also includes average Hg emission factors
; 	did not change other compounds, since they were similar to previous values
; 	and were not significantly different. Will update again before this version is finalized
	 	glcfactor = path4+'NEW_GLC_EFs_02_23_2009.csv' ; updated this file on April 22, 2009
; EDITED THE RX1.csv file on Dec. 10 to impact almost all land cover types; rerunning.
	;glcfactor = 'D:\Data2\wildfire\AGU2008\RX1.csv' ; RX1 emission factors.

; Read in fuel load for GLC
        inload3=ascii_template(glcfuelload)
        glcfuelload=read_ascii(glcfuelload, template=inload3)
       ; Field1 = GLC code
       ; Field2 = Total Load (average values)
       ; Field3 = Total Load (low values)
       ; Field4 = Total Load (high Values)
       ; Field5 = woody fraction
       ; Field6 = herbaceous fraction

; Select the average, low, or high fuel load for the GLC case
; (Based on user selection at the beginning of the program)
       if loadnum eq 1 then glcload = glcfuelload.field2
       if loadnum eq 2 then glcload = glcfuelload.field3
       if loadnum eq 3 then glcload = glcfuelload.field4

; Read in GLC emission factors
        inload4 = ascii_template(glcfactor)
        glc_ef = read_ascii(glcfactor, template=inload4)
         ; Field01 = GLC Code
         ; Field02 = CO2
         ; Field03 = CO
         ; Field04 = PM10
         ; Field05 = PM2.5
         ; Field06 = NOx
         ; Field07 = NH3
         ; Field08 = SO2
         ; Field09 = VOC
         ; Field10 = CH4
         ; Field11 = HCN
         ; Field12 = CH3CN
         ; Field13 = Hg

; DECEMBER 09, 2008: READ in WESTERN STATES list
;	weststatesfile = 'C:\WORK\FIRE\Fire_EMIS_122008\default_infiles\western_states.csv'
	weststatesfile = 'D:\Data2\wildfire\EPA_EI\MODEL\default_infiles\western_states.csv' ; for PC
	inload5 = ascii_template(weststatesfile)
	weststates = read_ascii(weststatesfile, template = inload5)
	western = weststates.field1
	print, 'WESTERN STATES:', western
;***************************************************************************************
; FROM JAY'S CODE (11/03/2008)
	scale = 2.0 ; Point Response Function: scale effective pixel size
; ****************************************************************************************

; Select what level of Hg Emission factors you want to use... (NEW 04/05/07)
; and Write here the boreal forest Hg Emission Factor (new 04/04/07)
; read, 'What Hg EF do you want to use (ave = 1, low = 2, high = 3):', Hglev
Hglev = 1 ; chose average Hg emission factors
    if Hglev eq 1 then  begin
        hgname = 'HgAVE'
        borforHg = 0.000315 ; Average value EF for boreal forests(g Hg/kg fuel burnt)
    endif
    if Hglev eq 2 then begin
        hgname = 'HgMIN'
        borforHg = 0.000142 ; Minimum value EF for boreal forests ** FIXED on April 25, 2007
    endif
    if Hglev eq 3 then begin
        hgname = 'HgMAX'
        borforHg = 0.000488 ; Maximum value EF for boreal forests
    endif

; ****************************************************************************
; ****************************************************************************
;   READING IN ALL OF THE INPUT FILES
; ****************************************************************************
; ****************************************************************************
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        ntotfires = n_elements(map.field01)
		print, 'Finished reading input file'
; ********************************************************************************
; SET UP ARRAYS and COUNTERS
; *************************************************************************************
; CONFIDENCE is field 09 for years 2001-2007, it's field08 for Year 2008
; 2008 file (June 02, 2009) (Date has format 1/31/2008)
; 1    2     3    4    5     6    7   8    9        10   11       12       13      14        15        16   17    18
; LAT,LONG,SPIX,TPIX,DATE_,JDATE,UTC,FRP,CONFIDENCE,GLC,PCTTREE,PCTHERB,PCTBARE,ADMIN_NAME,CNTRY_NAME,ZONE,AGBUR,LANDFIRE,
;
; 2001-2007 File (April 22, 2009)
;    1        2       3     4   5     6     7   8     9        10   11     12       13      14         15        16   17      18
; WGS84LAT,WGS84LONG,SPIX,TPIX,DATE_,JDATE,UTC,FRP,CONFIDENCE,GLC,PCTTREE,PCTHERB,PCTBARE,ADMIN_NAME,CNTRY_NAME,ZONE,AGBUR,LANDFIRE,

		conf= map.field09 ; As of June 02, 2009- this field is the same for all input files

; REMOVE ALL FIRES WITH CONFIDENCE < 20
	okconf = where(conf gt 20)
	ngoodfires = n_elements(okconf)
	jd = intarr(ngoodfires)
	jd2 = intarr(ngoodfires)

if year eq '2008' then begin
; FOR YEAR 2008:
; 2008 file (June 02, 2009)
; 1    2     3    4    5     6    7   8    9        10   11       12       13      14        15        16   17    18
; LAT,LONG,SPIX,TPIX,DATE_,JDATE,UTC,FRP,CONFIDENCE,GLC,PCTTREE,PCTHERB,PCTBARE,ADMIN_NAME,CNTRY_NAME,ZONE,AGBUR,LANDFIRE,
	lat = map.field01[okconf]
    lon = map.field02[okconf]
	spix = map.field03[okconf]
	TPIX = map.field04[okconf]	; Added on Nov. 03, 2008 for the inclusion of Jay's code
    FRP = map.field08[okconf]			; ADDED on Nov. 03, 2008 for inclusion of new fire counts
    date2 = map.field05[okconf]			; This is text date (e.g., 12/24/2007)
    time = map.field07[okconf]		; UTC time
	conf = map.field09[okconf]
	glc = map.field10[okconf]
 	bare = map.field13[okconf]*1.0
	herb = map.field12[okconf]*1.0
    tree = map.field11[okconf]*1.0
    zone = map.field16[okconf]
    state = map.field14[okconf]
	cntry = map.field15[okconf]
	fed = map.field17[okconf]
	landfire = map.field18[okconf]
	julian = map.field06[okconf] ; added this for year 2008 only

endif else begin
; FOR YEARS 2001-2007:
; 2001-2007 File (April 22, 2009)
;    1        2       3     4   5     6     7   8     9        10   11     12       13      14         15        16   17      18
; WGS84LAT,WGS84LONG,SPIX,TPIX,DATE_,JDATE,UTC,FRP,CONFIDENCE,GLC,PCTTREE,PCTHERB,PCTBARE,ADMIN_NAME,CNTRY_NAME,ZONE,AGBUR,LANDFIRE,
	lat = map.field01[okconf]
    lon = map.field02[okconf]
	spix = map.field03[okconf]
	TPIX = map.field04[okconf]	; Added on Nov. 03, 2008 for the inclusion of Jay's code
    FRP = map.field08[okconf]			; ADDED on Nov. 03, 2008 for inclusion of new fire counts
    date2 = map.field05[okconf]			; This is text date (e.g., 12/24/2007)
    time = map.field07[okconf]		; UTC time
	conf = map.field09[okconf]
	glc = map.field10[okconf]
 	bare = map.field13[okconf]*1.0
	herb = map.field12[okconf]*1.0
    tree = map.field11[okconf]*1.0
    zone = map.field16[okconf]
    state = map.field14[okconf]
	cntry = map.field15[okconf]
	fed = map.field17[okconf]
	landfire = map.field18[okconf]  ; added this on 02.04.2009; this is either -9999 or the
									; code for a forest type of interest
endelse

; *****************************************************************************************
; Calculate Julian Day for Local Time
; 	array "jd" has the original Julian Dates from file
; 	array "jd2' has the corrected Julian Dates (based on the local time)
; JUNE 02, 2009: COMMENTED THIS SECTION OUT
; 		2008 input file now has the same format as the other years
;if year eq '2008' then begin
;	for j =0L,ngoodfires-1 do begin
;		  jd2[j]=julian[j]
;		; Correct for the GMT of the overpass
;			localtime = time[j]+(zone[j]*100)
;			if localtime lt 0 then jd2[j] = jd2[j]-1
;	endfor
;	goto, nextstep
;endif
	for j =0L,ngoodfires-1 do begin
		; Calculate JD for each fire (This is new, September 17, 2007)
		; Edited to auto calculate prevyear 11/03/2008
			sdum= date2[j]
			parts = strsplit(sdum,'/',/extract)
			jd[j] = Julday(parts[0],parts[1],parts[2]) - Julday(12,31,prevyear)
			jd2[j]=jd[j]
		; Correct for the GMT of the overpass
			localtime = time[j]+(zone[j]*100)
			if localtime lt 0 then jd2[j] = jd2[j]-1
	endfor
; *********************************************************************
; JAY'S CODE FORE REMOVING DOUBLE DETECTIONS
;	added November 2008
nextstep:
print, "Removing overlapping detections"

; First, set up flag array for each fire. Those that are overlaps will be assigned a value
; 	of -999 to be removed/skipped later on. Initially set to 1
	flag = intarr(ngoodfires)
	flag[*] = 1

; 	Set up parameters
		rearthkm=6371.
		dtor=!pi/180.
		earinc=23.5

	; Sort, to consider detects in order of largest to smallest pixel size
		areasav = TPIX * SPIX ; this is in km2 (size of pixel)
		; 12/08/2008 try sorting by date
		; index = sort(jd2)
		; Sort arrays
		datesav=jd2;(index) ; do local time day
  		latsav=lat;(index)
  		lonsav=lon;(index)
  		crosstracksav=TPIX;(index)
  		alongtracksav=SPIX;(index)

  ; reproject center of pixel
		xearth = fltarr(ngoodfires)
		yearth = fltarr(ngoodfires)
      	xearth=rearthkm*lonsav*dtor*cos(latsav*dtor)
      	yearth=rearthkm*latsav*dtor



  ; Loop over days. For each day, determine if a fire has any multiple detects, Flag multiple detects
	for m=1,365 do begin ; do over each day of the year
		  	today = where(datesav eq m) ; pick out all fires that occur on selected julian day
		  	if today[0] eq -1 then goto, skipfire1 ; skip this day if no fires on that day
		  	numfirestoday = n_elements(today)
			;print, 'numfirestoday = ', numfirestoday

  			; Loop over all fires for that day
  			for n=0L,numfirestoday-1 do begin
  				;print, 'n=,', n
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

; ***************************************************************************************************
; SET UP COUNTERS
	; Calculate the total cover from the VCF product
    	totcov = tree+herb+bare
    	missvcf = where(totcov lt 98.)
    	nummissvcf = n_elements(missvcf)

	; Set up Counters
		;   These are identifying how many fires are in urban areas, or have unidentified VCF or GLC
		;   values --> purely for statistics and quality assurance purposes
        	vcflt50 = 0L
        	vcflt1 = 0L
        	vcfgt150 = 0L
        	vcfcount = 0L
        	urbcount = 0L
        	glccount = 0L
        	allbare = 0L
        	watercount = 0L
        	skip = 0L	; total number of skipped fires
       		allherb = 0L
        	allbare2 = 0L
        	allbare3 = 0L
        	spixct = 0L	; Count of fires removed for SPIX > 2.5. Second QA done
        	overlapct = 0L ; count of all overlapping fires that are removed
; *****************************************************************************************************
; START LOOP OVER FIRE PIXELS and CALCULATE EMISSIONS
print, 'Calculating Emissions'


for j = 0L,ngoodfires-1 do begin
; DECEMBER 09, 2008: ONLY PROCESS WESTERN STATES
	west = where(state[j] eq western)
	if west[0] eq -1 then goto, skipfire

; OVERLAPS:  don't calculate fires that have been flagged in the overlap process
; Added 12/01/2008
	if flag[j] eq -999 then begin
		printf, 9, 'Fire number:',j,' removed because of overlap'
		overlapct = overlapct + 1
		goto, skipfire
	endif

; -------CORRECTIONS-----------
; QA #2
; GET RID OF POINTS WHERE SPIX ISN'T CORRECT (TOO STRETCHED!)
; 12/01/2008 COMMENTED OUT
;    if spix[j] gt 2.5 then begin
;       printf, 9, 'Fire number:',j,' removed. SPIX = ', spix[j]
;       spixct = spixct+1
;       skip = skip+1
;       goto, skipfire
;    endif

; Determine if data are there weird values assigned to the VCF or GLC products

; VCF product
    barecount = where(bare eq 100.)
    allbare = n_elements(barecount)

; If no cover (0 or VCF = -9999) is assigned to the cell, SKIP FIRE!
   if totcov[j] lt 1. then begin
       vcflt1 = vcflt1 + 1
       printf,9, 'j=', j, '  Cell has no VCF cover!! skipping fire at j = ', j
       skip = skip+1
       goto, skipfire
   endif

; Fourth,if fire pixel VCF assigned water or unknown (253),
;   AND GLC = -9999 or water, then false detect and SKIP FIRE
    if (totcov[j] eq 759. and glc[j] eq -9999) then begin
        printf,9, 'j=', j, '  Cell has VCF = 253 AND GLC = -9999!! skipping fire at j = ', j
       skip = skip+1
       goto, skipfire
    endif
   if (totcov[j] eq 759. and glc[j] eq 24) then begin
        printf,9, 'j=', j, '  Cell has VCF = 253 AND GLC = 24!! skipping fire at j = ', j
        skip = skip+1
        goto, skipfire
   endif

; First see if this is just a GIS processing error:
; SCALE THE VCF PRODUCT TO SUM TO 100
    if totcov[j] gt 101. and totcov[j] lt 200. then begin
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

; Now, after the fire VCF values have been scaled to total 100: if the fire
;    still has 100% bare cover, SKIP the FIRE
    if bare[j] eq 100. then begin
        printf,9, 'j=', j, '  Cell has 100% bare!! skipping fire at j = ', j
        allbare2 = allbare2+1
        skip = skip+1
        goto, skipfire
    endif

; If the fire pixel STILL has VCF = 253, but a GLC value other than unknown or water,
;    ASSUME 100% herbaceous for lack of something better
    if (totcov[j] eq 759) then begin
        printf,9, 'j=', j, '  Cell has VCF = 253 AND GLC is, ', glc[j], '  Assuming 100% herbaceous at j = ', j
        allherb = allherb + 1
        herb[j] = 100.
        bare[j] = 0.
        tree[j] = 0.
        totcov[j] = bare[j] +herb[j] + tree[j]
    endif

;; GLC Product; where GLC eq unknown (-9999 or 0) and already removed the ones with water/unknown from VCF
;   Assume grasslands - most are on coastlines
; NOTE: 09/07/06: changed the default land cover type to be dependent on
;    the percent tree cover at the grid
    if glc[j] eq -9999 or glc[j] eq -999 or glc[j] eq 0 then begin
       glccount = glccount+1
       if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
       if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
       if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
    endif

; ***************************************************************************************************
; CALCULATE BURNED AREA
    ; DEFAULT FIRE AREA
    ; INITIAL RUNS: SET DEFAULT MAXIMUM AND MINIMUM AREA BURNED
       ; Maximum
       ; print, "MAXIMUM AREA SET TO 1 km2'
        area = 1.0 ; Units = km2

;     ; this is fraction of the pixel that is not bare
        area= area*((100.-bare[j])/100.)

; *************************** FUEL TYPES & LOADINGS ***************************************************

; The variable p is a multiplier used to cut own emissions in urban and built up areas.
; Currently, don't assume any cut in the emissions.
       p = 1.0
; Determine the biomass of the land cover classification

; First- determine if water or unknown
       If (glc[j] eq 24) or (glc[j] eq 26) then begin
           printf, 9, 'j=', j, '  The GLC for this cell is WATER, SNOW/ICE or unknown'
                ;Is there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.02) AND lat lt (lat[j]+0.02))
                 samelon = where(lon gt (lon[j]-0.02) AND lon lt (lon[j]+0.02))
                 locnear = where(samelat eq samelon)

                 if locnear[0] gt -1 then begin   ; NOTE - only looking at first point nearby... should change in the future, 12/05/2008
                    if (glc[samelat[locnear[0]]] ne 24) AND (glc[samelat[locnear[0]]] ne 26) AND (glc[samelat[locnear[0]]] ne -9999) then begin ; edited this on Dec. 05, 2008;
                        	glc[j] = glc[samelat[locnear[0]]]
                        	printf, 9, 'Got a value from a nearby cell. Glc[j] =', glc[j], 'at j = ', j
                        	watercount = watercount+1
                        	if glc[j] eq -9999 or glc[j] eq 0 then goto, whatever1
                        	goto, outwater
                    endif
                 endif
                 whatever1:
                 printf,9, '  All nearby cells have GLC = water, unkonwn, etc.. Assume GLC = F(tree) (forest, shrub or grasslands)'
              	; 09/07/06 Changed default GLC assignment here
           			if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
               		if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
                 	if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
                 	watercount = watercount+1
                 	goto, outwater
        endif
        outwater:
;print, 'd'
; Next- determine if land cover is urban/built-up. If so- assign land cover of nearby vegetation (1/3 biomass)
         If glc[j] eq 22 then begin
                printf, 9, 'j=', j, '  Urban Cell! GLC Value = 22.'
                ; Is there a fire nearby from which we could use the land cover type?
                 samelat = where(lat gt (lat[j]-0.02) AND lat lt (lat[j]+0.02))
                 samelon = where(lon gt (lon[j]-0.02) AND lon lt (lon[j]+0.02))
                 locnear = where(samelat eq samelon)

                 if locnear[0] gt -1 then begin
                    if (glc[samelat[locnear[0]]] ne 22) AND (glc[samelat[locnear[0]]] ne -9999) then begin
                        glc[j] = glc[samelat[locnear[0]]]
                        if (glc[j] eq -9999) or (glc[j] eq 24) or (glc[j] eq 26) then goto, whatever
                        urbcount = urbcount+1
                        printf, 9, '   Got a replacement for the Urban cell. glc[j] =', glc[j]
                        goto, outurb
                    endif
                 endif
           	whatever:
            printf,9, '     no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
          		; 09/07/06 Changed default GLC assignment here
          		 if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
                 if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
                 if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
                 urbcount = urbcount+1
                 goto, outurb
         endif
         outurb:
  ; Last check on this! as of 09/16/05, GLC = 24 showing up 0 in emissions output
  ; ADded more possibilities on 12/05/2008 (22, 0)
          if (glc[j] eq 24) or (glc[j] eq -9999) or (glc[j] eq 26) or (glc[j] eq -999)  or (glc[j] eq 0) or (glc[j] eq 22) then begin
             ; 09/07/06 Changed default GLC assignment here
           		if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
                if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
                if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
          endif

       ; get fuel loading for the fire glc
         index2 = where(glcfuelload.field1 eq glc[j])


; *********************************************************************************************
; ****************************TYPE 1 CALCULATIONS ******************************************
; **** based onIto and Penner, 2004 ********************************************************
; ASSIGN CF VALUES (Combustion Factors)
; 02/17/2009: Edited this section to account for landfire classes
; and determine prescribed burn emissions or not.
; Edited this section on 04/23/2009. Reading in all LANDFIRE classes.
;
; (1) ASSIGN ALL the DEFAULT Comustion Efficiencies
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

;(2) If RX BURN IS TURNED ON
	; PRESCRIBED BURN- edit the combustion efficiencies of the identified LANDFIRE classes
	if 	rxburn eq 1 then begin ; THIS IS RX BURN
		;(B1) Identify only the LANDFIRE CLASSES that we are going to alter the emissions
		 if landfire[j] eq 2018 or landfire[j] eq 2021 or landfire[j] eq 2022 or landfire[j] eq 2026 or landfire[j] eq 2027 or $
		    landfire[j] eq 2028 or landfire[j] eq 2030 or landfire[j] eq 2031 or landfire[j] eq 2045 or landfire[j] eq 2051 or $
		    landfire[j] eq 2053 or landfire[j] eq 2054 or landfire[j] eq 2060 or landfire[j] eq 2061 or landfire[j] eq 2117 or $
		    landfire[j] eq 2166 or landfire[j] eq 2179 or landfire[j] eq 2227 or landfire[j] eq 2231 then begin ; these are the landfire classes confrimed on 04/22/2009

					CF1 = 0.0 ; no woody fuel is burned in any Rx Burn

				; ASSIGN FUEL COMBUSTION by LANDFIRE CLASS
				; (i) grand fir, doug fir, lodgepole, pipo
						if landfire[j] eq 2018 or landfire[j] eq 2166 then CF3 = 0.56
				; (ii) mixed conifer
						if 	landfire[j] eq 2021 or landfire[j] eq 2022 or landfire[j] eq 2026 or landfire[j] eq 2027 or $
							landfire[j] eq 2028 or landfire[j] eq 2030 or landfire[j] eq 2045 or landfire[j] eq 2061 or $
							landfire[j] eq 2231 then CF3 = 0.52
				; (iii) ponderosa/jeffrey
						if landfire[j] eq 2031 or landfire[j] eq 2053 or landfire[j] eq 2054 or landfire[j] eq 2060 or $
							landfire[j] eq 2117 or landfire[j] eq 2179 then CF3 = 0.52
				; (iv) white fir, pipo
						if landfire[j] eq 2051 then CF3 = 0.39
				; (v)  doug fir, pipo
						if landfire[j] eq 2227 then CF3 = 0.54
		endif
	endif ; end of Rx Burn CF assignments

; *******************************************************************************************
; Calculate the Mass burned of each classification (herbaceous, woody, and forest)
; These are in units of kg dry matter/m2
; Bmass is the total burned biomass
; Mherb is the Herbaceous biomass burned
; Mtree is the Woody biomass burned

    pctherb = herb[j]/100.
    pcttree = tree[j]/100.
    herbbm = glcload[index2]*glcfuelload.field6[index2]
    coarsebm = glcload[index2]*glcfuelload.field5[index2]

; NOT INCLUDING STUMP WOOD RIGHT NOW
; Bmass = biomass burned in fire

;  Grasslands
if tree[j] le 40 then begin
    Bmass = (pctherb*herbbm*CF3)+(pcttree*herbbm*CF3)
    ; Assumed here that litter biomass = herbaceous biomass and that the percent tree
    ;   in a grassland cell contributes to fire fuels... CHECK THIS!!!
    ; Assuming here that the duff and little around trees burn
endif

; Woodlands
if (tree[j] gt 40) and (tree[j] le 60) then begin
       Bmass = (pctherb*herbbm*CF3) + (pcttree*(herbbm*CF3+coarsebm*CF1))
endif

; Forests
if tree[j] gt 60 then begin
       Bmass = (pctherb*herbbm*CF3) + (pcttree*(herbbm*CF3+coarsebm*CF1))
endif

; *********************************************************************************************
; *************** CALCULATE EMISSIONS ********************************************************
; *********************************************************************************************
; NOTE: for simplicity case- 1 emission factor per GLC class (First run), biomass of herbaceous and woody
;    parts combined for total biomass of the pixel
; Emissions are in units of kg day-1
          ; CO2 Emissions
              emisco2 = area*1e6*(Bmass)*glc_ef.field02[index2]*p/1000.
          ; CO Emissions
              emisco = area*1e6*(Bmass)*glc_ef.field03[index2]*p/1000.
          ; PM10 Emissions
              emispm10 = area*1e6*(Bmass)*glc_ef.field04[index2]*p/1000.
          ; PM2.5 Emissions
              emispm25 = area*1e6*(Bmass)*glc_ef.field05[index2]*p/1000.
          ; SO2 Emissions
              emisso2 = area*1e6*(Bmass)*glc_ef.field08[index2]*p/1000.
          ; VOC Emissions
              emisvoc = area*1e6*(Bmass)*glc_ef.field09[index2]*p/1000.
          ; CH4 Emissions
               emisch4=area*1e6*(Bmass)*glc_ef.field10[index2]*p/1000.
          ; CH3CN Emissions
               emisch3cn=area*1e6*(Bmass)*glc_ef.field12[index2]*p/1000.
; N EMISSIONS
; September 17, 2007: Edited this section, so that if the fire is located within the valley and
; the vegetation is forested, the replaced the N emissions with those from Yoeklson et al.
; ACPD, 2007 ACPD, 7, pp 6687-6718, "Mexico City Area mountain Fires"
if (lat[j] ge 19. and lat[j] le 20. and lon[j] ge -100. and lon[j] le -98.) and ((glc[j] ge 1 and glc[j] le 8) OR glc[j] eq 20 or glc[j] eq 29) then begin
          ; NOx Emissions
              emisnox = area*1e6*(Bmass)*7.44*p/1000.
          ; NH3 Emissions
              emisnh3 = area*1e6*(Bmass)*0.91*p/1000.
         ; HCN Emissions
               emishcn=area*1e6*(Bmass)*1.02*p/1000.
endif else begin
          ; NOx Emissions
              emisnox = area*1e6*(Bmass)*glc_ef.field06[index2]*p/1000.
          ; NH3 Emissions
              emisnh3 = area*1e6*(Bmass)*glc_ef.field07[index2]*p/1000.
          ; HCN Emissions
              emishcn=area*1e6*(Bmass)*glc_ef.field11[index2]*p/1000.
endelse

; Hg Emissions
; Wrote this section about Hg Emisisons on 04/04/2007
; so that at higher latitudes, forests are assigned the Hg emisison
; factor for boreal forests (not temperate forests)
    if lat[j] gt 50. then begin ; determine if fires are at latitudes > 50N
       if glc[j] ge 1 and glc[j] le 8 or glc[j] eq 20 then begin ; determine if fires are in forested GLC
         emishg=area*1e6*(Bmass)*borforHg*p/1000.
       endif else begin
         emishg=area*1e6*(Bmass)*glc_ef.field13[index2]*p/1000.
       endelse
    endif
    if lat[j] le 50 then begin
        emishg=area*1e6*(Bmass)*glc_ef.field13[index2]*p/1000.
    endif
;
;
; PRINT RESULTS TO OUTPUT FILE
;printf, 6, 'j,longi,lat,day,LANDFIRE,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state, FED'
;
 ;form = '(I8,",",D20.10,",",D20.10,",",(6(I15,",")),3(D20.10,","),12(D25.10,","),3(A25,","))'
;print, 'print1'
            printf,6,format=form,j,lon[j],lat[j],jd2[j],landfire[j],glc[j],tree[j],herb[j],bare[j],frp[j],area,bmass, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,emisch4,emishcn, $
               emisch3cn,emishg,cntry[j],state[j], fed[j]
;print, 'print2'
            printf, 8, format=form2,j,glc[j],tree[j],herb[j],bare[j],totcov[j],area,herbbm, coarsebm, Bmass

skipfire:

endfor ; END LOOP OVER THE FIRES FOR THE DAY (j loop)
; END PROGRAM

quitearly:
printf, 9, ' '
printf, 9, ' '
printf, 9, ' '
printf, 9, '**********************************************************'
printf, 9, 'SUMMARY OF RESULTS AND PROCESSING'
printf, 9, '**********************************************************'
printf, 9, ' '
printf, 9, ' This run was done on: ', SYSTIME()
if loadnum eq 1 then printf, 9, ' MIDDLE GLC Fuel Loads'
if loadnum eq 2 then printf, 9, ' LOW GLC Fuel Loads'
if loadnum eq 3 then printf, 9, ' HIGH GLC Fuel Loads'
printf, 9 , 'Input file = :', infile
printf, 9, 'The total number of fires processed were: ', ngoodfires
printf, 9, 'The total number of fires skipped were: ', skip
printf, 9, 'The total number of fires skipped because of overlaps were:', overlapct
; Edited out 10/26/2007
printf, 9, 'The total number of fires with confidence < 20: ', ntotfires-ngoodfires
printf, 9, 'The number of fires with SPIX gt 2.5 and removed were: ', spixct
printf, 9, ' '
printf, 9, 'VCF STATS'
printf, 9, 'The number of fire with scaled VCF product were:', vcfcount
printf, 9, 'The number of files where the VCF summed to less than 95 was:', nummissvcf
printf, 9, 'The total number of fires in areas that were 100% bare were:', allbare
printf, 9, 'The total number of fires in areas that were 100% bare (and were not scaled) were:', allbare2
printf, 9, 'The total number of fires in areas with totcov gt 200 were:', vcfgt150
printf, 9, 'The total number of fires in ares with totcov lt 50 and gt 1 were:', vcflt50
printf, 9, 'The total number of fires with total coverage lt 1 = ', vcflt1
printf, 9, ' '
printf, 9, 'GLC STATS'
printf, 9, 'The number of fires with no GLC value were: ', glccount
printf, 9, 'The total number of fires within urban or other landscapes were:', urbcount
printf, 9, 'The total number of fires in water or snow were:', watercount
printf, 9, 'The number of fires with VCF = 253 And GLC ne -9999 or 24 was: ', allherb


t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'
junk = check_math() ;This clears the math errors
print, ' This run was done on: ', SYSTIME()
close,/all   ;make sure ALL files are closed
end
