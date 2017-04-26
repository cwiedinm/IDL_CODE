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
 ;  Dec. 13, 2004:
 ;      NO... Am putting the speciated VOC eimssions in the Gabyfile.pro (since they are only scale factors
 ;

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds


;**************************************************************************************
; GET INPUT AND OUTPUT FILES

; Input file pathway
    ;path = 'C:\WORK\wildfire\EPA_EI\MODEL\test_090204\'
    ;path = '/zeus/christin/FIRE/MODEL/'
    path='D:\Christine\WORK\wildfire\EPA_EI\2002Data\'
; Default files (i.e.,fuels, emission factors, etc.)
    path4 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\default_infiles\
; Output file pathway
    ; path2 = 'C:\FIRE\ascii_grids\V003\output\'
    path2 = 'D:\Christine\WORK\wildfire\EPA_EI\2002Data\output\'

; Input fire files
    infile = path+'input2002.txt'

; Input Fuel loading files
   glcfuelload = path4+'fuel_load_cg.txt'

; Input GLC emission factors
    glcfactor = path4+'Average_EF.txt'    ; Only 1 EF per GLC class

; Set up output file (comma delimited text file)
     outfile = 'out2002_fire_emis.txt'
     openw, 6, path2+outfile
     print, 'opened ', path2+outfile
     printf, 6, 'j,longi,lat,day,glc,lct,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4"
    form = '(I5,",",D20.10,",",D20.10,",",(6(I5,",")),2(D20.10,","),9(D25.10,","))'

; Set up a file to check outputs
    checkfile = 'check2_2004.txt'
    openw, 8, path2+checkfile
    printf, 8, 'j, GLCCode, tree, herb, bare, totcov, area, herbbm, coarsebm, Bmass'
    form2 = '(5(I5,","),5(D20.10,","))'
; Set up log file
    logfile = 'log.txt'
    openw, 7, path2+logfile

; ****************************************************************************************
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
        intemp=ascii_template(infile)
        map=read_ascii(infile, template=intemp)
; Get the number of fires in the file
        nfires = n_elements(map.field01)

    ; FIELDS IN INPUT FILE
    ; 1. LAT
    ; 2. Long
    ; 3. Date
    ; 4. JULIAN
    ; 5. UTC
    ; 6. TEMP
    ; 7. GLC
    ; 8. LCT
    ; 9.. pct_tree
    ; 10. pct_bare
    ; 11  pct_herb

; SET UP ARRAYS
    lat = map.field01
    lon = map.field02
    day = map.field04
    glc = map.field07
    lct = map.field08
    tree = map.field09
    herb = map.field11
    bare = map.field10

; Calculate the total cover from the VCF product
    totcov = tree+herb+bare

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

; Set up Counters
;   These are identifying how many fires are in urban areas, or have unidentified VCF or GLC
;   values --> purely for statistics and quality assurance purposes
        vcflt50 = 0
        vcflt1 = 0
        vcfgt150 = 0
        vcfcount = 0
        urbcount = 0
        glccount = 0
        allbare = 0
        watercount = 0



; *********************************************************************
; ***********************************************************************


; START LOOP OVER FIRE PIXELS
 for j =0L,nfires-1 do begin

;
; Determine if data are there weird values assigned to the VCF or GLC products

; VCF product

    barecount = where(bare eq 100)
    allbare = n_elements(barecount)

; First see if this is just a GIS processing error:
    if totcov[j] gt 102 and totcov[j] lt 200 then begin
       vcfcount = vcfcount+1
       tree[j] = tree[j]*100/totcov[j]
       herb[j] = herb[j]*100/totcov[j]
       bare[j] = bare[j]*100/totcov[j]
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif
    if totcov[j] lt 98 and totcov[j] ge 50 then begin
       vcfcount = vcfcount+1
       tree[j] = tree[j]*100/totcov[j]
       herb[j] = herb[j]*100/totcov[j]
       bare[j] = bare[j]*100/totcov[j]
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif
;Second, If no data are assigned to the grid, then scale up, still
    if totcov[j] lt 50 and totcov[j] ge 1 then begin
       vcflt50  = vcflt50+1
       tree[j] = tree[j]*100/totcov[j]
       herb[j] = herb[j]*100/totcov[j]
       bare[j] = bare[j]*100/totcov[j]
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif
; Secondb, if no cover (0 ) is assigned to the cell, assume 10% herbaceous and 90% bare
   if totcov[j] lt 1 then begin
       vcflt1 = vcflt1 + 1
       tree[j] = 0
       herb[j] = 10
       bare[j] = 90
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif
; Third, if entire fire is on bare, assume 10% herbaceous, 90% bare
    if bare[j] eq 100 then begin
       tree[j] = 0
       herb[j] = 10
       bare[j] = 90
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif
; Fourth, if assigned water or unknown, ssume 10% herbaceous, 90% bare
    if totcov[j] gt 200 then begin
       vcfgt150 = vcfgt150 + 1
       tree[j] = 0
       herb[j] = 10
       bare[j] = 90
       totcov[j] = bare[j] +herb[j] + tree[j]
    endif

;; GLC Product; where GLC eq unknown?
    if glc[j] eq 0 then begin
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
       p = 1.0
; Determine the biomass of the land cover classification

; First- determine if water or unknown
       If (glc[j] eq 24) or (glc[j] eq 26) then begin
           printf, 7, 'The GLC for this cell is WATER, SNOW/ICE or unknown.  j=',j
                ;Is there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.02) AND lat lt (lat[j]+0.02))
                 samelon = where(lon gt (lon[j]-0.02) AND lon lt (lon[j]+0.02))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if (locnear[0] ne 24) AND (locnear[0] ne 26) then begin
                        glc[j] = glc[locnear[0]]
                 printf, 7, '   Got a value from a nearby cell. Glc[j] =', glc[j]
                 watercount = watercount+1
                        goto, outwater
                    endif
                 endif
                 printf,7, 'All nearby cells have GLC = water, unkonwn, etc.. Assume GLC = 13 (grasslands)'
                 glc[j] = 13
                 watercount = watercount+1
                 goto, outwater
        endif
        outwater:

; Next- determine if land cover is urban/built-up. If so- assign land cover of nearby vegetation (1/3 biomass)
         If glc[j] eq 22 then begin
                printf, 7, 'Urban Cell! GLC Value = 22. Loop Number = ', j
                p = 0.5  ; multiply land cover biomass by 50% in urban and built-up regions
                ; IS there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.02) AND lat lt (lat[j]+0.02))
                 samelon = where(lon gt (lon[j]-0.02) AND lon lt (lon[j]+0.02))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if locnear[0] ne 22 then begin
                        glc[j] = glc[locnear[0]]
                        urbcount = urbcount+1
                        printf, 7, '   Got a replacement for the Urban cell. glc[j] =', glc[j]
                        goto, outurb
                    endif
                 endif
                 printf,7, 'no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
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
        CF6 = 0.30          ;
    endif
    if (tree[j] gt 40) and (tree[j] le 60) then begin   ;WOODLAND
       CF3 = exp(-0.013*(tree[j]/100.))     ; Apply to all herbaceous fuels
       CF1 = 0.30                   ; Apply to all coarse fuels in woodlands
                             ; From Ito and Penner [2004]
    endif
    If (tree[j] le 40) then begin       ;GRASSLAND
       CF3 = 0.98 ;Range is between 0.44 and 0.98
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
            printf,6,format=form,j,lon[j],lat[j],day[j],glc[j],lct[j],tree[j],herb[j],bare[j],area,bmass, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,emisch4
            printf, 8, format=form2,j,glc[j],tree[j],herb[j],bare[j],totcov[j],area,herbbm, coarsebm, Bmass
endfor ; END LOOP OVER THE FIRES FOR THE DAY (j loop)

; END PROGRAM

quitearly:
printf,7, 'The total number of fires processed were: ', nfires
printf, 7, 'VCF STATS'
printf,7, 'The number of fire with scaled VCF product were:', vcfcount
printf,7,  'The total number of fires in areas that were 100% bare were:', allbare
printf, 7, 'The total number of fires in areas with totcov gt 200were:', vcfgt150
printf, 7, 'The total number of fires in ares with totcov lt 50 and gt 1 were:', vcflt50
printf, 7, ' The total number of fires with total coverage lt 1 = ', vcflt1
printf, 7, 'GLC STATS'
printf,7, 'The number of fires with no GLC value were: ', glccount
printf,7, 'the total number of fires within urban or other landscapes were:', urbcount
printf,7, 'the total number of fires in water or snow were:', watercount

t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'
junk = check_math() ;This clears the math errors

close,/all   ;make sure ALL files are closed
end
