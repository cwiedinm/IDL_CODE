; ****************************************************************************
; GLOBAL FIRE EMISSIONS ESTIMATES FOR MOZART MODEL

; *********************************************************************************************

pro global_fire_smartfire_texas_viirs_indo

close, /all

 t0 = systime(1) ;Procedure start time in seconds

 yearnum= 2013
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
    fuelin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_inputs\Fuel_LOADS_NEW012010.csv' ; Updated 01/18/2010
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
    emisin = 'F:\Data2\wildfire\GLOBAL_MOZART\MODEL\INPUT\Model_Inputs\FINAL_EFS_08182010.csv' ; New file created 08/18/2010 (same as above, now includes PM10)
    inemis=ascii_template(emisin)
    emis=read_ascii(emisin, template=inemis)
;   Set up Emission Factor Arrays
 
; NEW FILE 10/20/200912
; 1     2            3         4   5  6    7   8    9   10   11  12   13   14 15  16  17  18  19  20
; LCT Type  Type  MCE CO2 CO  CH4 NMOC  H2  NOx SO2 PM2.5 TPM TPC OC  BC  NH3 NO  NO2 NMHC
; LCT  Type Type  MCE CO2 CO  CH4 NMOC  H2  NOx SO2 PM2.5 TPM TPC OC  BC  NH3 NO  NO2 NMHC

; FINAL FILE 02/13/2010
; ; 1     2            3            4   5   6   7    8    9      10  11    12  13  14  15  16  17  18  19
; LCT  Type  Descript  CO2 CO  CH4 NMOC  H2  NOXasNO SO2 PM25  TPM TPC OC  BC  NH3 NO  NO2 NMHC
; LCT  Type  Descript  CO2 CO  CH4 NMOC  H2  NOXasNO SO2 PM25  TPM TPC OC  BC  NH3 NO  NO2 NMHC

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

     outfile = 'E:\Data2\wildfire\INDONESIA\OUTPUT\oldfinnmethod\TEST_VIIRS_INDO_2013_FINNmethod_05282014.txt'
     openw, 6, outfile
     print, 'opened output file: ', outfile
              ; 'longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'
;     printf, 6, 'state,type,longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,fuelload,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'
;     form = '(A20,",",A6,",",D20.10,",",D20.10,",",(8(I10,",")),3(D20.10,","),17(D25.10,","),F6.3)'
 
     printf, 6, 'longi,lat,day,TIME,lct,genLC,globreg,pcttree,pctherb,pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR,state,fuelload, type'
     form = '(D20.10,",",D20.10,",",(8(I10,",")),2(D20.10,","),17(D25.10,","),F6.3,",",A25,",",F20.10,",",A6)'
 
    ; Print an output log file
    logfile = 'E:\Data2\wildfire\INDONESIA\OUTPUT\oldfinnmethod\LOG_TEST_TEST_VIIRS_INDO_2013_FINNmethod_05282014.txt'
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

  infile = 'E:\Data2\wildfire\INDONESIA\INPUT\CHECKINPUT\input_for_finn_042414A_LCT_GLC_TREE2_HERB_BARE2.csv'  
  

; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)
        print, 'Finished reading input file'
 
; 2012 File created 02/28/2013
; 1   2     3   4     5      6          7         8          9      10    11    12   
;DATE TIME  LAT LONG  AREA  COMBTEMP  PERCTREE  PERCHERB  PERCBARE  PEAT1 LCTA  GLCA

        lat1 = map.field03
        lon1 = map.field04
        date1 = map.field01
        tree1 = map.field07*1.0
        herb1 = map.field08*1.0
        bare1 = map.field09*1.0
        lct1 = map.field11 
        area1 = map.field05
  
; Total Number of fires input in original input file
      numorig = n_elements(lat1)

    
    print, 'Finished Reading Input file'

; Added 08/25/08: removed values of -9999 from VCF inputs
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
       numfire1 = numorig
       jd = intarr(numfire1)
       
;!!!!!!!!!!! EDIT THIS SECTION FOR THE CORRECT DATE FORMAT!!!
; DATE has format YYYYMMDD

for i = 0L,numfire1-1 do begin
         parts =  strsplit(date1[i],'/',/extract)
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
; *******************************************************************************************************************
; OCTOBER 16, 2009: For Tropics, where satellite coverage isn't daily, spread fires over 48 hours (starting at 24Z)
;    from 30N to 30S; using advice fom Jay's code
;    Create duplicates of the fires for 2-day periods in this region. If there are overlaps- then these will be removed in
;    the next section. 
;    Changed the names of arrays above (added '2' to the end of them above- so that I can use the original names here)

; Identify Tropics: 
; SEPTEMBER 13, 2013: IGNORE TROPICS OVERLAPS WITH SMARTFIRE INPUTS
 
  ngoodfires = n_elements(jd) 

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
; Sort fires in order of JD
    index2=sort(jd)
    lat=lat1[index2]
    lon=lon1[index2]
  ;  spix=spix[index2]
  ;  tpix=tpix[index2]
    tree=tree1[index2]
    herb=herb1[index2]
    bare=bare1[index2]
    lct=lct1[index2]
  ;  time=time[index2]
    jd=jd[index2]
    totcov = totcov[index2]
    area2 = area1[index2]

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


; Set up regional totals
  COwestus=0.0
  COeastus=0.0
  COcanak = 0.0
  COMEXCA = 0.0
  
  
  
      
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

; 1a) Skip any fires in Antarctica
; 2) Remove fires with no LCT assignment or in water bodies or snow/ice assigned by LCT
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


genveg = lct[j]

; ####################################################
; Assign Burning Efficiencies based on Generic
;   land cover (Hoezelmann et al. [2004] Table 5
; ####################################################

        
; ####################################################
; Assign Fuel Loads based on Generic land cover
;   and global region location
;   units are in g dry mass/m2
; ####################################################

    reg = 10   ; locate global region, get index
    if reg[0] eq -1 then begin
       printf, 9, 'Fire number:',j,' removed. Something is WRONG with global regions and fuel loads. Globreg =', globreg[j]
       goto, skipfire
    endif

; April 08, 2009: Edited this to say "Bmass1" not "Bmass"
; 	Bmass now gets calculated as a function of tree cover, too.
    if genveg eq 9 then begin
    ;For Brazil from Elliott Campbell, 06/14/2010
      if (lon[j] le -47.323 and lon[j] ge -49.156) and (lat[j] le -20.356 and lat[j] ge -22.708) then bmass1= 1100. else bmass1 = 500.
    endif
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
    
    ; DEC. 09, 2009: Added correction 
    ; Assign boreal forests in Southern Asia the biomass density of the temperate forest for the region
;    if genveg eq 5 and globreg[j] eq 11 then bmass1 = tefuel[reg]
    
    if bmass1 eq -1 then begin
        printf, 9, 'Fire number:',j,' removed. bmass assigned -1! 
        printf, 9, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        print, 'Fire number:',j,' removed. bmass assigned -1!
        print, '    genveg =', genveg, ' and globreg = ', globreg[j], ' and reg = ', reg
        bmass0 = bmass0+1
       goto, skipfire
    endif
 
 ; DECEMBER 08, 2009   
 ; Try a correction for Austrailia- for areas of woody savannah with dense forest cover, replace the woody savannah biomass loading with the forest loading. 
; if globreg[j] eq 12 then begin ; OCEANIA
;    if tree[j] gt 60. then begin ; Forested area
;      if genveg eq 2 then bmass1 = tefuel[reg]
;    endif
;endif

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
    herbbm = grfuel[reg]
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

    fuelload = (pctherb*herbbm) + (pcttree*coarsebm) ; Christine added this 09/04/2013 to include fuel loading in output file
                                                     ; Fuel load is in kg/m2
    
; ####################################################
; Assign Emission Factors based on Generic land cover
; ####################################################
    ; assign index for emission factors
;    if genveg eq 1 or genveg eq 2 then index = 0 ; grasslands & savannas
;    if genveg eq 3 then index = 1 ; tropical forests
;    if genveg eq 4 then index = 2 ; extratropical forests
;    if genveg eq 9 then index = 3 ; Crops
;    if genveg eq 5 then index = 4 ; Boreal Forests, added 10/19/2009

; Reassigned emission factors based on LCT, not genveg for new emission factor table
    if lct[j] eq 1 then index = 9 ; GRASSLAND
    if lct[j] eq 2 then index = 6 ; SHRUBLAND
    if lct[j] eq 3 then index = 1 ; TROP FOREST
    if lct[j] eq 4 then index = 3 ; TEMP FOREST
    if lct[j] eq 5 then index = 0 ; BOREAL FOREST
    if lct[j] eq 9 then index = 11 ; CROP
    if lct[j] eq 12 then index = 11 ; CROP

; ####################################################
; Calculate Emissions
; ####################################################
; Emissions = area*BE*BMASS*EF
    ; Convert units to consistent units
; #################################################
; Get Area burned from input
; ####################################################
        area= area2[j] ; Area in input file is m2

    ; Calculate emissions (kg)
; #######READ THIS ###########
  ; Specific to MOZART modeling and using 7-day total fire counts!!!!
    ; NOTE: Since reading in the 7-day total fires from teh rapid response:
    ; need to scale emissions down. Doing so by dividing by 3.5:
    ;  (added 01/17/06)
    ; 02/01/2005: Going to chose the daily average for the entire 7 days...
    ; but need to calculate in second program- not here!!  here, have all fires
    ; have their original estimates (factor = 1)
       factor = 1.
; 04/09/2009 : removed BE from these equations (commented out)
; 	 Bmass is now calculated to include BE
;       CO2 = CO2EF[index]*area*BE*bmass/1000./factor
;       CO = COEF[index]*area*BE*bmass/1000./factor
;       CH4 = CH4EF[index]*area*BE*bmass/1000./factor
;       NMHC = NMHCEF[index]*area*BE*bmass/1000./factor
;       H2 = H2EF[index]*area*BE*bmass/1000./factor
;       NOX = NOXEF[index]*area*BE*bmass/1000./factor
;       SO2 = SO2EF[index]*area*BE*bmass/1000./factor
;       PM25 = PM25EF[index]*area*BE*bmass/1000./factor
;       TPM = TPMEF[index]*area*BE*bmass/1000./factor
;       TC = TCEF[index]*area*BE*bmass/1000./factor
;       OC = OCEF[index]*area*BE*bmass/1000./factor
;       BC = BCEF[index]*area*BE*bmass/1000./factor
;       NH3 = NH3EF[index]*area*BE*bmass/1000./factor

; CALCULATE EMISSIONS kg/day
; NOV. 25, 2009: Added the multiplication of the factor for the tropics. Assigned ealier in the code, 
;     where the tropics are doubled. 
       CO2 = CO2EF[index]*area*bmass/1000./1000. ; g/kg * m2 * g/m2 * 
       CO = COEF[index]*area*bmass/1000./1000.
       CH4 = CH4EF[index]*area*bmass/1000./1000.
       NMHC = NMHCEF[index]*area*bmass/1000./1000.
       NMOC = NMOCEF[index]*area*bmass/1000./1000.
       H2 = H2EF[index]*area*bmass/1000./1000.
       NOX = NOXEF[index]*area*bmass/1000./1000.
       NO = NOEF[index]*area*bmass/1000./1000.
       NO2 = NO2EF[index]*area*bmass/1000./1000.
       SO2 = SO2EF[index]*area*bmass/1000./1000.
       PM25 = PM25EF[index]*area*bmass/1000./1000.
       TPM = TPMEF[index]*area*bmass/1000./1000.
       TPC = TCEF[index]*area*bmass/1000./1000.
       OC = OCEF[index]*area*bmass/1000./1000.
       BC = BCEF[index]*area*bmass/1000./1000.
       NH3 = NH3EF[index]*area*bmass/1000./1000.
       PM10 = PM10EF[index]*area*bmass/1000./1000.
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
; 'longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR'

;                      ; longi,lat,   day,  TIME,lct,   genLC, globreg,   pcttree,pctherb,
printf,6,format = form, lon[j],lat[j],jd[j],1200,lct[j],genveg,10,tree[j],herb[j], $
;      pctbare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10,FACTOR,        state';;
       bare[j],area,bmass,CO2,CO,CH4,H2,NOX,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,PM10


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
       
       
       ; ; Set up regional totals
if lat[j] gt 24. and lat[j] lt 49. and lon[j] gt -125. and lon[j] lt -100. then COwestus = COwestus + CO
if lat[j] gt 24. and lat[j] lt 49. and lon[j] gt -100. and lon[j] lt -60. then COeastus = COeastus + CO
if lat[j] gt 49. and lat[j] lt 70. and lon[j] gt -170. and lon[j] lt -55. then COcanak = COcanak + CO
if lat[j] gt 10. and lat[j] lt 28. and lon[j] gt -120. and lon[j] lt -65. then COmexca = COmexca + CO   
; 
; 
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
;printf, 9, ' '
;printf, 9, 'The Input file was: ', infile
;printf, 9, 'The emissions file was: ', emisin
;printf, 9, 'The fuel load file was: ', fuelin
;printf, 9, ' '
;printf, 9, 'The total number of fires input was:', numorig
;printf, 9, 'the total number of fires removed with confience < 20:', numorig-nconfgt20
;printf, 9, ''
;;printf, 9, 'the total number of fires in the tropics was: ', numadd
;printf, 9, 'The number of fires processed (ngoodfires):', ngoodfires
;printf, 9, ''
;printf, 9, 'The number of urban fires: ', urbnum
;printf, 9, 'The number of fires removed for overlap:', overlapct
;printf, 9, ' The number of fires skipped due to lct<= 0 or lct > 17:', lct0
;printf, 9, ' The number of fires skipped due to Global Region = Antarctica:', antarc
;printf, 9, ' The number of fires skipped due to 100% bare cover:', allbare
;printf, 9, ' The number of fires skipped due to problems with genveg:', genveg0
;printf, 9, ' The number of fires skipped due to bmass assignments:', bmass0
;printf, 9, ' The number of fires scaled to 100:', vcfcount
;printf, 9, ' The number of fires with vcf < 50:', vcflt50
;printf, 9, 'Total number of fires skipped:', spixct+lct0+antarc+allbare+genveg0+bmass0+confnum
;printf, 9, ''
;; Added this section 08/24/2010
;printf, 9, 'Global Totals (Tg) of biomass burned per vegetation type'
;printf, 9, 'GLOBAL TOTAL (Tg) biomass burned (Tg),', BMASStotal/1.e9
;printf, 9, 'Total Temperate Forests (Tg),', TOTTEMP/1.e9
;printf, 9, 'Total Tropical Forests (Tg),', TOTTROP/1.e9
;printf, 9, 'Total Boreal Forests (Tg),', TOTBOR/1.e9
;printf, 9, 'Total Shrublands/Woody Savannah(Tg),', TOTSHRUB/1.e9
;printf, 9, 'Total Grasslands/Savannas (Tg),', TOTGRAS/1.e9
;printf, 9, 'Total Croplands (Tg),', TOTCROP/1.e9
;printf, 9, ''
;printf, 9, 'Global Totals (km2) of area per vegetation type'
;printf, 9, 'TOTAL AREA BURNED (km2),', AREATOTAL
;printf, 9, 'Total Temperate Forests (km2),', TOTTEMParea
;printf, 9, 'Total Tropical Forests (km2),', TOTTROParea
;printf, 9, 'Total Boreal Forests (km2),', TOTBORarea
;printf, 9, 'Total Shrublands/Woody Savannah(km2),', TOTSHRUBarea
;printf, 9, 'Total Grasslands/Savannas (km2),', TOTGRASarea
;printf, 9, 'Total Croplands (km2),', TOTCROParea
;printf, 9, ''
;printf, 9, 'TOTAL CROPLANDS CO (kg),', TOTCROPCO
;printf, 9, 'TOTAL CROPLANDS PM2.5 (kg),', TOTCROPPM25
;printf, 9, ''
;printf, 9, 'GLOBAL TOTALS (Tg)'
;printf, 9, 'CO2 = ', CO2total/1.e9
;printf, 9, 'CO = ', COtotal/1.e9
;printf, 9, 'CH4 = ', CH4total/1.e9
;printf, 9, 'NMHC = ', NMHCtotal/1.e9
;printf, 9, 'NMOC = ', NMOCtotal/1.e9
;printf, 9, 'H2 = ', H2total/1.e9
;printf, 9, 'NOx = ', NOXtotal/1.e9
;printf, 9, 'NO = ', NOtotal/1.e9
;printf, 9, 'NO2 = ', NO2total/1.e9
;printf, 9, 'SO2 = ', SO2total/1.e9
;printf, 9, 'PM2.5 = ', PM25total/1.e9
;printf, 9, 'TPM = ', TPMtotal/1.e9
;printf, 9, 'TPC = ', TPCtotal/1.e9
;printf, 9, 'OC = ', OCtotal/1.e9
;printf, 9, 'BC = ', BCtotal/1.e9
;printf, 9, 'NH3 = ', NH3total/1.e9
;printf, 9, 'PM10 = ', PM10total/1.e9
;printf, 9, ''
;printf, 9, ''
;; WESTERN U.S. 
;printf, 9, ''
;printf, 9, 'Western US (Gg Species)'
;printf, 9, 'CO, ', COwestus/1.e6
;
;; EASTERN U.S. 
;printf, 9, ''
;printf, 9, 'Eastern US (Gg Species)'
;printf, 9, 'CO, ', COeastUS/1.e6
;
;; CANADA/AK 
;printf, 9, ''
;printf, 9, 'Canada/Alaska (Gg Species)'
;printf, 9, 'CO, ', COcanak/1.e6
;
;; Mexico and Central America 
;printf, 9, ''
;printf, 9, 'Mexico/Central America (Gg Species)'
;printf, 9, 'CO, ', COmexca/1.e6
;; ***************************************************************
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