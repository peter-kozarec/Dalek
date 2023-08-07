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
   trader.SetMarginMode();
   trader.SetTypeFilling(ORDER_FILLING_IOC);
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

   return MathFloor(pips);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double normalize_price(double price)
  {
   const double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   return MathRound(price/tick_size) * tick_size;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double normalize_lots(double lots)
  {
   const double min_lot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double normalized_lots = MathRound(lots/lot_step) * lot_step;

   if(normalized_lots < min_lot)
     {
      normalized_lots = min_lot;
     }
  
   return normalized_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculate_lot(const double stop_loss_in_pips)
  {
//---- Get the account balance or equity
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);

//---- Calculate the amount of money to risk on the trade
   const double risk_ammount = balance * MAX_RISK_PER_TRADE / 100.0;

//---- Calculate the value of one pip for the traded symbol
   const double pip_val = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);

//---- Calculate the lot size based on the stop loss distance and the risk amount
   const double lot_size = risk_ammount / (stop_loss_in_pips * pip_val);
   
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
   const double normalized_ask_price = normalize_price(ask_price);
   const double normalized_sl_price = normalize_price(sl_price);
   const double sl_pips = calculate_pips(normalized_ask_price - normalized_sl_price);
   const double lot_size = calculate_lot(sl_pips);
   const double normalized_lot_size = normalize_lots(lot_size);

   trader.Buy(normalized_lot_size, _Symbol, normalized_ask_price, normalized_sl_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void open_short(const double sl_price)
  {
   if(!trader_initialized)
      initialize_trader();

   const double bid_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double normalized_bid_price = normalize_price(bid_price);
   const double normalized_sl_price = normalize_price(sl_price);
   const double sl_pips = calculate_pips(normalized_sl_price - normalized_bid_price);
   const double lot_size = calculate_lot(sl_pips);
   const double normalized_lot_size = normalize_lots(lot_size);

   trader.Sell(normalized_lot_size, _Symbol, normalized_bid_price, normalized_sl_price);
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
