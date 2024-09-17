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

class SuppResLevels
{
    private:
        
        Extreme suppResContainer[];
        uint lookbackPeriod;
        uint extremeSideWidth;
        uint extremeWidth;
        uint uncheckedCandles;

    public:
        SuppResLevels();
        ~SuppResLevels();

        void UpdateUncheckedCandles();
        void UpdateLevelInRange(uint startCandlePos, uint endCandlePos);        
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

void SuppResLevels::UpdateUncheckedCandles()
{
    uncheckedCandles++;
}
SuppResLevels::SuppResLevels()
{
    extremeWidth = extremeSideWidth*2 + 1;
}

SuppResLevels::~SuppResLevels()
{
}

//TODO passing some argument so the update is viable for any period?
void SuppResLevels::UpdateLevelInRange(uint startCandlePos, uint endCandlePos)
{
    uncheckedCandles = startCandlePos;
    if(extremeSideWidth%2 == 0) extremeSideWidth += 1;
    for(uint i = extremeSideWidth + startCandlePos; i < endCandlePos; i++)
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
            ArrayAppendElement(suppResContainer, extreme);
        }
        if(isMiddleLowest == true)
        {

            Extreme extreme;
            extreme.isSupport = true;
            extreme.candle = i;
            extreme.price = Low[i];
            extreme.time = Time[i];        
            Alert("Bottom found at: " + string(extreme.candle) + " with price of: " + string(extreme.price));
            ArrayAppendElement(suppResContainer, extreme);
        }       
    }
}
void SuppResLevels::UpdateAllLevels()
{
    UpdateLevelInRange(1, lookbackPeriod);
}
void SuppResLevels::UpdateRecentLevels()
{
    if (uncheckedCandles > extremeWidth)
        UpdateLevelInRange(1, uncheckedCandles);
}

double SuppResLevels::GetLastSuppLevel()
{
    return 0;
}
double SuppResLevels::GetLastResLevel()
{
    return 0;
}
double SuppResLevels::GetLevelByCandle(uint pos)
{
    return 0;
}
double SuppResLevels::GetLevelByTime(datetime time)
{
    return 0;
}
void SuppResLevels::ClearContainer()
{
}