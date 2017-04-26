;*************************************************************************************
; This program takes the fire model output (comma-delimited emissions, glc, etc.)
;   1) converts the species to SAPRC99 species (including Speciation of VOC emissions)
;   2) Applies a diurnal profile to the emissions
;   3) creates an output NetCDF file
;
; January 6, 2005: First draft of program written, Christine Wiedinmyer
; March 18, 2005 - removed mistakes for speciation!!!
;   but this program doesn't print an output file!! Something is screwy!
;   See notes in Fire notebook (red one) for 03/18/2005
;
;**************************************************************************************

pro saprcfile

close, /all

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; USER CHANGE THESE Following inputs
; Get pathways
    inpath = 'G:\JANA_EPA\modeldomain\'
    outpath = 'G:\JANA_EPA\modeldomain\'
    inpath2 = 'D:\Christine\WORK\wildfire\EPA_EI\MODEL\SAPRC99\'
; Set Files

;   This is the file created from trh emissions model output and joined (spatially) with the
;   CU modeling domain
    infile = inpath+'testtry.txt'

;   This is the name of the created output file
    outfile = outpath+'testry_out.nc'

;   This is a file created to check the emisisons output
    checkfile = outpath+'check_firetots2004_daily.txt'

;   This is the input file needed to speciate the VOC emissions
;   to SAPRC99 Chemical species
    saprcfile = inpath2+'saprcspecies.txt'


; CHOSE WHICH DAYS YOU CARE ABOUT

    daymin = 190 ; July 5
    daymax = 195 ; July 10

    numcols = 147
    numrows = 111
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; Open input file emissions file and get the needed variables
        intemp=ascii_template(infile)
        fire=read_ascii(infile, template=intemp)
        ; Fields of Concern:
        ; Field01 = day
        ; Field02 = X
        ; Field03 = Y (X and Y and the grid ID for the CMAQ model domain)
        ; Field04 = GLC Code
        ; Field05 = CO
        ; Field06 = NOx
        ; Field07 = NH3
        ; Field08 = SO2
        ; Field09 = CH4 --> IGNORE: not included in CMAQ simulations (as of now!)
        ; Field10 = VOC
        ; Field11 = PM10
        ; Field12 = PM2.5
        ; Emissions are in kg/km2/day

       glc = fire.field04
       totfires = n_elements(fire.field01)

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


; ****************************************************************************
; SPECIATE ALL EMISSIONS AND PUT THEM IN SAPRC SPECIES FOR EACH FIRE POINT
for i = 0L,totfires-1 do begin
    CO1[i] = fire.field05[i]/28*1000   ; Emissions in mole/km2/day
    NO1[i] = fire.field06[i]/30*1000   ; ASSUME NOX as NO
    NH31[i] = fire.field07[i]/17*1000
    SO21[i] = fire.field08[i]/64*1000

    ; Particulate Species (in g/km2/day)
      ;The first 3 items here- speciated based on notes from Sreela (WRAP???)
       PEC1[i] = fire.field12[i]*0.09*1000     ; Elemental Carbon
       PMFINE1[i] = fire.field12[i]*0.274*1000 ; PM fine
       POA1[i] = fire.field12[i]*0.636*1000  ; Organic Aerosol
      ; Assume coarse aerosol is the difference between PM10 and PM2.5
       PMC1[i] = (Fire.field11[i] - fire.field12[i])*1000    ; Coarse Aerosol
    if PMC1[i] lt 0 then PMC1[i] = 0.0

    ;Now, need to speciate the VOC emissions to those above
    ; Land cover types for savannahs and grasslands

    if glc[i] eq 1 or glc[i] eq 2 or glc[i] eq 29 then begin     ; TROPICAL Forests
       fraction = saprcin.field3
    endif else begin
       if glc[i] ge 3 and glc[i] le 12 then begin          ; TEMPERATE Forests/shrublands
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
       ACET1[i] = ACET1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ;  gives mole/km2/day
    endfor

 ; ALK1
    points = where(saprcin.field7 eq 'ALK1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK11[i] = ALK11[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK2
    points = where(saprcin.field7 eq 'ALK2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK21[i] = ALK21[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000 ) ; gives mole/km2/day
    endfor

 ; ALK3
    points = where(saprcin.field7 eq 'ALK3')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK31[i] = ALK31[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK4
    points = where(saprcin.field7 eq 'ALK4')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK41[i] = ALK41[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ALK5
    points = where(saprcin.field7 eq 'ALK5')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ALK51[i] = ALK51[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ARO1
    points = where(saprcin.field7 eq 'ARO1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ARO11[i] = ARO11[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ARO2
    points = where(saprcin.field7 eq 'ARO2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ARO21[i] = ARO21[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; BALD
    points = where(saprcin.field7 eq 'BALD')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       BALD1[i] = BALD1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; CCHO
    points = where(saprcin.field7 eq 'CCHO')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       CCHO1[i] = CCHO1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; CCO_OH
    points = where(saprcin.field7 eq 'CCO_OH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       CCO_OH1[i] = CCO_OH1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ETHENE
    points = where(saprcin.field7 eq 'ETHENE')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ETHENE1[i] = ETHENE1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; HCHO
    points = where(saprcin.field7 eq 'HCHO')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       HCHO1[i] = HCHO1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; HCOOH
    points = where(saprcin.field7 eq 'HCOOH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       HCOOH1[i] = HCOOH1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; ISOPRENE
    points = where(saprcin.field7 eq 'ISOPRENE')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       ISOPRENE1[i] = ISOPRENE1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; MEK
    points = where(saprcin.field7 eq 'MEK')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       MEK1[i] = MEK1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; MEOH
    points = where(saprcin.field7 eq 'MEOH')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       MEOH1[i] = MEOH1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; OLE1
    points = where(saprcin.field7 eq 'OLE1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       OLE11[i] = OLE11[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; OLE2
    points = where(saprcin.field7 eq 'OLE2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       OLE21[i] = OLE21[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; PHEN
    points = where(saprcin.field7 eq 'PHEN')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       PHEN1[i] = PHEN1[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; PROD2
    points = where(saprcin.field7 eq 'PROD2')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       PROD21[i] = PROD21[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

 ; TRP1
    points = where(saprcin.field7 eq 'TRP1')
    numpoints = n_elements(points)
    ; assume that none of the arrays will equal -1, since I am only including species
    ; that are contained in that file
    for j = 0,numpoints-1 do begin
       TRP11[i] = TRP11[i]+(fire.field10[i]*fraction[points[j]]*saprcin.field5[points[j]]*saprcin.field6[points[j]]*1000)  ; gives mole/km2/day
    endfor

endfor ; End of loop calculating the speciated VOC emissions for every point
; ****************************************************************************************************




; These are the fire emissions datapoints in the days that were chosen
    numdays = daymax-daymin+1 ; this is the number of days chosen to process
; Set up arrays for each of the SAPRC99 Species
; has dimensions of columns, rows, numdays, layer)
    CO=fltarr(numcols, numrows, numdays, 1)
    ETHENE=fltarr(numcols, numrows, numdays, 1)
    ISOPRENE=fltarr(numcols, numrows, numdays, 1)
    MEOH=fltarr(numcols, numrows, numdays, 1)
    HCHO=fltarr(numcols, numrows, numdays, 1)
    CCHO=fltarr(numcols, numrows, numdays, 1)
    ACET=fltarr(numcols, numrows, numdays, 1)
    CCO_OH=fltarr(numcols, numrows, numdays, 1)
    HCOOH=fltarr(numcols, numrows, numdays, 1)
    PHEN=fltarr(numcols, numrows, numdays, 1)
    NO=fltarr(numcols, numrows, numdays, 1)
    NH3=fltarr(numcols, numrows, numdays, 1)
    SO2=fltarr(numcols, numrows, numdays, 1)
    OLE1=fltarr(numcols, numrows, numdays, 1)
    OLE2=fltarr(numcols, numrows, numdays, 1)
    ALK1=fltarr(numcols, numrows, numdays, 1)
    ALK2=fltarr(numcols, numrows, numdays, 1)
    ALK3=fltarr(numcols, numrows, numdays, 1)
    ALK4=fltarr(numcols, numrows, numdays, 1)
    ALK5=fltarr(numcols, numrows, numdays, 1)
    ARO1=fltarr(numcols, numrows, numdays, 1)
    ARO2=fltarr(numcols, numrows, numdays, 1)
    BALD=fltarr(numcols, numrows, numdays, 1)
    MEK=fltarr(numcols, numrows, numdays, 1)
    TRP1=fltarr(numcols, numrows, numdays, 1)
    PROD2=fltarr(numcols, numrows, numdays, 1)
    PEC=fltarr(numcols, numrows, numdays, 1)
    PMFINE=fltarr(numcols, numrows, numdays, 1)
    POA=fltarr(numcols, numrows, numdays, 1)
    PMC=fltarr(numcols, numrows, numdays, 1)

; ****************************************************************************************************
count = 0 ; to count the number of days
; Loop over the days of interest
    for i = daymin, daymax do begin
          ; Get all of the fire points for the given day
         fires = where(fire.field01 eq i)
         if fires[0] eq -1 then begin
            print, 'There are no fires in the domain for day ', i
            goto, skipday
         endif
         numfires = n_elements(fires)
         ; Do a loop over all of the fires for the day i
         for j = 0,numfires - 1 do begin
            ;Go through each grid cell in domain
            for k = 0,numcols-1 do begin
                for n = 0,numrows-1 do begin
                ; See if there are any fires in each grid cell
                 firesingrid = where(fire.field02 eq (k+1) and fire.field03 eq (n+1))
                 if firesingrid[0] eq -1 then goto, skipgrid  ; skip grid if no fires are in it (Assume that it gets a 0 value for everything)
                  numfiresingrid = n_elements(firesingrid)
                  ; Sum the emissions for all of the fires in the grid
                  ; Sums will have the units of mole (or g)/km2/day
                    for m = 0,numfiresingrid-1 do begin
                        CO[k,n,count,0]= CO[k,n,count,0]+CO1[firesingrid[m]]
                        ETHENE[k,n,count,0]= ETHENE[k,n,count,0]+ETHENE1[firesingrid[m]]
                        ISOPRENE[k,n,count,0]= ISOPRENE[k,n,count,0]+ISOPRENE1[firesingrid[m]]
                        MEOH[k,n,count,0]= MEOH[k,n,count,0]+MEOH1[firesingrid[m]]
                        HCHO[k,n,count,0]= HCHO[k,n,count,0]+HCHO1[firesingrid[m]]
                        CCHO[k,n,count,0]= CCHO[k,n,count,0]+CCHO1[firesingrid[m]]
                        ACET[k,n,count,0]= ACET[k,n,count,0]+ACET1[firesingrid[m]]
                        CCO_OH[k,n,count,0]= CCO_OH[k,n,count,0]+CCO_OH1[firesingrid[m]]
                        HCOOH[k,n,count,0]= HCOOH[k,n,count,0]+HCOOH1[firesingrid[m]]
                        PHEN[k,n,count,0]= PHEN[k,n,count,0]+PHEN1[firesingrid[m]]
                        NO[k,n,count,0]= NO[k,n,count,0]+NO1[firesingrid[m]]
                        NH3[k,n,count,0]= NH3[k,n,count,0]+NH31[firesingrid[m]]
                        SO2[k,n,count,0]= SO2[k,n,count,0]+SO21[firesingrid[m]]
                        OLE1[k,n,count,0]= OLE1[k,n,count,0]+OLE11[firesingrid[m]]
                        OLE2[k,n,count,0]= OLE2[k,n,count,0]+OLE21[firesingrid[m]]
                        ALK1[k,n,count,0]= ALK1[k,n,count,0]+ALK11[firesingrid[m]]
                        ALK2[k,n,count,0]= ALK2[k,n,count,0]+ALK21[firesingrid[m]]
                        ALK3[k,n,count,0]= ALK3[k,n,count,0]+ALK31[firesingrid[m]]
                        ALK4[k,n,count,0]= ALK4[k,n,count,0]+ALK41[firesingrid[m]]
                        ALK5[k,n,count,0]= ALK5[k,n,count,0]+ALK51[firesingrid[m]]
                        ARO1[k,n,count,0]= ARO1[k,n,count,0]+ARO11[firesingrid[m]]
                        ARO2[k,n,count,0]= ARO2[k,n,count,0]+ARO21[firesingrid[m]]
                        BALD[k,n,count,0]= BALD[k,n,count,0]+BALD1[firesingrid[m]]
                        MEK[k,n,count,0]= MEK[k,n,count,0]+MEK1[firesingrid[m]]
                        TRP1[k,n,count,0]= TRP1[k,n,count,0]+TRP11[firesingrid[m]]
                        PROD2[k,n,count,0]= PROD2[k,n,count,0]+PROD21[firesingrid[m]]
                        PEC[k,n,count,0]= PEC[k,n,count,0]+PEC1[firesingrid[m]]
                        PMFINE[k,n,count,0]= PMFINE[k,n,count,0]+PMFINE1[firesingrid[m]]
                        POA[k,n,count,0]= POA[k,n,count,0]+POA1[firesingrid[m]]
                        PMC[k,n,count,0]= PMC[k,n,count,0]+PMC1[firesingrid[m]]
                    endfor ; end m loop
                skipgrid:
                endfor ; end n loop (rows)
            endfor ; End k loop (columns)
         endfor ; end j loop over the number of fires for day i
    skipday:
    count=1+count
    endfor ; End of i loop over days

print, 'The program ended successfully!'

end