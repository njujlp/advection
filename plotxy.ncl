load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  ntrunc = 39
  nx = 120
  ny =  60
  nt =  20 
  dt = 5./nt
  tstep =1 
  dev = "x11"
  run = "correct"
;  run = "eulerian"
; dir = "semi-lag"
; run = "2500km_bilin"
; cint =   5
; cmin = -30
; cmax =  30
; cint =  2.
; cmin = -10
; cmax =  10
; cint =  0.5
; cmin = -3
; cmax =  3

; fname = dir+"/"+"hist_L"+run+".dat"
; fname = "../hist.dat"
  fname = "hist.dat"
  a = 6.371e6

  lon = fspan(0, 360.-360./nx, nx)
  lon!0 = "lon"
  lon&lon = lon
  lon@units = "degrees_east"
  gau_info = gaus(ny/2)
  lat = doubletofloat(gau_info(ny-1:0,0))
  wgty = doubletofloat(gau_info(:,1))
  wgtx = 1.0
  lat!0 = "lat"
  lat&lat = lat
  lat@units = "degrees_north"

  x = new((/ny, nx/), "double")
  x!0 = "lat"
  x&lat = lat
  x!1 = "lon"
  x&lon = lon
  u = x
  v = x
; fname1="semi-lag/history_L1e4km_bicubic.dat"
; fname1 = "history.dat"
; u = fbindirread(fname1, 1, (/ny, nx/), "double")
; v = fbindirread(fname1, 2, (/ny, nx/), "double")

; wks = gsn_open_wks(dev, "history_ps_L"+run)
  wks = gsn_open_wks(dev, run)

  res = True
  res@gsnMaximize = True
;  res@mpProjection = "stereographic"
;  res@mpCenterLonF =  0.
;  res@mpCenterLatF = 45.
;  res@mpLimitMode = "NPC"
;  res@mpLeftNPCF = 0.35
;  res@mpRightNPCF = 0.65
;  res@mpBottomNPCF = 0.35
;  res@mpTopNPCF = 0.65
;  res@mpGridAndLimbOn = True
  res@mpCenterLonF = 180.
  res@mpFillOn = False
  res@mpOutlineBoundarySets = "NoBoundaries"
; res@tiMainString = dir+" "+run
  res@tiMainString = fname
  rese = res
;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnLevelSpacingF = 10.
;  res@cnMinLevelValF = 10.
;  res@cnMaxLevelValF = 90.
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = ispan(10,90,10)*0.01
  res@cnMonoLineThickness = False
  res@cnLineThicknesses = (/1.,2.,1.,2.,1.,2.,1.,2.,1.,2.,1.,2./)

 res@gsnScalarContour = True
 res@vcMinDistanceF = 0.017
 res@vcRefMagnitudeF = 2.0
 res@vcRefLengthF = 0.01

  do i=0, nt, tstep
    res@gsnCenterString = "day="+i*dt
    x = fbindirread(fname, 3*i, (/ny, nx/), "double")
    u = fbindirread(fname, 3*i+1, (/ny, nx/), "double")
    v = fbindirread(fname, 3*i+2, (/ny, nx/), "double")
    print("day="+i*dt+" max phi="+max(x)+" min phi="+min(x))
    res@gsnLeftString = "max="+max(x)
    res@gsnRightString = "min="+min(x)
;    plot = gsn_csm_contour_map(wks, x, res)
   plot = gsn_csm_vector_scalar_map(wks, u, v, x, res)
  end do

; plot error 
  rese@cnMaxLevelCount = 12
  rese@cnMonoLineThickness = False
  rese@cnLineThicknesses = (/1.,2.,1.,2.,1.,2.,1.,2.,1.,2.,1.,2./)
  rese@gsnCenterString = "Simulated-Analytic"
; rese@cnLevelSpacingF = cint
; rese@cnMinLevelValF =  cmin
; rese@cnMaxLevelValF =  cmax
  rese@gsnDraw = False
  rese@gsnFrame = False
  rese@gsnContourZeroLineThicknessF = 0.0
  rese@gsnContourNegLineDashPattern = 2
  x0 = fbindirread(fname, 0, (/ny, nx/), "double")
  x = x-x0
  print("error max phi="+max(x)+" min phi="+min(x))
  print("global mean error="+wgt_areaave(x,wgty,wgtx,0))
  rese@gsnLeftString = "max="+max(x)
  rese@gsnRightString = "min="+min(x)
  plot = gsn_csm_contour_map(wks, x, rese)
  draw(plot)
  frame(wks)

end

