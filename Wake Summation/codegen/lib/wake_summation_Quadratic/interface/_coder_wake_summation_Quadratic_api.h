/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_wake_summation_Quadratic_api.h
 *
 * Code generation for function 'wake_summation_Quadratic'
 *
 */

#ifndef _CODER_WAKE_SUMMATION_QUADRATIC_API_H
#define _CODER_WAKE_SUMMATION_QUADRATIC_API_H

/* Include files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus

extern "C" {

#endif

  /* Function Declarations */
  real_T wake_summation_Quadratic(real_T Vw[100], real_T turbine_number, real_T
    freestream_velocity);
  void wake_summation_Quadratic_api(const mxArray * const prhs[3], const mxArray
    *plhs[1]);
  void wake_summation_Quadratic_atexit(void);
  void wake_summation_Quadratic_initialize(void);
  void wake_summation_Quadratic_terminate(void);
  void wake_summation_Quadratic_xil_shutdown(void);
  void wake_summation_Quadratic_xil_terminate(void);

#ifdef __cplusplus

}
#endif
#endif

/* End of code generation (_coder_wake_summation_Quadratic_api.h) */
