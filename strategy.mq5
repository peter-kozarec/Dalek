//+------------------------------------------------------------------+
//|                                                     strategy.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "strategy.mqh"
#include "configuration.mqh"
#include "trend.mqh"
#include "logger.mqh"
//+------------------------------------------------------------------+
//| Entry point of a strategy called on new aggregated bar           |
//+------------------------------------------------------------------+
void on_bar_aggregated()
  {
//---- Create dependent vector
   static vector v_dependent;
   if(v_dependent.Size() == 0)
     {
      v_dependent.Resize(TREND_DETECTION_BAR_COUNT);
      for(int i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
        {
         v_dependent[i] = i;
        }
     }

//---- Define polynomial degree to detect trend
   static int degree = 1;

//---- Get rates
   matrix m_ohlct;
   m_ohlct.CopyRates(_Symbol, _Period, COPY_RATES_CLOSE | COPY_RATES_VERTICAL, 1, TREND_DETECTION_BAR_COUNT);

   vector v_close = m_ohlct.Row(0);


//---- Calculate polynomial regression
   const vector v_coef = polyfit(v_dependent, v_close, degree);
   log_debug("Polynomial regression of degree " + (string)degree + " solved");
   for(int i = 0; i <= degree; i++)
     {
      log_debug("Coefficient a" + (string)i + " = " + (string)v_coef[i]);
     }

//---- Fit into y = a0 + a1x + a2x2 ... anxn
   vector v_fit;
   v_fit.Resize(TREND_DETECTION_BAR_COUNT);

   for(int i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
     {
      double sum = 0;
      for(int j = 0; j <= degree; j++)
        {
         sum += v_coef[j] * pow(v_close[i], j);
        }
      v_fit[i] = sum;
     }

//---- Calculate r squared
   const double rsq = r_squared(v_close, v_fit);
   log_debug("R-Squared calculated = " + (string)rsq);

//---- Determine uptrend
   static bool was_uptrend = false;
   if(is_uptrend(v_fit, rsq))
     {
      if(!was_uptrend)
        {
         log_info("Uptrend started");
         was_uptrend = true;
        }
      return;
     }
   else
     {
      if(was_uptrend)
        {
         log_info("Uptrend ended");
         was_uptrend = false;
        }
     }

//---- Determine downtrend
   static bool was_downtrend = false;
   if(is_downtrend(v_fit, rsq))
     {
      if(!was_downtrend)
        {
         log_info("Downtrend started");
         was_downtrend = true;
        }
      return;
     }
   else
     {
      if(was_downtrend)
        {
         log_info("Downtrend ended");
         was_downtrend = false;
        }
     }
  }
//+------------------------------------------------------------------+
