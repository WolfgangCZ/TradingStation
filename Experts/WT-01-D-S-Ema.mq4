//+------------------------------------------------------------------+
//|                                                WT-01-D-S-Ema.mq4 |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>

input double riskPerTrade = 0.01;
input uint stopLossATRMultiplier = 10;
input uint stopLossATRPeriod = 10;

input uint emaPeriod = 100;
input uint fastStochaPeriod = 5;
input uint slowStochaPeriod = 20;

double test_lot_size = 0.01;


uint fastStochaThreshold = 20;
uint slowStochaThreshold = 20;

bool is_long_open = false;
bool is_short_open = false;

int short_order_id = 0;
int long_order_id = 0;

int orderID = 0;
int magic_number = 1;

int OnInit()
{/*
   if(IsTradingAllowed())
   {
      ExpertRemove();
   }
   
   Alert("Starting EA WT-01-D-S-Ema");
   int    vDigits = (int)MarketInfo("EURUSD",MODE_DIGITS);
   int    vSpread = (int)MarketInfo("EURUSD",MODE_SPREAD);
   
   
   Print("--------------INITIAL MARKET INFO--------------------");
   
   Print("Current spread: " + vSpread);
   Print("Current vDigits: " + vDigits);
   
   Print("Symbol=",Symbol());
   Print("Point size in the quote currency=",MarketInfo(Symbol(),MODE_POINT));
   Print("Digits after decimal point=",MarketInfo(Symbol(),MODE_DIGITS));
   Print("Spread value in points=",MarketInfo(Symbol(),MODE_SPREAD));

   Print("Lot size in the base currency=",MarketInfo(Symbol(),MODE_LOTSIZE));
   Print("Tick value in the deposit currency=",MarketInfo(Symbol(),MODE_TICKVALUE));
   Print("Tick size in points=",MarketInfo(Symbol(),MODE_TICKSIZE)); 
   Print("Swap of the buy order=",MarketInfo(Symbol(),MODE_SWAPLONG));
   Print("Swap of the sell order=",MarketInfo(Symbol(),MODE_SWAPSHORT));

   Print("Trade is allowed for the symbol=",MarketInfo(Symbol(),MODE_TRADEALLOWED));
   Print("Minimum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MINLOT));
   Print("Step for changing lots=",MarketInfo(Symbol(),MODE_LOTSTEP));
   Print("Maximum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MAXLOT));
   Print("Swap calculation method=",MarketInfo(Symbol(),MODE_SWAPTYPE));
   Print("Profit calculation mode=",MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   Print("Margin calculation mode=",MarketInfo(Symbol(),MODE_MARGINCALCMODE));
   Print("Initial margin requirements for 1 lot=",MarketInfo(Symbol(),MODE_MARGININIT));
   Print("Margin to maintain open orders calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINMAINTENANCE));
   Print("Hedged margin calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINHEDGED));
   Print("Free margin required to open 1 lot for buying=",MarketInfo(Symbol(),MODE_MARGINREQUIRED));
   Print("Order freeze level in points=",MarketInfo(Symbol(),MODE_FREEZELEVEL)); 
   
   Print("--------------INITIAL MARKET INFO--------------------");
   */
   return(INIT_SUCCEEDED);
}

void OnTick()
{

   double currentATR = iATR(NULL, NULL, stopLossATRPeriod, NULL);
   double ema1 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 1);
   double ema2 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 2);
   double ema3 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 3);
   
   
   //long trade
   if(IsValley(ema3, ema2, ema1))
   {
      //openOrderID = OrderSend(NULL,OP_SELLLIMIT,lotSize,Bid,10,stopLossPrice,takeProfitPrice,NULL,magicNB);
      
      if(short_order_id != 0)
      {
         bool lastOrderSelected = OrderSelect(short_order_id, SELECT_BY_TICKET, MODE_TRADES);
         bool lastOrderClosed = OrderClose(short_order_id, OrderLots(), Ask, 10);
         Print("last order was selected: " + lastOrderSelected + ", last order was closed: " + lastOrderClosed);
         is_short_open = false;
         short_order_id = 0;
      }
      if(is_long_open == false)
         {
         double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*stopLossATRMultiplier, Ask),Digits);
         long_order_id = OrderSend(NULL, OP_BUY, test_lot_size, Ask, 10, NULL, NULL, NULL, magic_number);
         is_long_open = true;
         }
      }
      
   if(IsPeak(ema3, ema2, ema1))
   {
      if(long_order_id != 0)
      {
         bool lastOrderSelected = OrderSelect(long_order_id, SELECT_BY_TICKET, MODE_TRADES);
         bool lastOrderClosed = OrderClose(long_order_id, OrderLots(), Bid, 10);
         Print("last order was selected: " + lastOrderSelected + ", last order was closed: " + lastOrderClosed);
         is_long_open = false;
         long_order_id = 0;
      }
      if(is_short_open == false)
      {
         double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*stopLossATRMultiplier, Bid),Digits);
         short_order_id = OrderSend(NULL, OP_SELL, test_lot_size, Bid, 10, NULL, NULL, NULL, magic_number);
         is_short_open = true;
         
      }
   }

}


//---------------------INITIALIZATION------------------------



void OnDeinit(const int reason)
{

}