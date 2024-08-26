
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

//download all OHLC, time and volume data to CSV

datetime lastActionTime = 0;
string file_name = string(Symbol() + "_" + EnumToString(ENUM_TIMEFRAMES(_Period)) + "_pricedata.csv");
string sub_folder = "history";

int fileHandle;

int OnInit()
{
    Print("Path to a file: " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\files\\" + sub_folder + "\\" + file_name);
    fileHandle = FileOpen(sub_folder + "\\" + file_name, FILE_WRITE|FILE_CSV);
    if(fileHandle!=INVALID_HANDLE)
    {
        FileWrite(fileHandle,"Date, Time, Open, High, Low, Close, Volume");
    }
    else Print("Operation FileOpen failed, error ",GetLastError());
    return(INIT_SUCCEEDED);
}

void OnTick()
{
    if (lastActionTime != Time[0])
    {
        if(fileHandle!=INVALID_HANDLE)
        {
            FileWrite(fileHandle, Time[1], Open[1], High[1], Low[1], Close[1], Volume[1]);
        }
    else Print("Operation FileOpen failed, error ",GetLastError());
    }
}

void OnDeinit(const int reason)
{
    FileClose(fileHandle);
}