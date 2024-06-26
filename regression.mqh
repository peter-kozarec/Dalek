//+------------------------------------------------------------------+
//|                                                         math.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_REGRESSION_MQH
#define DALEK_REGRESSION_MQH
//+------------------------------------------------------------------+
namespace regression
{
//+------------------------------------------------------------------+
//| Calculate polynomial regresion r-squared                         |
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
     } // for(ulong i = 0; i < values.Size(); i++)

   return 1-(numerator/denominator);
  } // regression::r_squared
//+------------------------------------------------------------------+
//| Calculate polynomial regression coeficients                      |
//+------------------------------------------------------------------+
vector polyfit(const vector & x, const vector & y, const ulong degree)
  {
   const ulong m = x.Size();
   const ulong n = degree + 1;

   matrix Y;
   Y.Resize(m, 1);
   Y.Col(y, 0);

   matrix X;
   X.Resize(m, n);

   for(ulong i = 0; i < X.Rows(); i++)
     {
      for(ulong j = 0; j < X.Cols(); j++)
        {
         X[i][j] = pow(x[i], j);
        } // for(ulong j = 0; j < X.Cols(); j++)
     } // for(ulong i = 0; i < X.Rows(); i++)
     
   matrix XT = X.Transpose();
   matrix XTX = XT.MatMul(X);
   matrix IXTX = XTX.Inv();
   matrix XTY = XT.MatMul(Y);
   return IXTX.MatMul(XTY).Col(0);
  } // regression::polyfit
//+------------------------------------------------------------------+
}; // namespace regression
//+------------------------------------------------------------------+
#endif // DALEK_REGRESSION_MQH