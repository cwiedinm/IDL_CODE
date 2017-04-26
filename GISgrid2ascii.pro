; This program converts a GIS ASCII Grid file to a
; Comma delimited ascii file
; Written September 10, 2004
; For Claire's stuff

pro grid2ascii


close, /all

; Set file names and pathways

    path = 'D:\Christine\WORK\future_forest_paper\PAPER2\IMAGE22\'
   infile1 = path+'Glct_2000.txt'
    openr, 1, infile1
    infile2= path+'Glct_2100.txt'
    openr, 2, infile2

; Set up output file (comma delimited text file)
    path2 = 'D:\Christine\WORK\future_forest_paper\PAPER2\IMAGE22\txtfiles\'
    outfile = 'glc_2000_ascii.txt'
    openw, 6, path2+outfile

    printf, 6, 'latitude, longitude, 2000,2100'
    form = '(E20.9,",",E20.9,",",I6,",",I6)'


       ncols=1L
       nrows = 1L
       xll = 1L
       yll = 1L
       grid = 1.0
       nodata = -32000
       junk = 1.

 ; Read headers of grid ASCII grid file
 print, 'READING in the HEADERS'
      readf, 1, format = '(14X,I9)', ncols
      readf, 1, format = '(14X,I9)',nrows
      readf, 1, format = '(14X, I10)',xll
      readf, 1, format = '(14X, I10)',yll
      readf, 1, format = '(14X, D17.12)',grid
      readf, 1, format = '(14X,I7)',nodata

      readf, 2, format = '(14X,I9)', junk
      readf, 2, format = '(14X,I9)',junk
      readf, 2, format = '(14X, D17.12)',junk
      readf, 2, format = '(14X, D17.12)',junk
      readf, 2, format = '(14X, D17.12)',junk
      readf, 2, format = '(14X,I7)',junk


 ; Check header information: Print to screen
    print, 'Number of columns = ', ncols
    print, 'Number of rows = ',nrows
    print, 'XLL = ',xll
    print, 'YLL ',yll
    print, 'Cell Size = ',grid
    print, 'No data value = ',nodata


    value1 =intarr(ncols)
    value2 = intarr(ncols)

for i=0,nrows-1 do begin
    readf,1,value1
    readf,2, value2
    for j = 0,ncols-1 do begin
          xvalue = xll + j*(grid)+0.5*grid
          yvalue = yll + (nrows-i-1)*(grid)+0.5*grid
         printf, 6, xvalue,",",yvalue,",",value1[j],",",value2[j]
    endfor
endfor

close, /all

end