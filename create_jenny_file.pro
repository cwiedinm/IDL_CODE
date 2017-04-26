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
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro Create_JennY_File
close, /all

;Generic land cover codes (genveg) are as follows:
;    1 = grasslands and svanna
;    2 = woody savanna
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)

year = 2007
firstday =1 
lastday = 365

infile = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2012\GLOBAL_2007_09172012.txt'
outgrass = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_GRASS_01102012.txt'
outshrub = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_SHRUB_01102012.txt'
outtemp = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_TEMP_01102012.txt'
outtrop = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_TROP_01102012.txt'
outbor = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_BOR_01102012.txt'
outcrop = 'E:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JANUARY2013\JENNY\GLOB2007_CROP_01102012.txt'


; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
openw, 1, outgrass
openw, 2, outshrub
openw, 4, outtemp
openw, 3, outtrop
openw, 5, outbor
openw, 6, outcrop

printf, 1, 'DAY, LATITUDE, LONGITUDE, CO2'
printf, 2, 'DAY, LATITUDE, LONGITUDE, CO2'
printf, 3, 'DAY, LATITUDE, LONGITUDE, CO2'
printf, 4, 'DAY, LATITUDE, LONGITUDE, CO2'
printf, 5, 'DAY, LATITUDE, LONGITUDE, CO2'
printf, 6, 'DAY, LATITUDE, LONGITUDE, CO2'


form='(I6,3(",",D20.10))'


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
;		CO = fire.field14
;		OC = fire.field26
;		BC = fire.field27
;		PM25 = fire.field24
;		NOX = fire.field17
;		NO = fire.field18
;		NO2 = fire.field19
;		NH3 = fire.field20
;		SO2 = fire.field21
;		VOC = fire.field23
;		CH4 = fire.field15
;		area = fire.field11 ; added 05/02/2011; should be in m2

   	numfires = n_elements(day)
		nfires = numfires

print, "FINISHED READING INPUT FILE"
print, 'Input file = ', infile
print, 'First day = ', min(day)
print, 'Last day = ', max(day)


; DO LOOP OVER ALL FIRES
; Convert VOC species and output most in mole/km2/day
;-------------------------------
for i = 0L,numfires-1 do begin

; Skip fires on last day
; for leap years
if year eq 2000 or year eq 2004 or year eq 2008 or year eq 2012 then begin
  if day[i] gt 366 then begin
       print,'year = ',year,' and day: ',jday[i],' not included.
       goto, skipfire
  endif
endif
; For non-leap years
if year ne 2000 and year ne 2004 and year ne 2008 and year ne 2012 then begin
  if day[i] gt 365 then begin
       print,'year = ',year,' and day: ',jday[i],' not included.
       goto, skipfire
  endif
endif

; Make sure only include days of the months in the file (for WRF-CHEM)
if day[i] gt lastday or day[i] lt firstday then goto, skipfire
      
; GENERIC LAND COVER CLASSES
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
;
; STOP if no recognizable GenLC is in there
if genveg[i] eq 6 or genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP

if Co2[i] eq 0 then begin
   print,'fire = ',i+1,' and day: ',jday[i],' not included.
   goto, skipfire
endif


;openw, 1, outgrass
;openw, 2, outshrub
;openw, 4, outtemp
;openw, 3, outtrop
;openw, 5, outbor
;openw, 6, outcrop
;
if (genveg[i] eq 1) then printf, 1,format = form, day[i],lati[i],longi[i],co2[i] 
if (genveg[i] eq 2) then printf, 2,format = form, day[i],lati[i],longi[i],co2[i]
if (genveg[i] eq 3) then printf, 3,format = form, day[i],lati[i],longi[i],co2[i]
if (genveg[i] eq 4) then printf, 4,format = form, day[i],lati[i],longi[i],co2[i]
if (genveg[i] eq 5) then printf, 5,format = form, day[i],lati[i],longi[i],co2[i]
if (genveg[i] eq 9) then printf, 6,format = form, day[i],lati[i],longi[i],co2[i]

skipfire:

endfor ; end of i loop

; End Program
close, /all
;stop
print, 'Progran Ended! All done!'
END
