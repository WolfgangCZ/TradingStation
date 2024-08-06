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

double testLotSize = 0.01;


uint fastStochaThreshold = 20;
uint slowStochaThreshold = 20;

bool isLongOpen = false;
bool isShortOpen = false;

int shortOrderID = 0;
int longOrderID = 0;

int orderID = 0;
int magicNumber = 1;

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
      
      if(shortOrderID != 0)
      {
         bool lastOrderSelected = OrderSelect(shortOrderID, SELECT_BY_TICKET, MODE_TRADES);
         bool lastOrderClosed = OrderClose(shortOrderID, OrderLots(), Ask, 10);
         Print("last order was selected: " + lastOrderSelected + ", last order was closed: " + lastOrderClosed);
         isShortOpen = false;
         shortOrderID = 0;
      }
      if(isLongOpen == false)
         {
         double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*stopLossATRMultiplier, Ask),Digits);
         longOrderID = OrderSend(NULL, OP_BUY, testLotSize, Ask, 10, NULL, NULL, NULL, magicNumber);
         isLongOpen = true;
         }
      }
      
   if(IsPeak(ema3, ema2, ema1))
   {
      if(longOrderID != 0)
      {
         bool lastOrderSelected = OrderSelect(longOrderID, SELECT_BY_TICKET, MODE_TRADES);
         bool lastOrderClosed = OrderClose(longOrderID, OrderLots(), Bid, 10);
         Print("last order was selected: " + lastOrderSelected + ", last order was closed: " + lastOrderClosed);
         isLongOpen = false;
         longOrderID = 0;
      }
      if(isShortOpen == false)
      {
         double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*stopLossATRMultiplier, Bid),Digits);
         shortOrderID = OrderSend(NULL, OP_SELL, testLotSize, Bid, 10, NULL, NULL, NULL, magicNumber);
         isShortOpen = true;
         
      }
   }

}


//---------------------INITIALIZATION------------------------



void OnDeinit(const int reason)
{

}