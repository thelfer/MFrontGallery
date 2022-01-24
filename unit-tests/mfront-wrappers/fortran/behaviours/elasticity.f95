module ElasticityInterface
  use, intrinsic :: iso_c_binding, only: c_int, c_double
  implicit none
contains
  subroutine computeStiffnessTensor(K)&
    bind(c, name = "ElasticityInterfaceComputeStiffnessTensor")
    real(c_double), intent(out), dimension(6, 6) :: K
    real(c_double) E, nu, lambda, mu
    integer i,j
    E = 150e9
    nu = 0.3
    lambda = nu * E / ((1 + nu) * (1 - 2 * nu))
    mu = E / (2 * (1 + nu))
    ! stiffness matrix
    do i = 1, 6
       do j = 1, 6
          K(i, j) = 0
       end do
    end do
    do i = 1, 3
       do j = 1, 3
          K(i, j) = lambda
       end do
    end do
    do i = 1, 6
       K(i,i) =  K(i,i) + 2 * mu
    end do
  end subroutine computeStiffnessTensor
  subroutine integrate(K,sig, isvs, deto, dt, n)&
       bind(c, name = "ElasticityInterfaceIntegrate")
    implicit none
    real(c_double), intent(out), dimension(6, 6) :: K
    real(c_double), intent(out), dimension(6) :: sig
    real(c_double), intent(out), dimension(n) :: isvs
    real(c_double), intent(in), dimension(6) :: deto
    real(c_double), intent(in), value :: dt
    integer(c_int), intent(in), value :: n
    ! example 
    integer i
    real(c_double) tr
    real(c_double) E, nu, lambda, mu
    E = 150e9
    nu = 0.3
    lambda = nu * E / ((1 + nu) * (1 - 2 * nu))
    mu = E / (2 * (1 + nu))
    ! update the elastic strain
    do i = 1, 6
       isvs(i) =  isvs(i) + deto(i)
    end do
    tr = isvs(1) + isvs(2) + isvs(3)
    do i = 1, 3
       sig(i) = lambda * tr + 2 * mu * isvs(i)
    end do
    do i = 4, 6
       sig(i) = 2 * mu * isvs(i)
    end do
    ! stiffness matrix
    call computeStiffnessTensor(K)
  end subroutine integrate
  subroutine computeRate(deel, disvs, eel, isvs, sig, deto, n)&
       bind(c, name = "ElasticityInterfaceComputeRate")
    implicit none
    real(c_double), intent(out), dimension(6) :: deel
    real(c_double), intent(out), dimension(n) :: disvs
    real(c_double), intent(in), dimension(6) :: eel
    real(c_double), intent(in), dimension(n) :: isvs
    real(c_double), intent(in), dimension(6) :: sig
    real(c_double), intent(in), dimension(6) :: deto
    integer(c_int), intent(in), value :: n
    integer i
    ! update the elastic strain
    do i = 1, 6
       deel(i) = deto(i)
    end do
  end subroutine computeRate
end module ElasticityInterface
