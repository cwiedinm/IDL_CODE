; JULY 07 2007
; Edited to:
; 	- avearge over 10 years (1991-2000)
; 	- output NetCDF file (instead of text)

pro process_monthly_global_met_DSW
today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

close, /all

infile = 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\dswrf_monthly_1948-2000.nc'
print,'Reading/Writing: ',infile
ncid = ncdf_open(infile,/write)
ncdf_varget,ncid,'longitude',longitude
ncdf_varget,ncid,'latitude',latitude
ncdf_varget,ncid,'dswrf',dswrf

; time index is months since January 1948 (ugh!)
; YEAR 1991: indices 516 - 527
; YEAR 1992: indices 528 - 539
; YEAR 1993: indices 540 - 551
; YEAR 1994: indices 552 - 563
; YEAR 1995: indices 564 - 575
; YEAR 1996: indices 576 - 587
; YEAR 1997: indices 588 - 599
; YEAR 1998: indices 600 - 611
; YEAR 1999: indices 612 - 623
; YEAR 2000: indices 624 - 635


;openw, 1, 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\monthly_DSW_ave1991-2000.txt'
;printf, 1, 'Lat, Long, JAN, FEB, MAR, APR, MAY, JUNE, JUL, AUG, SEP, OCT, NOV, DEC'
;form = '(F25.15,13(",",F25.15))'


long2 = longitude
for l = 0,359 do begin
	if longitude[l] gt 180 then long2[l] = longitude[l]-360
endfor

time = intarr(12)
for k =0,11 do begin
	time[k] = k+1
endfor

DSW_AVE=fltarr(360,180,12)
JAN = fltarr(12)
FEB = fltarr(12)
MAR = fltarr(12)
APR = fltarr(12)
MAY = fltarr(12)
JUN = fltarr(12)
JUL = fltarr(12)
AUG = fltarr(12)
SEP = fltarr(12)
OCT = fltarr(12)
NOV = fltarr(12)
DEC = fltarr(12)

for i = 0,179 do begin
	for j = 0,359 do begin

;Get averages for each month (from 1991 - 2000)
JAN = [dswrf[j,i,0,624],dswrf[j,i,0,612],dswrf[j,i,0,600],dswrf[j,i,0,588],dswrf[j,i,0,576],dswrf[j,i,0,564],$
			dswrf[j,i,0,552],dswrf[j,i,0,540],dswrf[j,i,0,528],dswrf[j,i,0,516]]
FEB = [dswrf[j,i,0,625],dswrf[j,i,0,613],dswrf[j,i,0,601],dswrf[j,i,0,589],dswrf[j,i,0,577],dswrf[j,i,0,565],$
			dswrf[j,i,0,553],dswrf[j,i,0,541],dswrf[j,i,0,529],dswrf[j,i,0,517]]
MAR = [dswrf[j,i,0,626],dswrf[j,i,0,614],dswrf[j,i,0,602],dswrf[j,i,0,590],dswrf[j,i,0,578],dswrf[j,i,0,566],$
			dswrf[j,i,0,554],dswrf[j,i,0,542],dswrf[j,i,0,530],dswrf[j,i,0,518]]
APR =[dswrf[j,i,0,627],dswrf[j,i,0,615],dswrf[j,i,0,603],dswrf[j,i,0,591],dswrf[j,i,0,579],dswrf[j,i,0,567],$
			dswrf[j,i,0,555],dswrf[j,i,0,543],dswrf[j,i,0,531],dswrf[j,i,0,519]]
MAY = [dswrf[j,i,0,628],dswrf[j,i,0,616],dswrf[j,i,0,604],dswrf[j,i,0,592],dswrf[j,i,0,580],dswrf[j,i,0,568],$
			dswrf[j,i,0,556],dswrf[j,i,0,544],dswrf[j,i,0,532],dswrf[j,i,0,520]]
JUN = [dswrf[j,i,0,629],dswrf[j,i,0,617],dswrf[j,i,0,605],dswrf[j,i,0,593],dswrf[j,i,0,581],dswrf[j,i,0,569],$
			dswrf[j,i,0,557],dswrf[j,i,0,545],dswrf[j,i,0,533],dswrf[j,i,0,521]]
JUL = [dswrf[j,i,0,630],dswrf[j,i,0,618],dswrf[j,i,0,606],dswrf[j,i,0,594],dswrf[j,i,0,582],dswrf[j,i,0,570],$
			dswrf[j,i,0,558],dswrf[j,i,0,546],dswrf[j,i,0,534],dswrf[j,i,0,522]]
AUG = [dswrf[j,i,0,631],dswrf[j,i,0,619],dswrf[j,i,0,607],dswrf[j,i,0,595],dswrf[j,i,0,583],dswrf[j,i,0,571],$
			dswrf[j,i,0,559],dswrf[j,i,0,547],dswrf[j,i,0,535],dswrf[j,i,0,523]]
SEP = [dswrf[j,i,0,632],dswrf[j,i,0,620],dswrf[j,i,0,608],dswrf[j,i,0,596],dswrf[j,i,0,584],dswrf[j,i,0,572],$
			dswrf[j,i,0,560],dswrf[j,i,0,548],dswrf[j,i,0,536],dswrf[j,i,0,524]]
OCT = [dswrf[j,i,0,633],dswrf[j,i,0,621],dswrf[j,i,0,609],dswrf[j,i,0,597],dswrf[j,i,0,585],dswrf[j,i,0,573],$
			dswrf[j,i,0,561],dswrf[j,i,0,549],dswrf[j,i,0,537],dswrf[j,i,0,525]]
NOV = [dswrf[j,i,0,634],dswrf[j,i,0,622],dswrf[j,i,0,610],dswrf[j,i,0,598],dswrf[j,i,0,586],dswrf[j,i,0,574],$
			dswrf[j,i,0,562],dswrf[j,i,0,550],dswrf[j,i,0,538],dswrf[j,i,0,526]]
DEC = [dswrf[j,i,0,635],dswrf[j,i,0,623],dswrf[j,i,0,611],dswrf[j,i,0,599],dswrf[j,i,0,587],dswrf[j,i,0,575],$
			dswrf[j,i,0,563],dswrf[j,i,0,551],dswrf[j,i,0,539],dswrf[j,i,0,527]]

DSW_AVE[j,i,0] = MEAN(JAN)
DSW_AVE[j,i,1] = MEAN(FEB)
DSW_AVE[j,i,2] = MEAN(MAR)
DSW_AVE[j,i,3] = MEAN(APR)
DSW_AVE[j,i,4] = MEAN(MAY)
DSW_AVE[j,i,5] = MEAN(JUN)
DSW_AVE[j,i,6] = MEAN(JUL)
DSW_AVE[j,i,7] = MEAN(AUG)
DSW_AVE[j,i,8] = MEAN(SEP)
DSW_AVE[j,i,9] = MEAN(OCT)
DSW_AVE[j,i,10] = MEAN(NOV)
DSW_AVE[j,i,11] = MEAN(DEC)

;printf, 1, format = form, latitude[i],Long2[j],JAN[j,i],FEB[j,i],MAR[j,i],$
;		APR[j,i],MAY[j,i],JUN[j,i],JUL[j,i], $
;		AUG[j,i],SEP[j,i],OCT[j,i],NOV[j,i],DEC[j,i]
	endfor
endfor

ncdf_close,ncid
close, /all

; NOW, write to an NetCDF file.
 ncfile = 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\Monthly_DSW_AVE1999-2000.nc'
 print,ncfile

nmonths = 12
nlon = 360
nlat = 180

 ncid = ncdf_create(ncfile,/clobber)
 ; Define dimensions
 xid = ncdf_dimdef(ncid,'lon',nlon)
 yid = ncdf_dimdef(ncid,'lat',nlat)
 tid = ncdf_dimdef(ncid,'time',nmonths)

 ; Define dimension variables with attributes
 xvarid = ncdf_vardef(ncid,'lon',[xid],/float)
 ncdf_attput, ncid, xvarid,/char, 'units', 'degrees_east'
 ncdf_attput, ncid, xvarid,/char, 'long_name', 'Longitude'
 yvarid = ncdf_vardef(ncid,'lat',[yid],/float)
 ncdf_attput, ncid, yvarid,/char, 'units', 'degrees_north'
 ncdf_attput, ncid, yvarid,/char, 'long_name', 'Latitude'
 tvarid = ncdf_vardef(ncid,'time',[tid],/float)
 ncdf_attput, ncid, tvarid,/char, 'long_name', 'MONTH'
 ncdf_attput, ncid, tvarid,/char, 'units', 'Month of year'
 ;tvarid = ncdf_vardef(ncid,'date',[tid],/long)
 ;ncdf_attput, ncid, tvarid,/char, 'units', 'YYYYMMDD'
 ;ncdf_attput, ncid, tvarid,/char, 'long_name', 'Date'
 ;Define global attributes
 ncdf_attput,ncid,/GLOBAL,'title','Monthly averaged Downward Solar Radiation averaged from 1991-2000'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer'
; ncdf_attput,ncid,/GLOBAL,'Grid is 1x1 degree'
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'DSW_AVE', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'W m-2'
 ncdf_attput, ncid, varid,/char, 'long_name', 'Average DSW'
 ;ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',long2
 ncdf_varput,ncid,'lat',latitude
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'DSW_AVE',DSW_AVE
 ncdf_close,ncid

print, 'END OF PROGRAM'

end
