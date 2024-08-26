
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>

input int numberCandlesLookback = 5;
input double lastCandleRatio = 4;
input bool isLastCandleCompleted = false;
input double riskReward = 1;
input double atrMultiplier = 1;
input int atrPeriod = 4;
input double maxRisk = 0.01;

input int print_candles = 100;
input int checkpoint_1 = 3;
input int checkpoint_2 = 6;
input int checkpoint_3 = 12;
input int checkpoint_4 = 24;
input int checkpoint_5 = 48;
input int checkpoint_6 = 72;
input double sl_last_candle_ratio = 1;

int shortOrderID = 0;
int longOrderID = 0;
bool isShortOpen = false;
bool isLongOpen = false;
double testLotSize = 0.01;
int magicNumber = 1;

datetime lastActionTime = 0;
string fileName = string(Symbol() + "_" + EnumToString(ENUM_TIMEFRAMES(_Period)) + "_pricedata.csv");
string subFolder = "history";

int fileHandle;

int OnInit()
{
    Print("Path to a file: " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\files\\" + subFolder + "\\" + fileName);
    fileHandle = FileOpen(subFolder + "\\" + fileName, FILE_WRITE|FILE_CSV);
    if(fileHandle!=INVALID_HANDLE)
    {
        string header = "Date Time Type"
            +" Checkpoint+"+string(checkpoint_1)
            +" Checkpoint_"+string(checkpoint_2)
            +" Checkpoint_"+string(checkpoint_3)
            +" Checkpoint_"+string(checkpoint_4)
            +" Checkpoint_"+string(checkpoint_5)
            +" Checkpoint_"+string(checkpoint_6)
            +" SL";
        for(int i = 0; i<print_candles; i++)
        {
            header += " Low[" + string(i) + "]";
            header += " Open[" + string(i) + "]";
            header += " Close[" + string(i) + "]";
            header += " High[" + string(i) + "]";
        }
        FileWrite(fileHandle, header);
    }
    else Print("Operation FileOpen failed, error ",GetLastError());
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    FileClose(fileHandle);
}

void OnTick()
{
    double currentATR = iATR(NULL, NULL, atrPeriod, 0);
    if (!CheckIfOpenOrdersByMagicNB(magicNumber))
    {
        // long
        // wtf
        if(RangeBreakOut(numberCandlesLookback, lastCandleRatio, isLastCandleCompleted) == 1)
        {
            double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*atrMultiplier, Ask),Digits);
            double takeProfitPrice = NormalizeDouble(Ask + (Ask - stopLossPrice)*riskReward, Digits);
            double lotSize = OptimalLotSize(maxRisk, Ask, stopLossPrice);
            longOrderID = OrderSend(NULL, OP_BUY, lotSize, Ask, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
            // if (lastActionTime != Time[0])
            // {
            //     if(fileHandle!=INVALID_HANDLE)
            //     {
            //         FileWrite(fileHandle, Time[1], Open[1], High[1], Low[1], Close[1], Volume[1]);
            //     }
            // else Print("Operation FileOpen failed, error ",GetLastError());
            // }
        }
        // short
        if(RangeBreakOut(numberCandlesLookback, lastCandleRatio, isLastCandleCompleted) == -1)
        {
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*atrMultiplier, Bid),Digits);
            double takeProfitPrice = NormalizeDouble(Bid - (stopLossPrice - Bid)*riskReward, Digits);
            double lotSize = OptimalLotSize(maxRisk, Bid, stopLossPrice);
            shortOrderID = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magicNumber);
        }
    }
}
