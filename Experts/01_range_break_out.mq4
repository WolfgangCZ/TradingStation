
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>

input int candles_lookback = 5;
input double last_candle_ratio = 4;
input bool is_last_candle_complete = false;
input double risk_reward = 1;
input double atr_multiplier = 1;
input int atr_period = 4;
input double max_risk = 0.01;

input int print_candles = 100;
input int checkpoint_1 = 3;
input int checkpoint_2 = 6;
input int checkpoint_3 = 12;
input int checkpoint_4 = 24;
input int checkpoint_5 = 48;
input int checkpoint_6 = 72;
input double sl_last_candle_ratio = 1;

int short_order_id = 0;
int long_order_id = 0;
bool is_short_open = false;
bool is_long_open = false;
double test_lot_size = 0.01;
int magic_number = 1;

datetime last_action_time = 0;
string file_name = string(Symbol() + "_" + EnumToString(ENUM_TIMEFRAMES(_Period)) + "_pricedata.csv");
string sub_folder = "history";
int trade_stop = 5;
int stop_counter = 0;

int fileHandle;

int OnInit()
{
    Print("Path to a file: " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\files\\" + sub_folder + "\\" + file_name);
    fileHandle = FileOpen(sub_folder + "\\" + file_name, FILE_WRITE|FILE_CSV);
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

    if (last_action_time == Time[0] && stop_counter > 0)
    {
        stop_counter -= 1;
    }

    if (stop_counter == 0)
    {
        double currentATR = iATR(NULL, NULL, atr_period, 0);
        // long
        // wtf
        if(RangeBreakOut(candles_lookback, last_candle_ratio, is_last_candle_complete) == 1)
        {
            double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR*atr_multiplier, Ask),Digits);
            double takeProfitPrice = NormalizeDouble(Ask + (Ask - stopLossPrice)*risk_reward, Digits);
            double lotSize = OptimalLotSize(max_risk, Ask, stopLossPrice);
            long_order_id = OrderSend(NULL, OP_BUY, lotSize, Ask, 10, stopLossPrice, takeProfitPrice, NULL, magic_number);
            stop_counter = trade_stop;
            

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
        if(RangeBreakOut(candles_lookback, last_candle_ratio, is_last_candle_complete) == -1)
        {
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*atr_multiplier, Bid),Digits);
            double takeProfitPrice = NormalizeDouble(Bid - (stopLossPrice - Bid)*risk_reward, Digits);
            double lotSize = OptimalLotSize(max_risk, Bid, stopLossPrice);
            short_order_id = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magic_number);
            stop_counter = trade_stop;
        }
    }
}
