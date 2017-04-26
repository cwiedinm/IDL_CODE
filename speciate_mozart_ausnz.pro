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
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro speciate_MOZART_AUSNZ


close, /all

; Get pathways
   ; inpath = 'D:\Data2\wildfire\Gabi_Pfister\Fire_Emis2008\Model_output\'

;infile = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUSNZ\FireEmis_JAN_MAR_2009_AUSNZ_07022009.txt'
;outfile = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUSNZ\FireEmis_JAN_MAR_2009_AUSNZ_07022009_SPECIATE.txt
;checkfile = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\AUSNZ\CHECK_FireEmis_JAN_MAR_2009_AUSNZ_07022009_SPECIATE.txt'

;infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCT2009\GLOB_JAN_MAY2009.txt' ; RAN NOV. 18, 2009
;outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCT2009\PROCESSED\GLOB_JAN_MAY2009_MOZARTSPEC.txt' ; RAN NOV. 18,. 2009
;Checkfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\OCT2009\PROCESSED\check1.txt' ; RAN NOV. 18, 2009

infile ='F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOV2009\GLOB_JAN_MAY2009_11252009.txt' ; RAN NOV. 25, 2009
outfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOV2009\GLOB_JAN_MAY2009_11252009_MOZART.txt' ; RAN NOV. 25, 2009
checkfile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\NOV2009\CHECK_GLOB_JAN_MAY2009_11252009_MOZART.txt' ; RAN NOV. 25, 2009

; Open input file and get the needed variables
; Input files for AUS/NZ on July 02, 2009:
; 1   2    3   4   5    6   7     8        9         10      11      12  13    14  15 16 17 18  19  20  21  22  23    24
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM

; INPUT FILES FROM NOV. 18, 2009
;  1    2   3   4    5   6      7        8         9      10      11   12   13  14 15  16 17  18  19 20  21  22   23   24   25  26 27 28
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC 
;longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,CH4,H2,NOx,NO,NO2,NH3,SO2,NMHC,NMOC,PM25,TPM,OC,BC,TPC
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
	  glc = fire.field06 ; JULY 02, 2009: glc = genLC --> not used except for counting
	  CO2 = fire.field13
		CO = fire.field14
		OC = fire.field26
		BC = fire.field27
		PM25 = fire.field24
		NOX = fire.field17
		NO = fire.field18
		NO2 = fire.field19
		NH3 = fire.field20
		SO2 = fire.field21
		VOC = fire.field23
		CH4 = fire.field15
		
	

   	numfires = n_elements(glc)
		nfires = numfires

; Set up output Arrays
    CO2_emis = fltarr(numfires)
    CO_emis = fltarr(numfires)
    NOX_emis = fltarr(numfires)
    VOC_emis = fltarr(numfires)
    SO2_emis = fltarr(numfires)
    NH3_emis = fltarr(numfires)
    PM25_emis = fltarr(numfires)
    OC_emis = fltarr(numfires)
    CH4_emis = fltarr(numfires)
  	BC_EMIS = fltarr(numfires)
  	NO_emis = fltarr(numfires)
  	NO2_emis = fltarr(numfires)
  	

; Set up speciated VOC arrays
    C2H6emis =  fltarr(numfires)
    C2H4emis = fltarr(numfires)
    C3H8emis =  fltarr(numfires)
    C3H6emis =  fltarr(numfires)
    CH2Oemis =  fltarr(numfires)
    CH3OHemis =  fltarr(numfires)
    BIGALKemis =  fltarr(numfires)
    BIGENEemis =  fltarr(numfires)
    CH3COCH3emis =  fltarr(numfires)
    C2H5OHemis = fltarr(numfires)
    CH3CHOemis =  fltarr(numfires)
    MEKemis =  fltarr(numfires)
    TOLemis =  fltarr(numfires)

; Edited the output file on 02/23/2009
; edited 11/18/2009; added NO and NO2
openw, 5, outfile
printf, 5, 'DAY,GENVEG,LATI,LONGI,CO2,CO,NOX,NO,NO2,VOC,SO2,NH3,PM25,CH4,C2H6,C2H4,C3H8,C3H6,CH2O,CH3OH,BIGALK,BIGENE,CH3COCH3,C2H5OH,CH3CHO,MEK,TOL,OC,BC'
form='(I6,",",I6,",",27(D20.10,","))'

;openw, 3, checkfile
;printf, 3, 'day, longitude, latitude,CO, CO2, NOx,CH2O,NO, PM10,OC,BC,VOC'
;formcheck = '(I8,11(",",F25.14))'


;-------------------------------
; Species to calculate from CO2
;-------------------------------
; THIS SECTION PARAMETERS COPIED FROM OTHER IDL CODE (e.g., AMAZE CODE)

; Don't really need the specs here, just left them here for my knowledge
specs = ['C2H6','C2H4','C3H8','C3H6', $
 'CH2O','CH3OH','BIGALK','BIGENE','CH3COCH3','C2H5OH', $
 'CH3CHO','MEK','TOLUENE']
molwts = [30, 28, 44, 42,  $
  30, 32, 72, 56, 58, 46, $
   44, 72, 92]*1.E-3  ;kg/mole
nspec = n_elements(specs)
mw_co2 = 44.e-3  ;kg/mole

; Factors from Claire [mol-species/mol-CO2]
; Tropical forests (30S-30N)
tropsf = [1.07e-03, 1.86e-03, 9.00e-05, 3.49e-04, $
   8.89e-04, 1.67e-03, 1.32e-04, 3.21e-04, 2.850e-04, 6.030e-05, $
   8.560e-04, 5.180e-04, 2.010e-04]

;Temperate forests (lat>30)
tempsf =  [5.32e-04, 1.07e-03, 1.15e-04, 3.74e-04, $
   1.40e-03, 1.67e-03, 1.74e-04, 2.94e-04, 2.520e-04, 6.600e-05, $
   9.760e-04, 5.500e-04, 3.680e-04]

; Savanna/grass burning
savsf =   [2.84e-04, 7.54e-04, 5.45e-05, 1.66e-04, $
   2.23e-04, 1.08e-03, 8.28e-05, 1.75e-05, 2.030e-04, 4.590e-05, $
   5.560e-04, 3.210e-04, 1.280e-04]



; DO LOOP OVER ALL FIRES
for i = 0L,numfires-1 do begin
	; Orignial emissions stay the same
    	CO2_emis[i]=CO2[i]
    	CO_emis[i]=CO[i]
    	CH4_emis[i]=CH4[i]
    	VOC_emis[i]=VOC[i]
    	NH3_emis[i]=NH3[i]
    	NOX_emis[i]=NOX[i]
    	NO_emis[i] = NO[i] ; added 11/18/2009
    	NO2_emis[i] = NO2[i]
    	SO2_emis[i]=SO2[i]
    	OC_emis[i]=OC[i]
    	BC_emis[i]= BC[i]
    	PM25_emis[i]=PM25[i]

; JULY 02, 2009: Edited this section to change from GLC to LCT/GENLC (from regional to global model output)
;Generic Class	Generic description
;1	savanna and grasslands
;2	woody savanna
;3	tropical forest
;4	temperate forest
;5	boreal forest
;9	croplands
;10	urban
;0	no vegetation

; These next calculation takes the kg CO2 emitted and converts it to kg SPECIES:
; kg CO2 * (moleCO2)* (mole species)*(kg species)	 = kg species
; 		   (kg CO2)   ( mole CO2 ) 	 (mole species)

; STOP if no recognizable GenLC is in there
if genveg[i] eq 6 or genveg[i] eq 7 or genveg[i] eq 8 or genveg[i] eq 11 or genveg[i] eq 12 then STOP

; Tropical Forests (genveg = 3):
if (genveg[i] eq 3) then begin
	         C2H6emis[i] = co2[i]/mw_co2*tropsf[0]*molwts[0] ; This produces emissions in kg/day
           C2H4emis[i] = co2[i]/mw_co2*tropsf[1]*molwts[1] ; This produces emissions in kg/day
           C3H8emis[i] = co2[i]/mw_co2*tropsf[2]*molwts[2] ; This produces emissions in kg/day
           C3H6emis[i] = co2[i]/mw_co2*tropsf[3]*molwts[3] ; This produces emissions in kg/day
           CH2Oemis[i] = co2[i]/mw_co2*tropsf[4]*molwts[4] ; This produces emissions in kg/day
           CH3OHemis[i] = co2[i]/mw_co2*tropsf[5]*molwts[5] ; This produces emissions in kg/day
           BIGALKemis[i] = co2[i]/mw_co2*tropsf[6]*molwts[6] ; This produces emissions in kg/day
           BIGENEemis[i] = co2[i]/mw_co2*tropsf[7]*molwts[7] ; This produces emissions in kg/day
           CH3COCH3emis[i] = co2[i]/mw_co2*tropsf[8]*molwts[8] ; This produces emissions in kg/day
           C2H5OHemis[i] = co2[i]/mw_co2*tropsf[9]*molwts[9] ; This produces emissions in kg/day
           CH3CHOemis[i] = co2[i]/mw_co2*tropsf[10]*molwts[10] ; This produces emissions in kg/day
           MEKemis[i] = co2[i]/mw_co2*tropsf[11]*molwts[11] ; This produces emissions in kg/day
           TOLemis[i] = co2[i]/mw_co2*tropsf[12]*molwts[12] ; This produces emissions in kg/day

endif
; TEMPERATE Forests (genveg = 4) (also including boreal forests = 5):
if (genveg[i] eq 4) or (genveg[i] eq 5) then begin
       C2H6emis[i] = co2[i]/mw_co2*tempsf[0]*molwts[0] ; This produces emissions in kg/day
          C2H4emis[i] = co2[i]/mw_co2*tempsf[1]*molwts[1] ; This produces emissions in kg/day
          C3H8emis[i] = co2[i]/mw_co2*tempsf[2]*molwts[2] ; This produces emissions in kg/day
          C3H6emis[i] = co2[i]/mw_co2*tempsf[3]*molwts[3] ; This produces emissions in kg/day
          CH2Oemis[i] = co2[i]/mw_co2*tempsf[4]*molwts[4] ; This produces emissions in kg/day
          CH3OHemis[i] = co2[i]/mw_co2*tempsf[5]*molwts[5] ; This produces emissions in kg/day
          BIGALKemis[i] = co2[i]/mw_co2*tempsf[6]*molwts[6] ; This produces emissions in kg/day
          BIGENEemis[i] = co2[i]/mw_co2*tempsf[7]*molwts[7] ; This produces emissions in kg/day
          CH3COCH3emis[i] = co2[i]/mw_co2*tempsf[8]*molwts[8] ; This produces emissions in kg/day
          C2H5OHemis[i] = co2[i]/mw_co2*tempsf[9]*molwts[9] ; This produces emissions in kg/day
          CH3CHOemis[i] = co2[i]/mw_co2*tempsf[10]*molwts[10] ; This produces emissions in kg/day
          MEKemis[i] = co2[i]/mw_co2*tempsf[11]*molwts[11] ; This produces emissions in kg/day
          TOLemis[i] = co2[i]/mw_co2*tempsf[12]*molwts[12] ; This produces emissions in kg/day
endif

; Savannah/Grasslands (1):
; ** Including wooded savannas (2) and crops (9))
if (genveg[i] eq 1) or (genveg[i] eq 2) or (genveg[i] eq 9) then begin
           C2H6emis[i] = co2[i]/mw_co2*savsf[0]*molwts[0] ; This produces emissions in kg/day
           C2H4emis[i] = co2[i]/mw_co2*savsf[1]*molwts[1] ; This produces emissions in kg/day
           C3H8emis[i] = co2[i]/mw_co2*savsf[2]*molwts[2] ; This produces emissions in kg/day
           C3H6emis[i] = co2[i]/mw_co2*savsf[3]*molwts[3] ; This produces emissions in kg/day
           CH2Oemis[i] = co2[i]/mw_co2*savsf[4]*molwts[4] ; This produces emissions in kg/day
           CH3OHemis[i] = co2[i]/mw_co2*savsf[5]*molwts[5] ; This produces emissions in kg/day
           BIGALKemis[i] = co2[i]/mw_co2*savsf[6]*molwts[6] ; This produces emissions in kg/day
           BIGENEemis[i] = co2[i]/mw_co2*savsf[7]*molwts[7] ; This produces emissions in kg/day
           CH3COCH3emis[i] = co2[i]/mw_co2*savsf[8]*molwts[8] ; This produces emissions in kg/day
           C2H5OHemis[i] = co2[i]/mw_co2*savsf[9]*molwts[9] ; This produces emissions in kg/day
           CH3CHOemis[i] = co2[i]/mw_co2*savsf[10]*molwts[10] ; This produces emissions in kg/day
           MEKemis[i] = co2[i]/mw_co2*savsf[11]*molwts[11] ; This produces emissions in kg/day
           TOLemis[i] = co2[i]/mw_co2*savsf[12]*molwts[12] ; This produces emissions in kg/day
endif

if C2H6emis[i] eq 0 then begin
	 print,'fire = ',i+1,' and day: ',jday[i],' not included.
endif

; Print out to check file
;printf, 3, format = formcheck, day[i],longi[i],lati[i],CO[i], CO2[i],$
;          		NOX[i],CH2Oemis[i],OC[i],PM25[i],OCemis[i],$
;          		BC[i],VOC[i]


; Print to output file
k=i

;	                       DAY,   GENVEG,   LATI,   LONGI,   CO2,   CO,   NOX,   NO,    NO2,   VOC,   SO2,   NH3,   PM25
printf, 5, format = form,day[i],genveg[i],lati[i],longi[i],CO2[i],CO[i],NOX[i],NO[i], NO2[i],VOC[i],SO2[i],NH3[i],PM25[i],$
;   CH4,     C2H6,      C2H4,      C3H8,         C3H6,      CH2O,       CH3OH,      BIGALK,
	CH4[i],C2H6emis[i],C2H4emis[i],C3H8emis[i],C3H6emis[i],CH2Oemis[i],CH3OHemis[i],BIGALKemis[i], $
;   BIGENE,        CH3COCH3,          C2H5OH,   CH3CHO,       MEK,       TOL,       OC,    BC'
	BIGENEemis[i],CH3COCH3emis[i],C2H5OHemis[i],CH3CHOemis[i],MEKemis[i],TOLemis[i],OC[i],BC[i]

endfor ; end of i loop

; End Program
close, /all
print, 'Progran Ended! All done!'
END
