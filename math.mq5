//+------------------------------------------------------------------+
//|                                                         math.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "math.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double r_squared(const vector & values, const vector & estimate)
  {
   double val_mean = values.Mean();
   double numerator = 0;
   double denominator = 0;

   for(ulong i = 0; i < values.Size(); i++)
     {
      numerator += pow(values[i] - estimate[i], 2);
      denominator += pow(values[i] - val_mean, 2);
     }
     
   return 1-(numerator/denominator);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
vector polyfit(const vector & x, const vector & y, const ulong degree)
  {
   const ulong m = x.Size();
   const ulong n = degree + 1;

   matrix Y;
   Y.Resize(n, 1);

   for(ulong i = 0; i < Y.Rows(); i++)
     {
      for(ulong j = 0; j < Y.Cols(); j++)
        {
         Y[i][j] = (y * pow(x, i)).Sum();
        }
     }

   matrix X;
   X.Resize(n, n);

   for(ulong i = 0; i < X.Rows(); i++)
     {
      for(ulong j = 0; j < X.Cols(); j++)
        {
         X[i][j] = pow(x, i + j).Sum();
        }
     }

   return X.Inv().MatMul(Y).Col(0);
  }
//+------------------------------------------------------------------+
