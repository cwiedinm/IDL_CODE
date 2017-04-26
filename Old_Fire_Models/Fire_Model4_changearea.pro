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
 ;**********************************************************

 pro Fire_Emis

 close, /all

 t0 = systime(1) ;Procedure start time in seconds

;************************************************************************************
; Set up biomass and emission factor tables
; The first element in the arrays are for FORESTED and the second is for HERBACEOUS
; in each land cover

; Initialize the arrays
; BIOMASS DENSITY: 	Array 1: 0=forest, 1=herb
; 					Array 2: lct
; 					Units are in kg/m2
	bd=fltarr(2,18)
	bd[*,*] = 0.0
; PERCENT BURN: 	Array 1: 0=forest, 1=herb
;					Array 2: condition type: 0=DRY, 1= Moderate, 2 = Wet
;					Array 3: lct
	pctburn = fltarr(2,3,18)
	pctburn[*,*,*] = 0.0
; EMISSION FACTOR	Array 1: 0=forest, 1=herb
;					Array 2: compound
;						0=CO2, 1=CO, 2=PM10, 3=PM2.5, 4=NOx, 5=NH3, 6=SO2, 7=VOC
;					Array 3: lct
; 					(Units are in g/kg)
	emisfac=fltarr(2,8,18)
	emisfac[*,*,*]=0.0
;
; DEFINE EACH ARRAY (based on tables that were made originally in EXCEL
; Can add another array variable to account for more specific ecosystem information
; 		when this becomes available
 	; Define values for lct = 0 (WATER)
 	; 	leave it all as it - 0
	;
 ; Define Values for lct = 1 (evergreen needleleaf forest)
 		bd[0,1] = 7.0	; forest
 		bd[1,1] = 0.1	; herbaceous
 		pctburn[0,0,1]=50./100.	; forest, dry
 		pctburn[0,1,1]=33.3/100.	; forest, moderate
 		pctburn[0,2,1]=25./100.	; forest, wet
 		pctburn[1,0,1]=100./100.	; herbaceous, dry
 		pctburn[1,1,1]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,1]=50./100.	; herbaceous, wet
 		emisfac[0,0,1]=1569. ; forest, CO2
 		emisfac[0,1,1]=107.  ; forest, CO
 		emisfac[0,2,1]=11.2  ; forest, PM10
 		emisfac[0,3,1]=10.2  ; forest, PM2.5
 		emisfac[0,4,1]=2.0  ; forest, NOX
 		emisfac[0,5,1]=0.9  ; forest, NH3
		emisfac[0,6,1]=1.3  ; forest, SO2
		emisfac[0,7,1]=7.3  ; forest, VOC
		emisfac[1,0,1]=1613.  ; herbaceous, CO2
		emisfac[1,1,1]=57.  ; herbaceous, CO
		emisfac[1,2,1]=8.  ; herbaceous, PM10
		emisfac[1,3,1]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,1]=2.9  ; herbaceous, NOx
		emisfac[1,5,1]=0.56  ; herbaceous, NH3
		emisfac[1,6,1]=0.3  ; herbaceous, SO2
		emisfac[1,7,1]=5.4  ; herbaceous, VOC
; Define Values for lct = 2 (evergreen broadleaf forest)
 		bd[0,2] = 10.0	; forest
 		bd[1,2] = 0.1	; herbaceous
 		pctburn[0,0,2]=10./100.	; forest, dry
 		pctburn[0,1,2]=6.7/100.	; forest, moderate
 		pctburn[0,2,2]=5./100.	; forest, wet
 		pctburn[1,0,2]=100./100.	; herbaceous, dry
 		pctburn[1,1,2]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,2]=50./100.	; herbaceous, wet
 		emisfac[0,0,2]=1569. ; forest, CO2
 		emisfac[0,1,2]=128.  ; forest, CO
 		emisfac[0,2,2]=12.5  ; forest, PM10
 		emisfac[0,3,2]=11.2  ; forest, PM2.5
 		emisfac[0,4,2]=0.35  ; forest, NOX
 		emisfac[0,5,2]=0.0  ; forest, NH3
		emisfac[0,6,2]=1.3  ; forest, SO2
		emisfac[0,7,2]=7.3  ; forest, VOC
		emisfac[1,0,2]=1613.  ; herbaceous, CO2
		emisfac[1,1,2]=57.  ; herbaceous, CO
		emisfac[1,2,2]=8.  ; herbaceous, PM10
		emisfac[1,3,2]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,2]=2.9  ; herbaceous, NOx
		emisfac[1,5,2]=0.56  ; herbaceous, NH3
		emisfac[1,6,2]=0.3  ; herbaceous, SO2
		emisfac[1,7,2]=5.4  ; herbaceous, VOC
; Define Values for lct = 3 (deciduous needleleaf forest)
 		bd[0,3] = 6.0	; forest
 		bd[1,3] = 0.1	; herbaceous
 		pctburn[0,0,3]=20./100.	; forest, dry
 		pctburn[0,1,3]=13.3/100.	; forest, moderate
 		pctburn[0,2,3]=10./100.	; forest, wet
 		pctburn[1,0,3]=100./100.	; herbaceous, dry
 		pctburn[1,1,3]=66.7/100.; herbaceous, moderate
 		pctburn[1,2,3]=50./100.	; herbaceous, wet
 		emisfac[0,0,3]=1569. ; forest, CO2
 		emisfac[0,1,3]=107.  ; forest, CO
 		emisfac[0,2,3]=11.2  ; forest, PM10
 		emisfac[0,3,3]=10.2  ; forest, PM2.5
 		emisfac[0,4,3]=2.0  ; forest, NOX
 		emisfac[0,5,3]=0.9  ; forest, NH3
		emisfac[0,6,3]=1.3  ; forest, SO2
		emisfac[0,7,3]=7.3  ; forest, VOC
		emisfac[1,0,3]=1613.  ; herbaceous, CO2
		emisfac[1,1,3]=57.  ; herbaceous, CO
		emisfac[1,2,3]=8.  ; herbaceous, PM10
		emisfac[1,3,3]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,3]=2.9  ; herbaceous, NOx
		emisfac[1,5,3]=0.56  ; herbaceous, NH3
		emisfac[1,6,3]=0.3  ; herbaceous, SO2
		emisfac[1,7,3]=5.4  ; herbaceous, VOC
; Define Values for lct = 4 (deciduous braodleaf forest)
 		bd[0,4] = 5.0	; forest
 		bd[1,4] = 0.1	; herbaceous
 		pctburn[0,0,4]=20./100.	; forest, dry
 		pctburn[0,1,4]=13.3/100.	; forest, moderate
 		pctburn[0,2,4]=10./100.	; forest, wet
 		pctburn[1,0,4]=100./100.	; herbaceous, dry
 		pctburn[1,1,4]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,4]=50./100.	; herbaceous, wet
 		emisfac[0,0,4]=1569. ; forest, CO2
 		emisfac[0,1,4]=128.  ; forest, CO
 		emisfac[0,2,4]=12.5  ; forest, PM10
 		emisfac[0,3,4]=11.2  ; forest, PM2.5
 		emisfac[0,4,4]=0.35  ; forest, NOX
 		emisfac[0,5,4]=0.  ; forest, NH3
		emisfac[0,6,4]=1.3  ; forest, SO2
		emisfac[0,7,4]=7.3  ; forest, VOC
		emisfac[1,0,4]=1613.  ; herbaceous, CO2
		emisfac[1,1,4]=57.  ; herbaceous, CO
		emisfac[1,2,4]=8.  ; herbaceous, PM10
		emisfac[1,3,4]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,4]=2.9  ; herbaceous, NOx
		emisfac[1,5,4]=0.56  ; herbaceous, NH3
		emisfac[1,6,4]=0.3  ; herbaceous, SO2
		emisfac[1,7,4]=5.4  ; herbaceous, VOC
; Define Values for lct = 5 (mixed forest)
 		bd[0,5] = 6.0	; forest
 		bd[1,5] = 0.1	; herbaceous
 		pctburn[0,0,5]=35./100.	; forest, dry
 		pctburn[0,1,5]=23.3/100.	; forest, moderate
 		pctburn[0,2,5]=17.5/100.	; forest, wet
 		pctburn[1,0,5]=100./100.	; herbaceous, dry
 		pctburn[1,1,5]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,5]=50./100.	; herbaceous, wet
 		emisfac[0,0,5]=1569. ; forest, CO2
 		emisfac[0,1,5]=117.5  ; forest, CO
 		emisfac[0,2,5]=11.9  ; forest, PM10
 		emisfac[0,3,5]=10.7  ; forest, PM2.5
 		emisfac[0,4,5]=1.2  ; forest, NOX
 		emisfac[0,5,5]=0.37  ; forest, NH3
		emisfac[0,6,5]=1.3  ; forest, SO2
		emisfac[0,7,5]=7.3  ; forest, VOC
		emisfac[1,0,5]=1613.  ; herbaceous, CO2
		emisfac[1,1,5]=57.  ; herbaceous, CO
		emisfac[1,2,5]=8.  ; herbaceous, PM10
		emisfac[1,3,5]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,5]=2.9  ; herbaceous, NOx
		emisfac[1,5,5]=0.56  ; herbaceous, NH3
		emisfac[1,6,5]=0.3  ; herbaceous, SO2
		emisfac[1,7,5]=5.4  ; herbaceous, VOC
; Define Values for lct = 6 (closed shrubland)
 		bd[0,6] = 1.0	; forest
 		bd[1,6] = 0.05	; herbaceous
 		pctburn[0,0,6]=50./100.	; forest, dry
 		pctburn[0,1,6]=33.3/100.	; forest, moderate
 		pctburn[0,2,6]=25./100.	; forest, wet
 		pctburn[1,0,6]=100./100.	; herbaceous, dry
 		pctburn[1,1,6]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,6]=50./100.	; herbaceous, wet
 		emisfac[0,0,6]=1569. ; forest, CO2
 		emisfac[0,1,6]=77.  ; forest, CO
 		emisfac[0,2,6]=10.1  ; forest, PM10
 		emisfac[0,3,6]=8.7  ; forest, PM2.5
 		emisfac[0,4,6]=6.5  ; forest, NOX
 		emisfac[0,5,6]=0.7  ; forest, NH3
		emisfac[0,6,6]=1.4  ; forest, SO2
		emisfac[0,7,6]=7.2  ; forest, VOC
		emisfac[1,0,6]=1613.  ; herbaceous, CO2
		emisfac[1,1,6]=57.  ; herbaceous, CO
		emisfac[1,2,6]=8.  ; herbaceous, PM10
		emisfac[1,3,6]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,6]=2.9  ; herbaceous, NOx
		emisfac[1,5,6]=0.56  ; herbaceous, NH3
		emisfac[1,6,6]=0.3  ; herbaceous, SO2
		emisfac[1,7,6]=5.4  ; herbaceous, VOC
; Define Values for lct = 7 (open shrubland)
 		bd[0,7] = 0.5	; forest
 		bd[1,7] = 0.025	; herbaceous
 		pctburn[0,0,7]=50./100.	; forest, dry
 		pctburn[0,1,7]=33.3/100.	; forest, moderate
 		pctburn[0,2,7]=25./100.	; forest, wet
 		pctburn[1,0,7]=100./100.	; herbaceous, dry
 		pctburn[1,1,7]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,7]=50./100.	; herbaceous, wet
 		emisfac[0,0,7]=1569. ; forest, CO2
 		emisfac[0,1,7]=103.  ; forest, CO
 		emisfac[0,2,7]=15.  ; forest, PM10
 		emisfac[0,3,7]=13.4  ; forest, PM2.5
 		emisfac[0,4,7]=6.5  ; forest, NOX
 		emisfac[0,5,7]=0.7  ; forest, NH3
		emisfac[0,6,7]=1.4  ; forest, SO2
		emisfac[0,7,7]=7.2  ; forest, VOC
		emisfac[1,0,7]=1613.  ; herbaceous, CO2
		emisfac[1,1,7]=57.  ; herbaceous, CO
		emisfac[1,2,7]=8.  ; herbaceous, PM10
		emisfac[1,3,7]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,7]=2.9  ; herbaceous, NOx
		emisfac[1,5,7]=0.56  ; herbaceous, NH3
		emisfac[1,6,7]=0.3  ; herbaceous, SO2
		emisfac[1,7,7]=5.4  ; herbaceous, VOC
; Define Values for lct = 8 (woody savannahs)
 		bd[0,8] = 0.25	; forest
 		bd[1,8] = 0.05	; herbaceous
 		pctburn[0,0,8]=50./100.	; forest, dry
 		pctburn[0,1,8]=33.3/100.	; forest, moderate
 		pctburn[0,2,8]=25./100.	; forest, wet
 		pctburn[1,0,8]=100./100.	; herbaceous, dry
 		pctburn[1,1,8]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,8]=50./100.	; herbaceous, wet
 		emisfac[0,0,8]=1569. ; forest, CO2
 		emisfac[0,1,8]=77.  ; forest, CO
 		emisfac[0,2,8]=10.1  ; forest, PM10
 		emisfac[0,3,8]=8.7  ; forest, PM2.5
 		emisfac[0,4,8]=6.5  ; forest, NOX
 		emisfac[0,5,8]=0.7  ; forest, NH3
		emisfac[0,6,8]=1.4  ; forest, SO2
		emisfac[0,7,8]=7.2  ; forest, VOC
		emisfac[1,0,8]=1613.  ; herbaceous, CO2
		emisfac[1,1,8]=57.  ; herbaceous, CO
		emisfac[1,2,8]=8.  ; herbaceous, PM10
		emisfac[1,3,8]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,8]=2.9  ; herbaceous, NOx
		emisfac[1,5,8]=0.56  ; herbaceous, NH3
		emisfac[1,6,8]=0.3  ; herbaceous, SO2
		emisfac[1,7,8]=5.4  ; herbaceous, VOC
; Define Values for lct = 9 (Savannas)
 		bd[0,9] = 0.1	; forest
 		bd[1,9] = 0.1	; herbaceous
 		pctburn[0,0,9]=90./100.	; forest, dry
 		pctburn[0,1,9]=60./100.	; forest, moderate
 		pctburn[0,2,9]=45./100.	; forest, wet
 		pctburn[1,0,9]=100./100.	; herbaceous, dry
 		pctburn[1,1,9]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,9]=50./100.	; herbaceous, wet
 		emisfac[0,0,9]=1569. ; forest, CO2
 		emisfac[0,1,9]=77.  ; forest, CO
 		emisfac[0,2,9]=10.1  ; forest, PM10
 		emisfac[0,3,9]=8.7  ; forest, PM2.5
 		emisfac[0,4,9]=6.5  ; forest, NOX
 		emisfac[0,5,9]=0.7  ; forest, NH3
		emisfac[0,6,9]=1.4  ; forest, SO2
		emisfac[0,7,9]=7.2  ; forest, VOC
		emisfac[1,0,9]=1613.  ; herbaceous, CO2
		emisfac[1,1,9]=57.  ; herbaceous, CO
		emisfac[1,2,9]=8.  ; herbaceous, PM10
		emisfac[1,3,9]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,9]=2.9  ; herbaceous, NOx
		emisfac[1,5,9]=0.56  ; herbaceous, NH3
		emisfac[1,6,9]=0.3  ; herbaceous, SO2
		emisfac[1,7,9]=5.4  ; herbaceous, VOC
; Define Values for lct = 10 (Grasslands)
 		bd[0,10] = 5.0	; forest
 		bd[1,10] = 0.1	; herbaceous
 		pctburn[0,0,10]=90./100.	; forest, dry
 		pctburn[0,1,10]=60./100.	; forest, moderate
 		pctburn[0,2,10]=45./100.	; forest, wet
 		pctburn[1,0,10]=100./100.	; herbaceous, dry
 		pctburn[1,1,10]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,10]=50./100.	; herbaceous, wet
 		emisfac[0,0,10]=1569. ; forest, CO2
 		emisfac[0,1,10]=117.5  ; forest, CO
 		emisfac[0,2,10]=11.9  ; forest, PM10
 		emisfac[0,3,10]=10.7  ; forest, PM2.5
 		emisfac[0,4,10]=1.2  ; forest, NOX
 		emisfac[0,5,10]=0.37  ; forest, NH3
		emisfac[0,6,10]=1.3  ; forest, SO2
		emisfac[0,7,10]=7.3  ; forest, VOC
		emisfac[1,0,10]=1613.  ; herbaceous, CO2
		emisfac[1,1,10]=57.  ; herbaceous, CO
		emisfac[1,2,10]=8.  ; herbaceous, PM10
		emisfac[1,3,10]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,10]=2.9  ; herbaceous, NOx
		emisfac[1,5,10]=0.56  ; herbaceous, NH3
		emisfac[1,6,10]=0.3  ; herbaceous, SO2
		emisfac[1,7,10]=5.4  ; herbaceous, VOC
; Define Values for lct = 11 (Permanent Wetlands)
 		bd[0,11] = 1.0	; forest
 		bd[1,11] = 0.2	; herbaceous
 		pctburn[0,0,11]=50./100.	; forest, dry
 		pctburn[0,1,11]=33.3/100.	; forest, moderate
 		pctburn[0,2,11]=25./100.	; forest, wet
 		pctburn[1,0,11]=100./100.	; herbaceous, dry
 		pctburn[1,1,11]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,11]=50./100.	; herbaceous, wet
 		emisfac[0,0,11]=1569. ; forest, CO2
 		emisfac[0,1,11]=125.  ; forest, CO
 		emisfac[0,2,11]=10.7  ; forest, PM10
 		emisfac[0,3,11]=10.7  ; forest, PM2.5
 		emisfac[0,4,11]=1.2  ; forest, NOX
 		emisfac[0,5,11]=0.37  ; forest, NH3
		emisfac[0,6,11]=1.3  ; forest, SO2
		emisfac[0,7,11]=7.3  ; forest, VOC
		emisfac[1,0,11]=1613.  ; herbaceous, CO2
		emisfac[1,1,11]=57.  ; herbaceous, CO
		emisfac[1,2,11]=8.  ; herbaceous, PM10
		emisfac[1,3,11]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,11]=2.9  ; herbaceous, NOx
		emisfac[1,5,11]=0.27  ; herbaceous, NH3
		emisfac[1,6,11]=0.3  ; herbaceous, SO2
		emisfac[1,7,11]=5.4  ; herbaceous, VOC
; Define Values for lct = 12 (Croplands)
 		bd[0,12] = 0.4	; forest
 		bd[1,12] = 0.4	; herbaceous
 		pctburn[0,0,12]=90./100.	; forest, dry
 		pctburn[0,1,12]=60./100.	; forest, moderate
 		pctburn[0,2,12]=45./100.	; forest, wet
 		pctburn[1,0,12]=100./100.	; herbaceous, dry
 		pctburn[1,1,12]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,12]=50./100.	; herbaceous, wet
 		emisfac[0,0,12]=1569. ; forest, CO2
 		emisfac[0,1,12]=117.5  ; forest, CO
 		emisfac[0,2,12]=11.9  ; forest, PM10
 		emisfac[0,3,12]=10.7  ; forest, PM2.5
 		emisfac[0,4,12]=1.2   ; forest, NOX
 		emisfac[0,5,12]=0.37  ; forest, NH3
		emisfac[0,6,12]=1.3  ; forest, SO2
		emisfac[0,7,12]=7.3  ; forest, VOC
		emisfac[1,0,12]=1613.  ; herbaceous, CO2
		emisfac[1,1,12]=57.  ; herbaceous, CO
		emisfac[1,2,12]=8.  ; herbaceous, PM10
		emisfac[1,3,12]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,12]=2.9  ; herbaceous, NOx
		emisfac[1,5,12]=0.56  ; herbaceous, NH3
		emisfac[1,6,12]=0.3  ; herbaceous, SO2
		emisfac[1,7,12]=5.4  ; herbaceous, VOC
; Define Values for lct = 13 (Urban & Built Up)
 		bd[0,13] = 0.	; forest
 		bd[1,13] = 0.	; herbaceous
 		pctburn[0,0,13]=20./100.	; forest, dry
 		pctburn[0,1,13]=20./100.	; forest, moderate
 		pctburn[0,2,13]=20./100.	; forest, wet
 		pctburn[1,0,13]=20./100.	; herbaceous, dry
 		pctburn[1,1,13]=20./100.	; herbaceous, moderate
 		pctburn[1,2,13]=20./100.	; herbaceous, wet
 		emisfac[0,0,13]=0. ; forest, CO2
 		emisfac[0,1,13]=0.  ; forest, CO
 		emisfac[0,2,13]=0.  ; forest, PM10
 		emisfac[0,3,13]=0.  ; forest, PM2.5
 		emisfac[0,4,13]=0.   ; forest, NOX
 		emisfac[0,5,13]=0.  ; forest, NH3
		emisfac[0,6,13]=0.  ; forest, SO2
		emisfac[0,7,13]=0.  ; forest, VOC
		emisfac[1,0,13]=0.  ; herbaceous, CO2
		emisfac[1,1,13]=0.  ; herbaceous, CO
		emisfac[1,2,13]=0.  ; herbaceous, PM10
		emisfac[1,3,13]=0.  ; herbaceous, PM2.5
		emisfac[1,4,13]=0.  ; herbaceous, NOx
		emisfac[1,5,13]=0.  ; herbaceous, NH3
		emisfac[1,6,13]=0.  ; herbaceous, SO2
		emisfac[1,7,13]=0.  ; herbaceous, VOC
; Define Values for lct = 14 (Cropland and Natural Vegetation Mosaic)
 		bd[0,14] = 6.0	; forest
 		bd[1,14] = 0.1	; herbaceous
 		pctburn[0,0,14]=50./100.	; forest, dry
 		pctburn[0,1,14]=33.3/100.	; forest, moderate
 		pctburn[0,2,14]=25./100.	; forest, wet
 		pctburn[1,0,14]=100./100.	; herbaceous, dry
 		pctburn[1,1,14]=66.7/100.	; herbaceous, moderate
 		pctburn[1,2,14]=50./100.	; herbaceous, wet
 		emisfac[0,0,14]=1569. ; forest, CO2
 		emisfac[0,1,14]=117.5  ; forest, CO
 		emisfac[0,2,14]=11.9  ; forest, PM10
 		emisfac[0,3,14]=10.7  ; forest, PM2.5
 		emisfac[0,4,14]=1.2  ; forest, NOX
 		emisfac[0,5,14]=0.37  ; forest, NH3
		emisfac[0,6,14]=1.3  ; forest, SO2
		emisfac[0,7,14]=7.3  ; forest, VOC
		emisfac[1,0,14]=1613.  ; herbaceous, CO2
		emisfac[1,1,14]=57.  ; herbaceous, CO
		emisfac[1,2,14]=8.  ; herbaceous, PM10
		emisfac[1,3,14]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,14]=2.9  ; herbaceous, NOx
		emisfac[1,5,14]=0.56  ; herbaceous, NH3
		emisfac[1,6,14]=0.3  ; herbaceous, SO2
		emisfac[1,7,14]=5.4  ; herbaceous, VOC
; Define Values for lct = 15 (Ice and Snow)
 		bd[0,15] = 0.	; forest
 		bd[1,15] = 0.	; herbaceous
 		pctburn[0,0,15]=0.	; forest, dry
 		pctburn[0,1,15]=0.	; forest, moderate
 		pctburn[0,2,15]=0.	; forest, wet
 		pctburn[1,0,15]=0.	; herbaceous, dry
 		pctburn[1,1,15]=0.	; herbaceous, moderate
 		pctburn[1,2,15]=0.	; herbaceous, wet
 		emisfac[0,0,15]=0. ; forest, CO2
 		emisfac[0,1,15]=0.  ; forest, CO
 		emisfac[0,2,15]=0.  ; forest, PM10
 		emisfac[0,3,15]=0.  ; forest, PM2.5
 		emisfac[0,4,15]=0.   ; forest, NOX
 		emisfac[0,5,15]=0.  ; forest, NH3
		emisfac[0,6,15]=0.  ; forest, SO2
		emisfac[0,7,15]=0.  ; forest, VOC
		emisfac[1,0,15]=0.  ; herbaceous, CO2
		emisfac[1,1,15]=0.  ; herbaceous, CO
		emisfac[1,2,15]=0.  ; herbaceous, PM10
		emisfac[1,3,15]=0.  ; herbaceous, PM2.5
		emisfac[1,4,15]=0.  ; herbaceous, NOx
		emisfac[1,5,15]=0.  ; herbaceous, NH3
		emisfac[1,6,15]=0.  ; herbaceous, SO2
		emisfac[1,7,15]=0.  ; herbaceous, VOC
; Define Values for lct = 16 (Barren or Sparsely Vegetated)
 		bd[0,16] = 0.05	; forest
 		bd[1,16] = 0.05	; herbaceous
 		pctburn[0,0,16]=100./100.	; forest, dry
 		pctburn[0,1,16]=75./100.	; forest, moderate
 		pctburn[0,2,16]=50./100.	; forest, wet
 		pctburn[1,0,16]=100./100.	; herbaceous, dry
 		pctburn[1,1,16]=75./100.	; herbaceous, moderate
 		pctburn[1,2,16]=50./100.	; herbaceous, wet
 		emisfac[0,0,16]=1569. ; forest, CO2
 		emisfac[0,1,16]=117.5  ; forest, CO
 		emisfac[0,2,16]=11.9  ; forest, PM10
 		emisfac[0,3,16]=10.7  ; forest, PM2.5
 		emisfac[0,4,16]=1.2  ; forest, NOX
 		emisfac[0,5,16]=0.37  ; forest, NH3
		emisfac[0,6,16]=1.3  ; forest, SO2
		emisfac[0,7,16]=7.3  ; forest, VOC
		emisfac[1,0,16]=1613.  ; herbaceous, CO2
		emisfac[1,1,16]=57.  ; herbaceous, CO
		emisfac[1,2,16]=8.  ; herbaceous, PM10
		emisfac[1,3,16]=7.6  ; herbaceous, PM2.5
		emisfac[1,4,16]=2.9  ; herbaceous, NOx
		emisfac[1,5,16]=0.56  ; herbaceous, NH3
		emisfac[1,6,16]=0.3  ; herbaceous, SO2
		emisfac[1,7,16]=5.4  ; herbaceous, VOC

;**************************************************************************************
; GET INPUT AND OUTPUT FILES
 ; Set file names and pathways
   lctfile = 'co_lct.txt'
   treefile = 'co_pcttree.txt'
   herbfile = 'co_pctherb.txt'
   barefile = 'co_pctbare.txt'
   firefile = 'june30_co_v003_ascii

	; Input file pathway
		path = 'C:\FIRE\ascii_grids\V003\'
		;path = '/zeus/christin/FIRE/MODEL/'
	; Output file pathway
		 path2 = 'C:\FIRE\ascii_grids\V003\output\'
		;path2 = path

; Set up output file (comma delimited text file)
	outfile = 'test_co_june30_v003.txt'
	openw, 6, path2+outfile

; Open the files that are needed for the modeling
		openr, 1,  path+lctfile
		openr, 2,  path+treefile
		openr, 3,  path+herbfile
		openr, 4,  path+barefile
		openr, 5,  path+firefile

 		file = path+lctfile
 		print, 'opened ', file
 		file = path+treefile
 		print, 'opened ', file
 		file = path+herbfile
 		print, 'opened ', file
 		file = path+barefile
 		print, 'opened ', file
 		file = path+firefile
 		print, 'opened ', file

	printf, 6, 'xvalue, yvalue, lct,lcta1,lctm1,percentTree,percentherb,percentbare,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC'
	form = '(E20.9,",",E20.9,",",(3(I5,",")),E20.10,",",E20.10,",",E20.10,",",8(E25.10,","))'
; ******************************************************************************************
;
; Include here input data for moisture (to be added later)
;
wetness = 0
if wetness eq 0 then k = 1 ; this is the array for the wetness in the percent burn
; ASSUME that it is dry (03/18/04) for the Colorado files
k = 0	; DRY CONDITIONS
; ****************************************************************************************
; Initialize variables
		ncols=1L
		nrows = 1L
		xll = 1L
		yll = 1L
		grid = 1.0
		nodata = -32000
		junk = 1.

 ; Read headers of each of the ASCII grid files
 ; 		NOTE: These should be the same for each file!
 print, 'READING in the HEADERS'
 		readf, 1, format = '(14X,I9)', ncols
 		readf, 1, format = '(14X,I9)',nrows
 		readf, 1, format = '(14X, I10)',xll
 		readf, 1, format = '(14X, I10)',yll
 		readf, 1, format = '(14X, D17.12)',grid
 		readf, 1, format = '(14X,I7)',nodata
print, 'Finished reading in header from file 1'
 		readf, 2, format = '(14X,I9)', junk
 		readf, 2, format = '(14X,I9)',junk
 		readf, 2, format = '(14X, D17.12)',junk
 		readf, 2, format = '(14X, D17.12)',junk
 		readf, 2, format = '(14X, D17.12)',junk
 		readf, 2, format = '(14X,I7)',junk
print, 'Finished reading in header from file 2'
 		readf, 3, format = '(14X,I9)', junk
 		readf, 3, format = '(14X,I9)',junk
 		readf, 3, format = '(14X, D17.12)',junk
 		readf, 3, format = '(14X, D17.12)',junk
 		readf, 3, format = '(14X, D17.12)',junk
 		readf, 3, format = '(14X,I7)',junk
print, 'Finished reading in header from file 3'
 		readf, 4, format = '(14X,I9)', junk
 		readf, 4, format = '(14X,I9)',junk
 		readf, 4, format = '(14X, D17.12)',junk
 		readf, 4, format = '(14X, D17.12)',junk
 		readf, 4, format = '(14X, D17.12)',junk
 		readf, 4, format = '(14X,I7)',junk
print, 'Finished reading in header from file 4'
 		readf, 5, format = '(14X,I9)', junk
 		readf, 5, format = '(14X,I9)',junk
 		readf, 5, format = '(14X, D17.12)',junk
 		readf, 5, format = '(14X, D17.12)',junk
 		readf, 5, format = '(14X, D17.12)',junk
 		readf, 5, format = '(14X,I7)',junk
print, 'Finished reading in header from file 5'
 ; Check header information: Print to screen
	print, 'Number of columns = ', ncols
	print, 'Number of rows = ',nrows
 	print, 'XLL = ',xll
 	print, 'YLL ',yll
 	print, 'Cell Size = ',grid
 	print, 'No data value = ',nodata

; Initialize the arrays to be read in
	lct = intarr(ncols, nrows)
	pcttree = fltarr(ncols,nrows)
	pctbare  = fltarr(ncols,nrows)
	pctherb = fltarr(ncols,nrows)
	fireloc = fltarr(ncols,nrows)

; Initialize output arrays
	emisco = fltarr(ncols,nrows)
	emisco2 = fltarr(ncols,nrows)
	emispm10 = fltarr(ncols,nrows)
	emispm25 = fltarr(ncols,nrows)
	emisnox = fltarr(ncols,nrows)
	emisnh3 = fltarr(ncols,nrows)
	emisvoc = fltarr(ncols,nrows)
	emisso2 = fltarr(ncols,nrows)

; READING INPUT FILES- all at once! (change on 03.18.04)
; Read the row from each of the input file
 	readf,1,lct
	readf,2,pcttree
	readf,3,pctherb
	readf,4,pctbare
	readf,5,fireloc

;***********************************************************************
; START LOOP OVER THE DOMAIN
; Need to do everything by ROW- since the North American file is so big!
; This is the start of the loop to go through it all by ROW
; Re-writing loops and arrays on 03.18.04 so that all of the rows and columns are
; read in at the same time- using on a test case for COLORADO (smaller files)
for i=0,nrows-1 do begin
  ; Read through each value (column value)
 	for j=0,ncols-1 do begin
;**************************************************************
; Process only those grids with fires identified
 		if (fireloc[j,i] lt 8) then goto, LOOP
;***************************************************************
; Correct the VCF product
 			sum = pcttree[j,i] + pctherb[j,i] + pctbare[j,i]
; 			print, 'j=', j, 'i =',i, 'sum =', sum, 'lct =', lct[j]
			; If it's all OK- and no unknowns are in there- than skip this section
 			if (sum le 100.) then goto, skip
 			; If there are some unknown values in the percentages, the sum will be large
 			; And the percentages need to be corrected (this is due to the way in which the
 			; pct files were processed within the GIS
 				if (sum gt 100.) and (sum le 150.) then begin
 					; scale back to a total of 100.
 					pcttree[j,i] = pcttree[j,i]*100./sum
 					pctherb[j,i] = pctherb[j,i]*100./sum
 					pctbare[j,i] = pctbare[j,i]*100./sum
 				endif else begin
 					if (sum gt 150.) then begin
 					; This means that there are some unknowns in here and we
 					; will look at the grid cell next to this (to the west)
 						sum = pcttree[j-1,i] + pctherb[j-1,i] + pctbare[j-1,i]
 						if (sum gt 100.) AND (sum lt 150.) then begin
 							pcttree[j,i] = pcttree[j-1,i]*100./sum
 							pctherb[j,i] = pctherb[j-1,i]*100./sum
 							pctbare[j,i] = pctbare[j-1,i]*100./sum
 						endif else begin
 							if (sum le 100.) then begin
 							pcttree[j,i] = pcttree[j-1,i]
 							pctherb[j,i] = pctherb[j-1,i]
 							pctbare[j,i] = pctbare[j-1,i]
 							endif
 						if (sum gt 150.) then begin
 						; then we will look at the next grid cell...to the east
 							sum = pcttree[j+1,i] + pctherb[j+1,i] + pctbare[j+1,i]
 							if (sum gt 100.) AND (sum lt 150.) then begin
 								pcttree[j,i] = pcttree[j+1,i]*100./sum
 								pctherb[j,i] = pctherb[j+1,i]*100./sum
 								pctbare[j,i] = pctbare[j+1,i]*100./sum
 							endif else begin
 							if (sum le 100.0) then begin
 								pcttree[j,i] = pcttree[j+1,i]
 								pctherb[j,i] = pctherb[j+1,i]
 								pctbare[j,i] = pctbare[j+1,i]
 							endif else begin
 								print, 'Sum is still messed up! j = ', j, 'i = ',i
 								goto, quitearly
 							endelse
 							endelse
 						endif
 						endelse
					endif
 				endelse
skip:
;****************************************************************************
; Calculate the emissions based on
; Calculate/Estimate biomass burned- to be changed and incresed later!
 			; Estimate Fire Area
 			; Edited this on 03.18.04 to adjust area based on how much is on fire around the tile
 					area = 1.4e5 ; 0.14 km2
 			; Add 0.1 km2 for each adjoining pixel with a fire
			if j eq ncols-1 then goto, skip2
			if i eq nrows-1 then goto, skip3
 			if fireloc[j,i+1] eq 8 or fireloc[j,i+1] eq 9 then area = area + 0.1e5
 			if fireloc[j+1,i+1] eq 8 or fireloc[j+1,i+1] eq 9 then area = area + 0.1e5
 			if fireloc[j+1,i] eq 8 or fireloc[j+1,i] eq 9 then area = area + 0.1e5
 			if j eq 0 or i eq 0 then goto, skip1
 			if fireloc[j+1,i-1] eq 8 or fireloc[j+1,i-1] eq 9 then area = area + 0.1e5
			skip2:
 			if fireloc[j-1,i+1] eq 8 or fireloc[j-1,i+1] eq 9 then area = area + 0.1e5
 			skip3:
 			if fireloc[j-1,i-1] eq 8 or fireloc[j-1,i-1] eq 9 then area = area + 0.1e5
 			if fireloc[j-1,i] eq 8 or fireloc[j-1,i] eq 9 then area = area + 0.1e5
 			if fireloc[j,i-1] eq 8 or fireloc[j,i-1] eq 9 then area = area + 0.1e5
 			; Calculate Biomass Burned
 			; Calculate emissions if LCT = WATER, Snow/Ice, unknown
			skip1:
			If (lct[j,i] eq 0) or (lct[j,i] eq 15) or (lct[j,i] eq 255) or (lct[j,i] eq 254) then begin
 				print, 'The LCT for this cell is WATER, SNOW/ICE or unknown. i = ',i,' j=',j
 				if (lct[j-1,i] eq 0) or (lct[j-1,i] eq 15) or (lct[j-1,i] eq 255) or (lct[j-1,i] eq 254) then begin
 					if (lct[j+1,i] eq 0) or (lct[j+1,i] eq 15) or (lct[+1,i] eq 255) or (lct[j+1,i] eq 254) then begin
 						print, 'All surrounding cells have value of : ', lct[j,i], lct[j+1,i], lct[j-1,i]
 						goto, quitearly
 					endif else begin
 						; Emissions of the next cell [j+1] applied to this one
						; CO2 EMISSIONS
 						emisco2[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,0,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,0,lct[j+1,i]]))
						; CO EMISSIONS
 						emisco[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,1,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,1,lct[j+1,i]]))
						; PM10 EMISSIONS
 						emispm10[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,2,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,2,lct[j+1,i]]))
						; PM2.5 EMISSIONS
 						emispm25[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,3,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,3,lct[j+1,i]]))
						; NOX EMISSIONS
 						emisnox[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,4,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,4,lct[j+1,i]]))
						; NH3 EMISSIONS
 						emisnh3[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,5,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,5,lct[j+1,i]]))
						; SO2 EMISSIONS
 						emisso2[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,6,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,6,lct[j+1,i]]))
						; VOC EMISSIONS
 						emisvoc[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*bd[0,lct[j+1,i]]*emisfac[0,7,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*bd[1,lct[j+1,i]]*emisfac[1,7,lct[j+1,i]]))
						goto, output
 					endelse
 				endif
 				; Calculate the emissions of the next cell [j-1]
 					; CO2 EMISSIONS
 					emisco2[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,0,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,0,lct[j-1,i]]))
					; CO EMISSIONS
 					emisco[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,1,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,1,lct[j-1,i]]))
					; PM10 EMISSIONS
 					emispm10[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,2,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,2,lct[j-1,i]]))
					; PM2.5 EMISSIONS
 					emispm25[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,3,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,3,lct[j-1,i]]))
					; NOX EMISSIONS
 					emisnox[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,4,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,4,lct[j-1,i]]))
					; NH3 EMISSIONS
 					emisnh3[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,5,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,5,lct[j-1,i]]))
					; SO2 EMISSIONS
 					emisso2[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,6,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,6,lct[j-1,i]]))
					; VOC EMISSIONS
 					emisvoc[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*bd[0,lct[j-1,i]]*emisfac[0,7,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*bd[1,lct[j-1,i]]*emisfac[1,7,lct[j-1,i]]))
					goto, output
 			endif

 			; Calculate emissions if LCT = URBAN
 			; Urban emissions use the emissions of the vegetation class next to the grid
 			; and 1/3 of the biomass density
			If lct[j,i] eq 13 then begin
				if lct[j-1] eq 13 then begin
					if lct[j+1] eq 13 then begin
						print, 'All surrounding cells are urban! j =', j,lct[j], lct[j+1], lct[j-1]
 						print, 'calculating emissions based on several cells over. lct[j+5] =', lct[j+5]
						; CO2 Emissions
						emisco2[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,0,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,0,lct[j+5,i]]))
						; CO Emissions
						emisco[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,1,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,1,lct[j+5,i]]))
 						; PM10 Emissions
						emispm10[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,2,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,2,lct[j+5,i]]))
 						; PM2.5 Emissions
						emispm25[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,3,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,3,lct[j+5,i]]))
 						; NOx Emissions
						emisnox[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,4,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,4,lct[j+5,i]]))
 						; NH3 Emissions
						emisnh3[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,5,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,5,lct[j+5,i]]))
 						; SO2 Emissions
						emisso2[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,6,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,6,lct[j+5,i]]))
 						; VOC Emissions
						emisvoc[j,i]=area*((pcttree[j+5,i]/100.*pctburn[0,k,lct[j+5,i]]*(1/3)*bd[0,lct[j+5,i]]*emisfac[0,7,lct[j+5,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+5,i]]*(1/3)*bd[1,lct[j+5,i]]*emisfac[1,7,lct[j+5,i]]))
						goto, output
 					endif else begin
					; Calculate the urban emissions using bd = 1/3 of the cell next to it (j+1)
					; CO2 Emissions
					emisco2[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,0,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,0,lct[j+1,i]]))
					; CO Emissions
					emisco[j] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,1,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,1,lct[j+1,i]]))
					; PM10 Emissions
					emispm10[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,2,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,2,lct[j+1,i]]))
					; PM2.5 Emissions
					emispm25[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,3,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,3,lct[j+1,i]]))
					; NOX Emissions
					emisnox[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,4,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,4,lct[j+1,i]]))
					; NH3 Emissions
					emisnh3[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,5,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,5,lct[j+1,i]]))
					; SO2 Emissions
					emisso2[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,6,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,6,lct[j+1,i]]))
					; VOC Emissions
					emisvoc[j,i] = area*((pcttree[j+1,i]/100.*pctburn[0,k,lct[j+1,i]]*(1/3)*bd[0,lct[j+1,i]]*emisfac[0,7,lct[j+1,i]])+(pctherb[j+1,i]/100.*pctburn[1,k,lct[j+1,i]]*(1/3)*bd[1,lct[j+1,i]]*emisfac[1,7,lct[j+1,i]]))
					goto,output
					endelse
				endif
				; Calculate the urban emissions using bd = 1/3 of the cell next to it
				; CO2 Emissions
				emisco2[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,0,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,0,lct[j-1,i]]))
				; CO Emissions
				emisco[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,1,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,1,lct[j-1,i]]))
				; PM10 Emissions
				emispm10[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,2,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,2,lct[j-1,i]]))
				; PM2.5 Emissions
				emispm25[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,3,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,3,lct[j-1,i]]))
				; NOX Emissions
				emisnox[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,4,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,4,lct[j-1,i]]))
				; NH3 Emissions
				emisnh3[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,5,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,5,lct[j-1,i]]))
				; SO2 Emissions
				emisso2[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,6,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,6,lct[j-1,i]]))
				; VOC Emissions
				emisvoc[j,i] = area*((pcttree[j-1,i]/100.*pctburn[0,k,lct[j-1,i]]*(1/3)*bd[0,lct[j-1,i]]*emisfac[0,7,lct[j-1,i]])+(pctherb[j-1,i]/100.*pctburn[1,k,lct[j-1,i]]*(1/3)*bd[1,lct[j-1,i]]*emisfac[1,7,lct[j-1,i]]))
				goto, output
			endif
;
			; Calculate emissions for all other LCTs
			if (lct[j] ge 1) and (lct[j] le 16)	then begin
				; CALCULATE EMISSIONS
				; CO2 Emissions
					emisco2[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,0,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,0,lct[j,i]]))
				; CO Emissions
					emisco[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,1,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,1,lct[j,i]]))
				; PM10 Emissions
					emispm10[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,2,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,2,lct[j,i]]))
				; PM2.5 Emissions
					emispm25[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,3,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,3,lct[j,i]]))
				; NOx Emissions
					emisnox[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,4,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,4,lct[j,i]]))
				; NH3 Emissions
					emisnh3[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,5,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,5,lct[j,i]]))
				; SO2 Emissions
					emisso2[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,6,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,6,lct[j,i]]))
				; VOC Emissions
					emisvoc[j,i] = area*((pcttree[j,i]/100.*pctburn[0,k,lct[j,i]]*bd[0,lct[j,i]]*emisfac[0,7,lct[j,i]])+(pctherb[j,i]/100.*pctburn[1,k,lct[j,i]]*bd[1,lct[j,i]]*emisfac[1,7,lct[j,i]]))
				goto, output
			endif else begin
				print, 'Something is wrong!!! lct[j] = ', lct[j,i]
				print, 'j = ', j, 'i = ', i
				print, "STOPPING PROGRAM EARLY!'
				goto, quitearly
			endelse
			; OUTPUT THE RESULTS INTO COMMA_DELIMITED FILE
			output:
     		xvalue = xll + j*(grid)+0.5*grid
     		yvalue = yll + (nrows-i-1)*(grid)+0.5*grid
			;printf, 6, 'xvalue, yvalue, lct,lct+1,lct-1,percentTree,percentherb,percentbare,CO'
			if j eq 0 or i eq 0 then goto, print2
       		printf,6,format=form,xvalue,yvalue,lct[j,i],lct[j+1,i],lct[j-1,i],pcttree[j,i], pctherb[j,i],pctbare[j,i],emisco2[j,i],emisco[j,i],emispm10[j,i],emispm25[j,i],emisnox[j,i],emisnh3[j,i],emisso2[j,i],emisvoc[j,i]
			print2:
			printf,6,format=form,xvalue,yvalue,lct[j,i],lct[j+1,i],lct[j,i],pcttree[j,i], pctherb[j,i],pctbare[j,i],emisco2[j,i],emisco[j,i],emispm10[j,i],emispm25[j,i],emisnox[j,i],emisnh3[j,i],emisso2[j,i],emisvoc[j,i]
       	    LOOP:
 	endfor
endfor

quitearly:

; END PROGRAM
t1 = systime(1)-t0
print,'Fire_emis> End Procedure in '+ $
   strtrim(string(fix(t1)/60,t1 mod 60, $
   format='(i3,1h:,i2.2)'),2)+'.'

junk = check_math() ;This clears the math errors

close,/all   ;make sure ALL files are closed
end
