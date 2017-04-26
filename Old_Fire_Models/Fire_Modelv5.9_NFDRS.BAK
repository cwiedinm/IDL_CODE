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
 ;  December 9, 2004; Edited code to include speciated VOC based on Louisa's code for MOZART
 ;  December 13, 2004:
 ;      Am putting the speciated VOC eimssions in the Gabyfile.pro (since they are only scale factors
 ;  March 02, 2005:
 ;    Editing fire module to include area-specific emissions factors (i.e. for Alaska)
 ;      NOT DONE YET
 ;  April 6, 2005
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
 ;****************************************************************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds


;**************************************************************************************
; GET INPUT AND OUTPUT FILES
; **User Instructions: User must set pathways of the input and output files
; INPUT file pathway
    ;path = 'C:\WORK\wildfire\EPA_EI\MODEL\test_090204\'
    ;path = '/zeus/christin/FIRE/MODEL/'
     path='D:\Christine\WORK\wildfire\EPA_EI\ANGIE\July05\'
    ; path = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\Output_AUG2005\2003\'
; Input fire files
    infile = path+'2003Fuel.txt'
    ;infile = path+'test2003input.txt'
; ****************************************************************************
; Default files: emission factors, fuel loadings, etc.
; DEFAULT files (i.e.,fuels, emission factors, etc.)
    path4 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\default_infiles\'

; Input Fuel loading files
    ; GLC fuel loadings: SIMPLE
        glcfuelload = path4+'fuel_load_cg.txt'
; NOTE:  the fuel loads in 'fuel_load_cg.txt' have the units kg/m2
; Input GLC emission factors (kg/Mg)
        glcfactor = path4+'Average_EF.txt'    ; Only 1 EF per GLC class

; Read in fuel load for GLC
        inload3=ascii_template(glcfuelload)
        glcfuelload=read_ascii(glcfuelload, template=inload3)
       ; Field1 = GLC code
       ; Field2 = herbaceous load
       ; Field3 = Tree load

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

; OPEN UP US. NFDRS fuels data
; fuel loads are kg/m2
    nfdrsfuelload = path4+'Orig_files\NFDRS\NFRDS_fuelload_kg_m2.csv'
; OPEN UP NFDRS Emission Factors -- emission factors kg/Mg- or g/kg
;   emission factors table created 08/24/05 (based on UT report)
    nfdrsfactor =path4+'Orig_files\NFDRS\NFDRS_EFs.csv'

; read in NFDRS fuels data
      inload5=ascii_template(nfdrsfuelload)
        nfdrsfuel=read_ascii(nfdrsfuelload, template=inload5)
        ; Field01 = US Fuel model codes
        ; Field02 = AK codes
        ; Field03 = Total
        ; Field04 = 1hr
        ; Field05 = 10hr
        ; Field06 = 100hr
        ; Field07 = 1000hr
        ; Field08 = Woody
        ; Field09 = Herbaceous
        ; Field10 = Drought

; read in NFDRS Emission Factors
        inload6=ascii_template(nfdrsfactor)
        nfdrsef=read_ascii(nfdrsfactor, template=inload6)
       ; Field1= NFDRS fuel component
         ; 0 = 1-hr
         ; 1 = 10-hr
         ; 2 = 100-hr
         ; 3 = Woody
         ; 4 = Herbacous
         ; 5 = drought
       ; Field2 = Combustion Efficiency
       ; Field3 = CO
       ; Field4 = CH4
       ; Field5 = NMHC
       ; Field6 =    PM2.5
       ; Field7 = PM10
       ; Field8 = NOX
       ; Field9 = NH3
; Set up counter for number of fires in the US with NFDRS fuels
       countus = 0

; *** AS of August 24, 2005 - Can't do Canada because don't have fuel loadings
; OPEN UP CANADIAN fuels data
; fuel loads are kg/m2
    ;   canfuelload = path4+'\Orig_files\CAN\NFRDS_fuelload_kg_m2.csv'
; OPen up Canadian Fuel Emission factor
    ; canfactor =

; **** OPEN FCCS FUELS INFORMATION
; fuel loadings for FCCS
    fccsfuel = path4+'\Orig_files\FCCS\fccsfuels.csv
; emission factors for FCCS


; MODIS FUEL LOADINGS
; To come- as of August 24, 2005- waiting for updated disk from XYZ


; ******************************************************************
; OUTPUT FILES
; OUTPUT file pathway
    ; path2 = 'C:\FIRE\ascii_grids\V003\output\'
    path2 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\Output_AUG2005\2003\'

; Set up output file (comma delimited text file)
     outfile = 'Modelout_2003_Default.txt'
     openw, 6, path2+outfile
     print, 'opened ', path2+outfile
     printf, 6, 'j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,cntry,state'
;        'bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4'
    form = '(I8,",",D20.10,",",D20.10,",",(6(I15,",")),2(D20.10,","),9(D25.10,","),2(A15,","))'

; Set up output file with NFDRS- Calculated Emissions
     outfile2 = 'Modelout_2003_NFDRS_nodrought.txt'
     openw, 7, path2+outfile2
     print, 'opened ', path2+outfile
     printf, 7, 'j,long,lat,day,glc,id,nfdrs,area,CO,PM10,PM25,NOx,NH3,VOC,CH4,country,state'
     form3 = '(I8,",",D20.10,",",D20.10,",",(4(I10,",")),8(D25.10,","),2(A15,","))'

; Set up a file to check outputs
    checkfile = 'check2_2004.txt'
    openw, 8, path2+checkfile
    printf, 8, 'j, GLCCode, tree, herb, bare, totcov, area, herbbm, coarsebm, Bmass'
    form2 = '(5(I5,","),5(D20.10,","))'
; Set up log file
    logfile = 'log2003_try2_nodrought.txt'
    openw, 9, path2+logfile
    printf, 9, "this one did not include drought for the NFDRS conditions and the original GLC fuel loads"

; ****************************************************************************************
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)

; REdo Fields because now can export information directly from GIS (08/24/05)
    ; FIELDS IN INPUT FILE
    ; 1. LAT
    ; 2. Long
    ; 3. SPIX
    ; 4. JULIAN
    ; 5. ID
    ; 6. GLC
    ; 7. pct_bare
    ; 8. pct_herb
    ; 9.. pct_tree
    ; 10. NFDRS
    ; 11  CAN_FUEL
    ; 12. FCCS
    ; 13 - 19: NOAA Layers 1 - 7
    ; 20: Country Name
    ; 21: State Name

; SET UP ARRAYS
    lat = map.field01
    lon = map.field02
    day = map.field04
    glc = map.field06
    id = map.field05
    tree = map.field09*1.0
    herb = map.field08*1.0
    bare = map.field07*1.0
    spix = map.field03
    nfdrs = map.field10
    canfuel = map.field11
    fccs = map.field12
    noaa1 = map.field13
    noaa2 = map.field14
    noaa3 = map.field15
    noaa4 = map.field16
    noaa5 = map.field17
    noaa6 = map.field18
    noaa7 = map.field19
    cntry = map.field20
    state = map.field21


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
 for j =0L,nfires-1 do begin
;
; GET RID OF POINTS WHERE SPIX ISN'T CORRECT (TOO STRETCHED!)
    if spix[j] gt 2.5 then begin
       printf, 9, 'Fire number:',j,' removed. SPIX = ', spix[j]
       spixct = spixct+1
       goto, skipfire2
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
    if glc[j] eq -9999 or glc[j] eq 0 then begin
       glccount = glccount+1
       glc[j] = 13 ; Set GLC to grasslands
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
                        if glc[j] eq -9999 then goto, whatever
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
    herbbm = glcfuelload.field2[index]
    coarsebm = glcfuelload.field3[index]

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
            printf,6,format=form,j,lon[j],lat[j],day[j],glc[j],id[j],tree[j],herb[j],bare[j],area,bmass, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,emisch4
            printf, 8, format=form2,j,glc[j],tree[j],herb[j],bare[j],totcov[j],area,herbbm, coarsebm, Bmass

skipfire:
; ***************************************************************************************
; NOW: CALCULATE EMISSIONS FROM NFDRS
; only calculate fires with NFDRS fuels associated with them
  if nfdrs[j] lt 0 then goto, skipfire2
; Count the number of NFDRS fires
    countus = countus+1

; Get rid of fires with no information for the fuels
if nfdrs[j] eq 0 or nfdrs[j] eq 22 or nfdrs[j] eq 23 or nfdrs[j] eq 24 then begin
    printf, 9, 'The fire number has nfdrs with zero fuel loadings:', j, nfdrs[j]
    goto, skipfire2
endif

if nfdrs[j] eq 13 then begin
    printf, 9, 'Fire is NFDRS agriculture. j = ', j
    goto, agfire
endif

; Calculate emissions
    code = where(nfdrs[j] eq nfdrsfuel.field01)
; Get fuel loadings of each fuel component and fuel combustion
    hr1 = nfdrsfuel.field04[code]*nfdrsef.field2[0]
    hr10 = nfdrsfuel.field05[code]*nfdrsef.field2[1]
    hr100 = nfdrsfuel.field06[code]*nfdrsef.field2[2]
    hr1000 = nfdrsfuel.field07[code]*nfdrsef.field2[3]
    woody = nfdrsfuel.field08[code]*nfdrsef.field2[4]
    herbac = nfdrsfuel.field09[code]*nfdrsef.field2[5]
 ;   drought = nfdrsfuel.field10[code]*nfdrsef.field02[6] ; try runs with and without drought
    drought = 0.
; Calculate Emissions
; Emissions have final units of: kg/day
    emco = area*1000*((hr1*nfdrsef.field3[0])+(hr10*nfdrsef.field3[1])+(hr100*nfdrsef.field3[2])+$
         (hr1000*nfdrsef.field3[3])+(woody*nfdrsef.field3[4])+ $
         (herbac*nfdrsef.field3[5])+(drought*nfdrsef.field3[6]))
    emch4 = area*1000*((hr1*nfdrsef.field4[0])+(hr10*nfdrsef.field4[1])+(hr100*nfdrsef.field4[2])+$
         (hr1000*nfdrsef.field4[3])+(woody*nfdrsef.field4[4])+ $
         (herbac*nfdrsef.field4[5])+(drought*nfdrsef.field4[6]))
    emvoc = area*1000*((hr1*nfdrsef.field5[0])+(hr10*nfdrsef.field5[1])+(hr100*nfdrsef.field5[2])+$
         (hr1000*nfdrsef.field5[3])+(woody*nfdrsef.field5[4])+ $
         (herbac*nfdrsef.field5[5])+(drought*nfdrsef.field5[6]))
    empm25 = area*1000*((hr1*nfdrsef.field6[0])+(hr10*nfdrsef.field6[1])+(hr100*nfdrsef.field6[2])+$
         (hr1000*nfdrsef.field6[3])+(woody*nfdrsef.field6[4])+ $
         (herbac*nfdrsef.field6[5])+(drought*nfdrsef.field6[6]))
    empm10 = area*1000*((hr1*nfdrsef.field7[0])+(hr10*nfdrsef.field7[1])+(hr100*nfdrsef.field7[2])+$
         (hr1000*nfdrsef.field7[3])+(woody*nfdrsef.field7[4])+ $
         (herbac*nfdrsef.field7[5])+(drought*nfdrsef.field7[6]))
    emnox = area*1000*((hr1*nfdrsef.field8[0])+(hr10*nfdrsef.field8[1])+(hr100*nfdrsef.field8[2])+$
         (hr1000*nfdrsef.field8[3])+(woody*nfdrsef.field8[4])+ $
         (herbac*nfdrsef.field8[5])+(drought*nfdrsef.field8[6]))
    emnh3 = area*1000*((hr1*nfdrsef.field9[0])+(hr10*nfdrsef.field9[1])+(hr100*nfdrsef.field9[2])+$
         (hr1000*nfdrsef.field9[3])+(woody*nfdrsef.field9[4])+ $
         (herbac*nfdrsef.field9[5])+(drought*nfdrsef.field9[6]))
    goto, printout

agfire:
; If it's an NFDRS agriculture area, then just set emissions to use the GLC classifications
; Fuel loading for agriculture = 0.5 kg/m2
    emco = area*1000.*0.50*57.0 ; emission factor = 57 g/kg
; NO CH4 Emission factors for crops! Use that from grasslands
    emch4 = area*1000.*0.50*2.3 ; Emission factor = 2.3 g/kg
    emvoc = area*1000.*0.50*5.4 ; Emission factor = 5.4 g/kg
    empm25 = area*1000.*0.5*7.6
    empm10 = area*1000.*0.5*8.0
    emnox = area*1000.*0.5*2.2
; No NH3 Emission factor for crops! Use that from Grasslands
    emnh3 = area*1000.*0.5*1.45
goto, printout

; PRINT RESULTS TO OUTPUT FILE
printout:
            printf,7,format=form3,j,lon[j],lat[j],day[j],glc[j],id[j],nfdrs[j],area,emco,empm10,empm25,emnox,emnh3,emvoc,emch4


skipfire2:
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
printf, 9 , 'Input file = :', infile
printf, 9, 'The total number of fires processed were: ', nfires
printf, 9, 'The total number of fires skipped were: ', skip
printf, 9, 'The number of fires with SPIX gt 2.5 and removed were: ', spixct
printf, 9, ' '
printf, 9, 'The total number of fires in the NFDRS was: ', countus
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

close,/all   ;make sure ALL files are closed
end
