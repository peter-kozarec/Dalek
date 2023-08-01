//+------------------------------------------------------------------+
//|                                                        dalek.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "aggregator.mqh"
#include "strategy.mqh"
#include "configuration.mqh"
#include "logger.mqh"

input group "General"
input LogLevel LoggingLevel = INFO;

input group "RiskManagement"
input double MaxRiskPerTrade = 1.0;

input group "Strategy"
input int TrendDetectionBarCount = 90;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize configuration parameters
   LOGGER_LEVEL = LoggingLevel;
   MAX_RISK_PER_TRADE = MaxRiskPerTrade;
   TREND_DETECTION_BAR_COUNT = TrendDetectionBarCount;

   log_info("Dalek initialized");
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
