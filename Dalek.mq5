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

input group "1 - Fixed position sizing"
input double PositionSize /* Position size (lot) - Disables "2 - Dynamic position sizing". */ = 0;
input double StopLossPips /* Stop Loss (pip) */ = 100;
input double TakeProfitPips /* Take Profit (pip) */ = 100;

input group "2 - Dynamic position sizing"
input double MaxRiskPercentage /* Max Risk - Percentage of equity to put at risk for each trade. */ = 2.0;
input double RiskRewardRatio /* Risk Reward Ration - Stop Loss multiplier for Take Profit */ = 1.1;
input double AntiMartingaleWinStep /* Anti Martingale Win Step - After win increased Max Risk. */ = 0.1;
input double AntiMartingaleMaxWinStep /* Anti Martingale Max Win Step - Maximum increased. */ = 1;
input double AntiMartingaleLossStep /* Anti Martingale Loss Step - After win decreased Max Risk. */ = 0.1;
input double AntiMartingaleMaxLossStep /* Anti Martingale Max Loss Step - Maximim decreased. */ = 1;

input group "3 - Trailing stop loss"

input group "4 - Spread deviation kill switch"
input bool SpreadDeviationActive = true;
input double AboveAveragePercentage = 10.0;

input group "5 - Volume deviation kill switch"
input bool VolumeDeviationActive = true;
input double BelowAveragePercentage = 10.0;

input group "6 - Trend detection (Using Polynomial regression)"
input ENUM_TIMEFRAMES TrendDetectionTimeFrame /* Period */ = PERIOD_CURRENT;
input ulong TrendDetectionBarCount /* Period multiplier - Bars used for trend detection. */ = 85;
input ulong PolynomialDegree /* Polynomial degree. */ = 2;
input double RSquaredTreshold /* R-Squared treshold - Treshold for model to be considered valid. */ = 0.75;


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
