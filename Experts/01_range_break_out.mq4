
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>
#include <FunctionTemplates.mqh>

input int candles_lookback = 5;
input double last_candle_ratio = 4;
input bool is_last_candle_complete = false;
input double risk_reward = 1;
input double atr_multiplier = 1;
input int atr_period = 4;
input double max_risk = 0.01;
input string file_name = "zkouska.csv";

input int print_candles = 3;
input int candles_timeout = 10;

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
int ring_index = 0;

datetime last_action_time = 0;
string sub_folder = "range_breakout";
int trade_stop = 5;
int stop_counter = 0;
const int buffer_size = 200;

int fileHandle = 0;
bool is_initialized = false;

string file_content = "";

class OpenTrade
{
    public:
        OpenTrade(){}
        OpenTrade(double stoploss, double entry_price, double target, int ticket_id)
        {
            sl = stoploss;
            entry = entry_price;
            tp = target;
            candles_past = candles_timeout;
            id = ticket_id;
            is_closed = false;
            print_previous_candles(print_candles);
            cp_1 = cp_2 = cp_3 = cp_4 = cp_5 = cp_6 = "x ";
            sl_close = "timeout";
            price_movement = string(TimeCurrent()) + " ";
        }
        ~OpenTrade()
        {
            write_down_entry_price();
            write_down_order_type();
            write_down_checkpoints();
            write_down_sl();
            FileWrite(fileHandle, price_movement + candle_ohlc);
        }
        void write_down_order_type()
        {
            if (sl > tp)
            {
                price_movement += string("short ");
            }
            else
            {
                price_movement += string("ling ");
            }
        }
        void write_down_checkpoints()
        {
            price_movement += string(cp_1 + " ");
            price_movement += string(cp_2 + " ");
            price_movement += string(cp_3 + " ");
            price_movement += string(cp_4 + " ");
            price_movement += string(cp_5 + " ");
            price_movement += string(cp_6 + " ");

        }
        void write_down_sl()
        {
            price_movement += sl_close + " ";
        }
        void write_down_entry_price()
        {
            price_movement += string(entry) + " ";
        }
        string price_movement;

        string cp_1;
        string cp_2;
        string cp_3;
        string cp_4;
        string cp_5;
        string cp_6;
        string sl_close;



        string candle_ohlc;
        double check_points[6];
        double sl;
        double entry;
        double tp;
        double candles_past;
        bool is_closed;
        int id;

    private:
        void print_previous_candles(int candles_to_print)
        {
            for (int i = 0; i<candles_to_print; i++)
            {
                candle_ohlc += string(High[i]) + " ";
                candle_ohlc += string(Open[i]) + " ";
                candle_ohlc += string(Close[i]) + " ";
                candle_ohlc += string(Low[i]) + " ";
            }
        }
};

OpenTrade *open_trades_buffer [];

void init()
{
    Print("Path to a file: " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\files\\" + sub_folder + "\\" + file_name);
    if (fileHandle == 0)
    {
        fileHandle = FileOpen(sub_folder + "\\" + file_name, FILE_WRITE|FILE_CSV);
        string header = "Date Time Type Entry"
            +" CP_"+string(checkpoint_1)
            +" CP_"+string(checkpoint_2)
            +" CP_"+string(checkpoint_3)
            +" CP_"+string(checkpoint_4)
            +" CP_"+string(checkpoint_5)
            +" CP_"+string(checkpoint_6)
            +" SL";
        for(int i = 0; i<print_candles; i++)
        {
            header += " Low[" + string(i) + "]";
            header += " Open[" + string(i) + "]";
            header += " Close[" + string(i) + "]";
            header += " High[" + string(i) + "]";
        }
        header += "\n";
        FileWrite(fileHandle, header);
    }
    if(fileHandle==INVALID_HANDLE)
    {
        Print("Operation FileOpen failed, error ",GetLastError());
    } 
}

void OnDeinit(const int reason)
{
    FileClose(fileHandle);
}
void delete_open_trade(OpenTrade* &open_trades[], int i)
{
    delete open_trades[i];
    open_trades[i] = NULL;
    ArrayEraseElement(open_trades, i);
}

void process_open_trades(OpenTrade* &open_trades[])
{
    if (ArraySize(open_trades) == 0) return;
    for (int i = ArraySize(open_trades) - 1; i >= 0 ; i--)
    {
        OpenTrade *open_trade = open_trades[i];
        bool is_order_selected = OrderSelect(open_trade.id, SELECT_BY_TICKET, MODE_TRADES);
        datetime order_close_time = OrderCloseTime();
        open_trade.candles_past -= 1;
        double open_price = Ask;
        if (OrderType() == OP_BUY)
        {
            open_price = Bid;
        }

        if (is_order_selected && order_close_time != 0)
        {
            open_trade.sl_close = string("stop");
            delete_open_trade(open_trades, i);
        }
        else if (open_trade.candles_past == 0)
        {
            bool is_order_closed = OrderClose(open_trade.id, OrderLots(), open_price, 10, 0);
            delete_open_trade(open_trades, i);
        }
        else
        {
            double sl_ratio = open_trade.entry - open_trade.sl;
            double open_price_ratio = (open_price - open_trade.entry);
            string price_ratio = string(NormalizeDouble(open_price_ratio / sl_ratio, 2));
            if((candles_timeout - open_trade.candles_past) == checkpoint_1) 
                open_trade.cp_1 = price_ratio;
            else if ((candles_timeout - open_trade.candles_past) == checkpoint_2) 
                open_trade.cp_2 = price_ratio;
            else if ((candles_timeout - open_trade.candles_past) == checkpoint_3) 
                open_trade.cp_3 = price_ratio;
            else if ((candles_timeout - open_trade.candles_past) == checkpoint_4) 
                open_trade.cp_4 = price_ratio;
            else if ((candles_timeout - open_trade.candles_past) == checkpoint_5) 
                open_trade.cp_5 = price_ratio;
            else if ((candles_timeout - open_trade.candles_past) == checkpoint_6) 
                open_trade.cp_6 = price_ratio;
        }
    }
}

void OnTick()
{
    if (!is_initialized)
    {
        init();
        is_initialized = true;
    }

    if(iTime(NULL, 0, 0) == TimeCurrent())
    {
        if (stop_counter > 0)
        {
            stop_counter -= 1;
        }
        process_open_trades(open_trades_buffer);
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
            if (long_order_id > 0)
            {
                OpenTrade *open_trade = new OpenTrade(stopLossPrice, Ask, takeProfitPrice, long_order_id);
                ArrayAppendElement(open_trades_buffer, open_trade);
            }
        }
        // short
        if(RangeBreakOut(candles_lookback, last_candle_ratio, is_last_candle_complete) == -1)
        {
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*atr_multiplier, Bid),Digits);
            double takeProfitPrice = NormalizeDouble(Bid - (stopLossPrice - Bid)*risk_reward, Digits);
            double lotSize = OptimalLotSize(max_risk, Bid, stopLossPrice);
            short_order_id = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magic_number);
            stop_counter = trade_stop;

            if (short_order_id > 0)
            {
                OpenTrade *open_trade = new OpenTrade(stopLossPrice, Ask, takeProfitPrice, short_order_id);
                ArrayAppendElement(open_trades_buffer, open_trade);

            }
        }
    }
}
