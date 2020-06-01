/*
    Copyright (C) 2003  David Masin
    email: masin@natur.cuni.cz

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software Foundation
    59 Temple Place, Suite 330, Boston, MA, 02111-1307, USA

    The use of the program is subject to acknowledgement.
*/
#ifndef GENERALMOD_H
#define GENERALMOD_H

#include <iostream>
#include <cmath>
#include <cstdlib>
#include "errno.h"

#ifndef max2
 #define max2(a,b) ((a)>(b)?(a):(b))
#endif

#ifndef min2
 #define min2(a,b) ((a)<(b)?(a):(b))
#endif

using namespace std;

/*****************************General model, main structure***************************************/

struct General_model {

  //Numbers of variables
  int nparms, nstatev, ngstrain, ngstress;
  static const int max_ngstrain = 8;
  static const int max_ngstress = 7;
  static const int max_nstatev  = 20;
  static const int max_nparms   = 40;
  static const int nrkf_parms   = 5;
  static const int nrkf_statev  = 4;
  bool debug;

  General_model(int np, int ns, int ngstra, int ngstre) : nparms(np), nstatev(ns), ngstrain(ngstra), ngstress(ngstre) {};

  //Updated soil_model with Runge-Kutta schemes
  virtual long soil_model(double strain_gen[], double stress_gen[], double qstatev[],
        double dstrain_gen[], double dtime, double *DDtan_gen, double parms[], double rkf_statev[], double rkf_parms[], int flag, int kinc=0) {return(0);};
        
  virtual bool calc_fsigq(double signet[9], double suction, double Temper, double *qstatev,
        double deps[9], double dsuction, double dTemper, double dtime, 
        double dsignet[9], double &Sr_new, double dqstatev[], int kinc) {return(0);};

  //Functions for general stress-full 9x9 convention conversion
  void convert_from_general(double general[], double stressstrain[], double othervar[], int nothv, int flag);
  void convert_to_general(double general[], double stressstrain[], double othervar[], int nothv, int flag);
  void convert4th_to_abaqus(double DDfull[3][3][3][3], double DDabq[6][6]);
  void map_indices_fulltoabq(int fulli, int fullj, int &abq);
  void map_indices_abqtofull(int &fulli, int &fullj, int abq);

  //Functions for mathematical operations
  double gscalar_power(double a, double b);
  double gscalar_dabs(double k);
  void garray_set(double *ptr, double value, long int n);
  double garray_size(double a[], long int n);
  void garray_move(double from[], double to[], long int n);
  int garray_copy (double source[], double destination[], int length);
  int garray_rcopy (double source[], int source_index, double destination[], int destination_index, int number_of_elements);
  void garray_add(double a[], double b[], double c[], long int n);
  void garray_subtract (double a[], double b[], double c[], long int n);
  void garray_multiply(double a[], double b[], double c, long int n);
  int garray_addmult (double source1[], double source2[], double multiplier, double destination[], int length);
  int garray_swap (double a[], double b[], int length);
  double garray_snorm(double a[], long fi, long nc);
  double garray_inproduct(double a[], double b[], long int n);
  double gtrace(double a[3][3]);
  double gmatrix_determinant(double a[], long int n);
  void gmatrix_ab(double *a, double *b, double *c, long int n, long int m, long int k);
  void gmatrix_a4b(double a[3][3][3][3],  double b[], double c[]);
  double tensor_dbldot_prod (double a[], double b[], double k);
  double round_to_digits(double value, int digits);
  long test_math_err();

  //Runge-Kutta schemes (functions adapted from SIFEL)
  long calc_rkf(double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);
  long adfwdeuler (double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);
  long rkf23 (double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);
  long rkf23bs (double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);
  long rkf34 (double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);
  long rkf45 (double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], double rkf_statev[], double rkf_parms[], int kinc);

  //Additional routines
  long rkf_redstep (double rc, double &h, double hmin);
  bool check_math_error();
  virtual long correct_statev_values(double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], int call) {return(0);};
  virtual long correct_DDtan_gen(double strain_gen[], double stress_gen[], double *DDtan_gen) {return(0);};
};

/****************** Hypoplasticity for unsaturated soils, expansive soils with *******************/
/****************** double-porosity structure, thermal effects. Updated version ***********************************/

struct Hypoplasti_unsat_expansive_thermal : General_model {
  Hypoplasti_unsat_expansive_thermal() : General_model(c_nparms, c_nstatev, c_ngstrain, c_ngstress){};

  static const int c_ngstrain = 8;
  static const int c_ngstress = 7;
  static const int c_nstatev  = 10;
  static const int c_nparms   = 23;
  static const bool debug     = true;

  //Model parameters and other constants
  double phic, lambda, kappa, N, nuparam, Ocparam;
  double nparam, lparam, nTparam, lTparam, mparam;
  double alpha_s, kappam, smstar, emstar, mmparam, csh;
  double sairentry0, eM0, Trparam, aTparam, bTparam;
  double lambdap0, aer, pt, alphaG, alphanu, alphaE;
  double rlambdascan;

  //Updated soil_model with Runge-Kutta schemes
  long soil_model(double strain_gen[], double stress_gen[], double qstatev[],
        double dstrain_gen[], double dtime, double *DDtan_gen, double parms[], double rkf_statev[], double rkf_parms[], int flag, int kinc=0);

  /* functions which distinguish original and updated versions */
  virtual double give_rlambda(double suction, double a_scan, double dsuction, double sewM, double SrM, double& rlambda_for_ascan);

  //Model-specific routines
  void initialise_variables(double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], double dtime,
          double parms[], int kinc);
  void initialise_parameters(double parms[]);
  bool calc_fsigq(double signet[9], double suction, double Temper, double *qstatev,
        double deps[9], double dsuction, double dTemper, double dtime, 
        double dsignet[9], double &Sr_new, double dqstatev[], int kinc);
  void update_hisv(double signet[9], double suction, double Temper, double *qstatev,
        double deps[9], double dsuction, double dTemper,
        double dsignet[9], double &Sr, double *dqstatev, int flag, double fu, int kinc);
  void make_sig_unsat(double sig[3*3], double suction, double SrM,
        double tensor_unsat[3*3], double &scalar_unsat);
  void calc_depm(double signet[9], double suction, double Temper, double dsuction,
        double dTemper, double dsignet[9], double depm[9], double fu);
  void calc_N_lambda_dpeds(double &Nuse, double &lambda_use, double &dpeds_divpe, double &dpedT_divpe,
        double signet[9], double suction, double Temper, double *qstatev);
  void give_LNH(double signet[9], double dsuction, double Temper, double qstatev[],
        double hypo_L[3][3][3][3], double hypo_N[3][3], double H_unsat[3][3], double HT_unsat[3][3], double fm, 
        double &fu);
  void direct_stiffness_matrix(double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], 
        double dtime, double *DDtan_gen, double parms[], int kinc);
  double give_SrM_new(double suction, double SrM, double eM, double Temper, double sewM, double se, double dsuction, double deM, double dTemper, double a_scan, int flag);

  //Additional routines
  long correct_statev_values(double strain_gen[], double stress_gen[], double qstatev[], double dstrain_gen[], int call);
  long correct_DDtan_gen(double strain_gen[], double stress_gen[], double *DDtan_gen);
};

/****************** Hypoplasticity for unsaturated soils, expansive soils with *******************/
/****************** double-porosity structure, thermal effects. ***********************************/
/* Version "Mašín, D. (2017). Coupled thermohydromechanical double structure model for expansive soils. ASCE Journal of Engineering Mechanics 143, No. 9."
*/

struct Hypoplasti_unsat_expansive_thermal_original : Hypoplasti_unsat_expansive_thermal {
  Hypoplasti_unsat_expansive_thermal_original() : Hypoplasti_unsat_expansive_thermal(){};

  /* functions which distinguish original and updated versions */
  virtual double give_rlambda(double suction, double a_scan, double dsuction, double sewM, double SrM, double& rlambda_for_ascan);

};

#endif
