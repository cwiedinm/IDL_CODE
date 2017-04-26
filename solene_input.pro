; Create a file for Solene that only includes the input for August 2007 for Greece
; program written 12/14/2011
 
 pro Solene_input
 
 close, /all
 
    inputfile = 'E:\Data2\wildfire\MODEL_INPUTS\GLOBAL\2007\GLOB_MAY_SEP2007_10212009.txt'
    inemis=ascii_template(inputfile)
    map=read_ascii(inputfile, template=inemis)
    
;2007 FILES
;     1        2     3     4     5      6        7       8   9   10   11       12
; LATITUDE,LONGITUDE,TRACK,SCAN,ACQDATE,TIME,CONFIDENCE,LCT,TREE,HERB,BARE,Regionnum, (date format= 3/1/2007)
      lat1 = map.field01
        lon1 = map.field02
        spix1 = map.field04
        tpix1 = map.field03 ; TRACK, added on 02.23.2009
        date1 = map.field05
        time1 = map.field06 ; Added 02.24.2009
        CONF = map.field07    ; ADDED 08/25/08
        tree1 = map.field09
        herb1 = map.field10
        bare1 = map.field11
        lct1 = map.field08 
        globreg1 = map.field12
        
openw, 1, 'E:\Data2\wildfire\MODEL_INPUTS\GLOBAL\2007\SOLENE\Fire_Inputs_day210-260_2007_12212011.txt'
form = '(F20.10,",",F20.10,",",F20.10,",",F20.10,",",A12,",",A12,",",I3,5(",",I7))'
printf, 1, 'Latitude, Longitude,SPIX, TPIX, Date, Time, Confidence, LCT, TREE, HERB, BARE, REGNUM'

numfires= n_elements(lat1)
for i = 0,numfires-1 do begin

;The region is:
;longitude min=21; max=24;
;latitude min=36.3; max=38.2;

  if lat1[i] lt 36. or lat1[i] gt 38.2 or lon1[i] lt 21. or lon1[i] gt 24. then goto, skipfire
  printf, 1, format=form, lat1[i],lon1[i],spix1[i],tpix1[i],date1[i],time1[i],conf[i],lct1[i],tree1[i],herb1[i],bare1[i],6
  
  skipfire:
endfor

close, /all

end
