 ; *********************************************************
 ;
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
 ; August 31, 2007:
 ;  ******************************************************************************************************************

 pro Fire_Emisv2

 close, /all

 t0 = systime(1) ;Procedure start time in seconds
 ext = ' '
 year = ' '

; **************************************************************************************
; USER interface questions to define run
 read, 'What year are you processing?', year
 ext = 'MAY082007'
; What fuel loads do you want to use? (ave = 1, low = 2, high = 3):
       loadnum = 1 ; made this standard on April 04, 2007!!
       				; WRONG. On April 04, 2007, this was the high value (3)!
    			 	; changed this back to 1 on May 08, 2007... need to rerun.
;****************************
; Select what level of Hg Emission factors you want to use... (NEW 04/05/07)
; and Write here the boreal forest Hg Emission Factor (new 04/04/07)
; read, 'What Hg EF do you want to use (ave = 1, low = 2, high = 3):', Hglev
Hglev = 3
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
; **************************************************************************************


;**************************************************************************************
; GET INPUT AND OUTPUT FILES
; **User Instructions: User must set pathways of the input and output files
;
; BELOW are the ANNUAL input files...
; ** Make sure we change the fields assigned to variables below (based on header information
;    I am including here for each file)
pathy = 'D:\Data2\wildfire\
; 2006 MODIS FIRE INPUTS
;   Header:
;   WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,HERB,TREE,ADMIN_NAME,CNTRY_NAME,
;
 ; 	TYPICALLY- use this file...
;     infile = pathy+'EPA_EI\Brad_files\2006_RSCA_01102007\MODIS_na_2006_modelin.txt' ; emission calculation 01/12/2007 (including HCN)
; CHEKING OLDER INPUT FILE FOR 2006 from 10/02/2006 (ran on MAy 04. 2007)
	;infile = 'D:\Data2\wildfire\EPA_EI\Brad_files\2006_RSAC_10022006\RSAC_100206_no2.txt'
	;LAT,LONG,JULIAN,SPIX,ID,GLC,BARE,HERB,TREE,STATE_NAME,COuntry,
;
; 2005 MODIS FIRE INPUTS
;   Header:
;   WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,HERB,TREE,COUNTRY,STATE,
;  infile = pathy+'EPA_EI\Brad_files\2005_detections\new01292007\Modelin_2005_Firedetects_Feb2007.txt'
;
; 2004 MODIS FIRE INPUTS
;   Header:
;   WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,HERB,TREE,NFDRS_US,NFDRS_CAN,FCCS,NOAA_L1,NOAA_L2,NOAA_L3,NOAA_L4,NOAA_L5,NOAA_L6,NOAA_L7,CNTRY_NAME,STATE_NAME,
;   infile = pathy+'EPA_EI\ANGIE\July05\Modelin\Modelin_2004_alldata.txt'
;
; 2003 MODIS FIRE INPUTS
;   Header:
;   WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,HERB,TREE,NFDRS_US,NFDRS_CAN,FCCS,NOAA_L1,NOAA_L2,NOAA_L3,NOAA_L4,NOAA_L5,NOAA_L6,NOAA_L7,CNTRY_NAME,STATE_NAME,
;    infile = pathy+'EPA_EI\ANGIE\July05\Modelin\Modelin_2003_alldata.txt'
;
; 2002 MODIS FIRE INPUTS
;   Header: (changed the tree and herb 01/29/2007 - but still named incorrectly in input file)
;   WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,TREE,HERB,NFRDS_US,NFRDS_CAN,FCCS,NOAA_L1,NOAA_L2,NOAA_L3,NOAA_L4,NOAA_L5,NOAA_L6,NOAA_L7,CNTRY_NAME,STATE_NAME,
    infile = pathy+'EPA_EI\ANGIE\July05\Modelin\Modelin_2002_alldata.txt'
; ******************************************************************
;                  OUTPUT FILES
; ******************************************************************
; OUTPUT file pathway

    path2 = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\Output_MAY07\'

; Set up output file (comma delimited text file)

     outfile = 'Modelout_'+year+'_GLC_'+ext+'_'+hgname+'.txt'
     openw, 6, path2+outfile
     print, 'opened ', path2+outfile
     printf, 6, 'j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state'
;
    form = '(I8,",",D20.10,",",D20.10,",",(6(I15,",")),2(D20.10,","),12(D25.10,","),2(A25,","))'

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

    path4 = 'D:\Data2\wildfire\EPA_EI\MODEL\default_infiles\Orig_files\DEfault\'

; Input Fuel loading files
    ; GLC fuel loadings: SIMPLE DEFAULT
      ; *************************
        ; NEW FUEL LOADS, SEPTEMBER 1, 2005, The loads have units kg/m2
           glcfuelload = path4+'New_glc_Fuel_loads2.csv'

    ;**** NEW EMISSION FACTOR FILES for APRIL 2007, including ranges of Hg EFs ****
    if Hglev eq 1 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_AVE.csv' ; Average Hg EF
    if Hglev eq 2 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_MIN.csv' ; MIN Hg EF
    if Hglev eq 3 then glcfactor = path4+'New_glc_EFs_APR2007_Hg_MAX.csv' ; MIN Hg EF

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
        nfires = n_elements(map.field01)

; SET UP ARRAYS - These are for 2006
;WGS84LAT,WGS84LONG,SPIX,JULIAN,ID,GLC,BARE,HERB,TREE,ADMIN_NAME,CNTRY_NAME,
if year eq 2006 then begin
    lat = map.field01
    lon = map.field02
    day = map.field04
    spix = map.field03
    glc = map.field06
    id = map.field05
    tree = map.field09*1.0
    herb = map.field08*1.0
    bare = map.field07*1.0
    cntry = map.field11
    state = map.field10
endif

;USED for checking 2006 input file from 10/02/2006
	;LAT,LONG,JULIAN,SPIX,ID,GLC,BARE,HERB,TREE,STATE_NAME,COuntry,
;if year eq 2006 then begin
;    lat = map.field01
;    lon = map.field02
;    day = map.field03
;    spix = map.field04
;    glc = map.field06
;    id = map.field05
;    tree = map.field09*1.0
;    herb = map.field08*1.0
;    bare = map.field07*1.0
;    cntry = map.field11
;    state = map.field10
;endif

if year eq 2005 then begin
    lat = map.field01
    lon = map.field02
    day = map.field04
    spix = map.field03
    glc = map.field06
    id = map.field05
    tree = map.field09*1.0
    herb = map.field08*1.0
    bare = map.field07*1.0
    cntry = map.field10
    state = map.field11
endif
; SET UP ARRAYS - these are for 2002
if year eq 2002 then begin
    lat = map.field01
    lon = map.field02
    day = map.field04
    spix = map.field03
    glc = map.field06
    id = map.field05
    tree = map.field08*1.0
    herb = map.field09*1.0
    bare = map.field07*1.0
    cntry = map.field20
    state = map.field21
endif

; SET UP ARRAYS - these are for 2003-5
if (year ge 2003) and (year le 2004) then begin
    lat = map.field01
    lon = map.field02
    day = map.field04
    spix = map.field03
    glc = map.field06
    id = map.field05
    tree = map.field09*1.0
    herb = map.field08*1.0
    bare = map.field07*1.0
    cntry = map.field20
    state = map.field21
endif

print, 'Finished reading input files'

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
        skip = 0L
        allherb = 0L
        allbare2 = 0L
        allbare3 = 0L
        spixct = 0L
; *********************************************************************
; ***********************************************************************
; START LOOP OVER FIRE PIXELS
print, 'Calculating Emissions'

 for j =0L,nfires-1 do begin
;
; GET RID OF POINTS WHERE SPIX ISN'T CORRECT (TOO STRETCHED!)
    if spix[j] gt 2.5 then begin
       printf, 9, 'Fire number:',j,' removed. SPIX = ', spix[j]
       spixct = spixct+1
       goto, skipfire
    endif

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

; ******************************* FUEL MOISTURE ******************************
; MOISTURE CONTENT OF FUELS
       ; Detemine the moisture contnent
       ; 0 = Very Dry, 1 = Dry, 2 = Moderate, 3 = Moist, 4 = Wet, 5 = Very Wet
       ; Ultimately, will have a file to read in fuel moisture
       ; For now, assume Very dry (0)
         moist = 0

;*********************************************************************************************

;CALCULATE BURNED AREA
    ; DEFAULT FIRE AREA

    ; INITIAL RUNS: SET DEFAULT MAXIMUM AND MINIMUM AREA BURNED
    ; DEFAULT AREAS
       ; Minimum
       ; print, 'MINIUMUM AREA SET TO 0.1 km2'
;      area = 0.1
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
                 if locnear[0] gt -1 then begin
                    if (locnear[0] ne 24) AND (locnear[0] ne 26) AND (locnear[0] ne -9999) then begin
                        glc[j] = glc[locnear[0]]
                        printf, 9, '     Got a value from a nearby cell. Glc[j] =', glc[j]
                        watercount = watercount+1
                        if glc[j] eq -9999 then goto, whatever1
                        goto, outwater
                    endif
                 endif
                 whatever1:
                 printf,9, '     All nearby cells have GLC = water, unkonwn, etc.. Assume GLC = F(tree) (forest, shrub or grasslands)'
              ; 09/07/06 Changed default GLC assignment here
           if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
                if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
                 if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
                 watercount = watercount+1
                 goto, outwater
        endif
        outwater:

; Next- determine if land cover is urban/built-up. If so- assign land cover of nearby vegetation (1/3 biomass)
         If glc[j] eq 22 then begin
                printf, 9, 'j=', j, '  Urban Cell! GLC Value = 22.'
                ; Is there a fire nearby from which we could use the land cover type?
                 samelat = where(lat gt (lat[j]-0.02) AND lat lt (lat[j]+0.02))
                 samelon = where(lon gt (lon[j]-0.02) AND lon lt (lon[j]+0.02))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if (locnear[0] ne 22) AND (locnear[0] ne -9999) then begin
                        glc[j] = glc[locnear[0]]
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
          if (glc[j] eq 24) or (glc[j] eq -9999) or (glc[j] eq 26) or (glc[j] eq -999) then begin
             ; 09/07/06 Changed default GLC assignment here
           if tree[j] gt 60 then glc[j] = 6 ; Assign mixed forest
                if tree[j] gt 40 and tree[j] le 60 then glc[j] = 12 ; Mixed shrubland
                 if tree[j] le 40 then glc[j] = 13 ; Set GLC to grasslands
         endif

       ; get fuel loading for the fire glc
         index = where(glcfuelload.field1 eq glc[j])


; Input from Ito and Penner (2004) paper
; ASSIGN RSF (fraction of large wood that is burned as a result of smoldering combusition
        RSF =1.0
; ASSIGN TFF (tree Felled Factor)
        TFF = 1.0

; *********************************************************************************************
; ****************************TYPE 1 CALCULATIONS ******************************************
; **** based onIto and Penner, 2004 ********************************************************

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
    herbbm = glcload[index]*glcfuelload.field6[index]
    coarsebm = glcload[index]*glcfuelload.field5[index]

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
              emisco2 = area*1e6*(Bmass)*glc_ef.field02[index]*p/1000.
          ; CO Emissions
              emisco = area*1e6*(Bmass)*glc_ef.field03[index]*p/1000.
          ; PM10 Emissions
              emispm10 = area*1e6*(Bmass)*glc_ef.field04[index]*p/1000.
          ; PM2.5 Emissions
              emispm25 = area*1e6*(Bmass)*glc_ef.field05[index]*p/1000.
          ; NOx Emissions
              emisnox = area*1e6*(Bmass)*glc_ef.field06[index]*p/1000.
          ; NH3 Emissions
              emisnh3 = area*1e6*(Bmass)*glc_ef.field07[index]*p/1000.
          ; SO2 Emissions
              emisso2 = area*1e6*(Bmass)*glc_ef.field08[index]*p/1000.
          ; VOC Emissions
              emisvoc = area*1e6*(Bmass)*glc_ef.field09[index]*p/1000.
          ; CH4 Emissions
               emisch4=area*1e6*(Bmass)*glc_ef.field10[index]*p/1000.
          ; HCN Emissions
               emishcn=area*1e6*(Bmass)*glc_ef.field11[index]*p/1000.
          ; CH3CN Emissions
               emisch3cn=area*1e6*(Bmass)*glc_ef.field12[index]*p/1000.
        ; Hg Emissions
; Wrote this section about Hg Emisisons on 04/04/2007
; so that at higher latitudes, forests are assigned the Hg emisison
; factor for boreal forests (not temperate forests)
    if lat[j] gt 50. then begin ; determine if fires are at latitudes > 50N
       if glc[j] ge 1 and glc[j] le 8 or glc[j] eq 20 then begin ; determine if fires are in forested GLC
         emishg=area*1e6*(Bmass)*borforHg*p/1000.
       endif else begin
         emishg=area*1e6*(Bmass)*glc_ef.field13[index]*p/1000.
       endelse
    endif
    if lat[j] le 50 then begin
        emishg=area*1e6*(Bmass)*glc_ef.field13[index]*p/1000.
    endif
;
;
; PRINT RESULTS TO OUTPUT FILE
            printf,6,format=form,j,lon[j],lat[j],day[j],glc[j],id[j],tree[j],herb[j],bare[j],area,bmass, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,emisch4,emishcn, $
               emisch3cn,emishg,cntry[j],state[j]
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
printf, 9, 'The total number of fires processed were: ', nfires
printf, 9, 'The total number of fires skipped were: ', skip
printf, 9, 'The number of fires with SPIX gt 2.5 and removed were: ', spixct
printf, 9, ' '
;printf, 9, 'The total number of fires in the NFDRS was: ', countus1
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
