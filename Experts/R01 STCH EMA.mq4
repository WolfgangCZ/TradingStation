//+------------------------------------------------------------------+
//|                                                 R01 STCH EMA.mq4 |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>

input double riskPerTrade = 0.01;
input double riskReward = 1;
input uint stochaThreshold = 20;


input uint stopLossATRMultiplier = 2;
input uint stopLossATRPeriod = 100;

input uint emaPeriod = 200;
input uint stochaPeriod = 5;

datetime LastActionTime = 0;

double testLotSize = 0.01;


float fastEmaMultiplier = 0.5;

int orderID;
int magicNumber = 1;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }

void OnTick()
{
   double currentATR = iATR(NULL, NULL, stopLossATRPeriod, NULL);
   double emaSlow1 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 1);
   double emaSlow2 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 2);
   double emaSlow3 = iMA(NULL, NULL, emaPeriod, 0, 1, 4, 3);
   double emaFast = iMA(NULL, NULL, emaPeriod*fastEmaMultiplier, 0, 1, 4, 1);
   double stocha1 = iStochastic(NULL, NULL, stochaPeriod, 3, 3, 1, 0, 0, 1);
   double stocha2 = iStochastic(NULL, NULL, stochaPeriod, 3, 3, 1, 0, 0, 2);
   double stocha3 = iStochastic(NULL, NULL, stochaPeriod, 3, 3, 1, 0, 0, 3);
   
   //trading only first tick of a candle and only 1 trade at a time
   if (LastActionTime != Time[0] && !CheckIfOpenOrdersByMagicNB(magicNumber))
   {
      //SHORT TRADE
      if(
      IsFalling(emaSlow3, emaSlow2, emaSlow1)
      && IsPeak(stocha1, stocha2, stocha3)
      && High[2] < emaSlow2
      && High[2] > emaFast
      && stocha2 > (100-stochaThreshold)
      )
      {               
         double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*stopLossATRMultiplier, Bid),Digits);
         double takeProfitPrice = NormalizeDouble(Bid - (stopLossPrice - Bid)*riskReward, Digits);
         double lotSize = asfk(riskPerTrade,Bid, stopLossPrice);
         orderID = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
      }
      //LONG TRADE
      if(
      IsRising(emaSlow3, emaSlow2, emaSlow1)
      && IsValley(stocha1, stocha2, stocha3)
      && Low[2] > emaSlow2
      && Low[2] < emaFast
      && stocha2 < stochaThreshold
      )
      {
         double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*stopLossATRMultiplier, Ask),Digits);
         double takeProfitPrice = NormalizeDouble(Ask + (Ask - stopLossPrice)*riskReward, Digits);
         double lotSize = asfk(riskPerTrade,Ask, stopLossPrice);
         orderID = OrderSend(NULL, OP_BUY, lotSize, Ask, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
      }
   }
}
//+------------------------------------------------------------------+
