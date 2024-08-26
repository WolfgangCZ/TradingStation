//+------------------------------------------------------------------+
//|                                                WT-02-LAG-MMI.mq4 |
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
#include <indicators.mqh>


input double riskPerTrade = 0.01;

input int emaPeriod = 20;
input int mmiPeriod = 200;
input int mmiSmoothing = 10;
input int stopLossATRMultiplier = 10;


double test_lot_size = 0.01;

datetime LastActionTime = 0;




bool IsLongOpen = false;
bool is_short_open = false;

int short_order_id = 0;
int long_order_id = 0;

int orderID = 0;
int magic_number = 1;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if (lastactiontime != time[0])
   {
      double currentATR = iATR(NULL, NULL, 100, 0);
      double ema1 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 1);
      double ema2 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 2);
      double ema3 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 3);
      
      double mmi1 = iMMI(1, mmiPeriod, mmiSmoothing);
      double mmi2 = iMMI(2, mmiPeriod, mmiSmoothing);
      double mmi3 = iMMI(3, mmiPeriod, mmiSmoothing);
      
      
      //long trade
      if(IsFalling(mmi3, mmi2, mmi1))
      {
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
            if(IsLongOpen == false)
               {
               
               double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*stopLossATRMultiplier, Ask),Digits);
               double lotSize = OptimalLotSize(riskPerTrade,Ask, stopLossPrice);
               long_order_id = OrderSend(NULL, OP_BUY, lotSize, Ask, 10, stopLossPrice, NULL, NULL, magic_number);
               IsLongOpen = true;
               }
            }
            
         if(IsPeak(ema3, ema2, ema1))
         {
            if(long_order_id != 0)
            {
               bool lastOrderSelected = OrderSelect(long_order_id, SELECT_BY_TICKET, MODE_TRADES);
               bool lastOrderClosed = OrderClose(long_order_id, OrderLots(), Bid, 10);
               Print("last order was selected: " + lastOrderSelected + ", last order was closed: " + lastOrderClosed);
               IsLongOpen = false;
               long_order_id = 0;
            }
            if(is_short_open == false)
            {
               
               double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*stopLossATRMultiplier, Bid),Digits);
               double lotSize = OptimalLotSize(riskPerTrade,Bid, stopLossPrice);
               short_order_id = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, NULL, NULL, magic_number);
               is_short_open = true;
               
            }
         }
      }
   }
}

//---------------------INITIALIZATION------------------------



void OnDeinit(const int reason)
{

}