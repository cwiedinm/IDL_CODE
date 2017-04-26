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
 ; ***********************************************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds

; Determine whether to use CF values (from Ito and Penner, 2004) or FEPS algorithms
    read, 'type 1 for using CF values, 2 for using FEPS', type

;**************************************************************************************
; GET INPUT AND OUTPUT FILES

; Input file pathway
    ;path = 'C:\WORK\wildfire\EPA_EI\MODEL\test_090204\'
    ;path = '/zeus/christin/FIRE/MODEL/'
    path='D:\Christine\WORK\wildfire\EPA_EI\Hayman_Fire\'
; Default files (i.e.,fuels, emission factors, etc.)
    path4 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\default_infiles\
; Output file pathway
    ; path2 = 'C:\FIRE\ascii_grids\V003\output\'
    path2 = 'D:\Christine\WORK\wildfire\EPA_EI\Hayman_Fire\output\'

; Input fire files
    infile = path+'All_Hayman.csv'

; input Fuel loading files
;   nfdrsfuelload = path4+'NFRDS_fuelload_ton_acre.csv'
;   canfuelload = path4+'CAN_fuelload_ton_acre.csv'
   glcfuelload = path4+'GLC_fuelload_all2.csv'

; Input GLC emission factors
    glcfactor = path4+'glc_emisfactors4.csv'
    glcfactor2 = path4+'Flame_Smol_GlC_eFs.csv'

; Set up output file (comma delimited text file)
if type eq 1 then  outfile = 'testHayman_run_CF.txt'
if type eq 2 then  outfile = 'testHayman_run_FEPS.txt'
    openw, 6, path2+outfile
      print, 'opened ', path2+outfile
if type eq 1 then begin
    printf, 6, 'j,longitude,latitude,day,glc,lct,pct_tree,pct_herb,pct_bare,area,bmass,nothing,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
endif
if type eq 2 then begin
    printf, 6, 'j,longitude,latitude,day,glc,lct,pct_tree,pct_herb,pct_bare,area,Bflame,Bsmolder,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
endif
    form = '(I5,",",D20.10,",",D20.10,",",(6(I5,",")),3(D20.10,","),8(D25.10,","))'




; ****************************************************************************************
; Read in FIRE FILE
; SKIP FIRST LINE WITH LABELS
    intemp=ascii_template(infile)
    map=read_ascii(infile, template=intemp)
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

; NOTE: On runs for September 15, 2004: Do not include AK, CAnada, and US Fuels maps
;$$ 7. AK
;$$ 8. AK+1
;$$ 9. US NFDRS
;$$ 10. CAN_Fuels

    lat = map.field01
    lon = map.field02
    day = map.field04
    glc = map.field07
    lct = map.field08
    tree = map.field09
    herb = map.field11
    bare = map.field10
    ;lct1 = map.field12


; Read in fuel load for GLC
    inload3=ascii_template(glcfuelload)
    glcfuelload=read_ascii(glcfuelload, template=inload3)

; Read in GLC emission factors
; DEPENDS WHICH TYPE OF ALGORITHMS USED!!!
    if type eq 1 then begin
        inload4 = ascii_template(glcfactor)
        glc_ef = read_ascii(glcfactor, template=inload4)
    endif
    if type eq 2 then begin
        inload4 = ascii_template(glcfactor2)
        glc_ef = read_ascii(glcfactor2, template=inload4)
    endif

; Set up the moisture stuff from FEPS
       mcf = fltarr(6,4)
       ; First array variable - moisture
       ; second array variable - vegtation
    ; Canopy
       mcf(0,0) = 0.33
       mcf(1,0) = 0.5
       mcf(2,0) = 1.0
       mcf(3,0) = 2.0
       mcf(4,0) = 4.0
       mcf(5,0) = 5.0
    ; Shrub
       mcf(0,1) = 0.25
       mcf(1,1) = 0.33
       mcf(2,1) = 0.5
       mcf(3,1) = 1.0
       mcf(4,1) = 2.0
       mcf(5,1) = 4.0
    ; Grass
       mcf(0,2) = 0.125
       mcf(1,2) = 0.25
       mcf(2,2) = 1.0
       mcf(3,2) = 2.0
       mcf(4,2) = 4.0
       mcf(5,2) = 5.0
    ; Duff
       mcf(0,3) = 0.33
       mcf(1,3) = 0.5
       mcf(2,3) = 1.0
       mcf(3,3) = 2.0
       mcf(4,3) = 4.0
       mcf(5,3) = 5.0

; Ste up Counters
    vcfcount = 0
    urbcount = 0
    glccount = 0
; *********************************************************************
; ***********************************************************************

 ; START LOOP OVER FIRE PIXELS
 for j =0,nfires-1 do begin

;
; Determine if data are there
; VCF product
;   IF VCF produvt unidentified, then assume all herbaceous
    if tree[j] gt 100 then begin
       vcfcount = vcfcount+1
       herb[j] = 100
       bare[j] = 0
       tree[j] = 0
    endif
;; GLC Product
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
; FIrst- determine if water or unknown

       If (glc[j] eq 24) or (glc[j] eq 26) then begin
           print, 'The GLC for this cell is WATER, SNOW/ICE or unknown.  j=',j
           ; IS there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.011) AND lat lt (lat[j]+0.011))
                 samelon = where(lon gt (lon[j]-0.014) AND lon lt (lon[j]+0.014))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if (locnear[0] ne 24) AND (locnear[0] ne 26) then begin
                        lct[j] = lct[locnear[0]]
                    endif else begin
                    print, 'All nearby cells have GLC = water, unkonwn, etc.. Assume GLC = 13 (grasslands)'
                    glc[j] = 13
                    urbcount = urbcount+1
                    endelse
                endif else begin
                    print, 'no nearby cells to assign GLC value. Assume GLC = 13 (grasslands)'
                    glc[j] = 13
                    urbcount = urbcount+1
                endelse
          print, 'override to grasslands because its water'
          glc[j] = 13 ; CHECK THIS LINE OF CODE
        endif

; Next- determine if land cover is urban/built-up. If so- assign land cover of nearby vegetation (1/3 biomass)
         If glc[j] eq 22 then begin
          print, 'Urban Cell! GLC Value = 22. Loop Number = ', j
           ; IS there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.011) AND lat lt (lat[j]+0.011))
                 samelon = where(lon gt (lon[j]-0.014) AND lon lt (lon[j]+0.014))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if locnear[0] ne 22 then begin
                        glc[j] = lct[locnear[0]]
                    endif else begin
                      print, 'no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
                      glc[j] = 13
                      urbcount = urbcount+1
                    endelse
                 endif else begin
                    print, 'no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
                    glc[j] = 13
                    urbcount = urbcount+1
                endelse
                glc[j] = 13
         p = 0.5 ; multiply land cover biomass by 50% in urban and built-up regions
         endif

       index = where(glcfuelload.field01 eq glc[j])

; ASSIGN RSF (fraction of large wood that is burned as a result of smoldering combusition
       RSF =1.0

; ASSIGN TFF (tree Felled Factor)
       TFF = 1.0
; **************************CHOSE ALGORITHMS************************************************
if type eq 1 then goto, TYPE1
if type eq 2 then goto, TYPE2

;*********************************************************************************************
; ****************************TYPE 1 CALCULATIONS ******************************************
; **** based onIto and Penner, 2004 ********************************************************
TYPE1:
; ASSIGN CF VALUES
      CF1 = glcfuelload.field08[index[0]]   ; live woody biomass
      CF2 = glcfuelload.field09[index[0]]   ; Stump woody biomass
      CF3 = glcfuelload.field10[index[0]]   ; leaf biomass
      CF4 = glcfuelload.field11[index[0]]   ; herbaceous
      CF5 = glcfuelload.field12[index[0]]   ; Litter
      CF6 = glcfuelload.field13[index[0]]   ; CWD

    if (tree[j] gt 40) and (tree[j] le 60) then begin
       CF3 = exp(-0.013*(tree[j]/100.))
       CF1 = 0.30
       CF2 = 0.30
       CF6 = 0.30
       CF4 = CF3
       CF5 = CF3
    endif
    If     (tree[j] le 40) then begin
       CF3 = 0.98 ; Range is between 0.44 and 0.98
       CF4 = 0.98
       CF5 = 0.98
       CF1 = 0.30 ; Didn't say- took this value!
       CF2 = 0.30
       CF6 = 0.30
    endif

; *******************************************************************************************
; Calculate the Mass burned of each classification (herbaceous, woody, and forest)
; These are in units of kg dry matter/m2
; Bmass is the total burned biomass
; Mherb is the Herbaceous biomass burned
; Mtree is the Woody biomass burned

livewoody = glcfuelload.field02[index[0]]
stumpwoody = glcfuelload.field03[index[0]]
leafbm = glcfuelload.field04[index[0]]
herbbm = glcfuelload.field05[index[0]]
littbm = glcfuelload.field06[index[0]]
CWDbm = glcfuelload.field07[index[0]]
pctherb = herb[j]/100.
pcttree = tree[j]/100.

; NOT INCLUDING STUMP WOOD RIGHT NOW

;  Grasslands
if tree[j] le 40 then begin
    Bmass = (pctherb*herbbm*CF4)+(pcttree*littbm*CF5)
;    Mherb = (pctherb*herbbm*CF4)+(pcttree*littbm*CF5)
;    Mtree = 0.0
endif
; Woodlands
if (tree[j] gt 40) and (tree[j] le 60) then begin
       Bmass = (pctherb*herbbm*CF4) + (pcttree*(littbm*CF5+ $
         leafbm*CF3+(RSF*(CWDbm*CF6+TFF*livewoody*CF1))))
;       Mherb = (pctherb*herbbm*CF4)+(pcttree**CF5)
;       Mtree = (tree[j]/100.*glcfuelload.field04[index[0]]*CF3+(RSF*((glcfuelload.field07[index[0]]*CF6)+TFF*(glcfuelload.field02[index[0]]*CF1))))
endif

; Forests
if tree[j] gt 60 then begin
       Bmass = (pctherb*herbbm*CF4) + (pcttree*(littbm*CF5+$
         leafbm*CF3+CWDbm*CF6+livewoody*CF1))
;       Mherb = (herb[j]/100.*glcfuelload.field05[index[0]]*CF4)+(tree[j]/100.*(glcfuelload.field06[index[0]]*CF5))
;       Mtree= (tree[j]/100.*glcfuelload.field04[index[0]]*CF3+glcfuelload.field07[index[0]]*CF6+glcfuelload.field02[index[0]]*CF1)
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

; PRINT RESULTS TO OUTPUT FILE
            printf,6,format=form,j,lon[j],lat[j],day[j],glc[j],lct[j],tree[j],herb[j],bare[j],area,bmass,0, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc
            goto, loop
; *********************************************************************************************
; **************************** TYPE 2 CALCULATIONS **********************************************
; ****************** based on FEPS algoirhtms ************************************************
TYPE2:
; NOTE: for the FEPS calculations, will not be using DUFF or Shrubs
; STEP 1: Calculate the percentage burned of each type of fuel:
;       LC are % burned of each type of fuel


       ; Canopy, shrub, grass, and duff
        e = 2.71828
         LCcan = 100*((1-(1/e))^(mcf(moist,0)))
         LCshrb = 100*((1-(1/e))^(mcf(moist,1)))
         LCgrass = 100*((1-(1/e))^(mcf(moist,2)))
         LCduff = 100*((1-(1/e))^(mcf(moist,3)))

       ; Woody/Broadcast Fuels
       ; Use this for
       ;          ; Made assumption here about which variable to use (0.8)!
         M1000hr = 2. ; This is in percent... needs to be added correctly!!!!!
         LCwood = (0.8)*(0.31+(31.-M1000hr))

       ; Litter/Piles
         LClit = 100.
        ;

    ; CALCULATE FUEL CONSUMERD FOR EACH CLASS (TON/ACRE)

    ; First- convert fuel load to ton/acre
    if tree[j] le 40 then begin
        woodyload = 0
    endif
    if (tree[j] gt 40) and (tree[j] le 60) then begin
       woodyload = tree[j]/100.*( glcfuelload.field04[index[0]]+(RSF*(glcfuelload.field07[index[0]]+TFF*glcfuelload.field02[index[0]]))*0.4461)
    endif
    if tree[j] gt 60 then begin
       woodyload = tree[j]/100.*((glcfuelload.field02[index[0]]+glcfuelload.field03[index[0]]+glcfuelload.field07[index[0]])*0.4461)
    endif


       litterload = herb[j]/100.*(glcfuelload.field06[index[0]])*0.4461
       leafload = tree[j]/100.*(glcfuelload.field04[index[0]])*0.4461
       herbload = herb[j]/100.*(glcfuelload.field05[index[0]])*0.4461

     ; Grass, assume hebaceous fuel loading + leaf
         bgrass = LCgrass*(herbload+leafload)/100. ; ton/acre

     ; Woody/Broadcast (assume totaal live woody, stump woody, and CWD)
         bwoody = LCwood*(woodyload)/100.

     ; Litter
         blitt = LClit * litterload/100.

     ; Biomass burned above ground (ton/acre)
         BAG  = bgrass + bwoody + blitt
         Btot = BAG
       ; Flaming Phase Consumption
         Bflame = 0.5*BAG  ; ton/acre
       ; Short Term Smoldering (ton/acre)
         if (Bflame lt (Btot-Bflame)) then begin
          Bsts = Bflame
         endif else begin
          Bsts = (Btot-Bflame)
         endelse
       ; Long Term Smoldering (ton/acre)
       ; NEED OT KNOW MOISTURE CONTENT OF DUFF
         Mduff = 0.10 ; THIS IS ASSUMED!! MAKE SURE WE CHECK******
         INVlts = 100/(e^(1*Mduff/130.))
         diff = Btot - Bflame-Bsts
       ; Since we don't have DUFF= assume:
         Blts = diff

    ; Convert Biomass burned back to kg/m2
       Bflame = Bflame *2.242
       Bsts = Bsts * 2.242
       Blts = Blts * 2.242
       Bsmolder = Blts+Bsts

    ; CALCULATE EMISSIONS USING FLAMING AND SMOLDERING EFS
    ; EMISSIONS OUTPUT in kg day-1
        ; CO2 Emissions
              emisco2 = (area*1e3*p*((glc_ef.field02[index[0]]*Bflame)+((Bsmolder)*glc_ef.field11[index[0]])))
          ; CO Emissions
              emisco = (area*1e3*p*((glc_ef.field03[index[0]]*Bflame)+((Bsmolder)*glc_ef.field12[index[0]])))
          ; PM10 Emissions
              emispm10 = (area*1e3*p*((glc_ef.field04[index[0]]*Bflame)+((Bsmolder)*glc_ef.field13[index[0]])))
          ; PM2.5 Emissions
              emispm25 = (area*1e3*p*((glc_ef.field05[index[0]]*Bflame)+((Bsmolder)*glc_ef.field14[index[0]])))
          ; NOx Emissions
              emisnox = (area*1e3*p*((glc_ef.field06[index[0]]*Bflame)+((Bsmolder)*glc_ef.field15[index[0]])))
          ; NH3 Emissions
              emisnh3 = (area*1e3*p*((glc_ef.field07[index[0]]*Bflame)+((Bsmolder)*glc_ef.field16[index[0]])))
          ; SO2 Emissions
              emisso2 = (area*1e3*p*((glc_ef.field08[index[0]]*Bflame)+((Bsmolder)*glc_ef.field17[index[0]])))
          ; VOC Emissions
              emisvoc = (area*1e3*p*((glc_ef.field09[index[0]]*Bflame)+((Bsmolder)*glc_ef.field18[index[0]])))

; PRINT RESULTS TO OUTPUT FILE
            printf,6,format=form,j,lon[j],lat[j],day[j],glc[j],lct[j],tree[j],herb[j],bare[j],area,Bflame,Bsmolder, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc
            goto, loop

loop:
endfor ; END LOOP OVER THE FIRES FOR THE DAY (j loop)



; END PROGRAM

quitearly:
print, 'The total number of fires processed were: ', nfires
print, 'The number of fire with unknown VCF product were:', vcfcount
print, 'The number of fires with no GLC value were: ', glccount
print, 'the total number of fires within urban or other landscapes were:', urbcount
t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'
junk = check_math() ;This clears the math errors

close,/all   ;make sure ALL files are closed
end
