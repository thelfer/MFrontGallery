! Copyright (C)  2009  C. Tamagnini, E. Sellari, D. Masin, P.A. von Wolffersdorff
!
! This program is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 2 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program; if not, write to the Free Software
! Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
!  USA.

c------------------------------------------------------------------------------
      subroutine umat_hcea(stress,statev,ddsdde,sse,spd,scd,
     &  rpl,ddsddt,drplde,drpldt,
     &  stran,dstran,time,dtime,temp,dtemp,predef,dpred,cmname,
     &  ndi,nshr,ntens,nstatv,props,nprops,coords,drot,pnewdt,
     &  celent,dfgrd0,dfgrd1,noel,npt,layer,kspt,kstep,kinc)
c------------------------------------------------------------------------------
c user subroutine for Abaqus
c------------------------------------------------------------------------------
c
c	Author: D. Masin, based on RKF23 implementation by C. Tamagnini
c
c----------------------------------------------------------------------------
c
      implicit none
c
      character*80 cmname
c
      integer ntens, ndi, nshr, nstatv, nprops, noel, npt,
     & layer, kspt, kstep, kinc, inittension
c
      double precision stress(ntens), statev(nstatv),
     &  ddsdde(ntens,ntens), ddsddt(ntens), drplde(ntens),
     &  stran(ntens), dstran(ntens), time(2), predef(1), dpred(1),
     &  props(nprops), coords(3), drot(3,3), dfgrd0(3,3), dfgrd1(3,3)
      double precision sse, spd, scd, rpl, drpldt, dtime, temp, 
     &  dtemp, pnewdt, celent
c
c ... 1. nasvdim    = maximum number of additional state variables
c     2. tolintT    = prescribed error tolerance for the adaptive 
c                     substepping scheme
c     3. maxnint    = maximum number of time substeps allowed.
c                     If the limit is exceeded abaqus is forced to reduce 
c                     the overall time step size (cut-back) 
c     4. DTmin      = minimum substeps size allowed.
c                     If the limit is exceeded abaqus is forced to reduce 
c                     the overall time step size (cut-back)
c     5. perturb    = perturbation parameter for numerical computation of Jacobian matrices
c     6. nfasv      = number of first additional state variable in statev field 
c     7. prsw       = switch for printing information
c
c ... declaration of local variables
c
        logical prsw,elprsw
c
      integer i,error,maxnint,nfev,testnan,maxninttest
        integer nparms,nasvdim,nfasv,nydim,nasv,nyact,testing,error_RKF
c
        double precision dot_vect_hcea
c       
      double precision parms(nprops),theta,tolintT,dtsub,DTmin,perturb
      double precision sig_n(6),sig_np1(6),DDtan(6,6),pore,F_sig(6)
        double precision deps_np1(6),depsv_np1,norm_deps,tolintTtest
        double precision norm_deps2,pp,qq,cos3t,I1,I2,I3,norm_D2,norm_D
        double precision ameanstress,avoid,youngel,tdepel0,tdepel1,nuel
        double precision Eyoung0,Eyoung1,nu0,nu1,aOCR,outofSBS,sensit
c
      parameter (nasvdim = 10)
      parameter (nydim = 6+nasvdim)
c       parameter (tolintT = 1.0d-3) ...orig value...
        parameter (tolintT = 1.0d-3) 
        parameter (tolintTtest = 1.0d-1) 
c
c       parameter (maxnint = 1000) ...orig value...
        parameter (maxnint = 10000)
        parameter (maxninttest = 1000)
        parameter (DTmin = 1.0d-17)
        parameter (perturb = 1.0d-5)
        parameter (nfasv = 1)
        parameter (prsw = .true.)

c
c ... additional state variables
c
      double precision  asv(nasvdim)
c
c ... solution vector (stresses, additional state variables)
c
      double precision  y(nydim),y_n(nydim),dy(nydim)
c
c
c ... Error Management:
c     ----------------
c     error =  0 ... no problem in time integration
c     error =  1 ... problems in evaluation of the time rate, (e.g. undefined 
c                    stress state), reduce time integration substeps
c     error =  3 ... problems in time integration, reduce abaqus load increment 
c                    (cut-back)
c     error = 10 ... severe error, terminate calculation
c
      error=0
c
c ... check problem dimensions
c
                
      if (ndi.ne.3) then
c
                write(1,*) 'ERROR: this UMAT can be used only for elm.'
                write(1,*) 'with 3 direct stress/strain components'
                write(1,*) 'noel = ',noel
                error=10
c
      endif
c
c ... check material parameters and move them to array parms(nparms)
c
      call check_parms_hcea(props,nprops,parms,nparms,error)
c
c ... print informations about time integration, useful when problems occur
c
      elprsw = .false.
      if (prsw) then
c
c ... print only in some defined elements
c
                if ((noel.eq.101).and.(npt.eq.1)) elprsw = .false.
      endif
c
c ... define number of additional state variables
c
      call define_hcea(nasv)
      nyact = 6 + nasv
      if (nyact.gt.nydim) then
          write(1,*) 'ERROR: nasvdim too small in UMAT'
          error=10
      endif
c
c ... suggested time substep size, and initial excess pore pressure
c
      dtsub = statev(13)
      pore = -statev(8)
c
c ... initialise void ratio
c
      sensit=1
      if(statev(14) .ge. 1) then 
      	sensit=statev(14) 
      end if

      if (statev(7) .lt. 0.001) then
       	    ameanstress=-(stress(1)+stress(2)+stress(3))/3
       	    avoid=0
            if(props(22) .le. 10.0) then 
                   avoid=props(22)
            else if(props(22) .gt. 10.0) then
        	   aOCR=props(22)-10.0d0
        	   avoid=dexp(props(5)-props(3)*
     .			   	   dlog(ameanstress+props(2))
     .        	   		-props(3)*dlog(aOCR/sensit))-1
            endif
            statev(7)=avoid
            statev(16)=0
      end if
      outofSBS=statev(16)
c
c ... vector of additional state variables
c
      do i=1,nasv-1
        asv(i) = statev(i-1+nfasv)
      enddo
c     sensitivity is statev(14)
      asv(8)=statev(14)
c
c ... compute volume strain increment and current effective stress tensor
c
      do i=1,6        
            sig_n(i)=0
            deps_np1(i)=0
      end do
      call move_sig_hcea(stress,ntens,pore,sig_n)
      call move_eps_hcea(dstran,ntens,deps_np1,depsv_np1)

      norm_D2=dot_vect_hcea(2,deps_np1,deps_np1,6)
      norm_D=sqrt(norm_D2)

c ... check whether the strain rate from the ABAQUS is not NAN	  

      testnan=0
      call umatisnan_hcea(norm_D,testnan)
      if (testnan .eq. 1) then 
	     call wrista_hcea(3,y,nydim,deps_np1,dtime,coords,
     &              statev,nstatv,
     &              parms,nparms,noel,npt,ndi,nshr,kstep,kinc)
	     write(1,*) 'Error in integration, noel ',noel
	     write(1,*) 'Try to decrease the global step size'
	     call xit_hcea
      end if
c
c --------------------
c ... Time integration
c --------------------
c

      call iniy_hcea(y,nydim,nasv,ntens,sig_n,asv)
      call push_hcea(y,y_n,nydim)

c ... check whether the initial state is not tensile
      inittension=0
      call check_RKF_hcea(inittension,y,nyact,nasv,parms,nparms)
c
      if (elprsw) then
        write(1,*) '==================================================='
        write(1,*) 'Call of umat:'
        write(1,*) '==================================================='
        call wrista_hcea(3,y,nydim,deps_np1,dtime,coords,statev,nstatv,
     &              parms,nparms,noel,npt,ndi,nshr,kstep,kinc)
      endif

c ... Switch for elasticity in the case tensile stress is reached
      youngel=0
c
c ... local integration using adaptive RKF-23 method, consistent Jacobian and error estimation
c
      if((dtsub.le.0.0d0).or.(dtsub.gt.dtime)) then
        dtsub = dtime
      endif
c
      testing=0
c     For use in PLAXIS, activate the following line
      if(kstep.eq.1 .AND. kinc.eq.1) testing=1
c     For use in ABAQUS EXPLICIT, activate the following line
c     if(kstep.eq.1 .AND. kinc.eq.1) testing=3
c     For use in ABAQUS, the two lines above should be inactive
	
      if(norm_D.eq.0) testing=2
c     FEM asking for ddsdde only

      nfev = 0 ! initialisation

      if(inittension.eq.0) then

      if(testing.eq.1) then
          call rkf23_update_hcea(y,nyact,nasv,dtsub,tolintTtest,
     &                      maxninttest,DTmin,
     &                      deps_np1,parms,nparms,nfev,elprsw,
     &                      dtime,error)
c ... give original state if the model fails without substepping
          if(error.eq.3) then
            do i=1,nyact        
               y(i)=y_n(i)
            end do
            error=0
          end if
      else if(testing.eq.2) then
            do i=1,nyact        
                  y(i)=y_n(i)
            end do
      else if(testing.eq.3) then
      	temp=parms(14)
      	parms(14)=0
        call perturbate_hcea(y_n,y,nyact,nasv,dtsub,
     &      tolintT,maxnint,DTmin,
     &      deps_np1,parms,nparms,nfev,elprsw,theta,ntens,DDtan,
     &      dtime,error)      	
        parms(14)=temp
        youngel=-100
        nuel=0.3
        call calc_elasti_hcea(y,nyact,nasv,dtsub,tolintT,
     &      maxnint,DTmin,
     &      deps_np1,parms,nparms,nfev,elprsw,
     &	    dtime,DDtan,
     &	    youngel,nuel,error)
c ... Normal RKF23 integration
      else   !inittension.eq.0 .and. testing.eq.0
          call rkf23_update_hcea(y,nyact,nasv,dtsub,tolintT,
     &                      maxnint,DTmin,
     &                      deps_np1,parms,nparms,nfev,
     &                      elprsw,dtime,error)
      end if
c
c ... error conditions (if any)
c
      if (error.eq.3) then
c
c          pnewdt = 0.25d0
c
c	    Info is replaced by statev(16)	
c           write(1,*) 'UMAT: step rejected in element '
c     &			,noel,' point ',npt
           call wrista_hcea(1,y,nydim,deps_np1,dtime,
     &                coords,statev,nstatv,
     &                parms,nparms,noel,npt,ndi,nshr,kstep,kinc)
c          call xit_hcea
c          return
c ...      do not do anything, we are the most likely close to the tensile region
           do i=1,nyact        
                  y(i)=y_n(i)
           end do
c ... statev(16) is checking the out-of-SBS state
	   statev(16)=1
c
      elseif (error.eq.10) then
c
           call wrista_hcea(2,y,nydim,deps_np1,dtime,
     &                coords,statev,nstatv,
     &                parms,nparms,noel,npt,ndi,nshr,kstep,kinc)
           call xit_hcea
      endif ! end error.eq.3

c ... compute ddsdde

      call perturbate_hcea(y_n,y,nyact,nasv,dtsub,
     &      tolintT,maxnint,DTmin,
     &      deps_np1,parms,nparms,nfev,elprsw,theta,ntens,DDtan,
     &      dtime,error)

c ... if tension, replace model solution with elastic solution using ddsdde	 
	   error_RKF=0
	   call check_RKF_hcea(error_RKF,y,nyact,nasv,parms,nparms)
 	   if(error_RKF.eq.1) then
	     call matmul_hcea(DDtan,deps_np1,F_sig,6,6,1)
         do i=1,6
           y(i)=y_n(i)+F_sig(i)
         end do
	   endif
	   error_RKF=0
	   call check_RKF_hcea(error_RKF,y,nyact,nasv,parms,nparms)
 	    if(error_RKF.eq.1) then
          do i=1,6
            y(i)=y_n(i)
          end do
	   endif

      else ! inittension.ne.0
c          we were initilly in the tensile stress, calc using matrix corrected for positive stress

         call perturbate_hcea(y_n,y,nyact,nasv,dtsub,
     &      tolintT,maxnint,DTmin,
     &      deps_np1,parms,nparms,nfev,elprsw,theta,ntens,DDtan,
     &      dtime,error)
	 
	     call matmul_hcea(DDtan,deps_np1,F_sig,6,6,1)
         do i=1,6
           y(i)=y_n(i)+F_sig(i)
         end do
	   error_RKF=0
	   call check_RKF_hcea(error_RKF,y,nyact,nasv,parms,nparms)
 	    if(error_RKF.eq.1) then
          do i=1,6
            y(i)=y_n(i)
          end do
	   endif

c ... statev(16) is checking the out-of-SBS state
	    statev(16)=1
      endif ! end inittension.eq.0
c
c ... update dtsub and nfev
c
      if(dtsub.le.0.0d0) then 
      	dtsub = 0
      else if(dtsub.ge.dtime) then 
      	dtsub = dtime
      end if
      statev(13)=dtsub
      statev(10)=dfloat(nfev)
c ... convert solution (stress + cons. tangent) to abaqus format
c     update pore pressure and compute total stresses 
c
      call solout_hcea(stress,ntens,asv,nasv,ddsdde,
     +            y,nydim,pore,depsv_np1,parms,nparms,DDtan)
     
c
c ... updated vector of additional state variables to abaqus statev vector
c
      do i=1,nasv-1
           statev(i-1+nfasv) = asv(i) 
      end do
c     sensitivity is statev(14)
      statev(14)=asv(8)
c
c ... transfer additional information to statev vector
c
      do i=1,6
           sig_np1(i)=y(i)
      end do
      pp=-(sig_np1(1)+sig_np1(2)+sig_np1(3))/3
c
      statev(8) = -pore 
      statev(9) = pp

      if(inittension.eq.0) then
      call calc_statev_hcea(sig_np1,statev,parms,nparms,nasv,
     & 	nstatv,deps_np1)
      end if
c
c -----------------------
c End of time integration
c -----------------------
c
      return
      end
c------------------------------------------------------------------------------
c-----------------------------------------------------------------------------
      subroutine check_parms_hcea(props,nprops,parms,nparms,error)
c-----------------------------------------------------------------------------
c checks input material parameters 
c
c written 10/2004 (Tamagnini & Sellari)
c-----------------------------------------------------------------------------
      implicit none
c
      integer nprops,nparms,i,error
c
      double precision props(nprops),parms(nprops)
        double precision zero,one,four,pi,pi_deg,minone
        double precision phi_deg,phi,lam_star,kap_star
	double precision N_star,p_ref,nparam,gamma
        double precision r_uc,beta_r,chi,bulk_w,p_t,vertical
        double precision kparam,Aparam,sfparam,alpha,G0,m_Trat
	double precision alphanu,alphaE,nuhh
c
        parameter(zero=0.0d0,one=1.0d0,four=4.0d0,pi_deg=180.0d0)
        parameter(minone=-1.0d0)
c
        nparms=nprops
c
      do i=1,nprops
                parms(i)=props(i)
      end do
c
c ... recover material parameters
c
        phi_deg=parms(1)
        p_t=parms(2)
        lam_star=parms(3)
        kap_star=parms(4)
        N_star=parms(5)
        nuhh=parms(6)
        alpha=parms(7)
        kparam=parms(8)
        Aparam=parms(9)
        sfparam=parms(10)
        p_ref=1.d0
        r_uc=parms(11)
        beta_r=parms(12)
        chi=parms(13)
        gamma=chi
        G0=parms(14) 
        nparam=parms(15) 
        m_Trat=parms(16)
        bulk_w=parms(17)
        vertical=parms(18)
        alphaE=parms(19)
        alphanu=parms(20)
c
        pi=four*datan(one)
        phi=phi_deg*pi/pi_deg
        parms(1)=phi
c
        if(phi.le.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'phi = ',phi
                error = 10
                return 
c
        end if
c
        if(lam_star.le.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'lam_star = ',lam_star
                error = 10 
                return 
c
        end if
c
        if(kap_star.le.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'kap_star = ',kap_star
                error = 10 
                return 
c
        end if
c
        if(N_star.le.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'N_star = ',N_star
                error = 10 
                return 
c
        end if
c
        if(nuhh.le.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'nuhh = ',nuhh
                error = 10 
                return 
c
        end if
c
        if(alpha.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'alpha = ',alpha
                error = 10 
                return 
c
        end if

        if(p_ref.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'p_ref = ',p_ref
                error = 10 
                return 
c
        end if
c
        if(G0.lt.minone) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'G0 = ',G0
                error = 10 
                return 
c
        end if
c
        if(m_Trat.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'm_Trat = ',m_Trat
                error = 10 
                return 
c
        end if
c
        if(r_uc.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'r_uc = ',r_uc
                error = 10 
                return 
c
        end if
c
        if(beta_r.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'beta_r = ',beta_r
                error = 10 
                return 
c
        end if
c
        if(chi.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'chi = ',chi
                error = 10 
                return 
c
        end if
c 
        if(bulk_w.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'bulk_w = ',bulk_w
                error = 10 
                return 
c
        end if
c 
        if(p_t.lt.zero) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'p_t = ',p_t
                error = 10 
                return 
c
        end if
        if(vertical.ne.1 .and. vertical.ne.2 .and. vertical.ne.3) then
c       
                write(1,*) 'ERROR: subroutine CHECK_PARMS:'
                write(1,*) 'vertical can be 1/2/3, = ',vertical
                error = 10
                return 
c
        end if
c 
      return
      end
c-----------------------------------------------------------------------------
      subroutine define_hcea(nasv)
c-----------------------------------------------------------------------------
      implicit none 
      integer nasv
c
c number of additional state variables 
c must be less than  18 (otherwise change nasvdim in umat)
c
c    nasv(1) ... del_11  intergranular strain component
c    nasv(2) ... del_22  intergranular strain component
c    nasv(3) ... del_33  intergranular strain component
c    nasv(4) ... del_12  intergranular strain component
c    nasv(5) ... del_13  intergranular strain component
c    nasv(6) ... del_23  intergranular strain component
c    nasv(7) ... void    void ratio
c    nasv(8) ... sensitivity
c
c modified 6/2005 (Tamagnini, Sellari & Miriano)
c
      nasv = 8
      return
      end
c------------------------------------------------------------------------------
      double precision function dot_vect_hcea(flag,a,b,n)
c------------------------------------------------------------------------------
c dot product of a 2nd order tensor, stored in Voigt notation
c created 10/2004 (Tamagnini & Sellari)
c
c flag = 1 -> vectors are stresses in Voigt notation
c flag = 2 -> vectors are strains in Voigt notation
c flag = 3 -> ordinary dot product between R^n vectors
c------------------------------------------------------------------------------
      implicit none
        integer i,n,flag
      double precision a(n),b(n)
        double precision zero,half,one,two,coeff
c
        parameter(zero=0.0d0,half=0.5d0,one=1.0d0,two=2.0d0)
c
        if(flag.eq.1) then
c
c ... stress tensor (or the like)
c
                coeff=two
c
        elseif(flag.eq.2) then
c
c ... strain tensor (or the like)
c
                coeff=half
c
        else
c
c ... standard vectors
c
                coeff=one
c       
        end if
c
        dot_vect_hcea=zero
c
        do i=1,n
                if(i.le.3) then
                      dot_vect_hcea = dot_vect_hcea+a(i)*b(i)
                else
                      dot_vect_hcea = dot_vect_hcea+coeff*a(i)*b(i)
                end if
        end do
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine get_F_sig_q_hcea(sig,q,nasv,parms,nparms,
     &          deps,F_sig,F_q,error)
c-----------------------------------------------------------------------------
c
c  finds vectors F_sigma and F_q in F(y)
c
c  written 6/2005 (Tamagnini, Sellari & Miriano)
c-----------------------------------------------------------------------------
        implicit none
        double precision dot_vect_hcea
        
c 
      integer nparms,nasv,ii
c
        double precision sig(6),q(nasv),parms(nparms),deps(6)
        double precision MM(6,6),HH(nasv,6),F_sig(6),F_q(nasv)
        double precision LL(6,6),NN(6),norm_D,norm_D2,norm2
        double precision trD,depsh,depd,Aparam,edev(6)
        integer istrain,error
c
c ... compute tangent operators
c
		if(parms(14) .le. 0.5) then
			istrain=0 
		else 
			istrain=1
		end if

        call get_tan_hcea(deps,sig,q,nasv,parms,nparms,MM,
     .        HH,LL,NN,istrain,error)
c
c ... compute F_sig=MM*deps
c
		if (istrain .eq. 1) then
        		call matmul_hcea(MM,deps,F_sig,6,6,1)
        else 
        		call matmul_hcea(LL,deps,F_sig,6,6,1)
		        norm_D2=dot_vect_hcea(2,deps,deps,6)
		        norm_D=sqrt(norm_D2)
                do ii=1,6
                     F_sig(ii)=F_sig(ii)+NN(ii)*norm_D
                end do
        end if
c
c ... compute F_q=HH*deps
c
        call matmul_hcea(HH,deps,F_q,nasv,6,1)
c
c ... correct F_q for soft model
c
	trD=deps(1)+deps(2)+deps(3)
        edev(1)=deps(1)-trD/3.
        edev(2)=deps(2)-trD/3.
        edev(3)=deps(3)-trD/3.
        edev(4)=deps(4)/2.
        edev(5)=deps(5)/2.
        edev(6)=deps(6)/2.
        norm2=edev(1)*edev(1)+edev(2)*edev(2)+edev(3)*edev(3)+
     &      2.*(edev(4)*edev(4)+edev(5)*edev(5)+edev(6)*edev(6))
        depsh=dsqrt(norm2*2./3.)
        Aparam=parms(9)
	depd=dsqrt(trD*trD+Aparam/(1-Aparam)*depsh*depsh)

        F_q(nasv)=HH(8,1)*depd
c          return
        end
c-----------------------------------------------------------------------------
      subroutine get_tan_hcea(deps,sig,q,nasv,parms,nparms,MM,HH,
     .		 LL,NN,istrain,error)
c-----------------------------------------------------------------------------
c  computes matrices M and H for Masin hypoplastic model for clays with explicit ASBS
c  version with intergranular strains
c
c  NOTE: stress and strain convention: tension and extension positive
c
c  written 6/2005 (Tamagnini & Sellari)
c-----------------------------------------------------------------------------
        implicit none
c 
      integer nparms,nasv,i,j,error,k,l
c
        double precision dot_vect_hcea
c
        double precision sig(6),q(nasv),parms(nparms),deps(6)
        double precision eta(6),eta_dev(6),del(6),void,sig_star(6)
        double precision sensit,H_s(6)
        double precision eta_del(6),eta_delta(6),eta_eps(6)
        double precision norm_del,norm_del2,norm_deps,norm_deps2,eta_dn2
        double precision pp,qq,cos3t,I1,I2,I3,tanpsi
        double precision a,a2,FF,alpha,fd,fdi,fs,c_1,c_2,Yi,YY
        double precision num,den,aF,Fa2,eta_n2,norm_m,norm_m2
        double precision IU(6,6)
        double precision MM(6,6),HH(nasv,6),LL(6,6),NN(6),AA(6,6),m(6)
        integer istrain,softmodel,vert,hor1,hor2
        double precision m_dir(6),m_dir1(6),Leta(6),H_del(6,6),H_e(6)
        double precision load,rho,N_par,Stf,kparam,Aparam,sfparam
        double precision kap_par,lambda_struct
        double precision zero,tiny,half,one,two,three,six,eight,nine
        double precision onethird,sqrt3,twosqrt2,sqrt2,oneeight,ln2m1
        double precision temp1,temp2,temp3,temp4,gamma
        double precision phi,lam_star,kap_star,N_star,nuvh,r_uc,p_ref
        double precision m_R,m_T,beta_r,chi,bulk_w,p_t,sinphi,sinphi2
        double precision nparam,m_Trat,G0,Gvh,alphanu,ocrcs
	double precision alphaG,alphaE,Am,nuhh,pmeangt1
	double precision factris,ALmat,BLmat,CLmat,DLmat,ELmat,FLmat

        double precision sin2phim,ashape,npow,cos2phic,fdsbs,alpha_power
        double precision pmean,fddivfdA,krondelta(6),hypo_Dsom(6),kpow
        double precision sinphickpow,sinphimkpow,Amult,AAhce(6,6),peast
        double precision nvect(3),pmat(3,3),kron_delta(3,3)
	double precision kck(3,3,3,3), kdk(3,3,3,3), pdk(3,3,3,3)
	double precision kdp(3,3,3,3), pck(3,3,3,3), pdp(3,3,3,3)
	double precision LLfour(3,3,3,3)
	double precision an1,an2,an3,an4,an5

	logical isotrop
c
        parameter(zero=0.0d0,one=1.0d0,two=2.0d0,three=3.0d0,six=6.0d0)
        parameter(tiny=1.0d-17,half=0.5d0,eight=8.0d0,nine=9.0d0)
c
c ... initialize constants and vectors
c
        onethird=one/three
        sqrt3=dsqrt(three)
        twosqrt2=two*dsqrt(two)
        sqrt2=dsqrt(two)
        oneeight=one/eight
        onethird=one/three
        ln2m1=one/dlog(two)
c
        do i=1,6
                do j=1,6
                        MM(i,j)=zero
                        LL(i,j)=zero
                        IU(i,j)=zero
                        H_del(i,j)=zero
                end do
                eta_del(i)=zero
                eta_delta(i)=zero
                eta_eps(i)=zero
        end do
c
        do i=1,nasv
                do j=1,6
                        HH(i,j)=zero
                end do
        end do
c
        IU(1,1)=one
        IU(2,2)=one
        IU(3,3)=one
        IU(4,4)=one
        IU(5,5)=one
        IU(6,6)=one
c
c ... recover material parameters
c
        phi=parms(1)
        p_t=parms(2)
        lam_star=parms(3)
        kap_par=parms(4)
        N_par=parms(5)
        nuhh=parms(6)
        alphaG=parms(7)
        if(alphaG.lt. 0.01) then
          alphaG=1.0
        end if
        kparam=parms(8)
        Aparam=parms(9)
        sfparam=parms(10)
        p_ref=1.d0
        r_uc=parms(11)
        beta_r=parms(12)
        chi=parms(13)
        gamma=chi
        if(gamma.eq.0) gamma=chi
        G0=parms(14) 
        nparam=parms(15) 
        m_Trat=parms(16)
        bulk_w=parms(17)
        vert=parms(18)
        alphaE=parms(19)
        alphanu=parms(20)
        if(alphaE.lt. 0.01) then
          alphaE=alphaG**1.25
        end if
        if(alphanu.lt. 0.01) then
          alphanu=alphaG
        end if
c
        sinphi=dsin(phi)
        sinphi2=sinphi*sinphi
        nuvh=nuhh/alphanu
        
        a=sqrt3*(three-sin(phi))/(twosqrt2*sin(phi))
	a2=a*a
	temp1=(lam_star-kap_par)/(lam_star+kap_par)
	temp2=(three+a2)/(sqrt3*a)
	alpha_power=ln2m1*dlog(temp1*temp2)
        if(nparms .ge. 21 .and. 
     &     parms(21) .ge. 0.00001) alpha_power=parms(21)
c
c ... recover internal state variables
c
        del(1)=q(1)
        del(2)=q(2)
        del(3)=q(3)
        del(4)=q(4)
        del(5)=q(5)
        del(6)=q(6)
        void=q(7)
        sensit=q(8)
c
c ... soft clay model
c
	softmodel=0
        Stf=1
        N_star=N_par
        kap_star=kap_par
	lambda_struct=lam_star
	if(sensit .ge. 1) then
	  softmodel=1
	  N_star=N_par+lam_star*log(sensit)
	  Stf=(sensit-kparam*(sensit-sfparam))/sensit
	  lambda_struct=lam_star/Stf
	end if
c
c ... axis translation due to cohesion (p_t>0)
c
        sig_star(1)=sig(1)-p_t
        sig_star(2)=sig(2)-p_t
        sig_star(3)=sig(3)-p_t
        sig_star(4)=sig(4)
        sig_star(5)=sig(5)
        sig_star(6)=sig(6)
c
c ... strain increment and intergranular strain directions
c
        norm_deps2=dot_vect_hcea(2,deps,deps,6)
        norm_del2=dot_vect_hcea(2,del,del,6)
        norm_deps=dsqrt(norm_deps2)
        norm_del=dsqrt(norm_del2)
c
        if(norm_del.ge.tiny) then
c
                do i=1,6
                        eta_del(i)=del(i)/norm_del
                end do
c
        end if
c
        eta_delta(1)=eta_del(1)
        eta_delta(2)=eta_del(2)
        eta_delta(3)=eta_del(3)
        eta_delta(4)=half*eta_del(4)
        eta_delta(5)=half*eta_del(5)
        eta_delta(6)=half*eta_del(6)
c
        if(norm_deps.ge.tiny) then
c
                do i=1,6
                        eta_eps(i)=deps(i)/norm_deps
                end do
c
        end if
c
c ... auxiliary stress tensors
c
        call inv_sig_hcea(sig_star,pp,qq,cos3t,I1,I2,I3)
c
c        if (pp.gt.tiny) then
c
c ... if mean stress is negative, return with MM = 0, HH = 0 and error = 10 (severe)
c
c                write(1,*) 'ERROR: subroutine GET_TAN:'
c                write(1,*) 'Mean stress is positive (tension): p = ',pp
c                error = 10
c                return 
c
c        end if
c
        eta(1)=sig_star(1)/I1
        eta(2)=sig_star(2)/I1
        eta(3)=sig_star(3)/I1
        eta(4)=sig_star(4)/I1
        eta(5)=sig_star(5)/I1
        eta(6)=sig_star(6)/I1   
c
        eta_dev(1)=eta(1)-onethird
        eta_dev(2)=eta(2)-onethird
        eta_dev(3)=eta(3)-onethird
        eta_dev(4)=eta(4)
        eta_dev(5)=eta(5)
        eta_dev(6)=eta(6)

        krondelta(1)=one
        krondelta(2)=one
        krondelta(3)=one
        krondelta(4)=zero
        krondelta(5)=zero
        krondelta(6)=zero
c
c ... explicit clay hypoplasticity specific
c
        peast=dexp((N_star-dlog(one+void))/lam_star)

        if((I3+I1*I2).ne.0) then
	      sin2phim=(9*I3+I1*I2)/(I3+I1*I2)
	    else
	      sin2phim=1
	    end if
	    if(sin2phim .gt. 1) then
	      sin2phim=1
	    end if
	    if(sin2phim .lt. 0) then
	      sin2phim=0
	    end if
	    
	cos2phic=1-sin(phi)*sin(phi)
	ashape=0.30d0
	ocrcs=2.0d0
c npow is omega in the paper	
	npow=-log(cos2phic)/log(ocrcs)+
     .   ashape*(sin2phim-sin(phi)*sin(phi))
	fdsbs=ocrcs*(1-sin2phim)**(1/npow)
	
        pmean=-I1/3.0d0
	fd=((ocrcs*pmean)/peast)**alpha_power
        fdsbs=fdsbs**alpha_power
	fddivfdA=fd/fdsbs

c        if((peast/pmean).lt.0.90) then
c           write(1,*) 'ERROR: subroutine GET_TAN:'
c           write(1,*) 'OCR cannot be lower than 1'
c           write(1,*) 'Check initial void ratio'
c           if (istrain .eq. 0) then
c           	   error = 3
c           end if
c           return 
c        end if

	isotrop=.false.
	if (sin2phim<1.e-10) then
	   sin2phim=0
	   isotrop=.true.
	end if
	if(isotrop) then
            cos3t=-1
        end if

        Am=nuvh*nuvh*(4*alphaE*alphanu-2*alphaE*
     .       alphaE*alphanu*alphanu+
     .       2*alphaE*alphaE-alphanu*alphanu)+
     .       nuvh*(4*alphaE+2*alphaE*alphanu)+1+2*alphaE;

	fs=9*pmean/2*(1/kap_par+1/lambda_struct)/Am

        do i=1,3
           nvect(i)=0
        end do
	nvect(vert)=1

        if(vert.ne.1 .and. vert.ne.2 .and. vert.ne.3) then
           write(1,*) 'ERROR: subroutine GET_TAN:'
           write(1,*) 'vertical direction can only be 1/2/3'
           error = 10
           return 
        end if
        do i = 1,3
                do j=1,3
                        pmat(i,j)=nvect(i)*nvect(j)
                        kron_delta(i,j)=0
                end do
        end do
        kron_delta(1,1)=1
        kron_delta(2,2)=1
        kron_delta(3,3)=1

        do i = 1,3
           do j=1,3
              do k=1,3
                 do l=1,3
		    kck(i,j,k,l)=(kron_delta(i,k)*kron_delta(j,l)+
     .                   kron_delta(i,l)*
     .                   kron_delta(j,k)+kron_delta(j,l)*
     .                   kron_delta(i,k)+
     .                   kron_delta(j,k)*kron_delta(i,l))/2
		    kdk(i,j,k,l)=kron_delta(i,j)*kron_delta(k,l)
		    pdk(i,j,k,l)=pmat(i,j)*kron_delta(k,l)
		    kdp(i,j,k,l)=kron_delta(i,j)*pmat(k,l)
		    pck(i,j,k,l)=(pmat(i,k)*kron_delta(j,l)+pmat(i,l)*
     .                   kron_delta(j,k)+pmat(j,l)*kron_delta(i,k)+
     .                   pmat(j,k)*kron_delta(i,l))/2
		    pdp(i,j,k,l)=pmat(i,j)*pmat(k,l)
                 end do
              end do
            end do
        end do
	an1=alphaE*(1-alphanu*nuvh-2*alphaE*nuvh*nuvh)
	an2=alphaE*nuvh*(alphanu+alphaE*nuvh)
	an3=alphaE*nuvh*(1+alphanu*nuvh-alphanu-alphaE*nuvh)
	an4=(1-alphanu*nuvh-2*alphaE*nuvh*nuvh)*(alphaE*(1-alphaG))/
     .    alphaG
	an5=alphaE*(1-alphaE*nuvh*nuvh)+1-
     .    alphanu*alphanu*nuvh*nuvh-2*alphaE*nuvh*(1+alphanu*nuvh)-
     .    2*alphaE*(1-alphanu*nuvh-2*alphaE*nuvh*nuvh)/alphaG
        do i = 1,3
           do j=1,3
              do k=1,3
                 do l=1,3
                    LLfour(i,j,k,l)=an1*kck(i,j,k,l)/2+an2*
     .		      kdk(i,j,k,l)+an3*(pdk(i,j,k,l)+
     .		      kdp(i,j,k,l))+an4*pck(i,j,k,l)+an5*pdp(i,j,k,l)
                 end do
              end do
            end do
        end do
        do i = 1,3
                do j=1,3
                        LL(i,j)=LLfour(i,i,j,j)
                end do
        end do
	LL(4,4)=LLfour(1,2,1,2)
	LL(5,5)=LLfour(1,3,1,3)
	LL(6,6)=LLfour(2,3,2,3)

        do i = 1,6
             hypo_Dsom(i)=0
        end do

        kpow=1.70d0+3.90d0*sin(phi)*sin(phi)
	sinphickpow=(sin(phi))**kpow
 	sinphimkpow=(sqrt(sin2phim))**kpow
	
	Amult=2.0d0/3.0d0-sqrt(sqrt(sin2phim))*(cos3t+1.0d0)/4.0d0
	
        do i=1,6
            hypo_Dsom(i)=-eta_dev(i)+krondelta(i)*
     &		(sinphimkpow-sinphickpow)/(1-sinphickpow)*
     &		Amult
        end do
        do i=4,6
            hypo_Dsom(i)=2.0d0*hypo_Dsom(i)
        end do

        norm_m2=dot_vect_hcea(2,hypo_Dsom,hypo_Dsom,6)
        norm_m=sqrt(norm_m2)
c
        hypo_Dsom(1)=hypo_Dsom(1)/norm_m
        hypo_Dsom(2)=hypo_Dsom(2)/norm_m
        hypo_Dsom(3)=hypo_Dsom(3)/norm_m
        hypo_Dsom(4)=hypo_Dsom(4)/norm_m
        hypo_Dsom(5)=hypo_Dsom(5)/norm_m
        hypo_Dsom(6)=hypo_Dsom(6)/norm_m

        do i = 1,6
                do j=1,6
                        AAhce(i,j)=fs*LL(i,j)+
     &                  sig_star(i)*krondelta(j)/lambda_struct
                end do
        end do

        call matmul_hcea(AAhce,hypo_Dsom,NN,6,6,1)
        do i=1,6
                NN(i)=-NN(i)*fddivfdA/(fd*fs)
        end do
c
c ... end basic model
c
        if(istrain .eq. 1) then
c
c ... loading function
c
        load=dot_vect_hcea(2,eta_del,eta_eps,6)
c
c ... intergranular strain--related tensors
c
        rho=norm_del/r_uc
c
        if (rho.gt.one) then
                rho=one
        end if
c
        call matmul_hcea(LL,eta_del,Leta,6,6,1)

c
c ... tangent stiffness M(sig,q,eta_eps)
c
        pmeangt1=p_t/4.0d0
        if(pmean.gt.pmeangt1) then
          pmeangt1=pmean
        end if

        Gvh=G0*pmeangt1**nparam
        m_R=Gvh*4*Am*alphaG/(9*pmeangt1*alphaE)*lambda_struct*kap_star/
     .		(lambda_struct+
     .		kap_star)/(1-alphanu*nuvh-2*alphaE*nuvh*nuvh)
        if(m_R.gt.40) m_R=40
	m_T=m_R*m_Trat
        temp1=((rho**chi)*m_T+(one-rho**chi)*m_R)*fs
c
        if (load.gt.zero) then
c    
                temp2=(rho**chi)*(one-m_T)*fs
                temp3=(rho**gamma)*fs*fd
c
                do i=1,6
                  do j=1,6
                    AA(i,j)=temp2*Leta(i)*eta_delta(j)
     &                      +temp3*NN(i)*eta_delta(j)
                    MM(i,j)=temp1*LL(i,j)+AA(i,j)
                  end do
                end do
c
        else
c
                temp4=(rho**chi)*(m_R-m_T)*fs
c
                do i=1,6
                  do j=1,6
                        AA(i,j)=temp4*Leta(i)*eta_delta(j)
                        MM(i,j)=temp1*LL(i,j)+AA(i,j)
                  end do
                end do
c
        end if
c
c ... intergranular strain evolution function
c     NOTE: H_del transforms a strain-like vector into a strain-like vector
c           eta_del(i) instead of eta_delta(i)
c           I = 6x6 unit matrix
c
        if (load.gt.zero) then
c
                do i=1,6
                  do j=1,6
                H_del(i,j)=IU(i,j)-(rho**beta_r)*eta_del(i)*eta_delta(j)
                  end do
                end do
c
        else
c
                do i=1,6
              H_del(i,i)=one
                end do
c
        end if
c
c ... void ratio evolution function (tension positive)
c
        do i=1,6 
                if (i.le.3) then
                  H_e(i)=one+void
                else
              H_e(i)=zero
                end if
        end do
c
c ... sensitivity evolution function (tension positive)
c
        do i=1,6 
		H_s(i)=zero
		if(softmodel.eq.1) then
		    if (i.le.3) then
		      H_s(i)=-kparam*(sensit-sfparam)/lam_star
		    else
		    H_s(i)=zero
		    end if
		end if
        end do
c
c ... assemble hardening matrix
c
        do i=1,nasv
                if (i.le.6) then
                        do j=1,6
                                HH(i,j)=H_del(i,j)
                        end do
                else if (i.eq.7) then
                        do j=1,6
                                HH(i,j)=H_e(j)
                        end do
                else if (i.eq.8) then
                        do j=1,6
                                HH(i,j)=H_s(j)
                        end do
                end if
        end do
c       
c ... end istrain ... --------------------------------------------------------------------------------
c
        else if (istrain .eq. 0) then
c
c ... void ratio evolution function (tension positive)
c        
        do i=1,6 
                if (i.le.3) then
                  H_e(i)=one+void
                else
              H_e(i)=zero
                end if
        end do        
c
c ... sensitivity evolution function (tension positive)
c
        do i=1,6 
		H_s(i)=zero
		if(softmodel.eq.1) then
		    if (i.le.3) then
		      H_s(i)=-kparam*(sensit-sfparam)/lam_star
		    else
		    H_s(i)=zero
		    end if
		end if
        end do
                
        do i=1,nasv
                if (i.le.6) then
                        do j=1,6
                                HH(i,j)=0
                        end do
                else if (i.eq.7) then
                        do j=1,6
                                HH(i,j)=H_e(j)
                        end do
                else if (i.eq.8) then
                        do j=1,6
                                HH(i,j)=H_s(j)
                        end do
                end if
        end do        
c ... end istrain/noistrain switch        
        end if

        do i=1,6
           do j=1,6
                LL(i,j)=LL(i,j)*fs
           end do
           NN(i)=NN(i)*fs*fd
        end do        

        return
        end
c-----------------------------------------------------------------------------
      subroutine iniy_hcea(y,nydim,nasv,ntens,sig,qq)
c-----------------------------------------------------------------------------
c initializes the vector of state variables
c-----------------------------------------------------------------------------
      implicit none
c
      integer i,nydim,nasv,ntens
c
      double precision y(nydim),qq(nasv),sig(ntens)
c
      do i=1,nydim
        y(i) = 0
      enddo
c
      do i=1,ntens
        y(i) = sig(i)
      enddo
c
c additional state variables
c
      do i=1,nasv
        y(6+i) = qq(i)
      enddo
c
      return
      end
c------------------------------------------------------------------------------
      subroutine inv_eps_hcea(eps,eps_v,eps_s,sin3t)
c------------------------------------------------------------------------------
c calculate invariants of strain tensor
c------------------------------------------------------------------------------
c
      implicit none
c
      integer i
c
      double precision eps(6),edev(6),edev2(6),ev3
        double precision tredev3,eps_v,eps_s,sin3t
        double precision norm2,numer,denom
c
      double precision zero,one,two,three,six
      double precision onethird,twothirds,sqrt6
c
      data zero,one,two,three,six/0.0d0,1.0d0,2.0d0,3.0d0,6.0d0/
c
c ... some constants
c
        onethird=one/three
        twothirds=two/three
        sqrt6=dsqrt(six)
c
c ... volumetric strain
c
      eps_v=eps(1)+eps(2)+eps(3)
c
      ev3=onethird*eps_v
c
c ... deviator strain
c
        edev(1)=eps(1)-ev3
        edev(2)=eps(2)-ev3
        edev(3)=eps(3)-ev3
        edev(4)=eps(4)/two
        edev(5)=eps(5)/two
        edev(6)=eps(6)/two
c
c ... second invariant
c
        norm2=edev(1)*edev(1)+edev(2)*edev(2)+edev(3)*edev(3)+
     &      two*(edev(4)*edev(4)+edev(5)*edev(5)+edev(6)*edev(6))
c
        eps_s=dsqrt(twothirds*norm2)
c
c ... components of (edev_ij)(edev_jk)
c
        edev2(1)=edev(1)*edev(1)+edev(4)*edev(4)+edev(5)*edev(5)
        edev2(2)=edev(4)*edev(4)+edev(2)*edev(2)+edev(6)*edev(6)
        edev2(3)=edev(6)*edev(6)+edev(5)*edev(5)+edev(3)*edev(3)
        edev2(4)=two*(edev(1)*edev(4)+edev(4)*edev(2)+edev(6)*edev(5))
        edev2(5)=two*(edev(5)*edev(1)+edev(6)*edev(4)+edev(3)*edev(5))
        edev2(6)=two*(edev(4)*edev(5)+edev(2)*edev(6)+edev(6)*edev(3))
c            
c ... Lode angle
c
        if(eps_s.eq.zero) then 
c
                sin3t=-one
c               
        else
c
                tredev3=zero
                do i=1,6
                        tredev3=tredev3+edev(i)*edev2(i)
                end do
c
                numer=sqrt6*tredev3
                denom=(dsqrt(norm2))**3
                sin3t=numer/denom
                if(dabs(sin3t).gt.one) then
                        sin3t=sin3t/dabs(sin3t)
                end if
c
        end if 
c
      return
      end
c------------------------------------------------------------------------------
      subroutine inv_sig_hcea(sig,pp,qq,cos3t,I1,I2,I3)
c------------------------------------------------------------------------------
c calculate invariants of stress tensor
c
c NOTE: Voigt notation is used with the following index conversion
c
c       11 -> 1
c       22 -> 2
c    33 -> 3
c       12 -> 4
c       13 -> 5
c       23 -> 6
c
c------------------------------------------------------------------------------
c
      implicit none
c
      double precision sig(6),sdev(6)
      double precision eta(6),eta_d(6),eta_d2(6)
      double precision xmin1,xmin2,xmin3
      double precision tretadev3,pp,qq,cos3t,I1,I2,I3
      double precision norm2,norm2sig,norm2eta,numer,denom
c
      double precision half,one,two,three,six
      double precision onethird,threehalves,sqrt6,tiny
c
      double precision dot_vect_hcea
c
      data half,one/0.5d0,1.0d0/
      data two,three,six/2.0d0,3.0d0,6.0d0/
      data tiny/1.0d-18/
c
c ... some constants
c
      onethird=one/three
      threehalves=three/two
      sqrt6=dsqrt(six)
c
c ... trace and mean stress
c
      I1=sig(1)+sig(2)+sig(3)
      pp=onethird*I1
c
c ... deviator stress
c
      sdev(1)=sig(1)-pp
      sdev(2)=sig(2)-pp
      sdev(3)=sig(3)-pp
      sdev(4)=sig(4)
      sdev(5)=sig(5)
      sdev(6)=sig(6)
c
c ... normalized stress and dev. normalized stress
c

      if(I1.ne.0) then
         eta(1)=sig(1)/I1
         eta(2)=sig(2)/I1
         eta(3)=sig(3)/I1
         eta(4)=sig(4)/I1
         eta(5)=sig(5)/I1
        eta(6)=sig(6)/I1
      else
        eta(1)=sig(1)/tiny
        eta(2)=sig(2)/tiny
        eta(3)=sig(3)/tiny
        eta(4)=sig(4)/tiny
        eta(5)=sig(5)/tiny
        eta(6)=sig(6)/tiny        
      end if
c
      eta_d(1)=eta(1)-onethird
      eta_d(2)=eta(2)-onethird
      eta_d(3)=eta(3)-onethird
      eta_d(4)=eta(4)
      eta_d(5)=eta(5)
      eta_d(6)=eta(6)
c
c ... second invariants
c
      norm2=dot_vect_hcea(1,sdev,sdev,6)
      norm2sig=dot_vect_hcea(1,sig,sig,6)
      norm2eta=dot_vect_hcea(1,eta_d,eta_d,6)
c
      qq=dsqrt(threehalves*norm2)
      I2=half*(norm2sig-I1*I1)
c
c ... components of (eta_d_ij)(eta_d_jk)
c
      eta_d2(1)=eta_d(1)*eta_d(1)+eta_d(4)*eta_d(4)+eta_d(5)*eta_d(5)
      eta_d2(2)=eta_d(4)*eta_d(4)+eta_d(2)*eta_d(2)+eta_d(6)*eta_d(6)
      eta_d2(3)=eta_d(6)*eta_d(6)+eta_d(5)*eta_d(5)+eta_d(3)*eta_d(3)
      eta_d2(4)=eta_d(1)*eta_d(4)+eta_d(4)*eta_d(2)+eta_d(6)*eta_d(5)
      eta_d2(5)=eta_d(5)*eta_d(1)+eta_d(6)*eta_d(4)+eta_d(3)*eta_d(5)
      eta_d2(6)=eta_d(4)*eta_d(5)+eta_d(2)*eta_d(6)+eta_d(6)*eta_d(3)
c           
c ... Lode angle
c
      if(norm2eta.lt.tiny) then 
c
        cos3t=-one
c               
      else
c
        tretadev3=dot_vect_hcea(1,eta_d,eta_d2,6)
c
        numer=-sqrt6*tretadev3
        denom=(dsqrt(norm2eta))**3
        cos3t=numer/denom
        if(dabs(cos3t).gt.one) then
             cos3t=cos3t/dabs(cos3t)
        end if
c
      end if 
c
c ... determinant
c
      xmin1=sig(2)*sig(3)-sig(6)*sig(6)
      xmin2=sig(4)*sig(3)-sig(6)*sig(5)
      xmin3=sig(4)*sig(6)-sig(5)*sig(2)
c
      I3=sig(1)*xmin1-sig(4)*xmin2+sig(5)*xmin3

c
      return
      end
c------------------------------------------------------------------------------
      subroutine matmul_hcea(a,b,c,l,m,n)
c------------------------------------------------------------------------------
c matrix multiplication
c------------------------------------------------------------------------------
      implicit none
c
      integer i,j,k,l,m,n
c
      double precision a(l,m),b(m,n),c(l,n)
c
      do i=1,l
        do j=1,n
          c(i,j) = 0.0d0
          do k=1,m
            c(i,j) = c(i,j) + a(i,k)*b(k,j)
          enddo
        enddo
      enddo
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine move_asv_hcea(asv,nasv,qq_n)
c-----------------------------------------------------------------------------
c move internal variables in vector qq_n and changes intergranular strain 
c from continuum to soil mechanics convention
c
c NOTE: del has always 6 components
c
c written 6/2005 (Tamagnini, Sellari & Miriano)
c-----------------------------------------------------------------------------
      implicit none
      integer nasv,i
      double precision asv(nasv),qq_n(nasv),zero 
c
        parameter(zero=0.0d0)
c
      do i=1,nasv
                qq_n(i)=zero
      enddo
c
c ... intergranular strain tensor stored in qq_n(1:6)
c
      do i=1,6
                qq_n(i) = -asv(i)
      enddo
c
c ... void ratio stored in qq_n(7)
c
        qq_n(7) = asv(7) 
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine move_eps_hcea(dstran,ntens,deps,depsv)
c-----------------------------------------------------------------------------
c Move strain increment dstran into deps and computes 
c volumetric strain increment
c
c NOTE: all strains negative in compression; deps has always 6 components
c
c written 7/2005 (Tamagnini, Sellari & Miriano)
c-----------------------------------------------------------------------------
      implicit none
      integer ntens,i
      double precision deps(6),dstran(ntens),depsv
c
      do i=1,ntens
                deps(i) = dstran(i)
      enddo
c
        depsv=deps(1)+deps(2)+deps(3)
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine move_sig_hcea(stress,ntens,pore,sig)
c-----------------------------------------------------------------------------
c computes effective stress from total stress (stress) and pore pressure (pore)
c
c NOTE: stress = total stress tensor (tension positive)
c         pore   = exc. pore pressure (undrained conds., compression positive)
c         sig    = effective stress (tension positive)
c
c       sig has always 6 components
c
c written 7/2005 (Tamagnini, Sellari & Miriano)
c-----------------------------------------------------------------------------
      implicit none
      integer ntens,i
      double precision sig(6),stress(ntens),pore,zero 
c
        parameter(zero=0.0d0)
c
      do i=1,6
                sig(i)=zero
      enddo
c
      do i=1,ntens
                if(i.le.3) then
                        sig(i) = stress(i)+pore
                else
                        sig(i) = stress(i)
                end if
      enddo
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine norm_res_hcea(y_til,y_hat,ny,nasv,norm_R)
c-----------------------------------------------------------------------------
c  evaluate norm of residual vector Res=||y_hat-y_til||
c
c  written 6/2005 (Tamagnini, Sellari & Miriano)
c-----------------------------------------------------------------------------
        implicit none
c 
      integer ny,nasv,ng,k,i,testnan
c
        double precision y_til(ny),y_hat(ny),void_til,void_hat,del_void
        double precision sensit_til,sensit_hat,del_sensit
        double precision err(ny),norm_R2,norm_R
        double precision norm_sig2,norm_q2,norm_sig,norm_q
        double precision sig_hat(6),sig_til(6),del_sig(6)
        double precision q_hat(nasv),q_til(nasv),del_q(nasv)
        double precision dot_vect_hcea,zero
c
        parameter(zero=0.0d0)
c
        ng=6*nasv
        k=42+nasv
c
        do i=1,ny
                err(i)=zero
        end do
c
c ... recover stress tensor and internal variables
c
        do i=1,6
                sig_hat(i)=y_hat(i)
                sig_til(i)=y_til(i)
                del_sig(i)=dabs(sig_hat(i)-sig_til(i))
        end do
c
        do i=1,6
                q_hat(i)=y_hat(6+i)
                q_til(i)=y_til(6+i)
                del_q(i)=dabs(q_hat(i)-q_til(i))
        end do
c
        void_hat=y_hat(6+7)
        void_til=y_til(6+7)
        del_void=dabs(void_hat-void_til)

        sensit_hat=y_hat(6+8)
        sensit_til=y_til(6+8)
        del_sensit=dabs(sensit_hat-sensit_til)
c
c ... relative error norms
c
        norm_sig2=dot_vect_hcea(1,sig_hat,sig_hat,6)
        norm_q2=dot_vect_hcea(2,q_hat,q_hat,6)
        norm_sig=dsqrt(norm_sig2)
        norm_q=dsqrt(norm_q2)
c
        if(norm_sig.gt.zero) then
                do i=1,6
                        err(i)=del_sig(i)/norm_sig
                end do
        end if
c
        if(norm_q.gt.zero) then
                do i=1,6
                err(6+i)=del_q(i)/norm_q
                end do
        end if
c
        err(6+nasv-1)=del_void/void_hat

	err(6+8)=0
	if(sensit_hat.gt.0) then
	  err(6+8)=del_sensit/sensit_hat
	end if
c
c ... global relative error norm
c
        norm_R2=dot_vect_hcea(3,err,err,ny)
        norm_R=dsqrt(norm_R2)
c
        testnan=0
        call umatisnan_hcea(norm_sig,testnan)
        call umatisnan_hcea(norm_q,testnan)
        call umatisnan_hcea(void_hat,testnan)
        call umatisnan_hcea(sensit_hat,testnan)
        if(testnan.eq.1) then
           norm_R=1.d20
        end if

        return
        end
c-----------------------------------------------------------------------------
      subroutine perturbate_hcea(y_n,y_np1,n,nasv,dtsub,err_tol,maxnint,
     &    DTmin,deps_np1,parms,nparms,nfev,elprsw,theta,ntens,DD, dtime,
     &    error)
c-----------------------------------------------------------------------------
c
c  compute numerically consistent tangent stiffness
c
c  written 12/2005 (Tamagnini)
c-----------------------------------------------------------------------------
      implicit none
c 
      logical elprsw
c
      integer ntens,jj,kk,i
      integer n,nasv,nparms,nfev
      integer maxnint,error
c
      double precision y_n(n),y_np1(n),y_star(n),parms(nparms)
      double precision dtsub,err_tol,DTmin, dtime
      double precision theta,sig(6),q(nasv)
      double precision deps_np1(6),deps_star(6)
      double precision dsig(6),DD(6,6),HHtmp(nasv,6)
      double precision LL(6,6),NN(6),m_R,Gvh,pmean,G0
      double precision alphaG,alphaE,alphanu,nuvh,nuhh
      double precision lambda,kappa,Am,pmeangt1,p_t,limitp
      integer istrain
      double precision zero
c
      parameter(zero=0.0d0)
c
c ... initialize DD and y_star
c 
      G0=parms(14)
      p_t=parms(2)
      do i=1,6
          sig(i)=y_n(i)
      end do
	  
 	  if((-(sig(1)+sig(2)+sig(3))/3)<p_t) then
		sig(1)=-p_t
		sig(2)=-p_t
		sig(3)=-p_t
		sig(4)=0
		sig(5)=0
		sig(6)=0
	  endif
	  
      do i=1,nasv
          q(i)=y_n(6+i)
      end do
      call push_hcea(y_n,y_star,n)
      pmean=-(sig(1)+sig(2)+sig(3))/3
      
      nuhh=parms(6)
      lambda=parms(3)
      kappa=parms(4)
      alphaG=parms(7)
      if(alphaG.lt. 0.01) then
          alphaG=1.0
      end if
      alphaE=parms(19)
      alphanu=parms(20)
      if(alphaE.lt. 0.01) then
          alphaE=alphaG**1.25
      end if
      if(alphanu.lt. 0.01) then
          alphanu=alphaG
      end if
      nuvh=nuhh/alphanu

      Am=nuvh*nuvh*(4*alphaE*alphanu-2*alphaE*
     .       alphaE*alphanu*alphanu+
     .       2*alphaE*alphaE-alphanu*alphanu)+
     .       nuvh*(4*alphaE+2*alphaE*alphanu)+1+2*alphaE
      pmeangt1=p_t/4.d0
      if(pmean.gt.pmeangt1) then
          pmeangt1=pmean
      end if
      Gvh=G0*pmeangt1**parms(15)
      m_R=Gvh*4*Am*alphaG/(9*pmeangt1*alphaE)*lambda*kappa/(lambda+
     .		kappa)/(1-alphanu*nuvh-2*alphaE*nuvh*nuvh)
      if(m_R.gt.40) m_R=40
      
      if(G0 .le. 0.5) then
          istrain=0 
      else 
          istrain=1
      end if

      do kk=1,6
          do jj=1,6
              DD(kk,jj)=zero
          end do
      end do

      if(error.ne.10) then
          call get_tan_hcea(deps_np1,sig,q,nasv,parms,nparms,
     .          	DD,HHtmp,LL,NN,istrain,error)                
        end if
        if(istrain .eq. 0) then
          do kk=1,6
                do jj=1,6
                       DD(kk,jj)=LL(kk,jj)
                end do
          end do
        else
          do kk=1,6
                do jj=1,6
                        DD(kk,jj)=m_R*LL(kk,jj)
                end do
          end do
        end if

        return
        end        
        
c-----------------------------------------------------------------------------
      subroutine push_hcea(a,b,n)
c-----------------------------------------------------------------------------
c push vector a into vector b
c-----------------------------------------------------------------------------
      implicit none
      integer i,n
      double precision a(n),b(n) 
c
      do i=1,n
                b(i)=a(i)
      enddo
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine rhs_hcea(y,ny,nasv,parms,nparms,deps,kRK,nfev,error)
c-----------------------------------------------------------------------------
c calculate coefficient kRK from current state y and strain increment deps
c Masin hypoplastic model for clays with intergranular strains
c
c written 12/2005 (Tamagnini & Sellari)
c-----------------------------------------------------------------------------
      implicit none
c
        integer error,ny,nparms,nasv,i,nfev
c
      double precision zero,one,two,four 
        double precision y(ny),kRK(ny),parms(nparms),deps(6)
        double precision sig(6),q(nasv)
        double precision F_sig(6),F_q(nasv)
c
        parameter(zero=0.0d0,one=1.0d0,two=2.0d0,four=4.0d0)
c
c ... update counter for the number of function f(y) evaluations
c
        nfev=nfev+1
c
c ... initialize kRK
c
        do i=1,ny
                kRK(i)=zero
        end do
c
c ... recover current state variables (sig,q)                   
c
        do i=1,6
                sig(i)=y(i)
        end do
c
      do i=1,nasv
                q(i)=y(6+i)
        end do
c       
c ... build F_sig(6) and F_q(nasv) vectors and move them into kRK
c
        call get_F_sig_q_hcea(sig,q,nasv,parms,nparms,deps,F_sig,F_q,
     &		error)
        if(error.eq.10) return
c
        do i=1,6
c
                kRK(i)=F_sig(i)
c
        end do                   
c       
        do i=1,nasv
c
                kRK(6+i)=F_q(i)
c
        end do                   
c
      return
      end
c-----------------------------------------------------------------------------
      subroutine rkf23_update_hcea(y,n,nasv,dtsub,err_tol,maxnint,DTmin,
     &                        deps_np1,parms,nparms,nfev,elprsw,dtime,
     &                        error)
c-----------------------------------------------------------------------------
c
c  numerical solution of y'=f(y)
c  explicit, adapive RKF23 scheme with local time step extrapolation
c
c  Tamagnini, Sellari & Miriano 6/2005
c
c-----------------------------------------------------------------------------
        implicit none
c
        logical elprsw
c
      integer n,nasv,nparms,i,ksubst,kreject,nfev
        integer maxnint,error,error_RKF
c
      double precision y(n),parms(nparms),dtsub,err_tol,DTmin
        double precision zero,half,one,two,three,four,six
        double precision ptnine,onesixth,onethird,twothirds,temp
c
        double precision deps_np1(6),y_k(n),y_2(n),y_3(n),y_til(n)
        double precision y_hat(n)
        double precision T_k,DT_k,dtime
        double precision kRK_1(n),kRK_2(n),kRK_3(n)
        double precision norm_R,S_hull
c
      parameter(zero=0.0d0,one=1.0d0,two=2.0d0,three=3.0d0)
      parameter(four=4.0d0,six=6.0d0,half=0.5d0,ptnine=0.9d0)
c
c ... initialize y_k vector and other variables
c
        do i=1,n
                y_k(i)=zero
        end do
c
        onesixth=one/six
        onethird=one/three
        twothirds=two/three
c
c ... start of update process
c
                
        error_RKF=0
        T_k=zero      
        DT_k=dtsub/dtime
        ksubst=0
        kreject=0
        nfev=0
c
        do i=1,n
                y_k(i)=y(i)
        end do
c
c ... start substepping 
c
        do while(T_k.lt.one) 
c
                ksubst=ksubst+1
c
c ... write substepping info
c
c               write(*,1234) ksubst,T_k,DT_k
c1234           format('Substep no.',i4,' -- T_k = ',d12.4,' -- DT_k = ',d12.4)
c
c ... check for maximum number of substeps
c
                if(ksubst.gt.maxnint) then
                       	write(1,*) 'number of substeps ',ksubst,
     &                             ' is too big, step rejected'
                        error=3
                        return
                end if          
c
c ... build RK functions
c
                call check_RKF_hcea(error_RKF,y_k,n,nasv,parms,nparms)
                if(error_RKF.eq.1) then 
		  error=3
		  return
		else
                  call rhs_hcea(y_k,n,nasv,parms,nparms,
     .			deps_np1,kRK_1,nfev,error)
		end if
                if(error.eq.10) return
c
c ... find y_2
c
                temp=half*DT_k
c
                do i=1,n
                        y_2(i)=y_k(i)+temp*kRK_1(i)
                end do

c               
                call check_RKF_hcea(error_RKF,y_2,n,nasv,parms,nparms)
                if(error_RKF.eq.1) then 
		  error=3
		  return
		else
		  call rhs_hcea(y_2,n,nasv,parms,nparms,
     .			deps_np1,kRK_2,nfev,error)
		end if
                if(error.eq.10) return
c                                       
c ... find y_3
c

                do i=1,n
                        y_3(i)=y_k(i)-DT_k*kRK_1(i)+two*DT_k*kRK_2(i)
                end do
c

                call check_RKF_hcea(error_RKF,y_3,n,nasv,parms,nparms)
                if(error_RKF.eq.1) then 
		  error=3
		  return
		else
		  call rhs_hcea(y_3,n,nasv,parms,nparms,
     .			deps_np1,kRK_3,nfev,error)
                end if
                if(error.eq.10) return

c                               
c ... approx. solutions of 2nd (y_til) and 3rd (y_hat) order
c
                do i=1,n        
                        y_til(i)=y_k(i)+DT_k*kRK_2(i)
                        y_hat(i)=y_k(i)+DT_k*
     &          (onesixth*kRK_1(i)+twothirds*kRK_2(i)+onesixth*kRK_3(i))
                end do
c
c ... local error estimate
c

                call norm_res_hcea(y_til,y_hat,n,nasv,norm_R)
c				check if output y_hat can be used as an input into the next step
                call check_RKF_hcea(error_RKF,y_hat,n,nasv,parms,nparms)

                if (error_RKF.ne.0) then
c                	error=1.d20
c                	error_RKF=0
			error=3
			return
                end if
c
c ... time step size estimator according to Hull
c       	
		if(norm_R .ne. 0) then
                	S_hull=ptnine*DT_k*(err_tol/norm_R)**onethird
                else
                	S_hull=1
                end if
c

      if (norm_R.lt.err_tol) then                             
c
c ... substep is accepted, update y_k and T_k and estimate new substep size DT_k
c
                 do i=1,n        
                        y_k(i)=y_hat(i)
                 end do
c
                        T_k=T_k+DT_k
                        DT_k=min(four*DT_k,S_hull)
                        dtsub=DT_k*dtime
                        DT_k=min((one-T_k),DT_k)        
c
      else
c
c ... substep is not accepted, recompute with new (smaller) substep size DT
c
                 DT_k=max(DT_k/four,S_hull)
c
c ... check for minimum step size
c
                 if(DT_k.lt.DTmin) then
                              write(1,*) 'substep size ',DT_k,
     &                             ' is too small, step rejected'
                              error=3
                              return
                 end if          
c                                       
      end if                                                  
c
c ... bottom of while loop
c
      end do
        
c
c ... recover final state
c
      do i=1,n
                y(i)=y_k(i)
      end do
c
      return
      end
c

c-----------------------------------------------------------------------------
      subroutine check_RKF_hcea(error_RKF,y,ny,nasv,parms,nparms)
c-----------------------------------------------------------------------------
c Checks is RKF23 solout vector y is OK for hypoplasticity
c-----------------------------------------------------------------------------
      implicit none
c
        integer error_RKF,ny,nasv,i,nparms,testnan,iopt
c
        double precision y(ny),parms(nparms)
        double precision sig(6),pmean,sig_star(6)
        double precision I1,I2,I3,pp,qq,cos3t
        double precision p_t,minstress,sin2phim,tolerance
        double precision OCR,omega,fSBS,sensit,cos2phic
        double precision coparam,sin2phicco,ashape,ocrcs
c
        p_t    =parms(2)
	minstress=p_t/100.d0
        do i=1,6
                sig(i)=y(i)
        end do

        sig_star(1)=sig(1)-p_t
        sig_star(2)=sig(2)-p_t
        sig_star(3)=sig(3)-p_t
        sig_star(4)=sig(4)
        sig_star(5)=sig(5)
        sig_star(6)=sig(6)
                
        call inv_sig_hcea(sig_star,pp,qq,cos3t,I1,I2,I3)
c       check for positive mean stress
        pmean=-I1/3
        if(pmean .lt. minstress) then
        	error_RKF=1
        end if
c
c		calculate MN mobilised friction angle
c
        if((I3+I1*I2).ne.0) then
	      sin2phim=(9*I3+I1*I2)/(I3+I1*I2)
	    else
	      sin2phim=1
	    end if
c
c	calculate SBS
c
       sensit=1
       if(y(8+6) .ge. 1) then 
      	 sensit=y(8+6) 
       end if
       OCR=-sensit*dexp((parms(5)-dlog(1+y(7+6)))/parms(3))/pp
       cos2phic=1-sin(parms(1))*sin(parms(1))

       ashape=0.3
       ocrcs=2.
c npow is omega in the paper	
       omega=-dlog(cos2phic)/dlog(ocrcs)+
     .   ashape*(sin2phim-sin(parms(1))*sin(parms(1)))
       fSBS=sin2phim+(1/OCR)**omega-1

c	check for tension
       if(sin2phim .ge. 1) then
            error_RKF=1
       end if

c	define friction cutoff - not used
c       coparam=1.3
c       sin2phicco=dsin(coparam*parms(1))*dsin(coparam*parms(1))
c       if(sin2phim .ge. sin2phicco) then
c            error_RKF=1
c       end if
      
c	define state outside SBS as inallowed
       tolerance=0.1
       if(parms(14) .ge. 0.5) then !istrain active
        if(OCR.le. ocrcs) then
       	 if(sin2phim.ge.(1-cos2phic+tolerance)) then
       	  error_RKF=1
         end if
        end if
        if(OCR.gt. ocrcs) then
         if(fSBS.ge. tolerance) then
          error_RKF=1
         end if
         if(fSBS.ge. tolerance) then
          error_RKF=1
         end if
        end if
       else !istrain inactive
         if(fSBS.ge. tolerance) then
          error_RKF=1
         end if
       end if
        
c	check for NAN
 	testnan=0
        do i=1,ny
       	  call umatisnan_hcea(y(i),testnan)
        end do
        call umatisnan_hcea(sin2phim,testnan)
        call umatisnan_hcea(OCR,testnan)
        call umatisnan_hcea(fSBS,testnan)
        
        if(testnan.eq.1) error_RKF=1
c
      return
      end
c

c-----------------------------------------------------------------------------
      subroutine solout_hcea(stress,ntens,asv,nasv,ddsdde,y,nydim,
     +                  pore,depsv_np1,parms,nparms,DD)
c-----------------------------------------------------------------------------
c copy the vector of state variables to umat output
c modified 7/2005 (Tamagnini, Sellari)
c
c NOTE: solid mechanics convention for stress and strain components
c       pore is always positive in compression
c-----------------------------------------------------------------------------
      implicit none
c
      integer nydim,nasv,nparms,ntens,i,j
c
      double precision y(nydim),asv(nasv),stress(ntens)
        double precision ddsdde(ntens,ntens),DD(6,6)
        double precision parms(nparms),bulk_w,pore,depsv_np1 
c
        bulk_w=parms(17)
c
c ... update excess pore pressure (if undrained conditions), compression positive
c
        pore=pore-bulk_w*depsv_np1
c
c updated total stresses (effective stresses stored in y(1:6))
c
      do i=1,ntens
                if (i.le.3) then
                        stress(i) = y(i)-pore
                else
                        stress(i) = y(i)
                end if
        enddo
c
c additional state variables (first 6 components are intergranular strains)
c
      do i=1,nasv
                asv(i) = y(6+i)
      enddo
c
c consistent tangent stiffness
c
      do j=1,ntens
        do i=1,ntens
          ddsdde(i,j) = DD(i,j)      
        enddo
      enddo
c
      do j=1,3
        do i=1,3
          ddsdde(i,j) = ddsdde(i,j)+bulk_w        
        enddo
      enddo
      return
      end
c-----------------------------------------------------------------------------
      subroutine wrista_hcea(mode,y,nydim,deps_np1,dtime,coords,statev,
     &           nstatv,parms,nparms,noel,npt,ndi,nshr,kstep,kinc)
c-----------------------------------------------------------------------------
c ... subroutine for managing output messages
c
c     mode
c
c     all = writes:             kstep, kinc, noel, npt
c       2   = writes also:      error message,coords(3),parms(nparms),ndi,nshr,stress(nstress)
c                                               deps(nstress),dtime,statev(nstatv)
c     3   = writes also:        stress(nstress),deps(nstress),dtime,statev(nstatv)
c-----------------------------------------------------------------------------
      implicit none
c
      integer mode,nydim,nstatv,nparms,noel,npt,ndi,nshr,kstep,kinc,i    
c
      double precision y(nydim),statev(nstatv),parms(nparms)
        double precision deps_np1(6),coords(3),dtime
c
c ... writes for mode = 2
c
      if (mode.eq.2) then
        write(1,*) '==================================================='
        write(1,*) 'ERROR: abaqus job failed during call of UMAT'
        write(1,*) '==================================================='
        write(1,*) 'state dump:'
        write(1,*) 
      endif
c
c ... writes for all mode values
c
c      write(1,111) 'Step: ',kstep, 'increment: ',kinc,
c     & 'element: ', noel, 'Integration point: ',npt
c      write(1,*) 
c
c ... writes for mode = 2
c
      if (mode.eq.2) then
        write(1,*) 'Co-ordinates of material point:'
        write(1,104) 'x1 = ',coords(1),' x2 = ',coords(2),' x3 = ',
     &    coords(3)
        write(1,*) 
        write(1,*) 'Material parameters:'
        write(1,*) 
        do i=1,nparms
          write(1,105) 'prop(',i,') = ',parms(i)
        enddo 
        write(1,*)
        write(1,102) 'No. of mean components:  ',ndi
        write(1,102) 'No. of shear components: ',nshr
        write(1,*)
      endif
c
c ... writes for mode = 2 or 3
c
      if ((mode.eq.2).or.(mode.eq.3)) then
        write(1,*) 'Stresses:'
        write(1,*) 
        write(1,101) 'sigma(1) = ',y(1)
        write(1,101) 'sigma(2) = ',y(2)
        write(1,101) 'sigma(3) = ',y(3)
        write(1,101) 'sigma(4) = ',y(4)
        write(1,101) 'sigma(5) = ',y(5)
        write(1,101) 'sigma(6) = ',y(6)
        write(1,*) 
        write(1,*) 'Strain increment:'
        write(1,*) 
        write(1,101) 'deps_np1(1) = ',deps_np1(1)
        write(1,101) 'deps_np1(2) = ',deps_np1(2)
        write(1,101) 'deps_np1(3) = ',deps_np1(3)
        write(1,101) 'deps_np1(4) = ',deps_np1(4)
        write(1,101) 'deps_np1(5) = ',deps_np1(5)
        write(1,101) 'deps_np1(6) = ',deps_np1(6)
        write(1,*) 
        write(1,*) 'Time increment:'
        write(1,*) 
        write(1,108) 'dtime = ',dtime
        write(1,*) 
        write(1,*) 'Internal variables:'
        write(1,*) 
        write(1,109) 'del(1) = ',statev(1)
        write(1,109) 'del(2) = ',statev(2)
        write(1,109) 'del(3) = ',statev(3)
        write(1,109) 'del(4) = ',statev(4)
        write(1,109) 'del(5) = ',statev(5)
        write(1,109) 'del(6) = ',statev(6)
        write(1,109) 'void   = ',statev(7)
        write(1,*) 
        write(1,*) '==================================================='
c
      endif
c
101   format(1X,a15,e11.4)
102   format(1X,a25,i1)
103   format(1X,a7,i5)
104   format(1X,3(a5,f10.4,2X))
105   format(1X,a5,i2,a4,f20.3)
106   format(1X,3(a9,f12.4,2X))
107   format(1X,3(a10,f12.4,2X))
108   format(1X,a8,f12.4)
109   format(1X,a6,f10.4)
110   format(1X,a5,f10.4)
111   format(1X,a6,i4,2X,a11,i4,2X,a9,i10,2X,a19,i4)
c       
      return
      end

      
c-----------------------------------------------------------------------------
      subroutine calc_statev_hcea(stress,statev,parms,nparms,nasv,
     & nstatv,deps)
c-----------------------------------------------------------------------------
c
c  computes additional state variables for postprocessing
c
c-----------------------------------------------------------------------------
        implicit none
c 
        logical elprsw
c
      integer ntens,jj,kk,i
      integer n,nasv,nparms,nfev,nstatv
        integer maxnint,error
c
      double precision parms(nparms),dot_vect_hcea
        double precision stress(6),statev(nstatv)
        double precision deps(6),tmax,tmin
        double precision MM(6,6),HHtmp(nasv,6)
        double precision LL(6,6),NN(6)
        integer istrain
        double precision zero,two,four,iopt,three
        double precision I1,I2,I3,cos3t,pp,qq
        double precision sin2phi,sinphi,sig_star(6),p_t
        double precision norm_del,norm_del2,del(6),sensit
c
      parameter(zero=0.0d0,two=2.0d0,four=4.0d0,three=3.0d0)
c

c ... calc phimob (statev 11) from Matsuoka-Nakai YS

      p_t    =parms(2)
      do i=1,3
              sig_star(i)=stress(i)-p_t
      end do
      do i=4,6
              sig_star(i)=stress(i)
      end do
      call inv_sig_hcea(sig_star,pp,qq,cos3t,I1,I2,I3)
	  if(I3 .ne. 0) then
        sin2phi=(9.d0+I1*I2/I3)/(1.d0+I1*I2/I3)
      else 
      	sin2phi=0
      end if
	  if(sin2phi .lt. 0) then
        sin2phi=0
      end if 
	  if(sin2phi .gt. 1) then
        sin2phi=1
      end if 
      sinphi=sqrt(sin2phi)
      
      statev(11)= asin(sinphi)*
     .   180.0d0/3.141592d0

c ... calc norm. length of intergr. strain rho (statev 12)
      if(parms(14) .le. 0.5) then
          istrain=0 
      else 
          istrain=1
      end if

      if(istrain .eq. 1) then
        
      do i=1,6
          del(i)=statev(i)
      enddo       
        
      norm_del2=dot_vect_hcea(2,del,del,6)
      norm_del=dsqrt(norm_del2)
      statev(12)=norm_del/parms(11)
     
      else
        statev(12)=0
      end if
      
      sensit=1
      if(statev(14) .ge. 1) then 
      	sensit=statev(14) 
      end if

c ... statev(15) is OCR
      statev(15)=-sensit*dexp((parms(5)-dlog(1+statev(7)))/parms(3))/pp

      return
      end        
            
c-----------------------------------------------------------------------------
      subroutine umatisnan_hcea(chcknum,testnan)
c-----------------------------------------------------------------------------
c
c  checks whether number is NaN
c
c-----------------------------------------------------------------------------
        double precision chcknum
        integer testnan

	    if (.not.(chcknum .ge. 0. .OR. chcknum .lt. 0.)) testnan=1        
	    if (chcknum .gt. 1.d30) testnan=1        
	    if (chcknum .lt. -1.d30) testnan=1        
 	    if (chcknum .ne. chcknum) testnan=1        
       
        return
        end         
      
c-----------------------------------------------------------------------------
        subroutine xit_hcea
c-----------------------------------------------------------------------------
        stop
c
        return
        end

C***********************************************************************
      Subroutine PrnSig_hcea(IOpt,S,xN1,xN2,xN3,S1,S2,S3,P,Q)
      Implicit Double Precision (A-H,O-Z)
      Dimension S(*),xN1(*),xN2(*),xN3(*)

      If (iOpt.Eq.1) Then
        Call Eig_3_hcea(0,S,xN1,xN2,xN3,S1,S2,S3,P,Q) ! with Eigenvectors
      Else
        Call Eig_3a_hcea(0,S,S1,S2,S3,P,Q) ! no Eigenvectors
      End If
      Return
      End
C***********************************************************************
      Subroutine Eig_3_hcea(iOpt,St,xN1,xN2,xN3,S1,S2,S3,P,Q)
      Implicit Double Precision (A-H,O-Z)
      Dimension St(6),A(3,3),V(3,3),
     *          xN1(3),xN2(3),xN3(3)
      !
      ! Get Eigenvalues/Eigenvectors for 3*3 matrix
      ! Wim Bomhof 15/11/'01
      ! PGB : adaption to Principal stress calculation
      !
      ! Applied on principal stresses, directions
      ! Stress vector St(): XX, YY, ZZ, XY, YZ, ZX
      !
      A(1,1) = St(1) ! xx
      A(1,2) = St(4) ! xy = yx
      A(1,3) = St(6) ! zx = xz

      A(2,1) = St(4) ! xy = yx
      A(2,2) = St(2) ! yy
      A(2,3) = St(5) ! zy = yz

      A(3,1) = St(6) ! zx = xz
      A(3,2) = St(5) ! zy = yz
      A(3,3) = St(3) ! zz

      ! Set V to unity matrix
      V(1,1) = 1
      V(2,1) = 0
      V(3,1) = 0

      V(1,2) = 0
      V(2,2) = 1
      V(3,2) = 0

      V(1,3) = 0
      V(2,3) = 0
      V(3,3) = 1


      abs_max_s=0.0
      Do i=1,3
        Do j=1,3
          if (abs(a(i,j)) .Gt. abs_max_s) abs_max_s=abs(a(i,j))
        End Do
      End Do
      Tol = 1d-20 * abs_max_s
      it = 0
      itmax = 50
      Do While ( it.Lt.itMax .And.
     *           abs(a(1,2))+abs(a(2,3))+abs(a(1,3)) .Gt. Tol )
        it=it+1
        Do k=1,3
          If (k .Eq. 1) Then
            ip=1
            iq=2
          Else If (k .Eq.2) Then
            ip=2
            iq=3
          Else
            ip=1
            iq=3
          End If
          If (abs(a(ip,iq)) .gt. Tol) Then
            tau=(a(iq,iq)-a(ip,ip))/(2.0*a(ip,iq))
            If (tau .Ge.0.0) Then
              sign_tau=1.0
            Else
              sign_tau=-1.0
            End If
            t=sign_tau/(abs(tau)+sqrt(1.0+tau*tau))
            c=1.0/sqrt(1.0+t*t)
            s=t*c
            a1p=c*a(1,ip)-s*a(1,iq)
            a2p=c*a(2,ip)-s*a(2,iq)
            a3p=c*a(3,ip)-s*a(3,iq)
            a(1,iq)=s*a(1,ip)+c*a(1,iq)
            a(2,iq)=s*a(2,ip)+c*a(2,iq)
            a(3,iq)=s*a(3,ip)+c*a(3,iq)
            a(1,ip)=a1p
            a(2,ip)=a2p
            a(3,ip)=a3p

            v1p=c*v(1,ip)-s*v(1,iq)
            v2p=c*v(2,ip)-s*v(2,iq)
            v3p=c*v(3,ip)-s*v(3,iq)
            v(1,iq)=s*v(1,ip)+c*v(1,iq)
            v(2,iq)=s*v(2,ip)+c*v(2,iq)
            v(3,iq)=s*v(3,ip)+c*v(3,iq)
            v(1,ip)=v1p
            v(2,ip)=v2p
            v(3,ip)=v3p

            ap1=c*a(ip,1)-s*a(iq,1)
            ap2=c*a(ip,2)-s*a(iq,2)
            ap3=c*a(ip,3)-s*a(iq,3)
            a(iq,1)=s*a(ip,1)+c*a(iq,1)
            a(iq,2)=s*a(ip,2)+c*a(iq,2)
            a(iq,3)=s*a(ip,3)+c*a(iq,3)
            a(ip,1)=ap1
            a(ip,2)=ap2
            a(ip,3)=ap3
          End If ! a(ip,iq)<>0
        End Do ! k
      End Do ! While
      ! principal values on diagonal of a
      S1 = a(1,1)
      S2 = a(2,2)
      S3 = a(3,3)
      ! Derived invariants
      P = (S1+S2+S3)/3
      Q = Sqrt( ( (S1-S2)**2 + (S2-S3)**2 + (S3-S1)**2 ) / 2 )

      ! Sort eigenvalues S1 <= S2 <= S3
      is1 = 1
      is2 = 2
      is3 = 3
      if (s1.Gt.s2) Then
        t   = s2
        s2  = s1
        s1  = t
        it  = is2
        is2 = is1
        is1 = it
      End If
      if (s2.Gt.s3) Then
        t   = s3
        s3  = s2
        s2  = t
        it  = is3
        is3 = is2
        is2 = it
      End If
      if (s1.Gt.s2) Then
        t   = s2
        s2  = s1
        s1  = t
        it  = is2
        is2 = is1
        is1 = it
      End If
      Do i=1,3
        xN1(i) = v(i,is1) ! first  column
        xN2(i) = v(i,is2) ! second column
        xN3(i) = v(i,is3) ! third  column
      End Do
      Return
      End ! Eig_3

      Subroutine Eig_3a_hcea(iOpt,St,S1,S2,S3,P,Q) ! xN1,xN2,xN3,
      Implicit Double Precision (A-H,O-Z)
      Dimension St(6),A(3,3)   !  V(3,3),xN1(3),xN2(3),xN3(3)
      !
      ! Get Eigenvalues ( no Eigenvectors) for 3*3 matrix
      ! Wim Bomhof 15/11/'01
      !
      ! Applied on principal stresses, directions
      ! Stress vector XX, YY, ZZ, XY, YZ, ZX
      !
      A(1,1) = St(1) ! xx
      A(1,2) = St(4) ! xy = yx
      A(1,3) = St(6) ! zx = xz

      A(2,1) = St(4) ! xy = yx
      A(2,2) = St(2) ! yy
      A(2,3) = St(5) ! zy = yz

      A(3,1) = St(6) ! zx = xz
      A(3,2) = St(5) ! zy = yz
      A(3,3) = St(3) ! zz

      abs_max_s=0.0
      Do i=1,3
        Do j=1,3
          if (abs(a(i,j)) .Gt. abs_max_s) abs_max_s=abs(a(i,j))
        End Do
      End Do
      Tol = 1d-20 * abs_max_s
      If (iOpt.Eq.1) Tol = 1d-50*abs_max_s
      it=0
      itmax = 50

      Do While ( it.lt.itmax .And.
     *           abs(a(1,2))+abs(a(2,3))+abs(a(1,3)) .Gt. Tol )

        it=it+1
        Do k=1,3
          If (k .Eq. 1) Then
            ip=1
            iq=2
          Else If (k .Eq.2) Then
            ip=2
            iq=3
          Else
            ip=1
            iq=3
          End If

          If (abs(a(ip,iq)) .gt. Tol) Then         ! ongelijk nul ?
            tau=(a(iq,iq)-a(ip,ip))/(2.0*a(ip,iq))
            If (tau .Ge.0.0) Then
              sign_tau=1.0
            Else
              sign_tau=-1.0
            End If
            t=sign_tau/(abs(tau)+sqrt(1.0+tau*tau))
            c=1.0/sqrt(1.0+t*t)
            s=t*c
            a1p=c*a(1,ip)-s*a(1,iq)
            a2p=c*a(2,ip)-s*a(2,iq)
            a3p=c*a(3,ip)-s*a(3,iq)
            a(1,iq)=s*a(1,ip)+c*a(1,iq)
            a(2,iq)=s*a(2,ip)+c*a(2,iq)
            a(3,iq)=s*a(3,ip)+c*a(3,iq)
            a(1,ip)=a1p
            a(2,ip)=a2p
            a(3,ip)=a3p

            ap1=c*a(ip,1)-s*a(iq,1)
            ap2=c*a(ip,2)-s*a(iq,2)
            ap3=c*a(ip,3)-s*a(iq,3)
            a(iq,1)=s*a(ip,1)+c*a(iq,1)
            a(iq,2)=s*a(ip,2)+c*a(iq,2)
            a(iq,3)=s*a(ip,3)+c*a(iq,3)
            a(ip,1)=ap1
            a(ip,2)=ap2
            a(ip,3)=ap3
          End If ! a(ip,iq)<>0
        End Do ! k
      End Do ! While
      ! principal values on diagonal of a
      S1 = a(1,1)
      S2 = a(2,2)
      S3 = a(3,3)
      ! Derived invariants
      P = (S1+S2+S3)/3
      Q = Sqrt( ( (S1-S2)**2 + (S2-S3)**2 + (S3-S1)**2 ) / 2 )

      if (s1.Gt.s2) Then
        t   = s2
        s2  = s1
        s1  = t
      End If
      if (s2.Gt.s3) Then
        t   = s3
        s3  = s2
        s2  = t
      End If
      if (s1.Gt.s2) Then
        t   = s2
        s2  = s1
        s1  = t
      End If
      Return
      End ! Eig_3a
      
c-----------------------------------------------------------------------------
      subroutine calc_elasti_hcea(y,n,nasv,dtsub,err_tol,maxnint,DTmin,
     &                        deps_np1,parms,nparms,nfev,elprsw,
     &				dtime,DDtan,youngel,nuel,error)
c-----------------------------------------------------------------------------
c
c  numerical solution of y'=f(y)
c  explicit, adapive RKF23 scheme with local time step extrapolation
c
c  Tamagnini, Sellari & Miriano 6/2005
c
c-----------------------------------------------------------------------------
        implicit none
c
        logical elprsw
c
      integer n,nasv,nparms,i,ksubst,kreject,nfev
      integer maxnint,error,error_RKF,tension,j
c
      double precision y(n),parms(nparms),dtsub,err_tol,DTmin
        double precision zero,half,one,two,three,four,six
        double precision ptnine,onesixth,onethird,twothirds,temp
c
        double precision deps_np1(6),y_k(n),y_2(n),y_3(n),y_til(n)
        double precision y_hat(n),DDtan(6,6)
        double precision T_k,DT_k,dtime,II(6,6),krondelta(6)
        double precision kRK_1(n),kRK_2(n),kRK_3(n)
        double precision norm_R,S_hull,youngel,nuel,F_sig(6)
c
      parameter(zero=0.0d0,one=1.0d0,two=2.0d0,three=3.0d0)
      parameter(four=4.0d0,six=6.0d0,half=0.5d0,ptnine=0.9d0)
c
c ... initialize y_k vector and other variables
c
        do i=1,n
                y_k(i)=zero
        end do
c
        onesixth=one/six
        onethird=one/three
        twothirds=two/three

c
c ... fourth order identity tensors in Voigt notation
c
        do i = 1,6
          do j=1,6
            II(i,j)=zero
          end do
        end do
        
        II(1,1)=one
        II(2,2)=one
        II(3,3)=one
        II(4,4)=half
        II(5,5)=half
        II(6,6)=half
c
        krondelta(1)=one
        krondelta(2)=one
        krondelta(3)=one
        krondelta(4)=zero
        krondelta(5)=zero
        krondelta(6)=zero
c
c ... Elastic stiffness tensor 
c
	if(youngel.gt.0) then
        do i = 1,6
          do j=1,6
            DDtan(i,j)=(youngel/(1+nuel))*(II(i,j) + 
     &       	nuel/(1-2*nuel)*krondelta(i)*krondelta(j));
          end do
        end do
        end if
        
        call matmul_hcea(DDtan,deps_np1,F_sig,6,6,1)
        do i=1,6
                y(i)=y(i)+F_sig(i)
        end do

        return
        end
c
