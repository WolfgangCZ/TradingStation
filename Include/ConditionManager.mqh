#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <SuppResLevels.mqh>
#include <NumberSeries.mqh>


struct ConditionCounter
{
    uint totalConditions;
    uint passedConditions;
};

class ConditionManager
{
    private:
        ConditionCounter conditionCounter;
        void ConditionFailed();
        void ConditionPassed();

    public:
        ConditionManager();
        void ResetConditions();
        //TODO rewrite to userinput manager
        bool IsPeak(NumberSeries* numbers);
        bool IsValley(NumberSeries* numbers);  
        bool CrossUnder(NumberSeries* numbers, UserInputManager *userParameters);
        bool CrossOver(NumberSeries* numbers, UserInputManager *userParameters);
        bool SlopeUp(NumberSeries* numbers);
        bool SlopeDown(NumberSeries* numbers);

        bool MaxOrdersNotReached(UserInputManager *userParameters); //rework, this is dumb
        bool MaxOrdersReached(UserInputManager *userParameters);
        bool NoTradeOpen(UserInputManager *userParameters); //rework or add IsSomeTradeOpen???? this is also dumb
        bool NoLongTradeOpen(UserInputManager *userParameters);
        bool NoShortTradeOpen(UserInputManager *userParameters);
        bool IsLongTradeOpen(UserInputManager *userParameters);
        bool IsShortTradeOpen(UserInputManager *userParameters);

        //TODO two series numbers crossings
        //TODO IsBeloWLevel(double minDistance, uint minLevelSignificance);
        //TODO IsAboveLevel(double minDistance, uint minLevelSignificance);
        bool AllConditionsPassed();
        double PercentageConditionsPassed();
};
//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================
        ConditionManager::ConditionManager()
        {
            conditionCounter.passedConditions = 0;
            conditionCounter.totalConditions = 0;
        }


        void ConditionManager::ResetConditions()
        {
            conditionCounter.totalConditions = 0;
            conditionCounter.passedConditions = 0;
        }
        void ConditionManager::ConditionFailed()
        {
            conditionCounter.totalConditions++;
        }
        void ConditionManager::ConditionPassed()
        {
            conditionCounter.passedConditions++;
            conditionCounter.totalConditions++;
        }
        bool ConditionManager::IsPeak(NumberSeries* numbers)
        {
            numbers.update();
            if((numbers.firstNumber < numbers.secondNumber) && (numbers.secondNumber > numbers.thirdNumber))
            {
                ConditionPassed();
                return true;
            }
            else           
            {
                ConditionFailed();
                return false;
            }
        }   
        bool ConditionManager::IsValley(NumberSeries* numbers)
        {
            numbers.update();
            if((numbers.firstNumber > numbers.secondNumber) && (numbers.secondNumber < numbers.thirdNumber))
            {
                ConditionPassed();
                return true;
            }
            else           
            {
                ConditionFailed();
                return false;
            }
        }  
        bool ConditionManager::CrossUnder(NumberSeries* numbers, UserInputManager *userParameters)
        {
            numbers.update();
            if(numbers.secondNumber > userParameters.threshold &&  numbers.thirdNumber < userParameters.threshold )
            {
                ConditionPassed();
                return true;
            }
            else           
            {
                ConditionFailed();
                return false;
            }
        }
        bool ConditionManager::CrossOver(NumberSeries* numbers, UserInputManager *userParameters)
        {
            numbers.update();
            if(numbers.secondNumber < userParameters.threshold &&  numbers.thirdNumber > userParameters.threshold )
            {
                ConditionPassed();
                return true;
            }
            else           
            {
                ConditionFailed();
                return false;
            }
        }
        bool ConditionManager::SlopeDown(NumberSeries* numbers)
        {
            numbers.update();
            if(numbers.firstNumber < numbers.secondNumber &&  numbers.secondNumber < numbers.thirdNumber )
            {
                ConditionPassed();
                return true;
            }
            else           
            {
                ConditionFailed();
                return false;
            }
        }
        bool ConditionManager::SlopeUp(NumberSeries* numbers)
        {
            numbers.update();
            if(numbers.firstNumber > numbers.secondNumber &&  numbers.secondNumber > numbers.thirdNumber )
            {    
                ConditionPassed();
                return true;
            }
            else
            {
                ConditionFailed();
                return false;
            }
        }
        bool ConditionManager::NoTradeOpen(UserInputManager *userParameters)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == userParameters.magicNumber) 
                    {
                        return false;
                    }  
                }
            }
            return true;
        }
        bool ConditionManager::AllConditionsPassed()
        {
            Print("Passed conditions: " + string(conditionCounter.passedConditions) + " Total conditions: " + string(conditionCounter.totalConditions));
            if(conditionCounter.passedConditions == conditionCounter.totalConditions && conditionCounter.totalConditions != 0)
            {
                ResetConditions();
                return true;
            }
            else
            {
                ResetConditions();
                return false;
            } 
        }
        double ConditionManager::PercentageConditionsPassed()
        {
            if(conditionCounter.totalConditions != 0 && conditionCounter.passedConditions != 0)
            {
                double percentage = conditionCounter.passedConditions / conditionCounter.totalConditions;
                conditionCounter.totalConditions = 0;
                conditionCounter.passedConditions = 0;
                return percentage;
            }    
            else 
                return 0;
        }
        bool ConditionManager::NoLongTradeOpen(UserInputManager *userParameters)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == userParameters.magicNumber && OrderType() == 0) 
                    {
                        ConditionFailed();
                        return false;
                    }  
                }
            }
            ConditionPassed();
            return true;
        }
        bool ConditionManager::NoShortTradeOpen(UserInputManager *userParameters)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == userParameters.magicNumber && OrderType() == 1) 
                    {
                        ConditionFailed();
                        return false;
                    }  
                }
            }
            ConditionPassed();
            return true;
        }
        bool ConditionManager::IsShortTradeOpen(UserInputManager *userParameters)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == userParameters.magicNumber && OrderType() == 1) 
                    {
                        ConditionPassed();
                        return true;
                    }  
                }
            }
            ConditionFailed();
            return false;
        }
        bool ConditionManager::IsLongTradeOpen(UserInputManager *userParameters)
        {
            int openOrders = OrdersTotal();
            for(int i = 0; i < openOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    if(OrderMagicNumber() == userParameters.magicNumber && OrderType() == 0) 
                    {
                        ConditionPassed();
                        return true;
                    }  
                }
            }
            ConditionFailed();
            return false;
        }

        bool ConditionManager::MaxOrdersNotReached(UserInputManager *userParameters)
        {
            if(OrdersTotal() < userParameters.maxOpenTrades)
            {
                ConditionPassed();
                return true;
            }
            else
            {
                ConditionFailed();
                return false;
            }
        }
        bool ConditionManager::MaxOrdersReached(UserInputManager *userParameters)
        {
            if(OrdersTotal() < userParameters.maxOpenTrades)
            {
                ConditionFailed();
                return false;
            }
            else
            {
                ConditionPassed();
                return true;
            }
        }

