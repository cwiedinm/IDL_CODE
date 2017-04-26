 ; *********************************************************
 ; This program reads in an ASCII grid file (in ESRI format)
 ; And prints out a comma delimited text file that contains
 ; the spatial information of each grid (for input to
 ; ACCESS or EXCEL)
 ; Created by Christine, 05/13/03
 ;
 ; Note: as of 05/13/03, need to only have numbers in header
 ; of ASCII grid file
 ;
 ; Edited on 05/22/2003 for the Big ELK fire ascii files from
 ; OLGA
 ; This version edited on 02/05/03 to read in the north American data
 ; for Carol and make sure we did this correctly
 ;**********************************************************

 pro read_asciigrid2

 close, /all

        filename = 'na_lct.txt'

 ; Set file names and pathways

 ;filename = 'pcrwn_'+res+'dd'
 outfile = 'na_lct_out.txt'

 ; Input file pathway
path = '/ur/christin/FIRE/'
; Output file pathway
 path2 = '/ur/christin/FIRE/'
openr, 1,  path+filename
 file = path+filename
 print, 'opened ', file

 ; Initialize vairables
 ncols=1L
 nrows = 1L
 xll = 1.0
 yll = 1.0
 grid = 1.0
 nodata = -32000

 ; read header
 readf, 1, format = '(14X,I9)', ncols
 readf, 1, format = '(14X,I9)',nrows
 readf, 1, format = '(14X, D17.12)',xll
 readf, 1, format = '(14X, D17.12)',yll
 readf, 1, format = '(14X, D17.12)',grid
 readf, 1, format = '(14X,I7)',nodata

 ; Check header information
 print, format = '(D25.14)', ncols
 print, format = '(D25.14)',nrows
print, format = '(D25.14)',xll
 print, format = '(D25.14)',yll
 print, format = '(D25.14)',grid
 print, nodata

;instead of what you have below use:

; Set up output file (comma delimited text file)
openw, 2, path2+outfile
printf, 2, 'xvalue, yvalue, lct'

lct = fltarr(ncols)

for i=0,nrows-1 do begin
 	readf,1,lct
 	for j=0,ncols-1 do begin
     		xvalue = xll + j*(grid)+0.5*grid
     		yvalue = yll + (nrows-i-1)*(grid)+0.5*grid
       		printf, 2, format = '(F25.13,",",F25.13,",",I9)', xvalue,yvalue,lct[j]
 endfor
endfor
close,1
close,2
end
