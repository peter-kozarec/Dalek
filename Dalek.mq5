//+------------------------------------------------------------------+
//|                                                        dalek.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Peter Kozarec"
#property link      "https://www.mql5.com/en/users/peterkozarec"
#property version   "1.00"
//+------------------------------------------------------------------+
#include "aggregator.mqh"
#include "strategy.mqh"
#include "configuration.mqh"
#include "logger.mqh"
#include "trader.mqh"
#include "context.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "0 - General settings"
input ulong MagicNumber /* Magic number - Unique ID for EA */ = 123456789;
input defs::LogLevel LoggingLevel /* Logging level */ = defs::INFO;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "1 - Risk management"
input double MaxRiskPercentage /* Percentage of equity to put at risk for each trade. */ = 2.0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "2 - Trend detection (Polynomial regression)"
input ENUM_TIMEFRAMES TrendDetectionTimeFrame /* Period */ = PERIOD_CURRENT;
input ulong TrendDetectionBarCount /* Period multiplier - Bars used for trend detection. */ = 85;
input ulong PolynomialDegree /* Polynomial degree. */ = 2;
input double RSquaredTreshold /* R-Squared treshold - Treshold for model to be considered valid. */ = 0.75;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//input group "3 - Breakout detection (Hidden Markov model)"
// ToDo

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "4 - Test settings (Flushed on deinit. Only for test!)"
input bool WriteTestDataToFiles /* Write test data to files. */ = false;
input string TestDataDirectory /* Test data directory. Needs write permission. */ = "";
input string TestDataPrefix /* Test data file prefix. */ = "test_";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize configuration parameters
   configuration::magic_number = MagicNumber;
   configuration::logger_level = LoggingLevel;
   configuration::max_risk_per_trade = MaxRiskPercentage;
   configuration::trend_detection_time_frame = TrendDetectionTimeFrame;
   configuration::trend_detection_bar_count = TrendDetectionBarCount;
   configuration::trend_detection_polynomial_degree = PolynomialDegree;
   configuration::trend_detection_r_squared_treshold = RSquaredTreshold;
   
   if(MQLInfoInteger(MQL_TESTER))
     {
      configuration::write_test_data = WriteTestDataToFiles;
      configuration::test_data_dir = TestDataDirectory;
      configuration::test_data_prefix = TestDataPrefix;
     } // if(MQLInfoInteger(MQL_TESTER))
   else
     {
      configuration::write_test_data = false;
     } // if(!MQLInfoInteger(MQL_TESTER))

   logger::log_info("Parameters set");
   logger::log_info("Dalek started");
 
   return INIT_SUCCEEDED;
  } // OnInit
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(configuration::write_test_data)
     {
      context::trend_analysis_writter.flush(
         configuration::test_data_dir + "/" +
         configuration::test_data_prefix +
         "TREND_ANALYSIS.csv");
     } // if(configuration::write_test_data)

   logger::log_info("Dalek closed. Reason = " + (string)reason);
  } // OnDeinit
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Aggregate ticks to detect trend
   aggregator::aggregate_ticks(strategy::detect_trend, 
                               configuration::trend_detection_time_frame, 
                               "detect_trend");

//--- Aggregate ticks to detect breakout
   aggregator::aggregate_ticks(strategy::detect_breakout, 
                               PERIOD_CURRENT, 
                               "detect_breakout");
  } // OnTick
//+------------------------------------------------------------------+
