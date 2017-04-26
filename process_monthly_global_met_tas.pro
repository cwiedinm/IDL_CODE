; JULY 07 2007
; Edited to:
; 	- avearge over 10 years (1991-2000)
; 	- output NetCDF file (instead of text)

pro process_monthly_global_met_TAS
today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

close, /all

infile = 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\TAS_monthly_1948-2000.nc'
print,'Reading/Writing: ',infile
ncid = ncdf_open(infile,/write)
ncdf_varget,ncid,'longitude',longitude
ncdf_varget,ncid,'latitude',latitude
ncdf_varget,ncid,'tas',tas

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


openw, 1, 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\monthly_TAS_ave1991-2000.txt'
printf, 1, 'Lat, Long, JAN, FEB, MAR, APR, MAY, JUNE, JUL, AUG, SEP, OCT, NOV, DEC'
form = '(F25.15,13(",",F25.15))'


long2 = longitude
for l = 0,359 do begin
	if longitude[l] gt 180 then long2[l] = longitude[l]-360
endfor

time = intarr(12)
for k =0,11 do begin
	time[k] = k+1
endfor

TAS_AVE=fltarr(360,180,12)
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
JAN = [TAS[j,i,0,624],TAS[j,i,0,612],TAS[j,i,0,600],TAS[j,i,0,588],TAS[j,i,0,576],TAS[j,i,0,564],$
			TAS[j,i,0,552],TAS[j,i,0,540],TAS[j,i,0,528],TAS[j,i,0,516]]
FEB = [TAS[j,i,0,625],TAS[j,i,0,613],TAS[j,i,0,601],TAS[j,i,0,589],TAS[j,i,0,577],TAS[j,i,0,565],$
			TAS[j,i,0,553],TAS[j,i,0,541],TAS[j,i,0,529],TAS[j,i,0,517]]
MAR = [TAS[j,i,0,626],TAS[j,i,0,614],TAS[j,i,0,602],TAS[j,i,0,590],TAS[j,i,0,578],TAS[j,i,0,566],$
			TAS[j,i,0,554],TAS[j,i,0,542],TAS[j,i,0,530],TAS[j,i,0,518]]
APR =[TAS[j,i,0,627],TAS[j,i,0,615],TAS[j,i,0,603],TAS[j,i,0,591],TAS[j,i,0,579],TAS[j,i,0,567],$
			TAS[j,i,0,555],TAS[j,i,0,543],TAS[j,i,0,531],TAS[j,i,0,519]]
MAY = [TAS[j,i,0,628],TAS[j,i,0,616],TAS[j,i,0,604],TAS[j,i,0,592],TAS[j,i,0,580],TAS[j,i,0,568],$
			TAS[j,i,0,556],TAS[j,i,0,544],TAS[j,i,0,532],TAS[j,i,0,520]]
JUN = [TAS[j,i,0,629],TAS[j,i,0,617],TAS[j,i,0,605],TAS[j,i,0,593],TAS[j,i,0,581],TAS[j,i,0,569],$
			TAS[j,i,0,557],TAS[j,i,0,545],TAS[j,i,0,533],TAS[j,i,0,521]]
JUL = [TAS[j,i,0,630],TAS[j,i,0,618],TAS[j,i,0,606],TAS[j,i,0,594],TAS[j,i,0,582],TAS[j,i,0,570],$
			TAS[j,i,0,558],TAS[j,i,0,546],TAS[j,i,0,534],TAS[j,i,0,522]]
AUG = [TAS[j,i,0,631],TAS[j,i,0,619],TAS[j,i,0,607],TAS[j,i,0,595],TAS[j,i,0,583],TAS[j,i,0,571],$
			TAS[j,i,0,559],TAS[j,i,0,547],TAS[j,i,0,535],TAS[j,i,0,523]]
SEP = [TAS[j,i,0,632],TAS[j,i,0,620],TAS[j,i,0,608],TAS[j,i,0,596],TAS[j,i,0,584],TAS[j,i,0,572],$
			TAS[j,i,0,560],TAS[j,i,0,548],TAS[j,i,0,536],TAS[j,i,0,524]]
OCT = [TAS[j,i,0,633],TAS[j,i,0,621],TAS[j,i,0,609],TAS[j,i,0,597],TAS[j,i,0,585],TAS[j,i,0,573],$
			TAS[j,i,0,561],TAS[j,i,0,549],TAS[j,i,0,537],TAS[j,i,0,525]]
NOV = [TAS[j,i,0,634],TAS[j,i,0,622],TAS[j,i,0,610],TAS[j,i,0,598],TAS[j,i,0,586],TAS[j,i,0,574],$
			TAS[j,i,0,562],TAS[j,i,0,550],TAS[j,i,0,538],TAS[j,i,0,526]]
DEC = [TAS[j,i,0,635],TAS[j,i,0,623],TAS[j,i,0,611],TAS[j,i,0,599],TAS[j,i,0,587],TAS[j,i,0,575],$
			TAS[j,i,0,563],TAS[j,i,0,551],TAS[j,i,0,539],TAS[j,i,0,527]]

TAS_AVE[j,i,0] = MEAN(JAN)
TAS_AVE[j,i,1] = MEAN(FEB)
TAS_AVE[j,i,2] = MEAN(MAR)
TAS_AVE[j,i,3] = MEAN(APR)
TAS_AVE[j,i,4] = MEAN(MAY)
TAS_AVE[j,i,5] = MEAN(JUN)
TAS_AVE[j,i,6] = MEAN(JUL)
TAS_AVE[j,i,7] = MEAN(AUG)
TAS_AVE[j,i,8] = MEAN(SEP)
TAS_AVE[j,i,9] = MEAN(OCT)
TAS_AVE[j,i,10] = MEAN(NOV)
TAS_AVE[j,i,11] = MEAN(DEC)

;printf, 1, format = form, latitude[i],Long2[j],JAN[j,i],FEB[j,i],MAR[j,i],$
;		APR[j,i],MAY[j,i],JUN[j,i],JUL[j,i], $
;		AUG[j,i],SEP[j,i],OCT[j,i],NOV[j,i],DEC[j,i]
	endfor
endfor

ncdf_close,ncid
close, /all

; NOW, write to an NetCDF file.
 ncfile = 'D:\Data2\MEGAN\MEGAN_INPUTS\MONTHLY_MET\Monthly_TAS_AVE1999-2000.nc'
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
 ncdf_attput,ncid,/GLOBAL,'title','Monthly averaged Temperature of Air at Surface averaged from 1991-2000'
 ncdf_attput,ncid,/GLOBAL,'authors','C. Wiedinmyer'
; ncdf_attput,ncid,/GLOBAL,'Grid is 1x1 degree'
 ncdf_attput,ncid,/GLOBAL,'History','Created '+todaystr+' from txt files from Christine Wiedinmyer'

 varid = ncdf_vardef(ncid, 'TAS_AVE', [xid,yid,tid], /float)
 ncdf_attput, ncid, varid,/char, 'units', 'K'
 ncdf_attput, ncid, varid,/char, 'long_name', 'Average TAS'
 ;ncdf_attput, ncid, varid,/short, 'mw', mw*1000.

 ncdf_control,ncid,/ENDEF

 ncdf_varput,ncid,'lon',long2
 ncdf_varput,ncid,'lat',latitude
 ncdf_varput,ncid,'time',time
 ncdf_varput,ncid,'TAS_AVE',TAS_AVE
 ncdf_close,ncid

print, 'END OF PROGRAM'

end
