;*************************************************************************************
; This program takes the fire model output (comma-delimited emissions, glc, etc.)
;   1) converts the species to SAPRC99 species (including Speciation of VOC emissions)
;
;
; January 6, 2005: First draft of program written, Christine Wiedinmyer
;    This version only does speciation and prints out the results (Jan. 7)
; January 13, 2005: Edited to include the time zone in which the grid lies
; March 18, 2005: Edited to correct for the way in which the SAPRC99 species
;   were being calculated!! (anything up until this date is incorrect!)
; April 15, 2005: Ran program for 2002 fires for input to CMAQ
; October 16, 2008: Ran program for 2006 fires for Mary Barth's 12km southern US domain
; 	Gabi will apply an hourly distribution after
; 	Checking code to make sure it still makes sense
; Ran on Feb. 23, 2009 to process Gabi's 2008 emission estimates
; JULY 07, 2009:
; 	- edited to process the 2008 fire emissions created on May 14, 2009
; AUGUST 18, 2009:
; 	- Edited to run with the file that I made for Rajesh (FIREEMIS_JAN-OCT2008_ASIA
; 	- This takes in the global LCT and not the regional file
; 	- PMc = TPM - PM2.5
; SEPTEMBER 08, 2009: 
;   - Edited this to run with the latest fire emisisons file I made for Rajesh (FIREEMIS_OCT_DEC2008_ASIA.txt)
;   - NOTE: Also have to change the paths of all files, since D drive is now F drive
; SEPTEMBER 29, 2009: 
;   - edited to run with 2008 ASIA emissions for Pallavi of Iowa  
;   - edited to run with 2007 fire file in Europe for Alma (has same headers as Pallavi's file)
;   - Edited to run with the 2003 Europe file for Alma (emissions created 09/29/2009)
;   
;**************************************************************************************

pro saprcspeciate

close, /all

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; USER CHANGE THESE Following inputs
; Get pathways
	; edited 10/16/2008
;    inpath = 'D:\Data2\wildfire\Gabi_Pfister\Fire_Emis2008\Model_output\'
;    outpath = 'D:\Data2\wildfire\Gabi_Pfister\Fire_Emis2008\Model_output\Speciate\';
;    inpath2 = 'D:\Data2\wildfire\EPA_EI\MODEL\SAPRC99\'

; Paths for July 07, 2009
;	inpath = 'D:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\'
;	outpath = 'D:\Data2\wildfire\MODEL_OUTPUTS\REGIONAL\GABI\'

; PATHS for AUGUST 18, 2009
;	outpath = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\'

; PATHS FOR SEPT. 08, 2008
; outpath = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\'

; Set Files
;   This is the file created from the emissions model output and joined (spatially) with the
;   CU modeling domain
; infile = inpath+'FIREEMIS_2008.txt'

; JULY 07, 2009
; infile = inpath+'FIREEMIS_2008_05142009.txt'

; AUGUST 18, 2009
;	infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\FIREEMIS_JAN_OCT2008_ASIA.txt'

; SEPT. 08, 2009
;  infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\FIREEMIS_OCT_DEC2008_ASIA.txt'

; SEPT. 29, 2009
;   infile = 'F:\Data2\wildfire\PALLAVI\FIREEMIS_2008_PALLAVI.txt' ; Pallavi's file
;   infile =  'F:\Data2\wildfire\ALMA\NEW_092009\FIREEMIS_MAY_SEPT2007_EUROPE.txt' ; Alma's 2007 file
    infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPT2009\ALMA\EUROPE2003_FIREEMIS.txt' ; New Europe 2003 fire emissions creates 09/29/2009

;   This is the name of the created output file
;    outfile = outpath+'FireEmiss_Speciated_2008.txt'
; 	July 07, 209
;	outfile = outpath+'FireEMIS_2008_SAPRC_05142009.txt'

; OUTPUT FILE, AUGUST 18, 2009
;	outfile = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\FIREEMIS_JAN-OCT2008_SAPRC.txt'

; OUTPUT FILE, SEPT. 08, 2009
; outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUGUST2009\GIS\RAJESH\FIREEMIS_OCT-DEC2008_SAPRC.txt'

; OUTPUT FILE, SEPT.  29, 2009
;  outfile = 'F:\Data2\wildfire\PALLAVI\FIREEMIS_2008_PALLAVI_SAPRC99.txt' ; Pallavi's file
;  outfile = 'F:\Data2\wildfire\ALMA\NEW_092009\FIREEMIS_MAY_SEPT2007_EUROPE_SAPRC99.txt'
;  outpath = 'F:\Data2\wildfire\ALMA\NEW_092009\'
  outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPT2009\ALMA\EUROPE2003_FIREEMIS_SAPRC99.txt'
  outpath = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPT2009\ALMA\'

  
;   This is a file created to check the emisisons output
    checkfile = outpath+'check_speciation_daily.txt'

;   This is the input file needed to speciate the VOC emissions
;   to SAPRC99 Chemical species
    saprcfile = 'F:\Data2\wildfire\EPA_EI\MODEL\SAPRC99\saprcspecies.txt'

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; Read in SAPRC speciation file
        inload4 = ascii_template(saprcfile)
        saprcin = read_ascii(saprcfile,template=inload4)
         ; Field01 = index for each compound (can be ignored
         ; Field02 = Fraction of Sanannah/Grasslands VOC emissions
         ; Field03 = Fraction of Tropical Forest VOC emissions
         ; Field04 = Fraction of Extratropical Forest VOC emissions
         ; Field05 = Molecular weight (g/mole) of that compound
         ; Field06 = Multiplication factor for SAPRC Species
         ; Field07 = SAPRC Species

; Open input file emissions file and get the needed variables
; This is the header of the emissions file that I made for Gabi:
; longi,lat,day,glc,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state,F26
        intemp=ascii_template(infile)
        fire=read_ascii(infile, template=intemp)
        ; Fields of Concern:
; The following is from Gabi's emission file for 2008 created on 02/20/2009
; 1,2     3   4   5     6         7       8      9   10   11    12  13 14   15   16  17 18  19  20  21   22   23  24    25    26
;j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state, FED

; Edited these on Feb. 23, 2009:
        ; Field04 = day
        ; Field02 = Longitude
        ; Field03 = Latitude
        ; Field05 = GLC Code
        ; Field13 = CO
        ; Field16 = NOx
        ; Field17 = NH3
        ; Field18 = SO2
        ; Field20 = CH4 --> IGNORE: not included in CMAQ simulations (as of now!)
        ; Field19 = VOC
        ; Field14 = PM10
        ; Field15 = PM2.5
        ; Emissions are in kg/km2/day

;; Edited these on 02/23/2009
;       glc = fire.field05
;       totfires = n_elements(fire.field01)
;       day = fire.field04
;       totVOC=fire.field19 ;(added this on Oct. 16, 2008), edited field on 02.23.2009
;	   lati = fire.field03
;	   longi = fire.field02

; JULY 07, 2009
; 1   2    3   4   5     6        7        8      9  10    11    12 13  14   15   16 17  18  19  20  21  22    23 24 25  26    27    28
; j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,OC,BC,cntry,state, FED

; AUGUST 18, 2009, RAJESH ASIA FILE
;  1     2   3    4   5    6     7       8        9       10       11   12   13  14 15 16 17  18  19  20  21  22   23
; longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM,

; SEPT. 08, 2009, Rajesh ASIA FILE #2
; 1     2   3   4    5   6     7    8     9  10 11 12 13  14  15  16  17  18    19
;longi,lat,day,TIME,lct,genLC,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM,
;     genveg = fire.field06
;     day = fire.field03
;     totVOC=fire.field16
;	   lati = fire.field02
;	   longi = fire.field01
;     totfires = n_elements(fire.field01)

; SEPT. 29, 2009: PALLAVI ASIA FILE, Also for Alma's file
; 1       2    3       4     5      6       7     8        9       10          11         12         13    14      15    16   17   18   19    20    21     22   23    24     25
; "FID_","j","longi","lat","day_","TIME_","lct","genLC","globreg","pct_tree","pct_herb","pct_bare","area","bmass","CO2","CO","OC","BC","NOx","NH3","SO2","VOC","CH4","PM25","TPM","F25"
; "FID_","j","longi","lat","day_","TIME_","lct","genLC","globreg","pct_tree","pct_herb","pct_bare","area","bmass","CO2","CO","OC","BC","NOx","NH3","SO2","VOC","CH4","PM25","TPM","F25"
; SEPT. 29, 2009: Alma's 2003 European Emissions file
; 1  2     3   4   5    6    7     8       9         10       11    12   13     14 15 16 17  18 19  20  21  22  23   24
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM
     genveg = fire.field07
     day = fire.field04
     totVOC=fire.field21
     lati = fire.field03
     longi = fire.field02
     totfires = n_elements(fire.field02)

print, 'Finished reading input files'

; Set up arrays for each of the SAPRC99 Species
; There is one entry for each of the fires in the original input file
; Just calculating the species for EACH individual fire now.
; Will allocate to each day and grid cell below
; put a "1" in front of each name to differ from final array names
    CO1=fltarr(totfires)
    ETHENE1=fltarr(totfires)
    ISOPRENE1=fltarr(totfires)
    MEOH1=fltarr(totfires)
    HCHO1=fltarr(totfires)
    CCHO1=fltarr(totfires)
    ACET1=fltarr(totfires)
    CCO_OH1=fltarr(totfires)
    HCOOH1=fltarr(totfires)
    PHEN1=fltarr(totfires)
    NO1=fltarr(totfires)
    NH31=fltarr(totfires)
    SO21=fltarr(totfires)
    OLE11=fltarr(totfires)
    OLE21=fltarr(totfires)
    ALK11=fltarr(totfires)
    ALK21=fltarr(totfires)
    ALK31=fltarr(totfires)
    ALK41=fltarr(totfires)
    ALK51=fltarr(totfires)
    ARO11=fltarr(totfires)
    ARO21=fltarr(totfires)
    BALD1=fltarr(totfires)
    MEK1=fltarr(totfires)
    TRP11=fltarr(totfires)
    PROD21=fltarr(totfires)
    PEC1=fltarr(totfires)
    PMFINE1=fltarr(totfires)
    POA1=fltarr(totfires)
    PMC1=fltarr(totfires)

; Edited the output file on October 16, 2008 (got rid of CMAQ grid information and time zone- put back in Lat/long)
openw, 5, outfile
;printf, 5, 'DAY,GLC,LATI,LONGI,CO,ETHENE,ISOPRENE,MEOH,HCHO,CCHO,ACET,CCO_OH,HCOOH,PHEN,NO,NH3,SO2,OLE1,OLE2,ALK1,ALK2,ALK3,ALK4,ALK5,ARO1,ARO2,BALD,MEK,TRP1,PROD2,PEC,PMFINE,POA,PMC'
;form='(I6,",",I6,",",32(D20.10,","))'
; AUGUST 18, 2009
printf, 5, 'DAY,GENVEG,LATI,LONGI,CO,ETHENE,ISOPRENE,MEOH,HCHO,CCHO,ACET,CCO_OH,HCOOH,PHEN,NO,NH3,SO2,OLE1,OLE2,ALK1,ALK2,ALK3,ALK4,ALK5,ARO1,ARO2,BALD,MEK,TRP1,PROD2,PEC,PMFINE,POA,PMC'
form='(I6,",",I6,",",32(D20.10,","))'

; ****************************************************************************
; SPECIATE ALL EMISSIONS AND PUT THEM IN SAPRC SPECIES FOR EACH FIRE POINT
print, "the number of fires is:", totfires
for i = 0L,totfires-1 do begin
; Edited these on Feb. 23, 2009:
        ; Field04 = day
        ; Field02 = Longitude
        ; Field03 = Latitude
        ; Field05 = GLC Code
        ; Field13 = CO
        ; Field16 = NOx
        ; Field17 = NH3
        ; Field18 = SO2
        ; Field20 = CH4 --> IGNORE: not included in CMAQ simulations (as of now!)
        ; Field19 = VOC
        ; Field14 = PM10
        ; Field15 = PM2.5
        ; Emissions are in kg/km2/day

; JULY 07, 2009
; 1   2    3   4   5     6        7        8      9  10    11    12 13  14   15   16 17  18  19  20  21  22    23 24 25  26    27    28
; j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,FRP,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,OC,BC,cntry,state, FED


; ; AUGUST 18, 2009, RAJESH ASIA FILE
;  1     2   3    4   5    6     7       8        9       10       11   12   13  14 15 16 17  18  19  20  21  22   23
; longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM,

; SEPT. 08, 2009, Rajesh ASIA FILE #2
; 1     2   3   4    5   6     7    8     9  10 11 12 13  14  15  16  17  18    19
;longi,lat,day,TIME,lct,genLC,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM,

;  SEPT. 29, 2009: PALLAVI ASIA FILE
; 1       2    3       4     5      6       7     8        9       10          11         12         13    14      15    16   17   18   19    20    21     22   23    24     25
; "FID_","j","longi","lat","day_","TIME_","lct","genLC","globreg","pct_tree","pct_herb","pct_bare","area","bmass","CO2","CO","OC","BC","NOx","NH3","SO2","VOC","CH4","PM25","TPM","F25"

; SEPT. 29, 2009: Alma's 2003 European Emissions file
; 1  2     3   4   5    6    7     8       9         10       11    12   13     14 15 16 17  18 19  20  21  22  23   24
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM
 

; ***** EDIT ACCORDING TO INPUT FILE *****
    CO1[i] = fire.field15[i]/28*1000   ; Emissions in mole/km2/day
    NO1[i] = fire.field18[i]/30*1000   ; ASSUME NOX as NO
    NH31[i] = fire.field19[i]/17*1000
    SO21[i] = fire.field20[i]/64*1000

    ; Particulate Species (in g/km2/day)
      ;The first 3 items here- speciated based on notes from Sreela (WRAP???)
      ; edited fields on 02.23.2009
      ; Take fractions of PM2.5 
       PEC1[i] = fire.field23[i]*0.09*1000     ; Elemental Carbon
       PMFINE1[i] = fire.field23[i]*0.274*1000 ; PM fine
       POA1[i] = fire.field23[i]*0.636*1000  ; Organic Aerosol
      ; Assume coarse aerosol is the difference between PM10 and PM2.5
      ; AUGUST 18, 2009: Assume difference between TPM and PM2.5 (overestimate!)
       PMC1[i] = (Fire.field24[i] - fire.field23[i])*1000    ; Coarse Aerosol
       if PMC1[i] lt 0 then PMC1[i] = 0.0

; *********** FOR REGIONAL MODEL OUTPUTS *******************************************
    ;Now, need to speciate the VOC emissions to those above
    ; Land cover types for savannahs and grasslands
;    if glc[i] eq 1 or glc[i] eq 2 or glc[i] eq 29 then begin     ; TROPICAL Forests
;       fraction = saprcin.field3
;    endif else begin
;       if glc[i] ge 3 and glc[i] le 12 then begin          ; TEMPERATE Forests/shrublands
;         fraction = saprcin.field4
;       endif else begin
;         fraction = saprcin.field2               ; Savanna and Graassland (all others)
;       endelse
;    endelse

; *********** FOR GLOBAL MODEL OUTPUTS **********************************************
; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and svanna
;    2 = woody savanna
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)

	if genveg[i] eq 3 then begin     ; TROPICAL Forests
    	   fraction = saprcin.field3
	endif else begin
	if genveg[i] eq 4 or genveg[i] eq 5 then begin          ; TEMPERATE Forests/shrublands
    	     fraction = saprcin.field4
	endif else begin
    	     fraction = saprcin.field2               ; Savanna and Graassland (all others)
    endelse
	endelse


 ; ACETONE
    points = where(saprcin.field7 eq 'ACET')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ACET1[i] = ACET1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ;  gives mole/km2/day
    endfor

 ; ALK1
    points = where(saprcin.field7 eq 'ALK1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK11[i] = ALK11[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK2
    points = where(saprcin.field7 eq 'ALK2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK21[i] = ALK21[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000 ) ; gives mole/km2/day
    endfor

 ; ALK3
    points = where(saprcin.field7 eq 'ALK3')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK31[i] = ALK31[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK4
    points = where(saprcin.field7 eq 'ALK4')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK41[i] = ALK41[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK5
    points = where(saprcin.field7 eq 'ALK5')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK51[i] = ALK51[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ARO1
    points = where(saprcin.field7 eq 'ARO1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ARO11[i] = ARO11[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ARO2
    points = where(saprcin.field7 eq 'ARO2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ARO21[i] = ARO21[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; BALD
    points = where(saprcin.field7 eq 'BALD')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       BALD1[i] = BALD1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; CCHO
    points = where(saprcin.field7 eq 'CCHO')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       CCHO1[i] = CCHO1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; CCO_OH
    points = where(saprcin.field7 eq 'CCO_OH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       CCO_OH1[i] = CCO_OH1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ETHENE
    points = where(saprcin.field7 eq 'ETHENE')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ETHENE1[i] = ETHENE1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; HCHO
    points = where(saprcin.field7 eq 'HCHO')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       HCHO1[i] = HCHO1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; HCOOH
    points = where(saprcin.field7 eq 'HCOOH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       HCOOH1[i] = HCOOH1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ISOPRENE
    points = where(saprcin.field7 eq 'ISOPRENE')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ISOPRENE1[i] = ISOPRENE1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; MEK
    points = where(saprcin.field7 eq 'MEK')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       MEK1[i] = MEK1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; MEOH
    points = where(saprcin.field7 eq 'MEOH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       MEOH1[i] = MEOH1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; OLE1
    points = where(saprcin.field7 eq 'OLE1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       OLE11[i] = OLE11[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; OLE2
    points = where(saprcin.field7 eq 'OLE2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       OLE21[i] = OLE21[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; PHEN
    points = where(saprcin.field7 eq 'PHEN')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       PHEN1[i] = PHEN1[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; PROD2
    points = where(saprcin.field7 eq 'PROD2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       PROD21[i] = PROD21[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; TRP1
    points = where(saprcin.field7 eq 'TRP1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       TRP11[i] = TRP11[i]+(totVOC[i]*fraction[points[j]]/saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor
; Edited the printout on October 16, 2008
; printf, 5, 'DAY,GLC,LATI,LONGI,CO,ETHENE,ISOPRENE,MEOH,HCHO,CCHO,ACET,CCO_OH,HCOOH,PHEN,NO,NH3,SO2,OLE1,OLE2,ALK1,ALK2,ALK3,ALK4,ALK5,ARO1,ARO2,BALD,MEK,TRP1,PROD2,PEC,PMFINE,POA,PMC'
;form='(I6,",",I6,",",32(D20.10,","))'
    printf,5,format=form, day[i],genveg[i],lati[i],longi[i],CO1[i],ETHENE1[i],ISOPRENE1[i],MEOH1[i],HCHO1[i],CCHO1[i],$
       ACET1[i],CCO_OH1[i],HCOOH1[i],PHEN1[i],NO1[i],NH31[i],SO21[i],OLE11[i],OLE21[i],ALK11[i],ALK21[i],ALK31[i],ALK41[i],$
       ALK51[i],ARO11[i],ARO21[i],BALD1[i],MEK1[i],TRP11[i],PROD21[i],PEC1[i],PMFINE1[i],POA1[i],PMC1[i]

endfor ; End of loop calculating the speciated VOC emissions for every point
; ****************************************************************************************************
close, /all

print,'This program is done!'

End