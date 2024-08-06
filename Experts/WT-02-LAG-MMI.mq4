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


double testLotSize = 0.01;

datetime LastActionTime = 0;




bool isLongOpen = false;
bool isShortOpen = false;

int shortOrderID = 0;
int longOrderID = 0;

int orderID = 0;
int magicNumber = 1;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if (LastActionTime != Time[0])
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
               double lotSize = asfk(riskPerTrade,Ask, stopLossPrice);
               longOrderID = OrderSend(NULL, OP_BUY, lotSize, Ask, 10, stopLossPrice, NULL, NULL, magicNumber);
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
               double lotSize = asfk(riskPerTrade,Bid, stopLossPrice);
               shortOrderID = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, NULL, NULL, magicNumber);
               isShortOpen = true;
               
            }
         }
      }
   }
}

//---------------------INITIALIZATION------------------------



void OnDeinit(const int reason)
{

}