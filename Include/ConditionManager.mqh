#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <NumberSeries.mqh>
#include <SuppResLevels.mqh>


struct ConditionCounter
{
    uint totalConditions;
    uint passedConditions;
};

class ConditionManager
{
    private:
        void ResetConditions(ConditionCounter &counter);
        void ConditionFailed(ConditionCounter &counter);
        void ConditionPassed(ConditionCounter &counter);

    public:
        ConditionManager();

        bool IsPeak(NumberSeries* numbers);
        bool IsPeak(NumberSeries* numbers, ConditionCounter &counter);
        bool IsValley(NumberSeries* numbers);  
        bool IsValley(NumberSeries* numbers, ConditionCounter &counter);  
        bool CrossUnder(NumberSeries* numbers, uint threshold);
        bool CrossUnder(NumberSeries* numbers, uint threshold, ConditionCounter &counter);
        bool CrossOver(NumberSeries* numbers, uint threshold);
        bool CrossOver(NumberSeries* numbers, uint threshold, ConditionCounter &counter);
        bool SlopeDown(NumberSeries* numbers);
        bool SlopeDown(NumberSeries* numbers, ConditionCounter &counter);       
        bool SlopeUp(NumberSeries* numbers);
        bool SlopeUp(NumberSeries* numbers, ConditionCounter &counter);
        bool MaxOrdersReached(int maxOrders); //rework, this is dumb
        bool NoTradeOpen(int magicNumber); //rework or add IsSomeTradeOpen???? this is also dumb
        bool IsLongTradeOpen(int magicNumber);
        bool IsLongTradeOpen(int magicNumber, ConditionCounter &counter);
        bool IsShortTradeOpen(int magicNumber);
        bool IsShortTradeOpen(int magicNumber, ConditionCounter &counter);
        //TODO two series numbers crossings
        //TODO IsBeloWLevel(double minDistance, uint minLevelSignificance);
        //TODO IsAboveLevel(double minDistance, uint minLevelSignificance);
        //TODO
        bool AllConditionsPassed(ConditionCounter &counter);
        double PercentageConditionsPassed(ConditionCounter &counter);
};
//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================

        void ConditionManager::ResetConditions(ConditionCounter &counter)
        {
            counter.totalConditions = 0;
            counter.passedConditions = 0;
        }
        void ConditionManager::ConditionFailed(ConditionCounter &counter)
        {
            counter.totalConditions++;
        }
        void ConditionManager::ConditionPassed(ConditionCounter &counter)
        {
            counter.passedConditions++;
            counter.totalConditions++;
        }
        ConditionManager::ConditionManager()
        {
        }
        bool ConditionManager::IsPeak(NumberSeries* numbers)
        {
            numbers.update();
            if((numbers.firstNumber < numbers.secondNumber) && (numbers.secondNumber > numbers.thirdNumber))
            {
                return true;
            }
            else           
            {
                return false;
            }
        }   
        bool ConditionManager::IsPeak(NumberSeries* numbers, ConditionCounter &counter)
        {
            if(IsPeak(numbers) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::IsValley(NumberSeries* numbers)
        {
            numbers.update();
            if((numbers.firstNumber > numbers.secondNumber) && (numbers.secondNumber < numbers.thirdNumber))
            {
                return true;
            }
            else           
            {
                return false;
            }
        }  
        bool ConditionManager::IsValley(NumberSeries* numbers, ConditionCounter &counter)
        {
            if(IsValley(numbers) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::CrossUnder(NumberSeries* numbers, uint threshold)
        {
            numbers.update();
            if(numbers.secondNumber > threshold &&  numbers.thirdNumber < threshold )
            {
                return true;
            }
            else           
            {
                return false;
            }
        }
        bool ConditionManager::CrossUnder(NumberSeries* numbers, uint threshold, ConditionCounter &counter)
        {
            numbers.update();
            if(CrossUnder(numbers, threshold) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::CrossOver(NumberSeries* numbers, uint threshold)
        {
            numbers.update();
            if(numbers.secondNumber < threshold &&  numbers.thirdNumber > threshold )
            {
                return true;
            }
            else           
            {
                return false;
            }
        }
        bool ConditionManager::CrossOver(NumberSeries* numbers, uint threshold, ConditionCounter &counter)
        {
            if(CrossOver(numbers, threshold) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::SlopeDown(NumberSeries* numbers)
        {
            numbers.update();
            if(numbers.firstNumber < numbers.secondNumber &&  numbers.secondNumber < numbers.thirdNumber )
            {
                return true;
            }
            else           
            {
                return false;
            }
        }
        bool ConditionManager::SlopeDown(NumberSeries* numbers, ConditionCounter &counter)
        {
            if(SlopeDown(numbers) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::SlopeUp(NumberSeries* numbers)
        {
            numbers.update();
            if(numbers.firstNumber > numbers.secondNumber &&  numbers.secondNumber > numbers.thirdNumber )
            {    
                return true;
            }
            else
            {
                return false;
            }
        }
        bool ConditionManager::SlopeUp(NumberSeries* numbers, ConditionCounter &counter)
        {
            if(SlopeUp(numbers) == true)
            {
                ConditionPassed(counter);
                return true;                
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::NoTradeOpen(int magicNumber)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == magicNumber) 
                    {
                        return false;
                    }  
                }
            }
            return true;
        }
        bool ConditionManager::AllConditionsPassed(ConditionCounter &counter)
        {
            Print("Passed conditions: " + string(counter.passedConditions) + " Total conditions: " + string(counter.totalConditions));
            if(counter.passedConditions == counter.totalConditions && counter.totalConditions != 0)
            {
                ResetConditions(counter);
                return true;
            }
            else
            {
                ResetConditions(counter);
                return false;
            } 
        }
        double ConditionManager::PercentageConditionsPassed(ConditionCounter &counter)
        {
            if(counter.totalConditions != 0 && counter.passedConditions != 0)
            {
                double percentage = counter.passedConditions / counter.totalConditions;
                counter.totalConditions = 0;
                counter.passedConditions = 0;
                return percentage;
            }    
            else 
                return 0;
        }
        bool ConditionManager::IsLongTradeOpen(int magicNumber)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == magicNumber && OrderType() == 0) 
                    {
                        return true;
                    }  
                }
            }
            return false;
        }
        bool ConditionManager::IsLongTradeOpen(int magicNumber, ConditionCounter &counter)
        {
            if(IsLongTradeOpen(magicNumber) == true)
            {
                ConditionPassed(counter);
                return true;
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::IsShortTradeOpen(int magicNumber)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == magicNumber && OrderType() == 1) 
                    {
                        return true;
                    }  
                }
            }
            return false;
        }
        bool ConditionManager::IsShortTradeOpen(int magicNumber, ConditionCounter &counter)
        {
            if(IsShortTradeOpen(magicNumber) == true)
            {
                ConditionPassed(counter);
                return true;
            }
            else
            {
                ConditionFailed(counter);
                return false;
            }
        }
        bool ConditionManager::MaxOrdersReached(int maxOrders)
        {
            if(OrdersTotal() < maxOrders)
            {
                
                return false;
            }
            else
                return true;
        }
