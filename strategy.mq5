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
//---- Get rates
   vector v_close;
   v_close.CopyRates(_Symbol, _Period, COPY_RATES_CLOSE, 1, TREND_DETECTION_BAR_COUNT);
   
//---- Calculate linear regression
   const vector v_lr = v_close.LinearRegression();
   log_debug("Linear regression calculated");
   
//---- Calculate r squared
   const double r_squared = r_squared_calculate(v_close, v_lr);
   log_debug("R-Squared = " + r_squared);

//---- Determine uptrend
   static bool was_uptrend = false;
   if(is_uptrend(v_lr, r_squared))
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
   if(is_downtrend(v_lr, r_squared))
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
