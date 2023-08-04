//+------------------------------------------------------------------+
//|                                                       trader.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "trader.mqh"
#include "configuration.mqh"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
CTrade trader;
//+------------------------------------------------------------------+
void initialize_trader()
  {
//---- Initialize logging
   if(LOGGER_LEVEL <= DEBUG)
     {
      trader.LogLevel(LOG_LEVEL_ALL);
     }
   else
     {
      if(LOGGER_LEVEL <= FATAL)
        {
         trader.LogLevel(LOG_LEVEL_ERRORS);
        }
      else
        {
         trader.LogLevel(LOG_LEVEL_NO);
        }
     }

//---- Initialize EA magic number
   trader.SetExpertMagicNumber(MAGIC_NUMBER);
  }
//+------------------------------------------------------------------+
