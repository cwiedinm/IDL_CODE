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
; ALso- for 2004: have to only have 9 months! - need to fix later
; December 28, 2004: Edited this program to put out daily totals on a 1 degree cell
;   This is for June - September ONLY
; AUGUST 28, 2006: EDITED this program so that I can speciate the VOCs from the MIRAGE
;   fire emissions for Jerome. Going to output the emissions from each file individually
;   (same as the fire emissions model output- only this time include speciated VOC)
; October 16, 2007: Using this code to speciate the new fire emissions that were calculated
; 		Septeber 2007 for 2006 (on FTP site for wenfong et. al>.)
;
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pro makefire_specVOC

close, /all

; Get pathways
;    outpath = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_OUTPUT\Jerome\'
     outpath = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\OUTPUT_SEPT2007\Speciated_emissions\'
; Set Files
    ;infile = 'D:\Christine\WORK\wildfire\MIRAGE\POINT_FILES\MODEL_OUTPUT\Modelout_2006_GLC_2006_072506.txt'
    ;areafile = outpath+'deg1_area.txt'
	infile = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\OUTPUT_SEPT2007\Fire_Emissions_2006_MC.txt'
    outfile = outpath+'Fire_emis2006_daily_spec_10162007.txt'
    checkfile = outpath+'check_firetots2006_daily_10162007.txt'


; Open input file and get the needed variables
; Input file header:
; j,longi,lat,day,glc,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,HCN,CH3CN,Hg,cntry,state
        intemp=ascii_template(infile)
        fire=read_ascii(infile, template=intemp)
        ; Fields of Concern:
        ; Field02 = lon
        ; Field03 = lat
        ; Field04 = day
        ; Field05 = GLC Code
        ; Field11 = CO2
        ; Field12 = CO
        ; Field13 = PM10
        ; Field14 = PM2.5
        ; Field15 = NOx
        ; Field16 = NH3
        ; Field17 = SO2
        ; Field18 = VOC
        ; Field19 = CH4
        ; Emissions are in kg/km2/day


       glc = fire.field05
       numfires = n_elements(fire.field01)
       day = fire.field04
       longi = fire.field02
       lat = fire.field03

; Set up output Arrays
    CO2_emis = fire.field11
    CO_emis = fire.field12
    NOX_emis = fire.field15
    VOC_emis = fire.field18
    SO2_emis = fire.field17
    NH3_emis = fire.field16
    PM25_emis = fire.field14
    PM10_emis = fire.field13
    CH4_emis = fire.field19
    co2emis = CO2_Emis
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
    NOemis = fltarr(numfires)
    OCemis =  fltarr(numfires)
    BCemis =  fltarr(numfires)
    VOCsum =  fltarr(numfires)

; Write the check file
    openw, 3, checkfile
    printf, 3, 'day, longitude, latitude, CO2, NOx,CH2O,NO'


 openw, 1, outfile
printf, 1, 'j,longi,lat,day,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,C2H6,C2H4,C3H8,C3H6,CH2O,CH3OH,BIGALK,BIGENE,CH3COCH3,C2H5OH,CH3CHO,MEK,TOL,NO,OC,BC,VOCSUM'
;        'bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4'
    form = '(I8,",",D20.10,",",D20.10,",",I15,",",26(D25.10,","))'
for i = 0L,numfires-1 do begin
    ; These factors are calculating kg/day of the MOZART species
       ; For Tropical Forests:
         if glc[i] eq 1 or glc[i] eq 2 or glc[i] eq 29 then begin
           C2H6emis[i] = C2H6emis[i]+co2emis[i]*7.295e-4
           C2H4emis[i] = C2H4emis[i]+co2emis[i]*1.181e-03
           C3H8emis[i] = C3H8emis[i]+co2emis[i]*9.0e-5
           C3H6emis[i] = C3H6emis[i]+co2emis[i]*3.331e-04
           CH2Oemis[i] = CH2Oemis[i] +co2emis[i]*6.061e-4
           CH3OHemis[i] = CH3OHemis[i] +co2emis[i]*1.212e-03
           BIGALKemis[i] = BIGALKemis[i] +co2emis[i]*2.16e-4
           BIGENEemis[i] = BIGENEemis[i] +co2emis[i]*4.085e-4
           CH3COCH3emis[i] = CH3COCH3emis[i]+co2emis[i]*3.757e-4
           C2H5OHemis[i] = C2H5OHemis[i]+co2emis[i]*6.304e-5
           CH3CHOemis[i] = CH3CHOemis[i]+co2emis[i]*8.56e-4
           MEKemis[i] = MEKemis[i]+co2emis[i]*8.476e-4
           TOLemis[i] = TOLemis[i]+co2emis[i]*4.203e-4
           NOemis[i] = NOemis[i]+co2emis[i]*9.607e-4
           OCemis[i] = OCemis[i]+co2emis[i]*3.292e-3
           BCemis[i] = BCemis[i]+co2emis[i]*4.178e-4
         endif
          ; For TEMPERATE Forests:
         if (glc[i] ge 3 and glc[i] le 9) or glc[i] eq 20 then begin
           C2H6emis[i] = C2H6emis[i]+co2emis[i]*3.627e-04
           C2H4emis[i] = C2H4emis[i]+co2emis[i]*6.809e-04
           C3H8emis[i] = C3H8emis[i]+co2emis[i]*1.15e-04
           C3H6emis[i] = C3H6emis[i]+co2emis[i]*3.57e-04
           CH2Oemis[i] = CH2Oemis[i] +co2emis[i]*9.545e-4
           CH3OHemis[i] = CH3OHemis[i] +co2emis[i]*1.212e-03
           BIGALKemis[i] = BIGALKemis[i] +co2emis[i]*2.847e-4
           BIGENEemis[i] = BIGENEemis[i] +co2emis[i]*3.742e-4
           CH3COCH3emis[i] = CH3COCH3emis[i]+co2emis[i]*3.322e-4
           C2H5OHemis[i] = C2H5OHemis[i]+co2emis[i]*6.9e-5
           CH3CHOemis[i] = CH3CHOemis[i]+co2emis[i]*9.76e-4
           MEKemis[i] = MEKemis[i]+co2emis[i]*9.00e-4
           TOLemis[i] = TOLemis[i]+co2emis[i]*7.695e-4
           NOemis[i] = NOemis[i]+co2emis[i]*1.814e-03
           OCemis[i] = OCemis[i]+co2emis[i]*5.801e-03
           BCemis[i] = BCemis[i]+co2emis[i]*3.57e-04
         endif
           ; For Savannah/Grasslands Forests:
           ; Including open shrublands, crops, and wetlands in this category!!
         if (glc[i] ge 10 and glc[i] le 19) or (glc[i] ge 21 and glc[i] le 28) then begin
           C2H6emis[i] = C2H6emis[i]+co2emis[i]*1.936e-04
           C2H4emis[i] = C2H4emis[i]+co2emis[i]*4.798e-04
           C3H8emis[i] = C3H8emis[i]+co2emis[i]*5.45e-05
           C3H6emis[i] = C3H6emis[i]+co2emis[i]*1.585e-04
           CH2Oemis[i] = CH2Oemis[i] +co2emis[i]*1.520e-4
           CH3OHemis[i] = CH3OHemis[i] +co2emis[i]*7.876e-04
           BIGALKemis[i] = BIGALKemis[i] +co2emis[i]*1.355e-04
           BIGENEemis[i] = BIGENEemis[i] +co2emis[i]*2.227e-05
           CH3COCH3emis[i] = CH3COCH3emis[i]+co2emis[i]*2.676e-04
           C2H5OHemis[i] = C2H5OHemis[i]+co2emis[i]*4.799e-05
           CH3CHOemis[i] = CH3CHOemis[i]+co2emis[i]*5.560e-04
           MEKemis[i] = MEKemis[i]+co2emis[i]*5.253e-04
           TOLemis[i] = TOLemis[i]+co2emis[i]*2.676e-04
           NOemis[i] = NOemis[i]+co2emis[i]*2.366e-03
           OCemis[i] = OCemis[i]+co2emis[i]*2.108e-03
           BCemis[i] = BCemis[i]+co2emis[i]*2.975e-04
         endif

       vocsum[i] = C2H6emis[i]+C2H4emis[i]+C3H8emis[i]+C3H6emis[i]+CH2Oemis[i]+$
         CH3OHemis[i]+BIGALKemis[i]+BIGENEemis[i]+CH3COCH3emis[i]+C2H5OHemis[i]+$
         CH3CHOemis[i]+MEKemis[i]+TOLemis[i]

       ; Print out to check file
          printf, 3, day[i],",",longi[i],",",lat[i],",",CO2_emis[i],",",NOX_emis[i],",",CH2Oemis[i],",",NOemis[i]
       ; print to output file
       printf, 1, format = form,i,longi[i],lat[i],day[i],CO2_emis[i],CO_emis[i], $
       PM10_emis[i],PM25_emis[i],NOX_emis[i],NH3_emis[i],SO2_emis[i],VOC_emis[i],$
       CH4_emis[i],C2H6emis[i],C2H4emis[i],C3H8emis[i],C3H6emis[i],CH2Oemis[i],$
       CH3OHemis[i],BIGALKemis[i],BIGENEemis[i],CH3COCH3emis[i],C2H5OHemis[i],$
       CH3CHOemis[i],MEKemis[i],TOLemis[i],NOemis[i],OCemis[i],BCemis[i],vocsum[i]

endfor ; End of i (daily) loop


close, /all
print, 'Progran Ended! All done!'
END
