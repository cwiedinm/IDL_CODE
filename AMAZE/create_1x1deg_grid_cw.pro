; April 17, 2009:


pro create_1x1deg_grid_cw

close,/all
year0 = 2008
resol='1x1'
dlat = 1
dlon = 1
latmin = -90.
latmax = 90.
lonmin = -180.
lonmax = 180.

nlat = (latmax-latmin)/dlat
nlon = (lonmax-lonmin)/dlon

lon_grid = findgen(nlon)*dlon+lonmin+0.5*dlon
lat_grid = findgen(nlat)*dlat+latmin+0.5*dlat
print,lon_grid[0],lon_grid[nlon-1]
print,lat_grid[0],lat_grid[nlat-1]


; read Christine's files
txtfile1 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\FireEmis_JAN_APR2008_global_04082009_newcode2.txt'
txtfile2 = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\FireEmis_MAY_SEPT_2008_global_04082009_newcode2.txt'
log = 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\Netcdf\log.txt'
openw, 9, log


nfires = nlines(txtfile1)+nlines(txtfile2)-2
index2 = intarr(nfires)
lonin = fltarr(nfires)
latin = fltarr(nfires)
jday = fltarr(nfires)
timein = fltarr(nfires) ; christine added 03/16/2009
genveg = intarr(nfires)
co2 = fltarr(nfires)
co = fltarr(nfires)
nox = fltarr(nfires)
nh3 = fltarr(nfires)
so2 = fltarr(nfires)
bc = fltarr(nfires)
oc = fltarr(nfires)
bmass = fltarr(nfires)

print,txtfile1
openr,ilun,txtfile1,/get_lun
sdum=' '
readf,ilun,sdum
vars = strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]

print,'Lon: ',vars[1]
print,'Lat: ',vars[2]
print,'Day: ',vars[3]
print,'Time: ',vars[4] ; Christine addeded 03/16/2009

;map_set,0,0,/continents

; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4

data1 = fltarr(nvars)
ifire=0L
while not eof(ilun) do begin
  readf,ilun,data1
  ; Christine edited the indices from the input files on 03/16/2009
  index2[ifire] = data1[0]
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6] ; This was an incorrect index. Fixed on 04/09/09
  bmass[ifire]=data1[12]
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ;plots,lonin[ifire],latin[ifire],psym=3
  ifire = ifire+1
endwhile
free_lun,ilun
jday1 = max(jday)
print,min(jday),jday1,ifire

print,txtfile2
openr,ilun,txtfile2,/get_lun
sdum=' '
readf,ilun,sdum
vars = strsplit(sdum,',',/extract)
nvars = n_elements(vars)
for i=0,nvars-1 do print,i,': ',vars[i]
print,'Lon: ',vars[1]
print,'Lat: ',vars[2]
print,'Day: ',vars[3]

;
; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4

data1 = fltarr(nvars)
while not eof(ilun) do begin
  readf,ilun,data1
 if (data1[3] gt jday1) then begin
  index2[ifire] = data1[0]
  lonin[ifire] = data1[1]
  latin[ifire] = data1[2]
  jday[ifire] = data1[3]
  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
  genveg[ifire] = data1[6] ; Edited these indices on 04/10/09
  co2[ifire] = data1[13]
  bmass[ifire]=data1[12]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  ifire = ifire+1
 endif
endwhile
free_lun,ilun

print,'Nfires, ifire:', nfires,ifire
nfires=ifire
jday = jday[0:nfires-1]

ndays = Max(jday)-Min(jday)+1
print, 'Day1, DayEnd, NumDays'
print,Min(jday),Max(jday),ndays
day0 = Min(jday)

date = lonarr(ndays)
time = fltarr(ndays)
for i = 0,ndays-1 do begin
  iday = i + day0-1
  time[i] = Julday(1,1,year0) - Julday(1,1,1990) + iday
  caldat,(Julday(1,1,year0)+iday),mon,day,year
  date[i] = year*10000L + mon*100L + day
endfor
print,date[0],date[ndays-1]


; Totals in Tg/yr
Print, "Emissions, Tg/yr"
print,'CO2:',Total(co2)/ndays *365. *1.e-9, Total(co2)/ndays *365. *1.e-9*12./44.
print,'CO:',Total(co)/ndays *365. *1.e-9, Total(co)/ndays *365. *1.e-9*12./28.
print,'NOx:',Total(nox)/ndays *365. *1.e-9, Total(nox)/ndays *365. *1.e-9*14./30.
print,'BC',Total(bc)/ndays *365. *1.e-9
print,'OC',Total(oc)/ndays *365. *1.e-9
print,'SO2',Total(so2)/ndays *365. *1.e-9, Total(so2)/ndays *365. *1.e-9*32./64.
print,'NH3',Total(nh3)/ndays *365. *1.e-9, Total(nh3)/ndays *365. *1.e-9*14./17.

; create a new text file with the emissions

openw, 1, 'D:\Data2\wildfire\AMAZE\ModelOutput\OUTPUT_04082009\Global_OCmass_1x1.txt'
Printf, 1, 'LAtitude, Longitude, Day, OC'
form = '(F25.10,",",F25.10,",",I6,",",F25.10)'
for i=0,273 do begin ; sum over days
	today = where(jday eq (i+1)) ; grab the day
	ocnow = oc[today] ; grab the OC for that day
	lonnow = lonin[today]
	latnow = latin[today]
	; Loop over Lat/Long
	for j = 0,nlon-1 do begin
		for k = 0,nlat-1 do begin
		 	latindex = lat_grid[k]
		 	lonindex = lon_grid[j]
		 	grid = where(latnow gt (latindex-0.5) and latnow le (latindex+0.5) and lonnow gt (lonindex-0.5) and lonnow le (lonindex+0.5)
		 	OCtot = total(ocnow[grid])
		 	printf, 1, format = form, latindex, lonindex, i+1, OCtot
		 endfor
	endfor
endfor

close, /all
