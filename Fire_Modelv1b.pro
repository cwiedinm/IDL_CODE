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
 ;       - correcting how? UNits were incorrect... fixed this in code
 ; May 10, 2006: runnig for he 2005 fire points that Brad just sent to me. Not running the inputs
 ;      with any other fuel loadings except the glc stuff;
 ; June 8, 2006: running the 2006 points that Brad sent to me, merged with the
 ;  reclassed VCF NA_ae4 rasters
 ; July 25, 2006: reran the 2006 data for Jerome (wasn't sure what was done on June 8 2006)
 ;   edited to do glc calculations only
 ; July 31, 2006: edited code to run with new files that have fire area included
 ;      running GLC/North American model only (no FCCS or MODIS fuels)
 ; *****************************************************************************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds
 ext = ' '
 year = ' '

; **************************************************************************************
; USER interface questions to define run
 read, 'What year are you processing?', year
 read, "What extension do you want to use with the output files (chose JD)?", ext
; Have User chose which fuel loads to use in calculations (for sensitivity)
 read, "What fuel loads do you want to use? (ave = 1, low = 2, high = 3):", loadnum

; **************************************************************************************


;**************************************************************************************
; GET INPUT AND OUTPUT FILES
; **User Instructions: User must set pathways of the input and output files
; INPUT file pathway
    ;path = 'C:\WORK\wildfire\EPA_EI\MODEL\test_090204\'
    ;path = '/zeus/christin/FIRE/MODEL/'
     ;path='D:\Christine\WORK\wildfire\EPA_EI\ANGIE\July05\Modelin\'
     ;path = 'D:\Christine\WORK\wildfire\EPA_EI\Brad_files\2005_detections\new05102006\'
    ;path = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\Output_AUG2005\2003\'
    ; changed 06/08/06
    ;path = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_INPUT\'
    path = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_OUTPUT\Jerome\GIS_FILES\modelinput\' ; path chosen for runs on 07/31/2006
; Input fire files
;    infile = path+'Modelin_July2001.txt'
     ;infile = path+'Modis2005_all.txt'
   ; infile = path+'all_pt2006b.txt'  ; done on 06/08/06
   ; infile = path+'all2006_072506.txt' ; re-created on 07/25/06
    infile = path+'March17_all.csv' ; created this file on July 31, 2006
;

; ****************************************************************************
; ******************************************************************

; ******************************************************************
;                  OUTPUT FILES
; ******************************************************************
; ******************************************************************
; OUTPUT file pathway
    ; This pat set 06/08/2006
    ;path2 = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_OUTPUT\'
    path2 = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_OUTPUT\Jerome\GIS_FILES\modeloutput\' ; set up on July 31, 2006

; Set up output file (comma delimited text file)
     outfile = 'Modelout_'+year+'_GLC_'+ext+'.txt'
     openw, 6, path2+outfile
     print, 'opened ', path2+outfile
     ; Edited print statements on July 31, 2006- to print out only 1 day...
     printf, 6, 'j,longi,lat,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4'
     form = '(I8,",",D20.10,",",D20.10,",",(5(I15,",")),2(D20.10,","),9(D25.10,","))'

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
; DEFAULT files (i.e.,fuels, emission factors, etc.)
    path4 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\default_infiles\'

; Input Fuel loading files
    ; GLC fuel loadings: SIMPLE DEFAULT
      ; *************************
        ; NEW FUEL LOADS, SEPTEMBER 1, 2005, The loads have units kg/m2
        ; WATCH! As of 09/06/05- have different fuel loading inputs
           glcfuelload = path4+'Orig_files\DEfault\New_glc_Fuel_loads2.csv'
; Input GLC emission factors (kg/Mg)
    ; Redid the emission factors on 09/01/05
        glcfactor = path4+'Orig_files\DEfault\New_glc_EFs.csv'    ; Only 1 EF per GLC class

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
        nfires = n_elements(map.field1)

; REdo Fields because now can export information directly from GIS (08/24/05)
; Set up these new fields on July 31, 2006\
; new files are for 1 day (for now) and include area burned
    ; FIELDS IN INPUT FILE
    ; 1. id (= 0 for now)
    ; 2. id2
    ; 3. glc
    ; 4. tree
    ; 5. herb
    ; 6. bare
    ; 7. area
    ; 8. longitude
    ; 9. latitude

; SET UP ARRAYS
    lat = map.field9
    lon = map.field8
    glc = map.field3
    id = map.field2
    tree = map.field4*1.0
    herb = map.field5*1.0
    bare = map.field6*1.0
    areain = map.field7

print, 'Finished reading input file'

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
;    if spix[j] gt 2.5 then begin
;       printf, 9, 'Fire number:',j,' removed. SPIX = ', spix[j]
;       spixct = spixct+1
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
    if glc[j] eq -9999 or glc[j] eq 0 then begin
       glccount = glccount+1
       glc[j] = 13 ; Set GLC to grasslands
    endif

; ********************************************************************
; SCALE AREA
       ; Area has units of m2 (new in code July 31, 2006

;     ; this is fraction of the pixel that is not bare
        area= areain[j]*((100.-bare[j])/100.)
      ; convert units back to km2
        area = area/1000000.

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
                 printf,9, '     All nearby cells have GLC = water, unkonwn, etc.. Assume GLC = 13 (grasslands)'
                 glc[j] = 13
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
                 glc[j] = 13
                 urbcount = urbcount+1
                 goto, outurb
         endif
         outurb:
        ; Last check on this! as of 09/16/05, GLC = 24 showing up 0 in emissions output
           if glc[j] eq 24 then glc[j] = 13
          if glc[j] eq -9999 then glc[j] = 13
          if glc[j] eq 26 then glc[j] = 13

         index = where(glcfuelload.field1 eq glc[j])

; Input from Ito and Penner (2004) paper
; ASSIGN RSF (fraction of large wood that is burned as a result of smoldering combusition
        RSF =1.0
; ASSIGN TFF (tree Felled Factor)
        TFF = 1.0

;*********************************************************************************************
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
; PRINT RESULTS TO OUTPUT FILE
               printf,6,format=form,j,lon[j],lat[j],glc[j],id[j],tree[j],herb[j],bare[j],area,bmass, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,emisch4
            printf, 8, format=form2,j,glc[j],tree[j],herb[j],bare[j],totcov[j],area,herbbm, coarsebm, Bmass

skipfire:
; ***************************************************************************************
;; NOW: CALCULATE EMISSIONS FROM NFDRS
;; only calculate fires with NFDRS fuels associated with them
;  if nfdrs[j] lt 0 then goto, skipfire2
;; Count the number of NFDRS fires
;    countus1 = countus1+1
;
;; Get rid of fires with no information for the fuels
;if nfdrs[j] eq 0 or nfdrs[j] eq 22 or nfdrs[j] eq 23 or nfdrs[j] eq 24 then begin
;    printf, 9, 'The fire number has nfdrs with zero fuel loadings:', j, nfdrs[j]
;    goto, skipfire2
;endif
;
;if nfdrs[j] eq 13 then begin
;    printf, 9, 'Fire is NFDRS agriculture. j = ', j
;    goto, agfire
;endif
;
;; Calculate emissions
;    code = where(nfdrs[j] eq nfdrsfuel.field01)
;; Get fuel loadings of each fuel component and fuel combustion
;    hr1 = nfdrsfuel.field04[code]*nfdrsef.field2[0]
;    hr10 = nfdrsfuel.field05[code]*nfdrsef.field2[1]
;    hr100 = nfdrsfuel.field06[code]*nfdrsef.field2[2]
;    hr1000 = nfdrsfuel.field07[code]*nfdrsef.field2[3]
;    woody = nfdrsfuel.field08[code]*nfdrsef.field2[4]
;    herbac = nfdrsfuel.field09[code]*nfdrsef.field2[5]
;    if droughtnum eq 1 then drought = nfdrsfuel.field10[code]*nfdrsef.field2[6] ; try runs with and without drought
;    if droughtnum eq 2 then drought = 0.
;; Calculate Emissions
;; Emissions have final units of: kg/day
;    emco = area*1000*((hr1*nfdrsef.field3[0])+(hr10*nfdrsef.field3[1])+(hr100*nfdrsef.field3[2])+$
;         (hr1000*nfdrsef.field3[3])+(woody*nfdrsef.field3[4])+ $
;         (herbac*nfdrsef.field3[5])+(drought*nfdrsef.field3[6]))
;    emch4 = area*1000*((hr1*nfdrsef.field4[0])+(hr10*nfdrsef.field4[1])+(hr100*nfdrsef.field4[2])+$
;         (hr1000*nfdrsef.field4[3])+(woody*nfdrsef.field4[4])+ $
;         (herbac*nfdrsef.field4[5])+(drought*nfdrsef.field4[6]))
;    emvoc = area*1000*((hr1*nfdrsef.field5[0])+(hr10*nfdrsef.field5[1])+(hr100*nfdrsef.field5[2])+$
;         (hr1000*nfdrsef.field5[3])+(woody*nfdrsef.field5[4])+ $
;         (herbac*nfdrsef.field5[5])+(drought*nfdrsef.field5[6]))
;    empm25 = area*1000*((hr1*nfdrsef.field6[0])+(hr10*nfdrsef.field6[1])+(hr100*nfdrsef.field6[2])+$
;         (hr1000*nfdrsef.field6[3])+(woody*nfdrsef.field6[4])+ $
;         (herbac*nfdrsef.field6[5])+(drought*nfdrsef.field6[6]))
;    empm10 = area*1000*((hr1*nfdrsef.field7[0])+(hr10*nfdrsef.field7[1])+(hr100*nfdrsef.field7[2])+$
;         (hr1000*nfdrsef.field7[3])+(woody*nfdrsef.field7[4])+ $
;         (herbac*nfdrsef.field7[5])+(drought*nfdrsef.field7[6]))
;    emnox = area*1000*((hr1*nfdrsef.field8[0])+(hr10*nfdrsef.field8[1])+(hr100*nfdrsef.field8[2])+$
;         (hr1000*nfdrsef.field8[3])+(woody*nfdrsef.field8[4])+ $
;         (herbac*nfdrsef.field8[5])+(drought*nfdrsef.field8[6]))
;    emnh3 = area*1000*((hr1*nfdrsef.field9[0])+(hr10*nfdrsef.field9[1])+(hr100*nfdrsef.field9[2])+$
;         (hr1000*nfdrsef.field9[3])+(woody*nfdrsef.field9[4])+ $
;         (herbac*nfdrsef.field9[5])+(drought*nfdrsef.field9[6]))
;    goto, printout
;
;agfire:
;; If it's an NFDRS agriculture area, then just set emissions to use the GLC classifications
;; But - no tress in any ag areas (unlike the GLC part...)
;; Fuel loading for agriculture = 0.49 kg/m2
;    ;emco2 = area*1000.*0.50*1515. ; CO2 Emission Factor = 1515 g/kg
;    emco = area*1000.*0.50*70. ; emission factor = 70 g/kg
;    emch4 = area*1000.*0.50*2.2 ; Emission factor = 2.2 g/kg
;    emvoc = area*1000.*0.50*6.7 ; Emission factor = 6.7 g/kg
;    empm25 = area*1000.*0.5*5.7
;    empm10 = area*1000.*0.5*6.9
;    emnox = area*1000.*0.5*2.4
;    emnh3 = area*1000.*0.5*1.5
;    ;emso2 = area*1000.*0.5*0.35
;goto, printout
;
;; PRINT RESULTS TO OUTPUT FILE
;printout:
;printf,7,format=form3,j,lon[j],lat[j],day[j],glc[j],id[j],nfdrs[j],area,emco,empm10,$
;    empm25,emnox,emnh3,emvoc,emch4,cntry[j],state[j]
;
;
;skipfire2:
; ***************************************************************************
;    END OF NFDRS CALCULATIONS
; ***************************************************************************
;
;
; ****************************************************************************
;; ***************************************************************************
;; CALCULATE EMISSIONS WITH FCCS FUELS FOR CONT. U.S.
;; ***************************************************************************
;; ***************************************************************************
;;
;;
;; only calculate fires with FCCS fuels associated with them
;  if fccs[j] lt 0 then goto, skipfire3
;;; Count the number of FCCS fires
;    countfccs = countfccs+1
;;
;;; Figure out what to do with fires with FCCS  = 0 (urb, ag., or barren)
;;; First- Assume ag fire if barren or urban:
;if fccs[j] eq 0 then begin
;    printf, 9, 'Fire is FCCS urb/ag/barren. j = ', j
;    ; If GLC code for fire is a crop class, calculate ag fire emissions
;    if glc[j] eq 18 or glc[j] eq 19 then goto, agfire2
;    ; Otherwise, skip the fire (if it's not ag)
;    goto, skipfire3
;endif
;;
;;; Calculate emissions for each FCCS Fire
;; Get FCCS Fuel information using ID from input file
;    indexfccs = where(fccsfuel.field01 eq fccs[j])
;;  fccsfuel
;       ; Field1= FCCS ID
;       hr1= fccsfuel.field02[indexfccs]
;       hr10 = fccsfuel.field03[indexfccs]
;       hr100 = fccsfuel.field04[indexfccs]
;       hr1000 = fccsfuel.field05[indexfccs]
;       dufffccs = fccsfuel.field06[indexfccs]
;       hrk10 = fccsfuel.field07[indexfccs]
;       HR10k = fccsfuel.field08[indexfccs]
;       grassfccs = fccsfuel.field09[indexfccs]
;       shrubfccs = fccsfuel.field10[indexfccs]
;       canfccs = fccsfuel.field11[indexfccs]
;; emission factors for FCCS
;       ; Field12 = CO2
;       ; Field 13 = CO
;       ; Field 14 = PM10
;       ; Field15 = PM2.5
;       ; Field16 = NOX
;       ; Field17 = NH3
;       ; Field18 = SO2
;       ; Field19 = VOC
;       ; Field20 = CH4
;
;; AUTOMATIC ASSUMPTIONS: 1st trial (put in Sept. 14, 2005)
;;   FCCS fuels: woody burn 30%; herbaceous (duff, grass, shrub) burn 90%
;; (only 30% of canopy burns)
;;   not distributing by VCF product
;; bmassfccs =  total biomass burned in fccs case
;    bmassfccs = 0.3*(hr1+hr10+hr100+hr1000+canfccs+hrk10+hr10k)+ $
;         0.9*(dufffccs+grassfccs+shrubfccs)
;
;         ; CO2 Emissions
;              emco2a = area*1e6*(Bmassfccs)*fccsfuel.field12[indexfccs]/1000.
;          ; CO Emissions
;              emcoa = area*1e6*(Bmassfccs)*fccsfuel.field13[indexfccs]/1000.
;          ; PM10 Emissions
;              empm10a = area*1e6*(Bmassfccs)*fccsfuel.field14[indexfccs]/1000.
;          ; PM2.5 Emissions
;              empm25a = area*1e6*(Bmassfccs)*fccsfuel.field15[indexfccs]/1000.
;          ; NOx Emissions
;              emnoxa = area*1e6*(Bmassfccs)*fccsfuel.field16[indexfccs]/1000.
;          ; NH3 Emissions
;              emnh3a = area*1e6*(Bmassfccs)*fccsfuel.field17[indexfccs]/1000.
;          ; SO2 Emissions
;              emso2a = area*1e6*(Bmassfccs)*fccsfuel.field18[indexfccs]/1000.
;          ; VOC Emissions
;              emvoca = area*1e6*(Bmassfccs)*fccsfuel.field19[indexfccs]/1000.
;         ; CH4 Emissions
;               emch4a=area*1e6*(Bmassfccs)*fccsfuel.field20[indexfccs]/1000.
;        goto, printout2
;
;agfire2:
;;; If it's an FCCS agriculture area, then just set emissions to use the GLC classifications
;;; Fuel loading for agriculture = 0.5 kg/m2
;    Bmassfccs = 0.50
;    emco2a = area*1000.*0.50*1515. ; CO2 Emission Factor = 1515 g/kg
;    emcoa = area*1000.*0.50*70. ; emission factor = 70 g/kg
;    emch4a = area*1000.*0.50*2.2 ; Emission factor = 2.2 g/kg
;    emvoca = area*1000.*0.50*6.7 ; Emission factor = 6.7 g/kg
;    empm25a = area*1000.*0.5*5.7 ; EF = 5.7 g/kg
;    empm10a = area*1000.*0.5*6.9 ; EF = 6.9 g/kg
;    emnoxa = area*1000.*0.5*2.4  ; EF = 2.4 g/kg
;    emnh3a = area*1000.*0.5*1.5  ; EF = 1.5 g/kg
;    emso2a = area*1000.*0.5*0.35  ; EF = 0.35 g/kg
;goto, printout2
;;
;printout2:
;printf,11,format=form4,j,lon[j],lat[j],day[j],glc[j],id[j],fccs[j],area,bmassfccs,emco2a,emcoa,empm10a,$
;    empm25a,emnoxa,emnh3a,emvoca,emch4a,emso2a,cntry[j],state[j]
;
;
;
;skipfire3:
;; ***************************************************************************
;;    END OF FCCS CALCULATIONS
;; ***************************************************************************
;;
;; ****************************************************************************
;; ***************************************************************************
;; CALCULATE EMISSIONS WITH MODIS FUELS FOR CONT. U.S.
;;        (+ southern CAN, northern Mexico)
;; ***************************************************************************
;; ***************************************************************************
;;  noaa1 = map.field13/10000. ; tree leaf biomass
;;    noaa2 = map.field14/10000. ; tree branch (wood and bark)
;;    noaa3 = map.field15/10000. ; above ground tree mass
;;    noaa4 = map.field16/10000. ; total shrub mass
;;    noaa5 = map.field17/10000. ; grass mass
;;    noaa6 = map.field18/10000. ; litter
;;    noaa7 = map.field19/10000. ; coarse woody debris
;
;; Only calculate for places where the MODIS fuels exist
;if noaa1[j] lt 0. then goto, skipfire4
;
;; Calculate biomass burned
;; Follow same method as for FCCS Fuels:
;;    30% of the woody and leaf fuels burn
;;    90% of the herbaceous fuels burn
;    Bmassnoaa = 0.3*(noaa1[j]+noaa2[j]+noaa3[j]+noaa7[j])+ $
;        0.9*(noaa4[j]+noaa5[j]+noaa6[j])
;
;; Emissions are in units of kg day-1
;;   Use GLC classes to determine the emission factor
;;   Some caveates:
;;    - Ag. fires not really taken into account so much (biomass cacluated in
;;        same way as all other classes
;;    - percent tree/herbaceous not considered in model, since used to determine
;;        NOAA fuel loads
;
;          ; CO2 Emissions
;              emco2b = area*1e6*(Bmassnoaa)*glc_ef.field02[index]/1000.
;          ; CO Emissions
;              emcob = area*1e6*(Bmassnoaa)*glc_ef.field03[index]/1000.
;          ; PM10 Emissions
;              empm10b = area*1e6*(Bmassnoaa)*glc_ef.field04[index]/1000.
;          ; PM2.5 Emissions
;              empm25b = area*1e6*(Bmassnoaa)*glc_ef.field05[index]/1000.
;          ; NOx Emissions
;              emnoxb = area*1e6*(Bmassnoaa)*glc_ef.field06[index]/1000.
;          ; NH3 Emissions
;              emnh3b = area*1e6*(Bmassnoaa)*glc_ef.field07[index]/1000.
;          ; SO2 Emissions
;              emso2b = area*1e6*(Bmassnoaa)*glc_ef.field08[index]/1000.
;          ; VOC Emissions
;              emvocb = area*1e6*(Bmassnoaa)*glc_ef.field09[index]/1000.
;         ; CH4 Emissions
;               emch4b=area*1e6*(Bmassnoaa)*glc_ef.field10[index]/1000.
;
;; Print out results
;     ; form5 = '(I8,",",D20.10,",",D20.10,",",(4(I10,",")),11(D25.10,","),2(A15,","))'
;; printf, 12, 'j,long,lat,day,glc,id,fccs,area,Bmassnoaa,CO2,CO,PM10,PM25,NOx,NH3,VOC,CH4,SO2,country,state'
;printf,12,format=form5,j,lon[j],lat[j],day[j],glc[j],id[j],fccs[j],area,Bmassnoaa,emco2b,emcob,empm10b,$
;    empm25b,emnoxb,emnh3b,emvocb,emch4b,emso2b,cntry[j],state[j]
;
;skipfire4:
;;***************************************************************************
;;    END OF MODIS FUELS CALCULATIONS
;; **************************************************************************


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
