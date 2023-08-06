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
bool trader_initialized = false;
//+------------------------------------------------------------------+
//|                                                                  |
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
   trader_initialized = true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculate_pips(const double price_difference)
  {
//---- Get the value of one pip for the traded symbol
   double pip_val = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

//---- Calculate the number of pips based on the price difference and the pip value
   double pips = price_difference / pip_val;

   return pips;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculate_lot(const double stop_loss_in_pips)
  {
//---- Get the account balance or equity
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

//---- Calculate the amount of money to risk on the trade
   double risk_ammount = balance * MAX_RISK_PER_TRADE / 100.0;

//---- Calculate the value of one pip for the traded symbol
   double pip_val = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);

//---- Calculate the lot size based on the stop loss distance and the risk amount
   double lot_size = risk_ammount / (stop_loss_in_pips * pip_val);

   return lot_size;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void open_long(const double sl_price)
  {
   if(!trader_initialized)
      initialize_trader();
   
   const double ask_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double sl_pip = calculate_pips(ask_price - sl_price);
   const double lot_size = calculate_lot(sl_pip);
   
   trader.Buy(lot_size, _Symbol, ask_price, sl_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void open_short(const double sl_price)
  {
   if(!trader_initialized)
      initialize_trader();

   const double bid_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double sl_pip = calculate_pips(sl_price - bid_price);
   const double lot_size = calculate_lot(sl_pip);
   
   trader.Sell(lot_size, _Symbol, bid_price, sl_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void modify_sl(const double sl)
  {
   if(!trader_initialized)
      initialize_trader();
   
   trader.PositionModify(_Symbol, sl, 0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_position()
  {
   if(!trader_initialized)
      initialize_trader();
   
   trader.PositionClose(_Symbol);
  }
//+------------------------------------------------------------------+
