//+------------------------------------------------------------------+
//|                                                         math.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "math.mqh"
#include <Math\Alglib\alglib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double r_squared(const vector & values, const vector & estimate)
  {
   double val_mean = values.Mean();
   double numerator = 0;
   double denominator = 0;

   for(int i = 0; i < values.Size(); i++)
     {
      numerator += pow(values[i] - estimate[i], 2);
      denominator += pow(values[i] - val_mean, 2);
     }
     
   return 1-(numerator/denominator);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
vector polyfit(const vector & x, const vector & y, const double degree)
  {
   const int m = x.Size();
   const int n = degree + 1;

   matrix Y;
   Y.Resize(n, 1);

   for(int i = 0; i < Y.Rows(); i++)
     {
      for(int j = 0; j < Y.Cols(); j++)
        {
         const vector cum = y * pow(x, i);
         Y[i][j] = cum.Sum();
        }
     }

   matrix X;
   X.Resize(n, n);

   for(int i = 0; i < X.Rows(); i++)
     {
      for(int j = 0; j < X.Cols(); j++)
        {
         if(i == 0 && j == 0)
           {
            X[i][j] = m;
           }
         else
           {
            const vector cum = pow(x, i + j);
            X[i][j] = cum.Sum();
           }
        }
     }

   const matrix X_INVERSE = X.Inv();
   const matrix B = X_INVERSE.MatMul(Y);

   return B.Col(0);
  }
//+------------------------------------------------------------------+
