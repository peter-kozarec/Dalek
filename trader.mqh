//+------------------------------------------------------------------+
//|                                                       trader.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_TRADER_MQH
#define DALEK_TRADER_MQH
//+------------------------------------------------------------------+
#include "configuration.mqh"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
namespace trader
{
//+------------------------------------------------------------------+
//| Trader object, takes care of trades                              |
//+------------------------------------------------------------------+
CTrade trader_;
//+------------------------------------------------------------------+
//| True after trader object has been initialized                    |
//+------------------------------------------------------------------+
bool trader_initialized_ = false;
//+------------------------------------------------------------------+
//| Set default values for trader object                             |
//+------------------------------------------------------------------+
void initialize_trader()
  {
//---- Initialize logging
   if(configuration::logger_level <= defs::DEBUG)
     {
      trader_.LogLevel(LOG_LEVEL_ALL);
     } // if(LOGGER_LEVEL <= DEBUG)
   else
     {
      if(configuration::logger_level <= defs::FATAL)
        {
         trader_.LogLevel(LOG_LEVEL_ERRORS);
        } // if(LOGGER_LEVEL <= FATAL)
      else
        {
         trader_.LogLevel(LOG_LEVEL_NO);
        } // if(LOGGER_LEVEL > FATAL)
     } // if(LOGGER_LEVEL > DEBUG)

//---- Initialize EA magic number
   trader_.SetExpertMagicNumber(configuration::magic_number);
   trader_.SetMarginMode();
   trader_.SetTypeFilling(ORDER_FILLING_IOC);
   trader_initialized_ = true;
  } // trader::initialize_trader
//+------------------------------------------------------------------+
//| Calculate pips for price difference                              |
//+------------------------------------------------------------------+
double calculate_pips(const double price_difference)
  {
//---- Get the value of one pip for the traded symbol
   double pip_val = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

//---- Calculate the number of pips based on the price difference and the pip value
   double pips = price_difference / pip_val;

//---- Return calculated pips
   return MathFloor(pips);
  } // trader::calculate_pips
//+------------------------------------------------------------------+
//| Normalize price to smalled price point                           |
//+------------------------------------------------------------------+
double normalize_price(double price)
  {
//---- Retrieve tick size
   const double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

//---- Calculate normalized price from the tick size
   return MathRound(price/tick_size) * tick_size;
  } // trader::normalize_price
//+------------------------------------------------------------------+
//| Normalize lots to the smallest lot step                          |
//+------------------------------------------------------------------+
double normalize_lots(double lots)
  {
//---- Retrieve minimal lot size for the current symbol
   const double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

//---- Retrieve minimal lot step for the current symbol
   const double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

//---- Calculate normalized lots from the minimal lot step and size.
   double normalized_lots = MathRound(lots/lot_step) * lot_step;

//---- If normalized lots are lower then to minimum size for position
//---- Use the minimal posizion size instead
   if(normalized_lots < min_lot)
     {
      normalized_lots = min_lot;
     } // if(normalized_lots < min_lot)

//---- Return normalized lots
   return normalized_lots;
  } // trader::normalize_lots
//+------------------------------------------------------------------+
//| Calculate position size from the stop loss distance              |
//+------------------------------------------------------------------+
double calculate_lot(const double stop_loss_in_pips)
  {
//---- Get the account balance or equity
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);

//---- Calculate the amount of money to risk on the trade
   const double risk_ammount = balance * configuration::max_risk_per_trade / 100.0;

//---- Calculate the value of one pip for the traded symbol
   const double pip_val = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);

//---- Calculate the lot size based on the stop loss distance and the risk amount
   const double lot_size = risk_ammount / (stop_loss_in_pips * pip_val);

//---- Return lot size
   return lot_size;
  } // trader::calculate_lot
//+------------------------------------------------------------------+
//| Open long position with defined stop loss                        |
//+------------------------------------------------------------------+
void open_long(const double sl_price)
  {
//---- Initialize trader if it is not yet
   if(!trader_initialized_)
     {
      initialize_trader();
     } // if(!trader_initialized_)

//---- Retrieve current ask price
   const double ask_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

//---- Normalize ask price, but probably no needed
   const double normalized_ask_price = normalize_price(ask_price);

//---- Normalize stop loss price
   const double normalized_sl_price = normalize_price(sl_price);

//---- Calculate stop loss in pips difference from current price
   const double sl_pips = calculate_pips(normalized_ask_price - normalized_sl_price);

//---- Calculate lot size based on stop loss and risk profile
   const double lot_size = calculate_lot(sl_pips);

//---- Normalize calculated lot size
   const double normalized_lot_size = normalize_lots(lot_size);

//---- Place market buy
   trader_.Buy(normalized_lot_size, _Symbol, normalized_ask_price, normalized_sl_price);
  } // trader::open_long
//+------------------------------------------------------------------+
//| Open short position with defined stop loss                       |
//+------------------------------------------------------------------+
void open_short(const double sl_price)
  {
//---- Initialize trader if it is not yet
   if(!trader_initialized_)
     {
      initialize_trader();
     } // if(!trader_initialized_)

//---- Retrieve current bid price
   const double bid_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

//---- Normalize bid price, but probably no needed
   const double normalized_bid_price = normalize_price(bid_price);

//---- Normalize stop loss price
   const double normalized_sl_price = normalize_price(sl_price);

//---- Calculate stop loss in pips difference from current price
   const double sl_pips = calculate_pips(normalized_sl_price - normalized_bid_price);

//---- Calculate lot size based on stop loss and risk profile
   const double lot_size = calculate_lot(sl_pips);

//---- Normalize calculated lot size
   const double normalized_lot_size = normalize_lots(lot_size);

//---- Place market sell
   trader_.Sell(normalized_lot_size, _Symbol, normalized_bid_price, normalized_sl_price);
  } // trader::open_short
//+------------------------------------------------------------------+
//| Modify stop loss of open position                                |
//+------------------------------------------------------------------+
void modify_sl(const double sl)
  {
//---- Initialize trader if it is not yet
   if(!trader_initialized_)
     {
      initialize_trader();
     } // if(!trader_initialized_)

// ToDo
  } // trader::modify_sl
//+------------------------------------------------------------------+
//| Close open position                                              |
//+------------------------------------------------------------------+
void close_position()
  {
//---- Initialize trader if it is not yet
   if(!trader_initialized_)
     {
      initialize_trader();
     } // if(!trader_initialized_)

// ToDo
  } // trader::close_position
//+------------------------------------------------------------------+
}; // namespace trader
//+------------------------------------------------------------------+
#endif