#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <NumberSeries.mqh>

//TODO cross threshold
//TODO cross 

class ConditionManager
{
    private:
        uint passedConditions;
        uint totalConditions;

    public:
        ConditionManager();

        bool IsPeak(NumberSeries* numbers);
        bool IsValley(NumberSeries* numbers);  
        double PercentageConditionsPassed();
        bool CrossUnder(NumberSeries* numbers, uint threshold);
        bool CrossOver(NumberSeries* numbers, uint threshold);
        bool SlopeDown(NumberSeries* numbers);
        bool SlopeUp(NumberSeries* numbers);
        bool MaxOrdersReached(int maxOrders); //rework, this is dumb
        bool NoTradeOpen(int magicNumber);
        bool AllConditionsPassed();
};
//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================

        ConditionManager::ConditionManager()
        {
            passedConditions = 0;
            totalConditions = 0; 
        }
        bool ConditionManager::IsPeak(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if((numbers.firstNumber < numbers.secondNumber) && (numbers.secondNumber > numbers.thirdNumber))
            {
                passedConditions++;
                return true;
            }
            else 
                return false;
        }   
        bool ConditionManager::IsValley(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if((numbers.firstNumber > numbers.secondNumber) && (numbers.secondNumber < numbers.thirdNumber))
            {
                passedConditions++;
                return true;
            }
            else 
                return false;

        }  
        bool ConditionManager::CrossUnder(NumberSeries* numbers, uint threshold)
        {
            numbers.update();
            totalConditions++;
            if(numbers.secondNumber > threshold &&  numbers.thirdNumber < threshold )
            {
                passedConditions++;
                return true;
            }
            else
                return false;


        }
        bool ConditionManager::CrossOver(NumberSeries* numbers, uint threshold)
        {
            numbers.update();
            totalConditions++;
            if(numbers.secondNumber < threshold &&  numbers.thirdNumber > threshold )
            {
                passedConditions++;
                return true;
            }
            else
                return false;
        }
        bool ConditionManager::SlopeDown(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if(numbers.firstNumber < numbers.secondNumber &&  numbers.secondNumber < numbers.thirdNumber )
            {
                passedConditions++;
                return true;
            }
            else
                return false;

        }
        bool ConditionManager::SlopeUp(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if(numbers.firstNumber > numbers.secondNumber &&  numbers.secondNumber > numbers.thirdNumber )
            {
                passedConditions++;
                return true;
            }
            else
                return false;

        }
        bool ConditionManager::NoTradeOpen(int magicNumber)
        {
            totalConditions++;
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
            passedConditions++;
            return true;
        }
        bool ConditionManager::AllConditionsPassed()
        {
            //Print("Passed conditions: " + string(passedConditions) + " Total conditions: " + string(totalConditions));
            if(passedConditions == totalConditions && totalConditions != 0)
            {
                passedConditions = 0;
                totalConditions = 0;
                return true;
            }
            else
            {
                passedConditions = 0;
                totalConditions = 0;
                return false;
            } 
        }
        double ConditionManager::PercentageConditionsPassed()
        {
            if(totalConditions != 0 && passedConditions != 0)
            {
                double percentage = passedConditions / totalConditions;
                totalConditions = 0;
                passedConditions = 0;
                return percentage;
            }    
            else 
                return 0;
        }
        bool ConditionManager::MaxOrdersReached(int maxOrders)
        {
            totalConditions++;
            if(OrdersTotal() < maxOrders)
            {
                passedConditions++;
                return false;
            }
            else
                return true;
        }