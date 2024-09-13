
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
int ring_index = 0;

datetime last_action_time = 0;
string file_name = "range_breakout.csv";
string sub_folder = "history";
int trade_stop = 5;
int stop_counter = 0;
const int buffer_size = 200;

int fileHandle;
bool is_initialized = false;

class OpenTrade
{
    public:
        OpenTrade(){}
        OpenTrade(double stoploss, double entry_price, double target, int ticket_id)
        {
            sl = stoploss;
            entry = entry_price;
            tp = target;
            candles_past = print_candles;
            id = ticket_id;
            is_closed = false;
        }

        double check_points[6];
        double sl;
        double entry;
        double tp;
        double candles_past;
        bool is_closed;
        int id;
};

template <typename T>
class DArray
{
    T array[];
    int m_length;
    int m_capacity;

    public:
        DArray(int length)
        {
            resize(m_capacity);
            m_length = length;
            m_capacity = length;
        }
        int length()
        {
            return m_length;
        }
        void append(T &object)
        {
            m_capacity *= 2 + 1;
            if (m_length == m_capacity)
            {
                resize(m_capacity);
            }
            array[m_length] = object;
            m_length++;
        }
        T *operator [](const int index)
        {
            return &array[index];
        }
        void remove(int index)
        {
            if (index < 0 || index >= m_length)
            {
                return;
            }
            m_length--;
            for (int i = index; i < m_length; i++)
            {
                array[i] = array[i + 1];
            }
        }
    private:
        void resize(int new_capacity)
        {
            ArrayResize(array, new_capacity, 1000);
        }
};

DArray<OpenTrade> *open_trades;

int init()
{
    Print("asfasdfasdfsfl;asdfjl;asdjkfl;asdkfj;asldkfj");
    Print("Path to a file: " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\files\\" + sub_folder + "\\" + file_name);
    fileHandle = FileOpen(sub_folder + "\\" + file_name, FILE_WRITE|FILE_CSV);
    if(fileHandle!=INVALID_HANDLE)
    {
        string header = "Time Type"
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

    open_trades = new DArray<OpenTrade>(buffer_size);

    return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason)
{
    FileClose(fileHandle);
}

void process_open_trades(DArray<OpenTrade> *trades)
{

    for (int i = 0; i < trades.length(); i++)
    {
        trades[i].candles_past -= 1;
    }
}

void OnTick()
{
    if (!is_initialized)
    {
        init();
        is_initialized = true;
    }

    if (last_action_time != Time[0])
    {
        if (stop_counter > 0)
        {
            stop_counter -= 1;
        }

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

            OpenTrade open_trade = new OpenTrade(stopLossPrice, Ask, takeProfitPrice, long_order_id);
            open_trades.append(open_trade);
        }
        // short
        if(RangeBreakOut(candles_lookback, last_candle_ratio, is_last_candle_complete) == -1)
        {
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR*atr_multiplier, Bid),Digits);
            double takeProfitPrice = NormalizeDouble(Bid - (stopLossPrice - Bid)*risk_reward, Digits);
            double lotSize = OptimalLotSize(max_risk, Bid, stopLossPrice);
            short_order_id = OrderSend(NULL, OP_SELL, lotSize, Bid, 10, stopLossPrice, takeProfitPrice, NULL, magic_number);
            stop_counter = trade_stop;

            OpenTrade open_trade = new OpenTrade(stopLossPrice, Ask, takeProfitPrice, short_order_id);
            open_trades.append(open_trade);
        }
    }
}
