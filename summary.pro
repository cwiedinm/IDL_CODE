; This program will calculate monthly totals per state
; WRiting this program on 10/02/2006 because
; results from ACCESS were weird.
; edited and used on January 12, 2006 - added all 12 months
; Monthly sums are in kg/state/month


pro summary

close, /all

; Set input file
path = 'E:\wildfire\EPA_EI\MODEL\OUTPUT\Output_JAN2007\'
;infile = path + 'Modelout_2006_GLC_10022006_no2.txt'
infile = path + 'Modelout_2006_GLC_allpoints.txt' ; done on 01/12/2007
    ;infile = path + 'Modelout_2006_GLC_092206.txt'
    ;infile = path + 'Modelout_2006_GLC_10022006.txt'
instate = 'E:\wildfire\EPA_EI\Brad_files\2006_RSAC_10022006\Model_output\states.txt'

; Set output file
outfile = path +'Emis_state_summ_2006.txt'

openw, 1, outfile
printf, 1, 'STATE, month, CO, PM25,CO2'
form = '(A20,",",I3,",",D20.5,",",D20.5,",",D20.5)'

; OPEN INPUT FILE
 input=ascii_template(infile)
 data=read_ascii(infile, template=input)
 ; j,longi,lat,day,glc,id,pct_tree,pct_herb,pct_bare,area,bmass,CO2,CO,PM10,PM25,NOx,NH3,SO2,VOC,CH4,cntry,state
 day = data.field04
 CO2 = data.field12
 CO = data.field13
 PM25 = data.field15
 state = data.field23

; open STATE file
inst = ascii_template(instate)
statein = read_ascii(instate, template=inst)
stlist = statein.field2
numstates = n_elements(stlist)

; set up array with last day of each month
month = intarr(12)
month[0] = 31
month[1] = 59
month[2] = 90
month[3] = 120
month[4] = 151
month[5] = 181
month[6] = 212
month[7] = 243
month[8] = 273
month[9] = 304
month[10] = 334
month[11] = 365

fd = 0
; Loop around each month and sum over states
for i = 0,11 do begin
    monthnum = i+1
    ; Identify which fires occured during this month
    if (i eq 0) then fd = 1
    if (i ne 0) then fd = (month[i-1]+1)
    firesnow = where(day ge fd and day le month[i])
    numfires1 = n_elements(firesnow)

    COmonth = CO[firesnow] ; these are the emissions for a given month
    Statemonth = state[firesnow]
    pm25month = pm25[firesnow]
    co2month = co2[firesnow]

; Do a loop over the fires for a given month
    for k = 0,numstates-1 do begin
            frst = where(statemonth eq stlist[k])
            if frst[0] eq -1 then begin
                print, 'No fires in ', stlist[k], ' in month of ', monthnum
                goto, skipstate
            endif
            COnow = COmonth[frst]
            pm25now = pm25month[frst]
            co2now = co2month[frst]
            ; calculate totals
              sumCO2 = total(CO2now)
              sumCO = total(COnow)
              sumpm25 = total(PM25now)
         ; print to output file
              printf, 1, format = form, stlist[k],monthnum,sumCO,sumpm25,sumCO2
              skipstate:
         ; set sums back to 0 for next state
             sumCO2 = 0
             sumco = 0
             sumpm25 = 0
     endfor ; end k loop
endfor ; end i loop

close, /all

print, 'ALL FINISHED!!'

end
