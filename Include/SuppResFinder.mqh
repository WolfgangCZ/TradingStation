#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <FunctionTemplates.mqh>

struct Extreme
{
    double price;
    datetime time;
    uint candle;
    bool isSupport;
};

class SuppResFinder
{
    private:
        
        Extreme suppResContainer[];
        uint lookbackPeriod;
        uint extremeSideWidth;
        uint extremeWidth;
        uint uncheckedCandles;

    public:
        SuppResFinder();
        ~SuppResFinder();
        
        void UpdateAllLevels();
        void UpdateRecentLevels();

        double GetLastSuppLevel();
        double GetLastResLevel();        
        double GetLevelByCandle(uint pos);
        double GetLevelByTime(datetime time);
        
        void ClearContainer();

};

//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================

SuppResFinder::SuppResFinder()
{
    extremeWidth = extremeSideWidth*2 + 1;
}

SuppResFinder::~SuppResFinder()
{
}

void SuppResFinder::UpdateAllLevels()
{
    if(extremeSideWidth%2 == 0) extremeSideWidth += 1;
    for(uint i = extremeSideWidth + 1; i < lookbackPeriod; i++)
    {
        double isMiddleHighest = true;
        double isMiddleLowest = true;
        for(uint j = -extremeSideWidth; j < extremeSideWidth + 1; j++)
        {
            if(j == 0) continue;   

            if(High[i+j] >= High[i])
            {
                isMiddleHighest = false;
            }
            if(Low[i+j] <= Low[i])
            {
                isMiddleLowest = false;
            }
        }
        if(isMiddleHighest == true)
        {
            //TODO change support or resistance based on current price not based on top or bottom 
            Extreme extreme;
            extreme.isSupport = false;
            extreme.candle = i;
            extreme.price = High[i];
            extreme.time = Time[i];        
            Alert("Top found at candle: " + string(extreme.candle) + " with price of: " + string(extreme.price));
            AppendElement(suppResContainer, extreme);
        }
        if(isMiddleLowest == true)
        {

            Extreme extreme;
            extreme.isSupport = true;
            extreme.candle = i;
            extreme.price = Low[i];
            extreme.time = Time[i];        
            Alert("Bottom found at: " + string(extreme.candle) + " with price of: " + string(extreme.price));
            AppendElement(suppResContainer, extreme);
        }
    }
}
void SuppResFinder::UpdateRecentLevels()
{
}

double SuppResFinder::GetLastSuppLevel()
{
    return 0;
}
double SuppResFinder::GetLastResLevel()
{
    return 0;
}
double SuppResFinder::GetLevelByCandle(uint pos)
{
    return 0;
}
double SuppResFinder::GetLevelByTime(datetime time)
{
    return 0;
}
void SuppResFinder::ClearContainer()
{
}