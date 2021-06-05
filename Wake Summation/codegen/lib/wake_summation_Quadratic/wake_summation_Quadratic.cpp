//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  wake_summation_Quadratic.cpp
//
//  Code generation for function 'wake_summation_Quadratic'
//


// Include files
#include "wake_summation_Quadratic.h"
#include <cmath>
#include <cstring>

// Function Definitions
double wake_summation_Quadratic(const double Vw[100], double turbine_number,
  double freestream_velocity)
{
  double wake_velocities_pair_data[20];
  double idx_data[10];
  double z1_data[10];
  double y;
  int idx;
  int ii;
  int ii_size_idx_0;
  signed char ii_data[10];
  boolean_T x[10];
  boolean_T exitg1;

  // turbine number is the index of the turbine refernced in the Vw matrix.
  // if for example we want the total influence on turbine 2, we want to
  // evaluate using the values that are present in that column.
  //  need to find the components of the upstream wake that will influence the
  //  current turbine
  for (idx = 0; idx < 10; idx++) {
    x[idx] = (Vw[idx + 10 * (static_cast<int>(turbine_number) - 1)] != 0.0);
  }

  idx = 0;
  ii = 0;
  exitg1 = false;
  while ((!exitg1) && (ii < 10)) {
    if (x[ii]) {
      idx++;
      ii_data[idx - 1] = static_cast<signed char>(ii + 1);
      if (idx >= 10) {
        exitg1 = true;
      } else {
        ii++;
      }
    } else {
      ii++;
    }
  }

  if (1 > idx) {
    ii_size_idx_0 = 0;
  } else {
    ii_size_idx_0 = idx;
  }

  for (idx = 0; idx < ii_size_idx_0; idx++) {
    idx_data[idx] = ii_data[idx];
  }

  idx = ii_size_idx_0 << 1;
  if (0 <= idx - 1) {
    std::memset(&wake_velocities_pair_data[0], 0, idx * sizeof(double));
  }

  // collect relevant data in those column and rows
  for (idx = 0; idx < ii_size_idx_0; idx++) {
    ii = static_cast<int>(idx_data[idx]);
    wake_velocities_pair_data[idx] = Vw[(ii + 10 * (static_cast<int>
      (turbine_number) - 1)) - 1];
    wake_velocities_pair_data[idx + ii_size_idx_0] = Vw[(ii + 10 * (ii - 1)) - 1];
  }

  //  knowing the appropiate wake influence coefficient values.
  for (idx = 0; idx < ii_size_idx_0; idx++) {
    idx_data[idx] = 1.0 - wake_velocities_pair_data[idx] /
      wake_velocities_pair_data[idx + ii_size_idx_0];
  }

  for (idx = 0; idx < ii_size_idx_0; idx++) {
    y = idx_data[idx];
    z1_data[idx] = y * y;
  }

  if (ii_size_idx_0 == 0) {
    y = 0.0;
  } else {
    y = z1_data[0];
    for (idx = 2; idx <= ii_size_idx_0; idx++) {
      y += z1_data[idx - 1];
    }
  }

  return freestream_velocity * (1.0 - std::sqrt(y));
}

// End of code generation (wake_summation_Quadratic.cpp)
