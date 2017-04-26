 ; *********************************************************
 ; This program reads in an ASCII grid file (in ESRI format)
 ; This program then calculates the fire emissions for
 ; North America for 1 day.
 ;
 ; Created by originally Christine, 05/13/03
 ; Got help from Louisa to read in large North American files 02/2004
 ; Edited and rewritten by Christine 02/26/04
 ;
 ; Completed first draft 03/01/04
 ; Ran with test case on 03/02/04
 ; Ran with North America on Zeus 03/08/04 - worked!
 ; Editing 03/09/04 to include all emissions (not just CO)
 ; Edited on 03/11/04 to run for Colorado case
 ; Edited on 03/18/04 to have varying estimated burn area
 ;  based on fires located in joining pixels- have to change from
 ;  one-dimensional arrays to 2-dim in the input files (will not work
 ;  with the larger files)
 ; Version 5: Modified on 04/01/04 to cut out a lot of the crap
 ;  also, to try to incoporate some of the FEPS algorithms
 ;  for smoldering/flaming
 ;  Note: this version is still meant for Colorado and smaller domains only
 ; July 27, 2004: This version is edited for the COlorado June 2002 test case
 ;  reading in base map file and 6 individual fire text files (made my Angie)
 ;  using the FEPS base algorithms
 ; September 2, 2004: Edited program to read in monthly files that contain all of the base
 ;  map information
 ; Edited on September 8- to get it to work with the Hayman fire data only
 ;***********************************************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds

; SET FLAG FOR ONLY CALCULATING THE GLC STUFF
 glc_flag = 0   ; value = 0 to do regular
           ; value  = 1 to only use GLC data

;************************************************************************************
; Set up biomass and emission factor tables
; The first element in the arrays are for FORESTED and the second is for HERBACEOUS
; in each land cover
; EMISSION FACTOR   Array 1: 0=flaming, 1=smoldering
;             Array 2: compound
;               0=CO2, 1=CO, 2=PM10, 3=PM2.5, 4=NOx, 5=NH3, 6=SO2, 7=VOC
;             Array 3: lct
;             (Units are in g/kg)
    emisfac=fltarr(2,8,18)
; See Spreadsheet for references and sources of emission factors
; Mostly from Battye & Battye EPA report
;   some from the CARB web document on Ag emissions
;
;
; DEFINE EACH ARRAY (based on tables that were made originally in EXCEL
; Can add another array variable to account for more specific ecosystem information
;    when this becomes available
    ; Define values for lct = 0 (WATER)
    ;     leave it all as it - 0
    ;
 ; Define Values for lct = 1 (evergreen needleleaf forest)
      emisfac[0,0,1]=1569. ; flaming, CO2
      emisfac[0,1,1]=46.  ; flaming, CO
      emisfac[0,2,1]=6.9  ; flaming, PM10
      emisfac[0,3,1]=6.1  ; flaming, PM2.5
      emisfac[0,4,1]=5.1  ; flaming, NOX
      emisfac[0,5,1]=0.04  ; flaming, NH3
       emisfac[0,6,1]=1.2  ; flaming, SO2
       emisfac[0,7,1]=1.5  ; flaming, VOC
       emisfac[1,0,1]=1569.  ; herbaceous, CO2
       emisfac[1,1,1]=159.  ; smoldering, CO
       emisfac[1,2,1]=14.45  ; smoldering, PM10
       emisfac[1,3,1]=13.48  ; smoldering, PM2.5
       emisfac[1,4,1]=0.4  ; smoldering, NOx
       emisfac[1,5,1]=2.24  ; smoldering, NH3
       emisfac[1,6,1]=1.63  ; smoldering, SO2
       emisfac[1,7,1]=5.3  ; smoldering, VOC
; Define Values for lct = 2 (evergreen broadleaf flaming)
      emisfac[0,0,2]=1569. ; flaming, CO2
      emisfac[0,1,2]=46.  ; flaming, CO
      emisfac[0,2,2]=7.  ; flaming, PM10
      emisfac[0,3,2]=6.1  ; flaming, PM2.5
      emisfac[0,4,2]=5.1  ; flaming, NOX
      emisfac[0,5,2]=0.28  ; flaming, NH3
       emisfac[0,6,2]=1.2  ; flaming, SO2
       emisfac[0,7,2]=1.5  ; flaming, VOC
       emisfac[1,0,2]=1569.  ; smoldering, CO2
       emisfac[1,1,2]=183.  ; smoldering, CO
       emisfac[1,2,2]=13.  ; smoldering, PM10
       emisfac[1,3,2]=11.7  ; smoldering, PM2.5
       emisfac[1,4,2]=0.4  ; smoldering, NOx
       emisfac[1,5,2]=0.28  ; smoldering, NH3
       emisfac[1,6,2]=1.63  ; smoldering, SO2
       emisfac[1,7,2]=5.29  ; smoldering, VOC
; Define Values for lct = 3 (deciduous needleleaf flaming)
      emisfac[0,0,3]=1569. ; flaming, CO2
      emisfac[1,0,3]=1569.  ; smoldering, CO2
      emisfac[0,1,3]=46.  ; flaming, CO
      emisfac[1,1,3]=159.  ; smoldering, CO
      emisfac[0,2,3]=6.9  ; flaming, PM10
      emisfac[1,2,3]=14.45  ; smoldering, PM10
      emisfac[0,3,3]=6.1  ; flaming, PM2.5
      emisfac[1,3,3]=13.8  ; smoldering, PM2.5
      emisfac[0,4,3]=5.1  ; flaming, NOX
      emisfac[1,4,3]= 0.4; smoldering, NOx
      emisfac[0,5,3]=0.04  ; flaming, NH3
      emisfac[1,5,3]=2.24  ; smoldering, NH3
       emisfac[0,6,3]=1.2  ; flaming, SO2
       emisfac[1,6,3]=1.63  ; smoldering, SO2
       emisfac[0,7,3]=1.5  ; flaming, VOC
       emisfac[1,7,3]=5.3  ; smoldering, VOC
; Define Values for lct = 4 (deciduous braodleaf flaming)
      emisfac[0,0,4]=1569. ; flaming, CO2
      emisfac[1,0,4]=1569.  ; smoldering, CO2
      emisfac[0,1,4]=46.  ; flaming, CO
      emisfac[1,1,4]=183.  ; smoldering, CO
      emisfac[0,2,4]=7.  ; flaming, PM10
      emisfac[1,2,4]=13.  ; smoldering, PM10
      emisfac[0,3,4]=6.1  ; flaming, PM2.5
      emisfac[1,3,4]=11.7  ; smoldering, PM2.5
      emisfac[0,4,4]=5.1  ; flaming, NOX
      emisfac[1,4,4]=0.4  ; smoldering, NOx
      emisfac[0,5,4]=0.28  ; flaming, NH3
      emisfac[1,5,4]=0.28  ; smoldering, NH3
       emisfac[0,6,4]=1.2  ; flaming, SO2
       emisfac[1,6,4]=1.63  ; smoldering, SO2
       emisfac[0,7,4]=1.5  ; flaming, VOC
       emisfac[1,7,4]=5.3  ; smoldering, VOC
; Define Values for lct = 5 (mixed flaming)
      emisfac[0,0,5]=1569. ; flaming, CO2
       emisfac[1,0,5]=1569.  ; smoldering, CO2
      emisfac[0,1,5]=46.  ; flaming, CO
      emisfac[1,1,5]=171.  ; smoldering, CO
      emisfac[0,2,5]=7.0  ; flaming, PM10
      emisfac[1,2,5]=13.7  ; smoldering, PM10
      emisfac[0,3,5]=6.1  ; flaming, PM2.5
      emisfac[1,3,5]=12.59  ; smoldering, PM2.5
      emisfac[0,4,5]=5.1  ; flaming, NOX
      emisfac[1,4,5]=0.4  ; smoldering, NOx
      emisfac[0,5,5]=0.16  ; flaming, NH3
      emisfac[1,5,5]=1.26  ; smoldering, NH3
       emisfac[0,6,5]=1.2  ; flaming, SO2
       emisfac[1,6,5]=1.63  ; smoldering, SO2
       emisfac[0,7,5]=1.5  ; flaming, VOC
       emisfac[1,7,5]=5.3  ; smoldering, VOC
; Define Values for lct = 6 (closed shrubland)
      emisfac[0,0,6]=1569. ; flaming, CO2
      emisfac[1,0,6]=1569.  ; smoldering, CO2
      emisfac[0,1,6]=60.  ; flaming, CO
      emisfac[1,1,6]=99.  ; smoldering, CO
      emisfac[0,2,6]=8.3  ; flaming, PM10
      emisfac[1,2,6]=12.4  ; smoldering, PM10
      emisfac[0,3,6]=6.8  ; flaming, PM2.5
      emisfac[1,3,6]=10.8  ; smoldering, PM2.5
      emisfac[0,4,6]=5.6  ; flaming, NOX
      emisfac[1,4,6]=3.0  ; smoldering, NOx
      emisfac[0,5,6]=0.12  ; flaming, NH3
      emisfac[1,5,6]=0.85  ; smoldering, NH3
       emisfac[0,6,6]=1.2  ; flaming, SO2
       emisfac[1,6,6]=3.2  ; smoldering, SO2
       emisfac[0,7,6]=1.38  ; flaming, VOC
       emisfac[1,7,6]=4.75  ; smoldering, VOC
; Define Values for lct = 7 (open shrubland)
      emisfac[0,0,7]=1569. ; flaming, CO2
      emisfac[1,0,7]=1569.  ; smoldering, CO2
      emisfac[0,1,7]=78.  ; flaming, CO
      emisfac[1,1,7]=106.  ; smoldering, CO
      emisfac[0,2,7]=15.9  ; flaming, PM10
      emisfac[1,2,7]=14.8  ; smoldering, PM10
      emisfac[0,3,7]=14.6  ; flaming, PM2.5
      emisfac[1,3,7]=13.2  ; smoldering, PM2.5
      emisfac[0,4,7]=5.6  ; flaming, NOX
      emisfac[1,4,7]=3.0  ; smoldering, NOx
      emisfac[0,5,7]=0.12  ; flaming, NH3
      emisfac[1,5,7]=0.85  ; smoldering, NH3
       emisfac[0,6,7]=1.2  ; flaming, SO2
       emisfac[1,6,7]=3.2  ; smoldering, SO2
       emisfac[0,7,7]=1.38  ; flaming, VOC
       emisfac[1,7,7]=4.75  ; smoldering, VOC
; Define Values for lct = 8 (woody savannahs)
      emisfac[0,0,8]=1569. ; flaming, CO2
      emisfac[1,0,8]=1569.  ; smoldering, CO2
      emisfac[0,1,8]=60.  ; flaming, CO
      emisfac[1,1,8]=99.  ; smoldering, CO
      emisfac[0,2,8]=8.3  ; flaming, PM10
      emisfac[1,2,8]=12.4  ; smoldering, PM10
      emisfac[0,3,8]=6.8  ; flaming, PM2.5
      emisfac[1,3,8]=10.8  ; smoldering, PM2.5
      emisfac[0,4,8]=5.6  ; flaming, NOX
      emisfac[1,4,8]=3.0  ; smoldering, NOx
      emisfac[0,5,8]=0.12  ; flaming, NH3
      emisfac[1,5,8]=0.85  ; smoldering, NH3
       emisfac[0,6,8]=1.2  ; flaming, SO2
       emisfac[1,6,8]=3.2  ; smoldering, SO2
       emisfac[0,7,8]=1.38  ; flaming, VOC
       emisfac[1,7,8]=4.75  ; smoldering, VOC
; Define Values for lct = 9 (Savannas)
      emisfac[0,0,9]=1569. ; flaming, CO2
      emisfac[1,0,9]=1569.  ; smoldering, CO2
      emisfac[0,1,9]=60.  ; flaming, CO
      emisfac[1,1,9]=99.  ; smoldering, CO
      emisfac[0,2,9]=8.3  ; flaming, PM10
      emisfac[1,2,9]=12.4  ; smoldering, PM10
      emisfac[0,3,9]=6.8  ; flaming, PM2.5
      emisfac[1,3,9]=10.8  ; smoldering, PM2.5
      emisfac[0,4,9]=5.6  ; flaming, NOX
      emisfac[1,4,9]=3.0  ; smoldering, NOx
      emisfac[0,5,9]=0.12  ; flaming, NH3
      emisfac[1,5,9]=0.85  ; smoldering, NH3
       emisfac[0,6,9]=1.2  ; flaming, SO2
       emisfac[1,6,9]=3.2  ; smoldering, SO2
       emisfac[0,7,9]=1.38  ; flaming, VOC
       emisfac[1,7,9]=4.75  ; smoldering, VOC
; Define Values for lct = 10 (Grasslands)
      emisfac[0,0,10]=1569. ; flaming, CO2
      emisfac[1,0,10]=1569.  ; smoldering, CO2
      emisfac[0,1,10]=57  ; flaming, CO
      emisfac[1,1,10]=57.  ; smoldering, CO
      emisfac[0,2,10]=8.0  ; flaming, PM10
      emisfac[1,2,10]=8.0  ; smoldering, PM10
      emisfac[0,3,10]=7.6  ; flaming, PM2.5
      emisfac[1,3,10]=7.6  ; smoldering, PM2.5
      emisfac[0,4,10]=2.8  ; flaming, NOX
      emisfac[1,4,10]=2.8  ; smoldering, NOx
      emisfac[0,5,10]=0.03  ; flaming, NH3
       emisfac[1,5,10]=0.37  ; smoldering, NH3
       emisfac[0,6,10]=0.3  ; flaming, SO2
       emisfac[1,6,10]=0.3  ; smoldering, SO2
       emisfac[0,7,10]=5.4  ; flaming, VOC
       emisfac[1,7,10]=5.4  ; smoldering, VOC
; Define Values for lct = 11 (Permanent Wetlands)
      emisfac[0,0,11]=1569. ; flaming, CO2
      emisfac[1,0,11]=1569.  ; smoldering, CO2
      emisfac[0,1,11]=57  ; flaming, CO
      emisfac[1,1,11]=57.  ; smoldering, CO
      emisfac[0,2,11]=8.0  ; flaming, PM10
      emisfac[1,2,11]=8.0  ; smoldering, PM10
      emisfac[0,3,11]=7.6  ; flaming, PM2.5
      emisfac[1,3,11]=7.6  ; smoldering, PM2.5
      emisfac[0,4,11]=2.8  ; flaming, NOX
      emisfac[1,4,11]=2.8  ; smoldering, NOx
      emisfac[0,5,11]=0.03  ; flaming, NH3
       emisfac[1,5,11]=0.37  ; smoldering, NH3
       emisfac[0,6,11]=0.3  ; flaming, SO2
       emisfac[1,6,11]=0.3  ; smoldering, SO2
       emisfac[0,7,11]=5.4  ; flaming, VOC
       emisfac[1,7,11]=5.4  ; smoldering, VOC
; Define Values for lct = 12 (Croplands)
      emisfac[0,0,12]=1569. ; flaming, CO2
      emisfac[1,0,12]=1569.  ; smoldering, CO2
      emisfac[0,1,12]=57.  ; flaming, CO
      emisfac[1,1,12]=57.  ; smoldering, CO
      emisfac[0,2,12]=8.0  ; flaming, PM10
      emisfac[1,2,12]=8.  ; smoldering, PM10
      emisfac[0,3,12]=7.6  ; flaming, PM2.5
      emisfac[1,3,12]=7.6  ; smoldering, PM2.5
      emisfac[0,4,12]=2.2   ; flaming, NOX
      emisfac[1,4,12]=2.2  ; smoldering, NOx
      emisfac[0,5,12]=0.03  ; flaming, NH3
      emisfac[1,5,12]=0.37  ; smoldering, NH3
       emisfac[0,6,12]=0.3 ; flaming, SO2
       emisfac[1,6,12]=0.3  ; smoldering, SO2
       emisfac[0,7,12]=5.4  ; flaming, VOC
       emisfac[1,7,12]=5.4  ; smoldering, VOC
; Define Values for lct = 13 (Urban & Built Up)
      emisfac[0,0,13]=0. ; flaming, CO2
      emisfac[0,1,13]=0.  ; flaming, CO
      emisfac[0,2,13]=0.  ; flaming, PM10
      emisfac[0,3,13]=0.  ; flaming, PM2.5
      emisfac[0,4,13]=0.   ; flaming, NOX
      emisfac[0,5,13]=0.  ; flaming, NH3
       emisfac[0,6,13]=0.  ; flaming, SO2
       emisfac[0,7,13]=0.  ; flaming, VOC
       emisfac[1,0,13]=0.  ; smoldering, CO2
       emisfac[1,1,13]=0.  ; smoldering, CO
       emisfac[1,2,13]=0.  ; smoldering, PM10
       emisfac[1,3,13]=0.  ; smoldering, PM2.5
       emisfac[1,4,13]=0.  ; smoldering, NOx
       emisfac[1,5,13]=0.  ; smoldering, NH3
       emisfac[1,6,13]=0.  ; smoldering, SO2
       emisfac[1,7,13]=0.  ; smoldering, VOC
; Define Values for lct = 14 (Cropland and Natural Vegetation Mosaic)
       emisfac[0,0,14]=1569. ; flaming, CO2
      emisfac[1,0,14]=1569.  ; smoldering, CO2
      emisfac[0,1,14]=57.  ; flaming, CO
      emisfac[1,1,14]=57.  ; smoldering, CO
      emisfac[0,2,14]=8.0  ; flaming, PM10
      emisfac[1,2,14]=8.  ; smoldering, PM10
      emisfac[0,3,14]=7.6  ; flaming, PM2.5
      emisfac[1,3,14]=7.6  ; smoldering, PM2.5
      emisfac[0,4,14]=2.2   ; flaming, NOX
      emisfac[1,4,14]=2.2  ; smoldering, NOx
      emisfac[0,5,14]=0.03  ; flaming, NH3
      emisfac[1,5,14]=0.37  ; smoldering, NH3
       emisfac[0,6,14]=0.3 ; flaming, SO2
       emisfac[1,6,14]=0.3  ; smoldering, SO2
       emisfac[0,7,14]=5.4  ; flaming, VOC
       emisfac[1,7,14]=5.4  ; smoldering, VOC
; Define Values for lct = 15 (Ice and Snow)
      emisfac[0,0,15]=0. ; flaming, CO2
      emisfac[0,1,15]=0.  ; flaming, CO
      emisfac[0,2,15]=0.  ; flaming, PM10
      emisfac[0,3,15]=0.  ; flaming, PM2.5
      emisfac[0,4,15]=0.   ; flaming, NOX
      emisfac[0,5,15]=0.  ; flaming, NH3
       emisfac[0,6,15]=0.  ; flaming, SO2
       emisfac[0,7,15]=0.  ; flaming, VOC
       emisfac[1,0,15]=0.  ; smoldering, CO2
       emisfac[1,1,15]=0.  ; smoldering, CO
       emisfac[1,2,15]=0.  ; smoldering, PM10
       emisfac[1,3,15]=0.  ; smoldering, PM2.5
       emisfac[1,4,15]=0.  ; smoldering, NOx
       emisfac[1,5,15]=0.  ; smoldering, NH3
       emisfac[1,6,15]=0.  ; smoldering, SO2
       emisfac[1,7,15]=0.  ; smoldering, VOC
; Define Values for lct = 16 (Barren or Sparsely Vegetated)
     emisfac[0,0,16]=1569. ; flaming, CO2
      emisfac[1,0,16]=1569.  ; smoldering, CO2
      emisfac[0,1,16]=57.  ; flaming, CO
      emisfac[1,1,16]=57.  ; smoldering, CO
      emisfac[0,2,16]=8.0  ; flaming, PM10
      emisfac[1,2,16]=8.  ; smoldering, PM10
      emisfac[0,3,16]=7.6  ; flaming, PM2.5
      emisfac[1,3,16]=7.6  ; smoldering, PM2.5
      emisfac[0,4,16]=2.2   ; flaming, NOX
      emisfac[1,4,16]=2.2  ; smoldering, NOx
      emisfac[0,5,16]=0.03  ; flaming, NH3
      emisfac[1,5,16]=0.37  ; smoldering, NH3
       emisfac[0,6,16]=0.3 ; flaming, SO2
       emisfac[1,6,16]=0.3  ; smoldering, SO2
       emisfac[0,7,16]=5.4  ; flaming, VOC
       emisfac[1,7,16]=5.4  ; smoldering, VOC


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

;**************************************************************************************
; GET INPUT AND OUTPUT FILES

; Input file pathway
    ;path = 'C:\WORK\wildfire\EPA_EI\MODEL\test_090204\'
    ;path = '/zeus/christin/FIRE/MODEL/'
    path='D:\Christine\WORK\wildfire\EPA_EI\Hayman_Fire\'
; DEfault files (i.e., fuels, emission factors, etc.)
    path4 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\default_infiles\
; Output file pathway
    ; path2 = 'C:\FIRE\ascii_grids\V003\output\'
    path2 = 'D:\Christine\WORK\wildfire\EPA_EI\Hayman_Fire\output\'

; Input fire files
    infile = path+'input.csv'

; input Fuel loading files
   nfdrsfuelload = path4+'NFRDS_fuelload_ton_acre.csv'
   canfuelload = path4+'CAN_fuelload_ton_acre.csv'
   glcfuelload = path4+'GLC_fuelload_all.csv'

; Input GLC emission factors
    glcfactor = path4+'glc_emisfactorscsv.csv'

; Set up output file (comma delimited text file)
    outfile = 'area_1_hayman_nfdrs_glc_ef.txt'
    openw, 6, path2+outfile
      print, 'opened ', path2+outfile
;   printf, 6, 'longitude,latitude,day,lct,fueltype,area,percentTree,percentherb,percentbare,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
    printf, 6, 'longitude,latitude,day,glc,lct,AKFuel,CanFuel,USFuel,area,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
    form = '(D20.10,",",D20.10,",",(6(I5,",")),1(D20.10,","),9(D25.10,","))'




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
; 5. GMT
; 6. TEMP
; 7. AK
; 8. AK+1
; 9. US NFDRS
; 10. CAN_Fuels
; 11. GLC
; 12. LCT
; 13. LCT+1
    lat = map.field01
    lon = map.field02
    day = map.field04
    akfuel = map.field08
    usfuel = map.field09
    canfuel = map.field10
    glc = map.field11
    lct = map.field13


; Read in Fuel load for NFRDS
    inload1=ascii_template(nfdrsfuelload)
    usfuelload=read_ascii(nfdrsfuelload, template=inload1)

; Read in fuel for Canada
    inload2=ascii_template(canfuelload)
    canfuelload=read_ascii(nfdrsfuelload, template=inload2)

; Read in fuel load for GLC
    inload3=ascii_template(glcfuelload)
    glcfuelload=read_ascii(glcfuelload, template=inload3)

; Read in GLC emission factors
    inload4 = ascii_template(glcfactor)
    glc_ef = read_ascii(glcfactor, template=inload4)


; SET FLAG FOR ONLY CALCULATING THE GLC STUFF
 glc_flag = 0   ; value = 0 to do regular
           ; value  = 1 to only use GLC data
;***********************************************************************

 ; START LOOP OVER FIRE PIXELS
 for j =0,nfires-1 do begin

; ******************************* FUEL MOISTURE ******************************
; MOISTURE CONTENT OF FUELS
       ; Detemine the moisture contnent
       ; 0 = Very Dry, 1 = Dry, 2 = Moderate, 3 = Moist, 4 = Wet, 5 = Very Wet
       ; Ultimately, will have a file to read in fuel moisture
       ; For now, assume Very dry (0)
         moist = 0
; **************************** AREA *******************************************
;CALCULATE FIRE AREAS

       area = 0.14 ; standard area = 0.14 km2
      ; Look First to see if fire was burning in pixel the day before
         if j eq 0 then goto, SKIPDAY1 ; can't look at prior day

        ; ADD 0.10 km2 to area if it was burning the previous day
         prevday = where(day eq j-1)
         if prevday[0] eq -1 then goto, SKIPDAY1 ; no fires on the previous day

         samelon = where(lon[prevday] eq lon[j])
         if samelon[0] eq -1 then goto, SKIPDAY1       ; no fires with the same longitude

         samelat = where(lat[samelon] eq lat[j])
         if samelat[0] ne -1 then area = 0.14 + 0.05

       SKIPDAY1:

       ; Check to see if the adjacent areas are on fire (if so, then add area)
       daynow = where(day[j] eq day[*])
       samelat = where(lat[daynow] gt (lat[j]-0.011) AND lat[daynow] lt (lat[j]+0.011))
       samelon = where(lon[daynow] gt (lon[j]-0.014) AND lon[daynow] lt (lon[j]+0.014))
       numlat = n_elements(samelat)
       numlon = n_elements(samelon)
       numadj = 0
       for l = 0, numlat-1 do begin
         same = where(samelon eq samelat[l])
         if same[0] ge 0 then numadj=numadj+1
       endfor
         print, 'Number of adjacent cells =',numadj, 'for fire #', j
         if numadj gt 9 then numadj = 9
         area = area+((numadj-1)*0.10)    ; add 0.10 km2 for every pixel on fire adjacent
         ; NOTE: MOST AREA BURNED IS 99% of Pixel
    ; DEFAULT AREAS
       ; Minimum
;      area = 0.1
       ; Maximum
      area = 1.0


; *************************** FUEL TYPES & LOADINGS ***************************************************
; GET FUEL TYPE
; FIRST CHECK IF THERE ARE SPECIFIC FUELS FOR AK (fuelmap = 1), Canada (fuelmap = 2),
;    or U.S. (fuelmap = 3). GLC (fuelmap = 4)
    fuelmap = 4 ; (Default, GLC)
    if glc_flag eq 1 then goto, FUEL4
    ; Is there any Alaskan Fuel data?
       if map.field08[j] gt 0 and map.field08[j] lt 22 then begin
         fuelmap = 1
         fuel = map.field08[j]
         goto, FUEL1
       endif
    ; Is there any Canadian Fuel Data?
       if map.field10[j] gt 0 then begin
         fuelmap = 2
         fuel = map.field08[j]
         goto, FUEL2
       endif
    ; Is there any US NFDRS Fuel Data?
       if map.field09[j] gt 0 then begin
         fuelmap = 3
         fuel = map.field09[j]
         print, 'fire in continental U.S. fuel model is :', fuel
         goto, FUEL1
       endif
if fuelmap eq 4 then goto, FUEL4

; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; I am stopping her efor the day- September 2
; Want to write 2 programs- one with FEPS for NFDRS
; one for just a generic emissions estimate across the board
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; ***************************** FUEL CONSUMED *********************************
; PERCENT OF EACH LOADING CONSUMED

FUEL1:

; These fuel loadings are for Alaska and continental US. and require NFDRS fuel
;   classification inputs

; Get the fuel loadings based on the fuel type
    ;if fuel eq 1 then begin
    ; Figure out which NFDRS fuel load we have
    ;   fuelmodel = where(usfuelload.field2 eq fuel)
    ;endif
    ;if fuel eq 3 then begin
    ;; Figure out which NFDRS fuel load we have
    ;   fuelmodel = where(usfuelload.field1 eq fuel)
    ;endif
;   LC are %
       e = 2.71828
       ; Canopy, shrub, grass, and duff
         LCcan = 100*((1-(1/e))^(mcf(moist,0)))
         LCshrb = 100*((1-(1/e))^(mcf(moist,1)))
         LCgrass = 100*((1-(1/e))^(mcf(moist,2)))
         LCduff = 100*((1-(1/e))^(mcf(moist,3)))
       ; Woody/Broadcast Fuels
       ; ****************************************************************
         ; Made assumption here about which variable to use (0.8)!
         M1000hr = 5. ; This is in percent... needs to be added correctly!!!!!
         LCwood = (0.8)*(0.31+(31.-M1000hr))
       ; Litter/Piles
         LClit = 100.
         ; This is also for piles, but since we don't know that- assume litter

    ; CALCULATE FUEL CONSUMERD FOR EACH CLASS (TON/ACRE)
       ; Shrub, assume smoldering fuel loading + 10hr fuel
         bshrb = LCshrb*(usfuelload.field09[fuel]+usfuelload.field05[fuel])/100. ; ton/acre
       ; Grass, assume hebaceous fuel loading
         bgrass = LCgrass*usfuelload.field09[fuel]/100. ; ton/acre
       ; Duff, assume Drought, very dry
         bduff = LCduff * usfuelload.field10[fuel]/100.
       ; Woody/Broadcast (assume woody + 1000hr + 100hr)
         bwoody = LCwood*(usfuelload.field08[fuel]+usfuelload.field07[fuel] $
          +usfuelload.field06[fuel])/100.
       ; Litter, assume 1 hr fuels
         blitt = LClit * usfuelload.field04[fuel]/100.

       ; Biomass burned above ground (ton/acre)
         BAG  = bshrb + bgrass + bwoody + blitt
         BBG = bduff
         Btot = BAG + BBG
       ; Flaming Phase Consumption
         Bflame = 0.5*BAG + 0.2*BBG ; ton/acre
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
         calc =   (usfuelload.field10[fuel]*INVlts/100)-Bduff
         Blts = max(diff, calc)



;************************** EMISSION CALCULATION:NFDRS PIXELS **************************************************
; CALCULATE EMISSIONS
       ; Calculate emissions if LCT = WATER, Snow/Ice, unknown
       ; *****remember- this is LCT + 1!
         If (lct[j] eq 1) or (lct[j] eq 16) or (lct[j] eq 256) or (lct[j] eq 255) then begin
           print, 'The LCT for this cell is WATER, SNOW/ICE or unknown.  j=',j
           ; IS there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.011) AND lat lt (lat[j]+0.011))
                 samelon = where(lon gt (lon[j]-0.014) AND lon lt (lon[j]+0.014))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if (locnear[0] ne 1) AND (locnear[0] ne 16) AND (locnear[0] ne 256) AND (locnear[0] ne 255) then begin
                        lct[j] = lct[locnear[0]]
                    endif else begin
                    flag =1 ; use GLC values instaed of LCT
                    print, 'All nearby cells have LCT = water, unkonwn, etc.. Assume LCT+1 = 11 (grasslands)
                    lct[j] = 11
                    endelse
                endif else begin
                    print, 'no nearby cells to assign LCT value. Assume LCT+1 = 11 (grasslands)
                    lct[j] = 11
                endelse
        endif

         ; set p = 1 for all lcts except for urban
         p=1.

       ; Calculate emissions if LCT = URBAN (13)
       ; Urban emissions use the emissions of the vegetation class next to the grid
       ; and 1/3 of the biomass density (reset value for p)
         If lct[j] eq 14 then begin
          print, 'Urban Cell! Loop Number = ', j
           ; IS there a cell nearby?
                 samelat = where(lat gt (lat[j]-0.011) AND lat lt (lat[j]+0.011))
                 samelon = where(lon gt (lon[j]-0.014) AND lon lt (lon[j]+0.014))
                 locnear = where(samelat eq samelon)
                 if locnear[0] gt -1 then begin
                    if locnear[0] ne 14 then begin
                        lct[j] = lct[locnear[0]]
                    endif else begin
                      flag =1 ; use GLC values instaed of LCT
                      print, 'no nearby cells to assign LCT value. Assume LCT+1 = 11 (grasslands)
                      lct[j] = 11
                    endelse
                 endif else begin
                    print, 'no nearby cells to assign LCT value. Assume LCT+1 = 11 (grasslands)
                    lct[j] = 11
          endelse
          p = 1./3.
          goto, calculate
         endif

         ; Calculate emissions for all other LCTs
         if (lct[j] ge 2) and (lct[j] le 17) then begin
          m = j
          goto, calculate
         endif else begin
          print, 'Something is wrong!!! lct[j] = ', lct[j]
          print, 'fire number = ', j
          print, "STOPPING PROGRAM EARLY!'
          goto, quitearly
         endelse

         calculate:
;          ; CALCULATE EMISSIONS (g emission - per day per 1km2 pixel)
;          lct2 = lct[j]-1
;          ; CO2 Emissions
;              emisco2 = (area*907.18476/0.0040468564*((emisfac[0,0,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,0,lct2])))
;          ; CO Emissions
;              emisco = area*907.18476/0.0040468564*((emisfac[0,1,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,1,lct2]))
;          ; PM10 Emissions
;              emispm10 = area*907.18476/0.0040468564*((emisfac[0,2,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,2,lct2]))
;          ; PM2.5 Emissions
;              emispm25 = area*907.18476/0.0040468564*((emisfac[0,3,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,3,lct2]))
;          ; NOx Emissions
;              emisnox = area*907.18476/0.0040468564*((emisfac[0,4,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,4,lct2]))
;          ; NH3 Emissions
;              emisnh3 = area*907.18476/0.0040468564*((emisfac[0,5,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,5,lct2]))
;          ; SO2 Emissions
;              emisso2 = area*907.18476/0.0040468564*((emisfac[0,6,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,6,lct2]))
;          ; VOC Emissions
;              emisvoc = area*907.18476/0.0040468564*((emisfac[0,7,lct2]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,7,lct2]))

       p = 1.0
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
                    endelse
                endif else begin
                    print, 'no nearby cells to assign GLC value. Assume GLC = 13 (grasslands)'
                    glc[j] = 13
                endelse
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
                    endelse
                 endif else begin
                    print, 'no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
                    glc[j] = 13
          endelse
          p = 1./3.
         endif
       index = where(glcfuelload.field1 eq glc[j])
       ; BIOMASS VALUES ARE IN UNITS kg/m2
       Bmass = glcfuelload.field2[index]
    ; Assign the percent burned
        pctburn = 0.81
       if (glc[j] ge 1) and (glc[j] le 4) or (glc[j] eq 6) or (glc[j] eq 7) then pctburn = 0.25
       if (glc[j] eq 5) or (glc[j] eq 8) or (glc[j] eq 20) or (glc[j] eq 29) then pctburn = 0.45


          ; CALCULATE EMISSIONS (g emission - per day per 1km2 pixel)- using the GLC EMISSION FACTORS
          lct2 = lct[j]-1
          ; CO2 Emissions
              emisco2 = (area*907.18476/0.0040468564*((glc_ef.field02[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field02[index])))
          ; CO Emissions
              emisco = area*907.18476/0.0040468564*((glc_ef.field03[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field03[index]))
          ; PM10 Emissions
              emispm10 = area*907.18476/0.0040468564*((glc_ef.field04[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field04[index]))
          ; PM2.5 Emissions
              emispm25 = area*907.18476/0.0040468564*((glc_ef.field05[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field05[index]))
          ; NOx Emissions
              emisnox = area*907.18476/0.0040468564*((glc_ef.field06[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field06[index]))
          ; NH3 Emissions
              emisnh3 = area*907.18476/0.0040468564*((glc_ef.field07[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field07[index]))
          ; SO2 Emissions
              emisso2 = area*907.18476/0.0040468564*((glc_ef.field08[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field08[index]))
          ; VOC Emissions
              emisvoc = area*907.18476/0.0040468564*((glc_ef.field09[index]*p*Bflame)+(p*(Bsts+Blts)*glc_ef.field09[index]))

skip:

; OUTPUT THE RESULTS INTO COMMA_DELIMITED FILE
;   printf, 6, 'longitude,latitude,day,lct,fueltype,area,percentTree,percentherb,percentbare,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
            printf,6,format=form,lon[j],lat[j],day[j],glc[j],lct2,akfuel[j]-1,canfuel[j],usfuel[j],area, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,(Bflame+Bsts+Blts)
goto, loop

FUEL4:
;*********************************************************************************************
;  THIS IS WHERE THE EMISSIONS FOR THE GLC CLASSES ARE CALCULATED
; Determine the biomass of the land cover classification
; FIrst- determine if water or unknown
       p = 1.0
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
                    endelse
                endif else begin
                    print, 'no nearby cells to assign GLC value. Assume GLC = 13 (grasslands)'
                    glc[j] = 13
                endelse
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
                    endelse
                 endif else begin
                    print, 'no nearby cells to assign GLC value from urban. Assume GLC=13 (grasslands)'
                    glc[j] = 13
          endelse
          p = 1./3.
         endif
       index = where(glcfuelload.field1 eq glc[j])
       ; BIOMASS VALUES ARE IN UNITS kg/m2
       Bmass = glcfuelload.field2[index]
    ; Assign the percent burned
        pctburn = 0.81
       if (glc[j] ge 1) and (glc[j] le 4) or (glc[j] eq 6) or (glc[j] eq 7) then pctburn = 0.25
       if (glc[j] eq 5) or (glc[j] eq 8) or (glc[j] eq 20) or (glc[j] eq 29) then pctburn = 0.45

; CALCULATE EMISSIONS
          ; CO2 Emissions
              emisco2 = pctburn*area*1000000*bmass*glc_ef.field02[index]*p
          ; CO Emissions
              emisco = pctburn*area*1000000*bmass*glc_ef.field03[index]*p
          ; PM10 Emissions
              emispm10 = pctburn*area*1000000*bmass*glc_ef.field04[index]*p
          ; PM2.5 Emissions
              emispm25 = pctburn*area*1000000*bmass*glc_ef.field05[index]*p
          ; NOx Emissions
              emisnox = pctburn*area*1000000*bmass*glc_ef.field06[index]*p
          ; NH3 Emissions
              emisnh3 = pctburn*area*1000000*bmass*glc_ef.field07[index]*p
          ; SO2 Emissions
              emisso2 = pctburn*area*1000000*bmass*glc_ef.field08[index]*p
          ; VOC Emissions
              emisvoc = pctburn*area*1000000*bmass*glc_ef.field09[index]*p

; PRTINT RESULTS

            printf,6,format=form,lon[j],lat[j],day[j],glc[j],lct[j]-1,akfuel[j]-1,canfuel[j],usfuel[j],area, $
               emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc,bmass

loop:
endfor ; END LOOP OVER THE FIRES FOR THE DAY (j loop)



; END PROGRAM

FUEL2:
quitearly:
t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'
junk = check_math() ;This clears the math errors

close,/all   ;make sure ALL files are closed
end
