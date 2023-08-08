//+------------------------------------------------------------------+
//|                                                     strategy.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_STRATEGY_MQH
#define DALEK_STRAGEGY_MQH
//+------------------------------------------------------------------+
#include "configuration.mqh"
#include "regression.mqh"
#include "trend.mqh"
#include "logger.mqh"
#include "defs.mqh"
#include "context.mqh"
#include "trader.mqh"
//+------------------------------------------------------------------+
namespace strategy
{
//+------------------------------------------------------------------+
//| Current trend detected                                           |
//+------------------------------------------------------------------+
defs::TrendDirection current_trend_ = defs::UNKNOWN;
//+------------------------------------------------------------------+
//| Detect breakout                                                  |
//+------------------------------------------------------------------+
void detect_breakout(ENUM_TIMEFRAMES timeframe)
  {
  } // strategy::detect_breakout
//+------------------------------------------------------------------+
//| Entry point of a strategy called on new aggregated bar           |
//+------------------------------------------------------------------+
void detect_trend(ENUM_TIMEFRAMES timeframe)
  {
//---- Create dependent vector
   static vector v_dependent;
   
//---- If dependend vector is empty, fill with values, done only once.
   if(v_dependent.Size() == 0)
     {
//---- Write header for csv, done only once 
      if(configuration::write_test_data)
        {
         string poly_coefs = "";
         for(ulong i = 0; 
             i <= configuration::trend_detection_polynomial_degree;
             i++)
           {
            poly_coefs += "a" + (string)i + ";";
           }

         context::trend_analysis_writter.add_line(
            "time;open;close;high;low;volume;" + 
            poly_coefs + 
            "R-square;trend;\n");
        } // if(configuration::write_test_data)

//---- Fill dependent vector with values
      v_dependent.Resize(configuration::trend_detection_bar_count);
      for(ulong i = 0;
          i < configuration::trend_detection_bar_count;
          i++)
        {
         v_dependent[i] = (double)i;
        }
     } // if(v_dependent.Size() == 0)

//---- Retrieve rates for the defined bar count
   MqlRates mql_rates[];
   if(CopyRates(_Symbol,
                timeframe, 
                1, 
                (int)configuration::trend_detection_bar_count, 
                mql_rates) <= 0)
     {
      logger::log_fatal(
         "Could not retrieve rates for " + 
         _Symbol + 
         ". Exiting...");
      // ToDo: Add handling of open positions
      ExpertRemove();
      return;
     }

//---- Create vector of closed prices
   vector v_close;
   v_close.Resize(configuration::trend_detection_bar_count);

//---- Fill close vector with values
   for(ulong i = 0;
       i < configuration::trend_detection_bar_count;
       i++)
     {
      v_close[i] = mql_rates[i].close;
     }

//---- Calculate polynomial regression
   vector v_coef = regression::polyfit(
                     v_dependent, 
                     v_close, 
                     configuration::trend_detection_polynomial_degree);

   logger::log_debug(
      "Polynomial regression of degree " + 
      (string)configuration::trend_detection_polynomial_degree + 
      " solved");
   
//---- Print calculated polynomial coefficients
   for(ulong i = 0;
       i <= configuration::trend_detection_polynomial_degree;
       i++)
     {
      logger::log_debug(
         "Coefficient a" + 
         (string)i + 
         " = " + 
         (string)v_coef[i]);
     }

//---- Fit into polynomial - y = a0 + a1x + a2x2 ... anxn
   vector v_fit;
   v_fit.Resize(configuration::trend_detection_bar_count);

   for(ulong i = 0; 
       i < configuration::trend_detection_bar_count; 
       i++)
     {
      double sum = 0;
      for(ulong j = 0; 
          j <= configuration::trend_detection_polynomial_degree; 
          j++)
        {
         sum += v_coef[j] * pow(v_dependent[i], j);
        }
      v_fit[i] = sum;
     }

//---- Calculate r squared
   const double rsq = regression::r_squared(v_close, v_fit);
   logger::log_debug("R-Squared calculated = " + (string)rsq);

   bool is_rsq_valid = true;
   if(rsq < configuration::trend_detection_r_squared_treshold)
     {
      logger::log_info("R-Squared is bellow treshold. Trend could not be detected");
      current_trend_ = defs::UNKNOWN;
      is_rsq_valid = false;
     } // if(rsq < configuration::trend_detection_r_squared_treshold)

//---- Determine uptrend
   static bool was_uptrend = false;
   if(is_rsq_valid && trend::is_uptrend(v_fit, rsq))
     {
      if(!was_uptrend)
        {
         logger::log_info("Uptrend started");
         was_uptrend = true;
        } // if(!was_uptrend)
      current_trend_ = defs::RISING;
     } // if(is_rsq_valid && trend::is_uptrend(v_fit, rsq))
   else
     {
      if(was_uptrend)
        {
         logger::log_info("Uptrend ended");
         was_uptrend = false;
        } // if(was_uptrend)
      current_trend_ = defs::UNKNOWN;
     } // if(!is_rsq_valid || !trend::is_uptrend(v_fit, rsq))

//---- Determine downtrend
   static bool was_downtrend = false;
   if(is_rsq_valid && trend::is_downtrend(v_fit, rsq))
     {
      if(!was_downtrend)
        {
         logger::log_info("Downtrend started");
         was_downtrend = true;
        } // if(!was_downtrend)
      current_trend_ = defs::FALLING;
     } // if(is_rsq_valid && trend::is_downtrend(v_fit, rsq))
   else
     {
      if(was_downtrend)
        {
         logger::log_info("Downtrend ended");
         was_downtrend = false;
        } // if(was_downtrend)
      current_trend_ = defs::UNKNOWN;
     } // if(!is_rsq_valid || !trend::is_downtrend(v_fit, rsq))

//---- Determine side trend
   static bool was_sidetrend = false;
   if(is_rsq_valid && trend::is_consolidating(v_fit, rsq))
     {
      if(!was_sidetrend)
        {
         logger::log_info("Consolidation started");
         was_sidetrend = true;
        } // if(!was_sidetrend)
      current_trend_ = defs::CONSOLIDATING;
     } // if(is_rsq_valid && trend::is_consolidating(v_fit, rsq))
   else
     {
      if(was_sidetrend)
        {
         logger::log_info("Consolidation ended");
         was_sidetrend = false;
        } // if(was_sidetrend)
      current_trend_ = defs::UNKNOWN;
     } // if(!is_rsq_valid || !trend::is_consolidating(v_fit, rsq))

//---- Add calculated and price data to the test output.
   if(configuration::write_test_data)
     {
      string poly_coefs = "";
      for(ulong i = 0; 
          i <= configuration::trend_detection_polynomial_degree; 
          i++)
        {
         poly_coefs += (string)v_coef[i] + ";";
        }

      string trend_dir;
      switch(current_trend_)
        {
         case defs::UNKNOWN:
            trend_dir = "UNKNOWN";
            break;
         case defs::RISING:
            trend_dir = "RISING";
            break;
         case defs::FALLING:
            trend_dir = "FALLING";
            break;
         case defs::CONSOLIDATING:
            trend_dir = "CONSOLIDATING";
            break;
        } // switch(current_trend_)

      context::trend_analysis_writter.add_line(
         (string)mql_rates[configuration::trend_detection_bar_count - 1].time + ";" +
         (string)mql_rates[configuration::trend_detection_bar_count - 1].open + ";" +
         (string)mql_rates[configuration::trend_detection_bar_count - 1].close + ";" +
         (string)mql_rates[configuration::trend_detection_bar_count - 1].high + ";" +
         (string)mql_rates[configuration::trend_detection_bar_count - 1].low + ";" +
         (string)mql_rates[configuration::trend_detection_bar_count - 1].real_volume + ";" +
         poly_coefs +
         (string)rsq + ";" +
         trend_dir + ";\n");
     } // if(configuration::write_test_data)
  } // strategy::detect_trend
//+------------------------------------------------------------------+
}; // namespace strategy
//+------------------------------------------------------------------+
#endif // DALEK_STRAGEGY_MQH