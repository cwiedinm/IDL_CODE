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
 ; 	based on fires located in joining pixels- have to change from
 ; 	one-dimensional arrays to 2-dim in the input files (will not work
 ; 	with the larger files)
 ; Version 5: Modified on 04/01/04 to cut out a lot of the crap
 ;  also, to try to incoporate some of the FEPS algorithms
 ;  for smoldering/flaming
 ; 	Note: this version is still meant for Colorado and smaller domains only
 ; July 27, 2004: This version is edited for the COlorado June 2002 test case
 ; 	reading in base map file and 6 individual fire text files (made my Angie)
 ; 	using the FEPS base algorithms
 ;***********************************************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds

;************************************************************************************
; Set up biomass and emission factor tables
; The first element in the arrays are for FORESTED and the second is for HERBACEOUS
; in each land cover
; EMISSION FACTOR	Array 1: 0=flaming, 1=smoldering
;					Array 2: compound
;						0=CO2, 1=CO, 2=PM10, 3=PM2.5, 4=NOx, 5=NH3, 6=SO2, 7=VOC
;					Array 3: lct
; 					(Units are in g/kg)
	emisfac=fltarr(2,8,18)
; See Spreadsheet for references and sources of emission factors
; Mostly from Battye & Battye EPA report
; 	some from the CARB web document on Ag emissions
;
;
; DEFINE EACH ARRAY (based on tables that were made originally in EXCEL
; Can add another array variable to account for more specific ecosystem information
; 		when this becomes available
 	; Define values for lct = 0 (WATER)
 	; 	leave it all as it - 0
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
numdays = 1
firstday = 1
read, 'How many days of fire files will you run?', numdays
read, 'What is the date of the first day?', firstday
firstday2 = strtrim(firstday,2)

; Input file pathway
	path = 'C:\WORK\wildfire\EPA_EI\MODEL\TEST_CO\Test_072704\'
	;path = '/zeus/christin/FIRE/MODEL/'
; Output file pathway
	; path2 = 'C:\FIRE\ascii_grids\V003\output\'
	path2 = path

; Set file names and pathways
   nfdrsfuelload = path+'NFRDS_fuelload.csv'
   basemapfile = path+ 'co_combine_2.txt'
; Input fire files
   if (firstday ge 1000) then begin
	fire1 =  'pt'+firstday2+'_out.txt'
   endif else begin
   	fire1 =  'pt0'+firstday2+'_out.txt'
   endelse


; Set up output file (comma delimited text file)
	outfile = 'test_co_June2002.txt'
	openw, 6, path2+outfile
 		print, 'opened ', path2+outfile
	printf, 6, 'longitude,latitude,day,lct,fueltype,area,percentTree,percentherb,percentbare,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
	form = '(D20.10,",",D20.10,",",(3(I5,",")),4(D20.10,","),8(D25.10,","))'


; make array of fire files to be read in
firefiles = strarr(numdays)

day = firstday
for i = 0,numdays-1 do begin
	if i eq 0 then begin
		firefiles(0) = fire1
	endif else begin
		day = day + 1
		day2 = strtrim(day,2)
  		 if (day ge 1000) then begin
			varname =  'pt'+day2+'_out.txt'
   		endif else begin
   			varname =  'pt0'+day2+'_out.txt'
   		endelse
   		firefiles(i) = varname
   	endelse
endfor

; ****************************************************************************************
; Read in BASEMAPFILE
; SKIP FIRST LINE WITH LABELS
; !! MAKE SURE READ IN AS DOUBLE!!
	intemp=ascii_template(basemapfile)
	map=read_ascii(basemapfile, template=intemp)
	nbase = n_elements(map.lat1e10)
; Correct the latitude and longitude
	lat = map.lat1e10/1e10
	lon = map.lon1e10/1e10
; Read in Fuel load for NFRDS
	inload=ascii_template(nfdrsfuelload)
	fuelload=read_ascii(nfdrsfuelload, template=inload)
;***********************************************************************

;***********************************************************************************
; Read in each fire file (one at a time), calculate emissions, save emissions arrays
intemp2=ascii_template(path+firefiles(0))

; INitialize arrays
; MAKE SURE THESE ARRAYS ARE CHANGED WHEN DOING THE ENTIRE US
	lat2 = dblarr(numdays,1000)
	lon2 = dblarr(numdays,1000)
	fuel=intarr(numdays,1000)
	loclat= lon64arr(numdays,1000)
	loclon = lon64arr(numdays,1000)

; START LOOP OVER MODEL DAYS (i loop)
for i =0,numdays-1 do begin
	; READ IN THE FIRE FILE
	; MAKE SURE READ IN AS DOUBLE!!
	infile = firefiles[i]
	infire=read_ascii(path+infile, template=intemp2)
	nfires = n_elements(infire.lat1e10)
	print, 'opened fire file: ',path+infile
	print, 'the number of fires = ', nfires
	; 	loclat=intarr(nfires)
	; 	loclon=intarr(nfires)
 ; START LOOP OVER FIRE PIXELS FOR DAY i (j loop)
	for j =0,nfires	-1 do begin
		; Correct lat and long
		lat2[i,j] = infire.lat1e10[j]/1e10
		lon2[i,j] = infire.lon1e10[j]/1e10

	; GET THE BASE MAP INFORMATION FOR THE FIRES
	; Get array ids for fire locations in base map
		loclat[i,j] = where(lat eq lat2[i,j])
		loclon[i,j] = Where(lon eq lon2[i,j])
			if loclat[i,j] le 0 then begin
				print, 'No match of latitude! day num = ', i+1, ' fire number = ,', j
				print, 'lat2=', lat2[i,j],' and lon2=',lon2[i,j]
				print, 'loclat[i,j] = ',loclat[i,j]
				; CHRISTINE IS JUST MAKING UP NUMBERS HERE FOR NOW!
				loclat[i,j] = 4399
				;for loop =0,nbase-2 do begin
				;	if lat2(i,j) lt lat(loop+1) and lat2(i,j) ge lat(loop) then loclat(i,j)=loop
				;endfor
			endif
			if loclon[i,j] le 0 then begin
				print, 'No match of longitude! day num = ', i+1, ' fire number = ,', j
				; CHRISTINE IS JUST MAKING SOMETHING UP FOR NOW!
				loclon[i,j] = 4399
				;for loop =0,nbase-2 do begin
				;	if lon2(i,j) lt lon(loop+1) and lon2(i,j) ge lon(loop) then loclon(i,j)=loop
				;endfor
			endif
		If loclat[i,j] ne loclon[i,j] then begin
			print, 'Location in the base file is not consistent'
			print, 'day number:', i+1, ' and fire number:',j
		endif

;CALCULATE FIRE AREA
		area = 0.14 ; standard area = 0.14 km2
		; Look First to see if fire was burning in pixel the day before
		if i eq 0 then goto, SKIPDAY1 ; can't look at prior day

		; FIND OUT IF FIRE WAS GOING PREVIOUS DAY
			priorlon = where(lon2[i,j] eq lon2[i-1,*])
	    	priorlat = where(lat2[i,j] eq lat2[i-1,*])
	    ; ADD 0.10 km2 to area if it was burning the previous day
	    	if (priorlon[0] gt 0) AND (priorlat[0] gt 0) then area = 0.14 + 0.05

SKIPDAY1:

		; Check to see if the adjacent areas are on fire (if so, then add area)
			; Used the average distances apart from the map.bare file
		samelat = where(lat2[i,*] gt (lat2[i,j]-0.011) AND lat2[i,*] lt (lat2[i,j]+0.011))
		samelon = where(lon2[i,*] gt (lon2[i,j]-0.014) AND lon2[i,*] lt (lon2[i,j]+0.014))
		numlat = n_elements(samelat)
		numlon = n_elements(samelon)
		numadj = 0
		for l = 0, numlat-1 do begin
			same = where(samelon eq samelat[l])
			if same[0] ge 0 then numadj=numadj+1
		endfor
			;print, 'NUmber of adjacent cells =',numadj
			if numadj gt 9 then numadj = 9
		area = area+((numadj-1)*0.10)	; add 0.10 km2 for every pixel on fire adjacent
		; NOTE: MOST AREA BURNED IS 99% of Pixel

getfueltype:
		; GET FUEL TYPE
			; First, check if in Continental U.S.> assign NFRDS fuel if so
			if map.fuel(loclon[i,j]) gt 0 then begin
				fuel[i,j]=map.fuel(loclon[i,j])
				print, 'fire in continental U.S. fuel model is :', fuel[i,j]
				goto, fuelend
			endif
		; Need to add information here for areas not in the continental U.S.

		fuelend:

; MOISTURE CONTENT OF FUELS
		; Detemine the moisture contnent
		; 0 = Very Dry, 1 = Dry, 2 = Moderate, 3 = Moist, 4 = Wet, 5 = Very Wet
		; Ultimately, will have a file to read in fuel moisture
		; For now, assume Very dry (0)
			moist = 0

; PERCENT OF EACH LOADING CONSUMED
; 	LC are %
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
		; Figure out which NFDRS fuel load we have
			fuelmodel = where(fuelload.field1 eq fuel[i,j])
		; No Canopy component in NFDRS- not sure what to do here
		; Shrub, assume smoldering fuel loading + 10hr fuel
			bshrb = LCshrb*(fuelload.field8[fuelmodel]+fuelload.field4[fuelmodel])/100. ; ton/acre
		; Grass, assume hebaceous fuel loading
			bgrass = LCgrass*fuelload.field8[fuelmodel]/100. ; ton/acre
		; Duff, assume Drought, very dry
			bduff = LCduff * fuelload.field9[fuelmodel]/100.
		; Woody/Broadcast (assume woody + 1000hr + 100hr)
			bwoody = LCwood*(fuelload.field7[fuelmodel]+fuelload.field6[fuelmodel] $
				+fuelload.field5[fuelmodel])/100.
		; Litter, assume 1 hr fuels
			blitt = LClit * fuelload.field3[fuelmodel]/100.

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
			calc = 	(fuelload.field9[fuelmodel]*INVlts/100)-Bduff
			Blts = max(diff, calc)



;****************************************************************************
; CALCULATE EMISSIONS
 			; Calculate emissions if LCT = WATER, Snow/Ice, unknown
			If (map.lct[loclat[i,j]] eq 0) or (map.lct[loclat[i,j]] eq 15) or (map.lct[loclat[i,j]] eq 255) or (map.lct[loclat[i,j]] eq 254) then begin
 				print, 'The LCT for this cell is WATER, SNOW/ICE or unknown. i = ',i,' j=',j
 				print, '		**The lct[j+1,i] =',map.lct[loclat[i,j]+1], ' and lct[j-1,i]= ', map.lct[loclat[i,j]-1]
 				if (map.lct[loclat[i,j]-1] eq 0) or (map.lct[loclat[i,j]-1] eq 15) or (map.lct[loclat[i,j]-1] eq 255) or (map.lct[loclat[i,j]-1] eq 254) then begin
 					if (map.lct[loclat[i,j]+1] eq 0) or (map.lct[loclat[i,j]+1] eq 15) or (lmap.lct[loclat[i,j]+1] eq 255) or (map.lct[loclat[i,j]+1] eq 254) then begin
 						print, 'All surrounding cells have value of: ', map.lct[loclat[i,j]], map.lct[loclat[i,j]+1], map.lct[loclat[i,j]-1]
 						print, 'Day Number = ', i, ' and the fire number = ', j
 						goto, quitearly
 					endif else begin
						m = loclat[i,j]+1
 						goto, calculate
 					endelse
 				endif
 				; Calculate the emissions of the next cell [j-1]
					m = loclat[i,j]-1
					goto, calculate
 			endif

			; set p = 1 for all lcts except for urban
			p=1.
 			; Calculate emissions if LCT = URBAN (13)
 			; Urban emissions use the emissions of the vegetation class next to the grid
 			; and 1/3 of the biomass density (reset value for p)
			If map.lct[loclat[i,j]] eq 13 then begin
			print, 'Urban Cell! Day Number = ', i, 'Fire number = ', j
				if  map.lct[loclat[i,j]-1] eq 13 then begin
					if map.lct[loclat[i,j]+1] eq 13 then begin
						print, 'All surrounding cells are urban!:', map.lct[loclat[i,j]],map.lct[loclat[i,j]-1], map.lct[loclat[i,j]+1]
						print, 'day number = ', i, ' and fire number = ', j
 						print, 'calculating emissions based on several cells over. lct[j+5] =', map.lct[loclat[i,j]+5]
						m = loclat[i,j]+5
						p = 1./3.
						goto, calculate
 					endif else begin
					m=loclat[i,j]+1
					p = 1./3.
					goto,calculate
					endelse
				endif
				m=loclat[i,j]-1
				p = 1./3.
				goto, calculate
			endif

			; Calculate emissions for all other LCTs
			if (map.lct[loclat[i,j]] ge 1) and (map.lct[loclat[i,j]] le 16)	then begin
				m = j
				goto, calculate
			endif else begin
				print, 'Something is wrong!!! lct[j] = ', map.lct[loclat[i,j]]
				print, 'fire number = ', j, 'day number = ', i
				print, "STOPPING PROGRAM EARLY!'
				goto, quitearly
			endelse

			calculate:
				; CALCULATE EMISSIONS (g emission - per day per 1km2 pixel)
				lct = map.lct[loclat[i,j]]
				; CO2 Emissions
					emisco2 = (area*907.18476/0.0040468564*((emisfac[0,0,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,0,lct])))
				; CO Emissions
					emisco = area*907.18476/0.0040468564*((emisfac[0,1,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,1,lct]))
				; PM10 Emissions
					emispm10 = area*907.18476/0.0040468564*((emisfac[0,2,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,2,lct]))
				; PM2.5 Emissions
					emispm25 = area*907.18476/0.0040468564*((emisfac[0,3,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,3,lct]))
				; NOx Emissions
					emisnox = area*907.18476/0.0040468564*((emisfac[0,4,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,4,lct]))
				; NH3 Emissions
					emisnh3 = area*907.18476/0.0040468564*((emisfac[0,5,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,5,lct]))
				; SO2 Emissions
					emisso2 = area*907.18476/0.0040468564*((emisfac[0,6,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,6,lct]))
				; VOC Emissions
					emisvoc = area*907.18476/0.0040468564*((emisfac[0,7,lct]*p*Bflame)+(p*(Bsts+Blts)*emisfac[1,7,lct]))



; Correct the VCF product
	 		sum = map.bare[loclat[i,j]] + map.herb[loclat[i,j]] + map.tree[loclat[i,j]]
; 			print, 'j=', j, 'i =',i, 'sum =', sum, 'lct =', lct[j]
			; If it's all OK- and no unknowns are in there- than skip this section
 			if (sum le 100.) then goto, skip
 			; If there are some unknown values in the percentages, the sum will be large
 			; And the percentages need to be corrected (this is due to the way in which the
 			; pct files were processed within the GIS
 				if (sum gt 100.) and (sum le 150.) then begin
 					; scale back to a total of 100.
 					map.tree[loclat[i,j]] = map.tree[loclat[i,j]]*100./sum
 					map.herb[loclat[i,j]] = map.herb[loclat[i,j]]*100./sum
 					map.bare[loclat[i,j]] = map.bare[loclat[i,j]]*100./sum
 				endif else begin
 					if (sum gt 150.) then begin
 					; This means that there are some unknowns in here and we
 					; will look at the grid cell next to this (to the west)
 						sum = map.bare[loclat[i,j]-1] + map.herb[loclat[i,j]-1] + map.tree[loclat[i,j]-1]
 						if (sum gt 100.) AND (sum lt 150.) then begin
 							map.tree[loclat[i,j]] = map.tree[loclat[i,j]-1]*100./sum
 							map.herb[loclat[i,j]] = map.herb[loclat[i,j]-1]*100./sum
 							map.bare[loclat[i,j]] = map.bare[loclat[i,j]-1]*100./sum
 						endif else begin
 							if (sum le 100.) then begin
 							map.tree[loclat[i,j]] = map.tree[loclat[i,j]-1]
 							map.herb[loclat[i,j]] = map.herb[loclat[i,j]-1]
 							map.bare[loclat[i,j]] = map.bare[loclat[i,j]-1]
 							endif
 						if (sum gt 150.) then begin
 						; then we will look at the next grid cell...to the east
 							sum = map.bare[loclat[i,j]+1] + map.herb[loclat[i,j]+1] + map.tree[loclat[i,j]+1]
 							if (sum gt 100.) AND (sum lt 150.) then begin
 								map.tree[loclat[i,j]] = map.tree[loclat[i,j]+1]*100./sum
 								map.herb[loclat[i,j]] = map.herb[loclat[i,j]+1]*100./sum
 								map.bare[loclat[i,j]] = map.bare[loclat[i,j]+1]*100./sum
 							endif else begin
 							if (sum le 100.0) then begin
 								map.tree[loclat[i,j]] = map.tree[loclat[i,j]+1]
 								map.herb[loclat[i,j]] = map.herb[loclat[i,j]+1]
 								map.bare[loclat[i,j]] = map.bare[loclat[i,j]+1]
 							endif else begin
 								print, 'Sum is still messed up! fire record #: ', j, 'Day Number = ',i
								print, 'sum = :', sum
 								goto, quitearly
 							endelse
 							endelse
 						endif
 						endelse
					endif
 				endelse
skip:

; OUTPUT THE RESULTS INTO COMMA_DELIMITED FILE
;	printf, 6, 'longitude,latitude,day,lct,fueltype,area,percentTree,percentherb,percentbare,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
       		printf,6,format=form,lon2[i,j],lat2[i,j],i,lct,fuel[i,j],area,	$
       			map.tree[loclat[i,j]],map.herb[loclat[i,j]],map.bare[loclat[i,j]], $
       			emisco2,emisco,emispm10,emispm25,emisnox,emisnh3,emisso2,emisvoc

	endfor ; END LOOP OVER THE FIRES FOR THE DAY (j loop)
endfor	; END LOOP OF DIFFERENT FIRE DAYS (i loop)



; END PROGRAM

quitearly:
t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'
junk = check_math() ;This clears the math errors

close,/all   ;make sure ALL files are closed
end
