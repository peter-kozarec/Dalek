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
#include "context.mqh"
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
      if(WRITE_TEST_DATA)
        {
         string poly_coefs = "";
         for(ulong i = 0; i <= POLYNOMIAL_REGRESSION_DEGREE; i++)
           {
            poly_coefs += "a" + (string)i + ";";
           }

         trend_analysis_data.add_line("time;open;close;high;low;volume;" + poly_coefs + "R-square;trend;\n");
        }

      v_dependent.Resize(TREND_DETECTION_BAR_COUNT);
      for(ulong i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
        {
         v_dependent[i] = (double)i;
        }
     }

   MqlRates mql_rates[];
   if(CopyRates(_Symbol, tf, 1, (int)TREND_DETECTION_BAR_COUNT, mql_rates) <= 0)
     {
      log_error("Could not retrieve rates for " + _Symbol);
      return;
     }

   vector v_close;
   v_close.Resize(TREND_DETECTION_BAR_COUNT);

   for(ulong i = 0; i < TREND_DETECTION_BAR_COUNT; i++)
     {
      v_close[i] = mql_rates[i].close;
     }

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

   bool is_rsq_valid = true;
   if(rsq < R_SQUARED_TRESHOLD)
     {
      log_info("R-Squared is bellow treshold. Trend could not be detected");
      current_trend = UNKNOWN;
      is_rsq_valid = false;
     }

//---- Determine uptrend
   static bool was_uptrend = false;
   if(is_rsq_valid && is_uptrend(v_fit, rsq))
     {
      if(!was_uptrend)
        {
         log_info("Uptrend started");
         was_uptrend = true;
        }
      current_trend = RISING;
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
   if(is_rsq_valid && is_downtrend(v_fit, rsq))
     {
      if(!was_downtrend)
        {
         log_info("Downtrend started");
         was_downtrend = true;
        }
      current_trend = FALLING;
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
   if(is_rsq_valid && is_consolidating(v_fit, rsq))
     {
      if(!was_sidetrend)
        {
         log_info("Consolidation started");
         was_sidetrend = true;
        }
      current_trend = CONSOLIDATING;
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


   if(WRITE_TEST_DATA)
     {
      string poly_coefs = "";
      for(ulong i = 0; i <= POLYNOMIAL_REGRESSION_DEGREE; i++)
        {
         poly_coefs += (string)v_coef[i] + ";";
        }

      string trend_dir;
      switch(current_trend)
        {
         case UNKNOWN:
            trend_dir = "UNKNOWN";
            break;
         case RISING:
            trend_dir = "RISING";
            break;
         case FALLING:
            trend_dir = "FALLING";
            break;
         case CONSOLIDATING:
            trend_dir = "CONSOLIDATING";
            break;
        }

      trend_analysis_data.add_line(
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].time + ";" +
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].open + ";" +
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].close + ";" +
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].high + ";" +
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].low + ";" +
         (string)mql_rates[TREND_DETECTION_BAR_COUNT - 1].real_volume + ";" +
         poly_coefs +
         (string)rsq + ";" +
         trend_dir + ";\n");
     }
  }
//+------------------------------------------------------------------+
