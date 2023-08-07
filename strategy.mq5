//+------------------------------------------------------------------+
//|                                                     strategy.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "strategy.mqh"
#include "configuration.mqh"
#include "trend.mqh"
#include "logger.mqh"
#include "defs.mqh"
#include "trader.mqh"
//+------------------------------------------------------------------+
//| Current trend detected                                           |
//+------------------------------------------------------------------+
TrendDirection current_trend = UNKNOWN;
//+------------------------------------------------------------------+
//| Detect breakout                                                  |
//+------------------------------------------------------------------+
void detect_breakout(ENUM_TIMEFRAMES tf)
  {
  }
//+------------------------------------------------------------------+
//| Entry point of a strategy called on new aggregated bar           |
//+------------------------------------------------------------------+
void detect_trend(ENUM_TIMEFRAMES tf)
  {
//---- Create dependent vector
   static vector v_dependent;
   if(v_dependent.Size() == 0)
     {
      v_dependent.Resize(TREND_DETECTION_BAR_COUNT);
      for(ulong i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
        {
         v_dependent[i] = (double)i;
        }
     }

//---- Get rates
   matrix m_ohlct;
   m_ohlct.CopyRates(_Symbol, tf, COPY_RATES_CLOSE | COPY_RATES_VERTICAL, 1, TREND_DETECTION_BAR_COUNT);

   vector v_close = m_ohlct.Row(0);


//---- Calculate polynomial regression
   vector v_coef = polyfit(v_dependent, v_close, POLYNOMIAL_REGRESSION_DEGREE);
   log_debug("Polynomial regression of degree " + (string)POLYNOMIAL_REGRESSION_DEGREE + " solved");
   for(ulong i = 0; i <= POLYNOMIAL_REGRESSION_DEGREE; i++)
     {
      log_debug("Coefficient a" + (string)i + " = " + (string)v_coef[i]);
     }

//---- Fit into polynomial - y = a0 + a1x + a2x2 ... anxn
   vector v_fit;
   v_fit.Resize(TREND_DETECTION_BAR_COUNT);

   for(ulong i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
     {
      double sum = 0;
      for(ulong j = 0; j <= POLYNOMIAL_REGRESSION_DEGREE; j++)
        {
         sum += v_coef[j] * pow(v_dependent[i], j);
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
      current_trend = RISING;
      return;
     }
   else
     {
      if(was_uptrend)
        {
         log_info("Uptrend ended");
         was_uptrend = false;
        }
      current_trend = UNKNOWN;
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
      current_trend = FALLING;
      return;
     }
   else
     {
      if(was_downtrend)
        {
         log_info("Downtrend ended");
         was_downtrend = false;
        }
      current_trend = UNKNOWN;
     }

//---- Determine side trend
   static bool was_sidetrend = false;
   if(is_consolidating(v_fit, rsq))
     {
      if(!was_sidetrend)
        {
         log_info("Consolidation started");
         was_sidetrend = true;
        }
      current_trend = CONSOLIDATING;
      return;
     }
   else
     {
      if(was_sidetrend)
        {
         log_info("Consolidation ended");
         was_sidetrend = false;
        }
      current_trend = UNKNOWN;
     }
  }
//+------------------------------------------------------------------+
