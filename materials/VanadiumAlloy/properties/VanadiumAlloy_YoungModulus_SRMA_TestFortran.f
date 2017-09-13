      program hello
      implicit none
      REAL*8 T
      REAL*8 y
      REAL*8 VanadiumAlloy_YoungModulus_SRMA
      T=293.15D0
      y=VanadiumAlloy_YoungModulus_SRMA(T)
      print *, "Hello World : ", y
      end program hello
