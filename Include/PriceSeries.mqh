#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict


class NumberSeries
{
    //EMA
    //STOCHA
    //RSI
    public: 
        double firstNumber;
        double secondNumber;
        double thirdNumber;
        virtual void update();
};



class SimpleMA : private NumberSeries
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



class Stochastics
{

};
