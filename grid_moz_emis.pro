; This program reads in the MOZART-4 emissions and then, (a) grids to 0.5o resoultion and (b) prints it out to a 
; file that can be read into GIS
; Created by Christine on 10/29/2010

pro grid_moz_emis

close, /all

; First, open the file 
infile = 'F:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\SEPTEMBER2010\SPECIATE\MOZ4\GLOB_JAN-NOV2009_09082010_09202010_MOZ4.txt'
; Read input file
intemp=ascii_template(infile)
fire=read_ascii(infile, template=intemp)
; 1   2    3      4     5    6   7 8  9  10  11  12  13  14   15     16     17     18     19    20     21   22   23   24   25     26       27       28      29
;DAY,TIME,GENVEG,LATI,LONGI,CO2,CO,H2,NO,NO2,SO2,NH3,CH4,NMOC,BIGALD,BIGALK,BIGENE,C10H16,C2H4,C2H5OH,C2H6,C3H6,C3H8,CH2O,CH3CHO,CH3COCH3,CH3COCHO,CH3COOH,CH3OH,CRESOL,GLYALD,GLYOXAL,HYAC,ISOP,MACR,MEK,MVK,HCN,CH3CN,TOLUENE,PM25,OC,BC,PM10,HCOOH,C2H2'  ; 11
lati = fire.field04
lon = fire.field05
day = fire.field01
ch3oh = fire.field29
genveg = fire.field03

; define arrays
longgrid = fltarr(720)
latigrid = fltarr(360)
methgrid = fltarr(720,360,12,6)
;methgrid[*,*,*,*] = 0.00

print, 'finished reading input file'
; next go through each month and then sum each grid cell
 for i = 0,11 do begin  ; go over each month
 ; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
         month = i+1
         print, 'Processing month: ', month
         ; set julian date (leap year)
         if month eq 1 then begin 
              daystart = 0 
              dayend = 31
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jan2009_meoh_crop.txt'
         endif
         if month eq 2 then begin 
              daystart = 32 
              dayend = 58
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\feb2009_meoh_crop.txt'
         endif
         if month eq 3 then begin 
              daystart = 59 
              dayend = 89
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\mar2009_meoh_crop.txt'
         endif
         if month eq 4 then begin 
              daystart = 90 
              dayend = 119
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\apr2009_meoh_crop.txt'
         endif
         if month eq 5 then begin 
              daystart = 120 
              dayend = 150
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\may2009_meoh_crop.txt'
         endif
         if month eq 6 then begin 
              daystart = 151 
              dayend = 180
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jun2009_meoh_crop.txt'
         endif
         if month eq 7 then begin 
              daystart = 181
              dayend = 211
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\jul2009_meoh_crop.txt'
         endif
         if month eq 8 then begin 
              daystart = 212 
              dayend = 242
              outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\aug2009_meoh_crop.txt'
         endif
         if month eq 9 then begin 
              daystart = 243 
              dayend = 272
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\sep2009_meoh_crop.txt'
         endif
         if month eq 10 then begin 
              daystart = 273 
              dayend = 303
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\oct2009_meoh_crop.txt'
         endif
         if month eq 11 then begin 
              daystart = 304 
              dayend = 333
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\nov2009_meoh_crop.txt'
         endif
         if month eq 12 then begin 
              daystart = 334 
              dayend = 365
               outfile1 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_ALL.txt'
;              outfile2 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_shrubtxt'
;              outfile3 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_tropfor.txt'
;              outfile4 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_tempfor.txt'
;              outfile5 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_borfor.txt'
;              outfile6 = 'F:\Data2\wildfire\IASI\Meoh_emis_2009\dec2009_meoh_crop.txt'
         endif
         ntotdays = 365
 
 ; Pull out fires in the month
thismonth = where(day ge daystart and day le dayend)

; set up output file
openw, 1, outfile1
printf, 1, "LAT,LONG,MONTH,MEOH_grass,MEOH_shrub,MEOH_tropfor,MEOH_tempfor,MEOH,borfor,MEOH_crop' 

form = '(F25.10,",",F25.10,",",I3,6(",",F25.10))'

; loop around the 0.5 degree spaces
latmin = -90.
longmin = -180.
for j = 0,719 do begin
  for k = 0,359 do begin
      grid = where((lati[thismonth] ge latmin+(k*0.5)) and (lati[thismonth] lt latmin+((k+1)*0.5)) and (lon[thismonth] ge longmin+(j*0.5)) and (lon[thismonth] le longmin+((j+1)*0.5)))
      latigrid[k] = latmin+(k*0.5)
      longgrid[j] = longmin+(j*0.5)
; Generic land cover codes (genveg) are as follows:
;    1 = grasslands and savanna
;    2 = woody savanna/shrublands
;    3 = tropical forest
;    4 = temperate forest
;    5 = boreal forest
;    9 = croplands
;    0 = no vegetation (should have been removed by now- but just in case...)
      methgrid[j,k,i,*] = 0.0
      if grid[0] lt 0 then begin
         goto, skipfire
      endif
      if grid[0] gt -1 then begin 
          ; GRASS
          grass = where(genveg[thismonth[grid]] eq 1)
          if grass[0] gt -1 then methgrid[j,k,i,0] = total(ch3oh[thismonth[grid[grass]]])
          ; SHURB
          shrub = where(genveg[thismonth[grid]] eq 2)
          if shrub[0] gt -1 then methgrid[j,k,i,1] = total(ch3oh[thismonth[grid[shrub]]])
          ; TROPFOR
          tropfor = where(genveg[thismonth[grid]] eq 3)
          if tropfor[0] gt -1 then methgrid[j,k,i,2] = total(ch3oh[thismonth[grid[tropfor]]])
          ; TEMPFOR
          tempfor = where(genveg[thismonth[grid]] eq 4)
          if tempfor[0] gt -1 then methgrid[j,k,i,3] = total(ch3oh[thismonth[grid[tempfor]]])
          ; BORFOR
          borfor = where(genveg[thismonth[grid]] eq 5)
          if borfor[0] gt -1 then methgrid[j,k,i,4] = total(ch3oh[thismonth[grid[borfor]]])
          ; CROPS
          crop = where(genveg[thismonth[grid]] eq 9)
          if crop[0] gt -1 then methgrid[j,k,i,5] = total(ch3oh[thismonth[grid[crop]]])
          printf,1, format=form,latigrid[k],longgrid[j],month,methgrid[j,k,i,0],methgrid[j,k,i,1],methgrid[j,k,i,2],methgrid[j,k,i,3],methgrid[j,k,i,4],methgrid[j,k,i,5]
      endif    
      skipfire:
  endfor
endfor    
close, 1
 
print, 'end of month: ', month
endfor ; End of monthly loop
 
print, 'Program all finished :)'
end ; End of program
 
         