subroutine umat2(stress, ddsdde, stran, dstran, ntens, props, nprops) BIND(C,NAME="umat2")
!
implicit none
integer ntens,nprops
real*8 stress(ntens), ddsdde(ntens,ntens),stran(ntens), dstran(ntens), props(nprops)
!
integer i,j
real*8 e,un,al,um,am1,am2
!
e=props(1)
un=props(2)
al=un*e/(1.d0+un)/(1.d0-2.d0*un)
um=e/2.d0/(1.d0+un)
am1=al+2.d0*um
am2=um
!      
stress(1)=stress(1)+am1*dstran(1)+al*(dstran(2)+dstran(3))
stress(2)=stress(2)+am1*dstran(2)+al*(dstran(1)+dstran(3))
stress(3)=stress(3)+am1*dstran(3)+al*(dstran(1)+dstran(2))
stress(4)=stress(4)+am2*dstran(4)
stress(5)=stress(5)+am2*dstran(5)
stress(6)=stress(6)+am2*dstran(6)
!
do i=1,6
   do j=1,6
      ddsdde(i,j)=0.d0
   enddo
enddo
ddsdde(1,1)=al+2.d0*um
ddsdde(1,2)=al
ddsdde(2,1)=al
ddsdde(2,2)=al+2.d0*um
ddsdde(1,3)=al
ddsdde(3,1)=al
ddsdde(2,3)=al
ddsdde(3,2)=al
ddsdde(3,3)=al+2.d0*um
ddsdde(4,4)=um
ddsdde(5,5)=um
ddsdde(6,6)=um
return
end subroutine umat2
