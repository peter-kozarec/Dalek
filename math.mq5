//+------------------------------------------------------------------+
//|                                                         math.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "math.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double r_squared_calculate(const vector & y, const vector & y_pred)
  {
//---- Calculate mean
   const double mean = y.Mean();

//---- Calculate sum of squared residuals
   double SSR = 0.0;
   for(int i = 0; i < y.Size(); i++)
     {
      SSR += pow((y_pred[i] - y[i]), 2);
     }

//---- Calculate total sum of squares
   double SST = 0.0;
   for(int i = 0; i < y.Size(); i++)
     {
      SST += pow((y[i] - mean), 2);
     }

//---- Return R-squared
   return 1.0 - (SSR / SST);
  }
//+------------------------------------------------------------------+
