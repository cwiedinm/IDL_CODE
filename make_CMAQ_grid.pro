; This is the new file to make the new grid for Jack
; below are the new parameters that he sent on Friday, Oct. 29
; This file makes one extra grid on the outside of the polygon
; The following are the grid definitions sent by Jack on January 31, 2005
; I will run this program 3 times- once for each domain
; (Edited March 10, 2005 by Christine)
; USA 36km CMAQ domain
; Edited 09/17/2008-09/24/2008 to make an input file for Xuemei
; HEADER information:
; 				 :GDTYP = 2 ;
;                :P_ALP = 33. ;
;                :P_BET = 45. ;
;                :P_GAM = -97. ;
;                :XCENT = -97. ;
;                :YCENT = 40. ;
;                :XORIG = -2628000. ;
;                :YORIG = -1980000. ;
;                :XCELL = 36000. ;
;                :YCELL = 36000. ;
;				  columns = 147
;				  rows= 111
; NOTE: This information is from the IO API Users Guide:
; X_ORIG is the X coordinate of the grid origin (lower left corner of the cell at column=row=1)
; Y_ORIG is the Y coordinate of the grid origin (lower left corner of the cell at column=row=1)
;;
; Edited on 10/09/2008 to set up the points for Tiffany's grid for WSU
;
;  global attributes:
;                :NCOLS = 184 ;
 ;               :NROWS = 121 ;
 ;               :GDTYP = 2 ;
 ;               :P_ALP = 33. ;
 ;               :P_BET = 45. ;
 ;               :P_GAM = -97. ;
;                :XCENT = -99.56718444824219 ;
 ;               :YCENT = 40.46052551269531 ;
 ;               :XORIG = -3312000. ;
 ;               :YORIG = -2178000. ;
 ;               :XCELL = 36000. ;
 ; ****** NOTE: **************************
; October 02, 2008: This is incorrect, and needs to be edited before doing AGAIN
; *********************************************************************************
; JANUARY 25, 2011: Make grid file for RONG
;                :IOAPI_VERSION = "2.2 2003141 (May 21, 2003)" ;
;                :FTYPE = 1 ;
;                :CDATE = 2011012 ;
;                :CTIME = 162647 ;
;                :WDATE = 2011012 ;
;                :WTIME = 162647 ;
;                :SDATE = 2005001 ;
;                :STIME = 10000 ;
;                :TSTEP = 7440000 ;
;                :NTHIK = 1 ;
;                :NCOLS = 213 ;
;                :NROWS = 192 ;
;                :NLAYS = 1 ;
;                :NVARS = 9 ;
;                :GDTYP = 2 ;
;                :P_ALP = 33. ;
;                :P_BET = 45. ;
;                :P_GAM = -97. ;
;                :XCENT = -97. ;
;                :YCENT = 40. ;
;                :XORIG = -2412000. ;
;                :YORIG = -972000. ;
;                :XCELL = 12000. ;
;                :YCELL = 12000. ;
;                :VGTYP = 2 ;
;                :VGTOP = 10000.f ;
;                :VGLVLS = 1.f, 0.f ;
;     
; JUNE 20, 2011
; Edited to create AMC and KB model domain
; 
;// global attributes:
;                :IOAPI_VERSION = "$Id: @(#) ioapi library version 3.0 $                                           " ;
;                :EXEC_ID = "????????????????                                                                " ;
;                :FTYPE = 1 ;
;                :CDATE = 2011160 ;
;                :CTIME = 130405 ;
;                :WDATE = 2011160 ;
;                :WTIME = 130405 ;
;                :SDATE = 1998196 ;
;                :STIME = 0 ;
;                :TSTEP = 10000 ;
;                :NTHIK = 1 ;
;                :NCOLS = 120 ;
;                :NROWS = 81 ;
;                :NLAYS = 34 ;
;                :NVARS = 6 ;
;                :GDTYP = 2 ;
;                :P_ALP = 33. ;
;                :P_BET = 45. ;
;                :P_GAM = -97. ;
;                :XCENT = -97. ;
;                :YCENT = 40. ;
;                :XORIG = -72000. ;
;                :YORIG = -684000. ;
;                :XCELL = 12000. ;
;                :YCELL = 12000. ;
;                :VGTYP = 7 ;
;                :VGTOP = 10000.f ;
; JUNE 28, 2011
; Create the 36 km domain from AMC and KB
;            :IOAPI_VERSION = "$Id: @(#) ioapi library version 3.0 $                                           " ;
;                :EXEC_ID = "????????????????                                                                " ;
;                :FTYPE = 1 ;
;                :CDATE = 2009246 ;
;                :CTIME = 181941 ;
;                :WDATE = 2009246 ;
;                :WTIME = 181941 ;
;                :SDATE = 1998196 ;
;                :STIME = 0 ;
;                :TSTEP = 10000 ;
;                :NTHIK = 1 ;
;                :NCOLS = 148 ;
;                :NROWS = 112 ;
;                :NLAYS = 1 ;
;                :NVARS = 24 ;
;                :GDTYP = 2 ;
;                :P_ALP = 33. ;
;                :P_BET = 45. ;
;                :P_GAM = -97. ;
;                :XCENT = -97. ;
;                :YCENT = 40. ;
;                :XORIG = -2736000. ;
;                :YORIG = -2088000. ;
;                :XCELL = 36000. ;
;                :YCELL = 36000. ;
;                :VGTYP = 7 ;
;                :VGTOP = 10000.f ;
;                :VGLVLS = 1.f, 0.995f ;
;                :GDNAM = "METCRO_36US1_CRO" ;
;                :UPNAM = "MG2MECH         " ;



pro make_cmaq_grid

close, /all

ncols = 148
nrows = 112
Yll = -2088000.
XLL = -2736000. 
gridsize = 36000. ; meters

; Chenc LL corner coordinates to LL center coordinates
	YLL = YLL - gridsize/2.
	XLL = XLL - gridsize/2.

openw, 1, 'E:\Data3\SOAS\Site_Selection\CMAQ\EMISSIONS\cmaq_points_36kmdom.txt'
printf, 1, 'ID, Latitude, Longitude, X, Y, BEISisop, BEISapin,BEISbpin,BEISterp,BEISsesq,MEGANisop,MEGANapin, MEGANbpin,MEGANterp,MEGANsesq'
form = '(I10,",",F25.10,",",F25.10,",",I4,",",I4,10(",",F25.10))'
ID = 0
For i = 0L,ncols+1 do begin
    for j = 0L,nrows+1 do begin
		ID = 1+ID
       lat = j*gridsize+YLL
       lon = i*gridsize+XLL
       printf,1,format = form, ID,lat,lon,i,j,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
    endfor
endfor


close, /all

end
