
cos_t = cos(temp_angle)
sin_t = sin(temp_angle)
tan_t = tan(temp_angle)
print *, temp_angle
do j=1,napx
temptr(1)=c1m3*xv1(j)
temptr(2)=c1m3*yv1(j)/moidpsv(j)
temptr(3)=c1m3*xv2(j)
temptr(4)=c1m3*yv2(j)/moidpsv(j)
temptr(5)=c1m3*sigmv(j)/(e0f/e0)
temptr(6)=c1m3*((mtc(j)*ejv(j)-e0)/e0f)
!x  = TRACK(1,i)
!px = TRACK(2,i)
!y  = TRACK(3,i)
!py = TRACK(4,i)
!t  = TRACK(5,i)
!pt = TRACK(6,i)

z_temp = sqrt(one + two*temptr(6)/(e0f/e0) + temptr(6)**2 - temptr(2)**2 - temptr(4)**2)
pttemp = 1 - tan_t*temptr(4)/z_temp

xv1(j) = c1e3*temptr(1)/(cos_t*pttemp)
xv2(j) = xv2(j) + c1e3*(tan_t*temptr(4)*temptr(1)/(z_temp*pttemp))
yv1(j) = c1e3*(cos_t*temptr(2) + sin_t*z_temp)*moidpsv(j)
sigmv(j) = sigmv(j) - c1e3*((tan_t*temptr(1)*(one/(e0f/e0)+temptr(6))/(z_temp*pttemp))*(e0f/e0))

print * , "xxxxttt", xv1(j), "px", xv2(j), yv2(j), sigmv(j)
enddo