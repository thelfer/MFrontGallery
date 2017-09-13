      program hello
      implicit none
      REAL*8 T
      REAL*8 y
      REAL*8 VanadiumAlloy_ShearModulus_SRMA
      T=293.15D0
      y=VanadiumAlloy_ShearModulus_SRMA(T)
      print *, y
      end program hello
