//+------------------------------------------------------------------+
//|                                                        dalek.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "aggregator.mqh"
#include "strategy.mqh"
#include "configuration.mqh"
#include "logger.mqh"
#include "trader.mqh"
//+------------------------------------------------------------------+
input group "0 - General settings"
const input ulong MagicNumber /* Magic number - Unique ID for EA */ = 123456789;
input LogLevel LoggingLevel /* Logging level */ = INFO;

input group "1 - Position sizing (Kelly criterion)"
input double MaxRiskPercentage /* Max Risk - Percentage of equity to put at risk for each trade. */ = 2.0;
input double RiskRewardRatio /* Risk Reward Ration - Stop Loss multiplier for Take Profit */ = 1.1;

input group "2 - Trend detection (Polynomial regression)"
input ENUM_TIMEFRAMES TrendDetectionTimeFrame /* Period */ = PERIOD_CURRENT;
input ulong TrendDetectionBarCount /* Period multiplier - Bars used for trend detection. */ = 85;
input ulong PolynomialDegree /* Polynomial degree. */ = 2;
input double RSquaredTreshold /* R-Squared treshold - Treshold for model to be considered valid. */ = 0.75;

input group "3 - Breakout detection (Hidden Markov model)"
// ToDo

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize configuration parameters
   MAGIC_NUMBER = MagicNumber;
   LOGGER_LEVEL = LoggingLevel;
   MAX_RISK_PER_TRADE = MaxRiskPercentage;
   log_info("Parameters set");

   log_info("Dalek started");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  log_info("Dalek closed. Reason = " + (string)reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Aggregate ticks to pars
   aggregate_ticks(on_bar_aggregated);
  }
//+------------------------------------------------------------------+
