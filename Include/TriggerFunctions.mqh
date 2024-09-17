//+------------------------------------------------------------------+
//|                                            TrigggerFunctions.mqh |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict
bool IsPeak(double lValue, double mValue, double rValue)
{
   if(lValue < mValue && mValue > rValue) return true;
   else return false;
}

bool IsValley(double lValue, double mValue, double rValue)
{
   if(lValue > mValue && mValue < rValue) return true;
   else return false;
}

bool IsFalling(double firstValue, double secondValue, double thirdValue)
{
   if(firstValue > secondValue && secondValue > thirdValue) return true;
   else return false;
}

bool IsRising(double firstValue, double secondValue, double thirdValue)
{
   if(firstValue < secondValue && secondValue < thirdValue) return true;
   else return false;
}
// numCandlesLoolback = how many candles to look back to determin if its breakout (candle 1 - n)
// breakOutRation = how many times has the 0 candle needs to be bigger than lookback candles
// waitToComplete = wait to last candle to complete
int RangeBreakOut(int numCandlesLookback, double breakOutRatio, bool waitToComplete)
{
   int offset = 0;
   if (waitToComplete) offset = 1;
   double sizeSum = 0;
   for (int i = 1 + offset; i < 1 + numCandlesLookback + offset; i++)
   {
      double range = MathAbs(High[i] - Low[i]);
      sizeSum += range;
   }
   double sizeSumAvg = sizeSum / numCandlesLookback;
   double lastCandleSize = Close[offset] - Open[offset];
   // Print("last candle size: " + string(lastCandleSize));
   // Print("size sum avg: " + string(sizeSumAvg*breakOutRatio));

   if (lastCandleSize > breakOutRatio*sizeSumAvg) 
   {
      // Print("=======BUY=======");
      return 1;
   }
   if ((-lastCandleSize) > breakOutRatio*sizeSumAvg)
   {
      // Print("======SELL======");
      return -1;
   }
   return 0;
}
