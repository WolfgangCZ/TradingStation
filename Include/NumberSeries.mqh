#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

//numbers are meant in oposite direction aka third number is "visually" on the left and first number is "visually" on the right
//this is because third number is third candle from current candle to the left, and first is last closed candle

class NumberSeries
{
    //EMA   
    //STOCHA
    //RSI
    public: 
        double firstNumber;
        double secondNumber;
        double thirdNumber;
        virtual void update()
        {}
};



class SimpleMA : public NumberSeries
{   
    public:  
        SimpleMA(uint inputPeriod)
        {
            period = inputPeriod;
        }      

        virtual void update() override
        {
            firstNumber = iMA(NULL, NULL, period, 0, 0, 4, 1);
            secondNumber = iMA(NULL, NULL, period, 0, 0, 4, 2);
            thirdNumber = iMA(NULL, NULL, period, 0, 0, 4, 3);
        }

    private:
        uint period;
};



class Stochastics : public NumberSeries
{
    public:
        Stochastics(uint inputKPeriod, uint inputDPeriod, uint inputSlowing)
        {
           kPeriod = inputKPeriod; 
           dPeriod = inputDPeriod; 
           slowing = slowing; 
        }   

        virtual void update()
        {
            firstNumber = iStochastic(NULL, NULL, kPeriod, dPeriod, slowing, 1, 0, 0, 1);
            secondNumber = iStochastic(NULL, NULL, kPeriod, dPeriod, slowing, 1, 0, 0, 2);
            thirdNumber = iStochastic(NULL, NULL, kPeriod, dPeriod, slowing, 1, 0, 0, 3);
        }
    private:
        uint kPeriod;
        uint dPeriod;
        uint slowing;
};
