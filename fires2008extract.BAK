; This code takes the 2008 fire emissions
; Created on June 05, 2009 and does the following:
; 1) Extracts North America and Europe
; 2) produces new files
;
; This is for Richard at HArvard for his modeling studies

;+
function nlines,file,help=help
;       =====>> LOOP THROUGH FILE COUNTING LINES
;
tmp = ' '
nl = 0L
on_ioerror,NOASCII
if n_elements(file) eq 0 then file = pickfile()
openr,lun,file,/get_lun
while not eof(lun) do begin
  readf,lun,tmp
  nl = nl + 1L
  endwhile
close,lun
free_lun,lun
NOASCII:
return,nl
end
;-------------------------------

pro fires2008extract

close, /all
today = bin_date(systime())
todaystr = String(today[0:2],format='(i4,"/",i2.2,"/",i2.2)')

year0 = 2008

; Ran June 29, 2009
txtfile1 = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE292009\FireEmis_JAN_APR_2008_global_06292009_NEWLCT.txt'
txtfile2 = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE292009\FireEmis_MAY_SEPT_2008_global_06292009_NEWLCT.txt'
log = 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE292009\log_extract_06292009.txt'

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
area = fltarr(nfires) ; added april 20, 2009
pm25 = fltarr(nfires) ; added June 30, 2009
tpm = fltarr(nfires) ; added June 30, 2009
voc = fltarr(nfires) ; Added June 30, 2009
ch4 = fltarr(nfires) ; Added June 30, 2009

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
; HEADINGS for 06292009 FILES																					22    23
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM
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
  area[ifire] = data1[11] ; Added area on April 20, 2009
  bmass[ifire] = data1[12] ; Added biomass on April 17, 2009
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  pm25[ifire] = data1[22]	; Added June 30, 2009
  tpm[ifire] = data1[23]	; Added June 30, 2009
  voc[ifire] = data1[20]	; Added June 30, 2009
  ch4[ifire] = data1[21]	; Added June 30, 2009
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
print,'Time: ',vars[4] ; Christine addeded 03/16/2009

; Fire Emissions model output headers:
; 0, 1     2   3   4    5   6     7         8       9        10      11   12    13 14 15 16  17 18  19  20   21
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4
; j,longi,lat,day,TIME,lct,genLC,globreg,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4

; From New one on June 29, 2009 (SAME AS BEFORE)
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
  bmass[ifire] = data1[12]
  area[ifire] = data1[11] ; Added area on April 20, 2009
  co2[ifire] = data1[13]
  co[ifire] = data1[14]
  oc[ifire] = data1[15]
  bc[ifire] = data1[16]
  nox[ifire] = data1[17]
  nh3[ifire] = data1[18]
  so2[ifire] = data1[19]
  pm25[ifire] = data1[22]	; Added June 30, 2009
  tpm[ifire] = data1[23]	; Added June 30, 2009
  voc[ifire] = data1[20]	; Added June 30, 2009
  ch4[ifire] = data1[21]	; Added June 30, 2009

  ifire = ifire+1
 endif
endwhile
free_lun,ilun

print,nfires,ifire
nfires=ifire
jday = jday[0:nfires-1]

ndays = Max(jday)-Min(jday)+1
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
print,'CO2:',Total(co2)/ndays *365. *1.e-9, Total(co2)/ndays *365. *1.e-9*12./44.
print,'CO:',Total(co)/ndays *365. *1.e-9, Total(co)/ndays *365. *1.e-9*12./28.
print,'NOx:',Total(nox)/ndays *365. *1.e-9, Total(nox)/ndays *365. *1.e-9*14./30.
print,'BC',Total(bc)/ndays *365. *1.e-9
print,'OC',Total(oc)/ndays *365. *1.e-9
print,'SO2',Total(so2)/ndays *365. *1.e-9, Total(so2)/ndays *365. *1.e-9*32./64.
print,'NH3',Total(nh3)/ndays *365. *1.e-9, Total(nh3)/ndays *365. *1.e-9*14./17.
print,'PM2.5',Total(pm25)/ndays *365. *1.e-9
print,'TPM',Total(tpm)/ndays *365. *1.e-9

print,'BIOMASS', Total(bmass), ' kg/m2 for only days of file'
print,'AREA BURNED' , Total(Area), ' m2 total for only days of file'

bb = fltarr(nfires)
for i = 0L,nfires-1 do begin
	bb[i] = bmass[i]*area[i]
endfor
print, 'biomass burned',  total(bb)

; Create output files
;
; 1) Northeastern U.S.
; 		Defined by latitude: 23 - 53N; Longitude 90 to 50W
; 2) Europe
; 		Defined by latitude: 0 - 70N; Longitude 13W to 45E

; FILE # 1: Eastern US
openw, 1, 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE292009\RICHARD\FireEmis_Jan-Sept_2008_EasternUS.txt'
printf, 1, 'day,TIME,Longitude,Latitude,BB,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM'
form = '(I5,",",I5,14(",",F25.12))'

;  lonin[ifire] = data1[1]
;  latin[ifire] = data1[2]
;  jday[ifire] = data1[3]
;  timein[ifire] = data1[4] ; Christine added this one 03/16/2009
;  genveg[ifire] = data1[6] ; Edited these indices on 04/10/09
;  bmass[ifire] = data1[12]
;  area[ifire] = data1[11] ; Added area on April 20, 2009
;  co2[ifire] = data1[13]
;  co[ifire] = data1[14]
;  oc[ifire] = data1[15]
;  bc[ifire] = data1[16]
;  nox[ifire] = data1[17]
;  nh3[ifire] = data1[18]
;  so2[ifire] = data1[19]
;  pm25[ifire] = data1[22]	; Added June 30, 2009
;  tpm[ifire] = data1[23]	; Added June 30, 2009

neus = where(lonin ge -90. and lonin le -50 and latin ge 23 and latin le 53)
numneus = n_elements(neus)
for i = 0,numneus-1 do begin
	printf, 1, format = form, jday[neus[i]],timein[neus[i]],lonin[neus[i]],latin[neus[i]], $
		bb[neus[i]],co2[neus[i]],co[neus[i]],oc[neus[i]],bc[neus[i]],nox[neus[i]],nh3[neus[i]],$
		so2[neus[i]],voc[neus[i]],ch4[neus[i]],pm25[neus[i]],tpm[neus[i]]
endfor

close,1

; FILE # 2: Europe
openw, 2, 'D:\Data2\wildfire\MODEL_OUTPUTS\GLOBAL\JUNE292009\RICHARD\FireEmis_Jan-Sept_2008_Europe.txt'
printf, 2, 'day,TIME,Longitude,Latitude,BB,CO2,CO,OC,BC,NOx,NH3,SO2,VOC,CH4,PM25,TPM'

eur = where(lonin ge -13. and lonin le 45. and latin ge 30 and latin le 80.)
numeur = n_elements(eur)
for i = 0L,numeur-1 do begin
	printf, 2, format = form, jday[eur[i]],timein[eur[i]],lonin[eur[i]],latin[eur[i]], $
		bb[eur[i]],co2[eur[i]],co[eur[i]],oc[eur[i]],bc[eur[i]],nox[eur[i]],nh3[eur[i]],$
		so2[eur[i]],voc[eur[i]],ch4[eur[i]],pm25[eur[i]],tpm[eur[i]]
endfor
close, 2

close, /all

end

