; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; This program will read in the output file from the fire model, and create
; NetCDF file for Gaby
; She needs the emissions summed for each month and put onto a 1 degree resolution
;
; The extent of my North American domain is:
;    latitude: 10.03 to 70.32
;    longitude: -164.98 to -54.999
; So, her file will start with a grid centered on
;    latitude:10.5
;    longitude:-164.5
; and will end on a grid centered on:
;    latitude:70.5
;    longitude:-55.5
; Program Created November 23-24, 2004 by Christine
;
; Dec. 13, 2004: Edited this program to also include speciated VOC emissions
;   using scaling factors from Louisa (used in MOZART)
; 	ALso- for 2004: have to only have 9 months! - need to fix later
;
; FEb. 11, 2008: Edited for North American Fire emissions for California Fire 2007 study
; Feb. 23, 2009: Edited so that it speciates the emissions and outputs a text file for Gab
; 		Running with 2008 emission estimates
; APRIL 29, 2009: Editing to take the NEW 2008 EMission estimates that were created on 04/24/2009
; MAY 14, 2009: Editing to make newest 2008 estimates with new fire detections for 05/14/2009
; MAY 19, 2009: Ran with Xiaoyan's fire emissions for 2002
; JULY 02, 2009:
; 			- saved from speciate_MOZART to speciate_MOZART_AUSNZ
; 			- Saved to D:\Data2\wildfire\EPA_EI\MODEL\IDL_CODE
; 			- edited to read in the AUS/NZ fire emissions and output speciated text file
; NOVEMBER 18, 2009: 
;       - Edited this file to process global emisisons for Louisa to run the new MOZART 
;         simulations for Claire's presentation
; NOVEMBER 25, 2009
; JANUARY 29, 2010
;     - Edited to use new MOZART speciation profile developed 01/28/2010
; 
; FEBRUARY 03, 2010
;     - edited to speciate to GEOS-CHEM 
; FEBRUARY 16, 2010
;   - Created new GEOS-chem speciation table
;   - Added in HCN
;   - Added regional totals to end of file
;   - reran 2007 May-sept for Richard
; MAY 02-03, 2011
;    - Edited to include area in output file, not to have an extra  day, and not to have overlapping days in the output files
;    - Ran 2010 and 2011 for Paul Palmer and group
; MAY 04, 2011
;   - Ran 2005-2009
; May 15, 2010
;   - Ran 2002-2004  
; May 16, 2011
;   - ran Jan-Apr 2011
; 
;   
;   DECEMBER 30, 2011
;   - cleaned up a little for STACY
;   
; SEPTEMBER 11, 2012
; - Ran for 2012 Emissions from January through August  
; 
; DECEMBER 24, 2012
; - Updated this code to produce emissions from all GEOSCHEM species
; - Ran 2006 and 2007 for Jenny Fisher 
; 
; JANUARY 10, 2013
; - Rewrote this code to produce files for each land use and CO2 only.
; 
; 
; February 28, 2013
; - rewrote to export only CO, PM2.5, area, biomass for ag lands
; 
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro Create_JESSICAM_ag_File_GRID
close, /all

;Generic land cover codes (genveg) are as follows:
;    1 = grasslands and svanna
;    2 = woody savanna
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)

year = 2012
firstday =1 
lastday = 366

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\GLOBAL_2012_02272013.txt'
;outgrass = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_GRASS_02282013.txt'
;outshrub = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_SHRUB_02282013.txt'
;outtemp = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_TEMP_02282013.txt'
;outtrop = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_TROP_02282013.txt'
;outbor = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_BOR_02282013.txt'
outcrop = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\FEBRUARY2013\JESSICA\GLOB2012_CROP_grid_02282013.txt'


; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
;openw, 1, outgrass
;openw, 2, outshrub
;openw, 4, outtemp
;openw, 3, outtrop
;openw, 5, outbor
openw, 6, outcrop

;printf, 1, 'LATITUDE, LONGITUDE, CO2, CO, PM25, Area, BIOMASS'
;printf, 2, 'LATITUDE, LONGITUDE, CO2, CO, PM25, Area, BIOMASS'
;printf, 3, 'LATITUDE, LONGITUDE, CO2, CO, PM25, Area, BIOMASS'
;printf, 4, 'LATITUDE, LONGITUDE, CO2, CO, PM25, Area, BIOMASS'
;printf, 5, 'LATITUDE, LONGITUDE, CO2, CO, PM25, Area, BIOMASS'
printf, 6, 'LATITUDE, LONGITUDE, CO, PM25, BC, Area, BIOMASS'


form='(7(D20.10,","))'


; Open input file and get the needed variables
; INPUT FILES FROM JAN. 29, 2010
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18  19 20  21  22   23   24   25  26 27 28    29
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC,FACTOR
	    intemp=ascii_template(infile)
      fire=read_ascii(infile, template=intemp)
        ; Emissions are in kg/km2/day

; Edited these fields on NOV. 18, 2009
    longi = fire.field01
    lati= fire.field02
    day = fire.field03
    jday = day
    time = fire.field04
    lct = fire.field05
    genveg = fire.field06
	  CO2 = fire.field13
		CO = fire.field14
;		OC = fire.field26
		BC = fire.field27
		PM25 = fire.field24
;		NOX = fire.field17
;		NO = fire.field18
;		NO2 = fire.field19
;		NH3 = fire.field20
;		SO2 = fire.field21
;		VOC = fire.field23
;		CH4 = fire.field15
		area = fire.field11 ; added 05/02/2011; should be in m2
    bmass = fire.field12 ; Added 02/28/2013

   	numfires = n_elements(day)
		nfires = numfires

print, "FINISHED READING INPUT FILE"
print, 'Input file = ', infile
print, 'First day = ', min(day)
print, 'Last day = ', max(day)

bioburn =  fltarr(numfires)
; Calculate biomass burned
; area is in m2
; bmass is kg/m2
for i = 0,numfires-1 do begin
  bioburn[i] = area[i] * bmass[i] ; *0.000001 ; Gg biomass burned
endfor

lat0 = -90.
lon0 = -180.0

; DO LOOP 5 degree lat/long and sum for entire year
for i = 0,719 do begin ; loop over longitude
  for j = 0,359 do begin ; loop over latitude
    TOTarea = 0.0
    TOTCO = 0.0
    TOTPM25 = 0.0
    TOTBC = 0.0
    totbioburn = 0.0
    lonmin = lon0+(0.5*i)
    lonmax = lon0+(0.5*(i+1))
    latmin = lat0+(0.5*j)
    latmax = lat0+(0.5*(j+1))
    gridnow = where(genveg eq 9 and longi ge lonmin and longi lt lonmax and lati ge latmin and lati lt latmax and day le 366)
    if gridnow[0] lt 0. then begin
      totarea = 0.0
      totCO = 0.0
      TOTpm25 =0.0
      totbioburn = 0.0
      TOTBC = 0.0
    endif
    if gridnow[0] gt 0. then begin
        totarea = total(area[gridnow]);*0.000001 ; convert to km2
        totCO = total(CO[gridnow]) ;* 0.000001 ; Convert to Gg
        totPM25 = total(pm25[gridnow]);*0.000001; Convert to Gg
        totbioburn = total(bioburn[gridnow]) ; In Units Gg
        TOTBC = total(bc[gridnow])
    endif
    printf, format = form, 6, (latmin+0.25), (lonmin+0.25), totCO, TOtPM25, totbc, totarea, totbioburn
  endfor ; end j loop
endfor ; end i loop

; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
