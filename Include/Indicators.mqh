//+------------------------------------------------------------------+
//|                                                   Indicators.mqh |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//market meanness index smoothed

double mean(int index, int period)
{
   double Sum = 0;
   for (int i = index; i < index + period; i++)
   {
      Sum += MathAbs(Open[i]-Close[i]);
   }
   return (Sum/period);
}

double iMMI(int candlePos, int period, int smoothingPeriod)
{
   
   int nl, nh;
   double m;
   double mmiSum = 0;
         
      for(int j = candlePos; j < candlePos + smoothingPeriod; j++)
      {  
        nl = 0;
        nh = 0;
        m = mean(j, period);
        for (int i = j; i < j + period; i++)
        {
            if (Open[i] > Close[i])
            {
               if (Open[i] - Close[i] > m)
               {
                  if ((Open[i] - Close[i]) > (Open[i-1] - Close[i-1]))
                  {
                     nl++;
                  }
               }
            }
            else
            {
               if (Close[i] - Open[i] < m)
               {
                  if (Close[i] - Open[i] < Close[i-1] - Open[i-1])
                  {
                     nh++;
                  }
               }
            }
         }
      
      mmiSum += 100.0 - (100.0 * (nl + nh) / (period));
      } 
      return mmiSum / smoothingPeriod;
}

//laguerre filter

double iLaguerreFilter(int pos, int period, double gamma)
{

   int       Price_Type = 0; 
   double Filter[];
   double L0[];
   double L1[];
   double L2[];
   double L3[];


	double CU, CD;
	
		double Price=iMA(NULL,0,period,0,0,Price_Type,pos);
		
		L0[pos] = (1.0 - gamma)*Price + gamma*L0[pos+1];
		L1[pos] = -gamma*L0[pos] + L0[pos+1] + gamma*L1[pos+1];
		L2[pos] = -gamma*L1[pos] + L1[pos+1] + gamma*L2[pos+1];
		L3[pos] = -gamma*L2[pos] + L2[pos+1] + gamma*L3[pos+1];
		
		CU = 0;
		CD = 0;
		if (L0[pos] >= L1[pos])
			CU = L0[pos] - L1[pos];
		else
			CD = L1[pos] - L0[pos];
		if (L1[pos] >= L2[pos])
			CU = CU + L1[pos] - L2[pos];
		else
			CD = CD + L2[pos] - L1[pos];
		if (L2[pos] >= L3[pos])
			CU = CU + L2[pos] - L3[pos];
		else
			CD = CD + L3[pos] - L2[pos];

		if (CU + CD != 0)
			Filter[pos] = (L0[pos] + 2 * L1[pos] + 2 * L2[pos] + L3[pos]) / 6.0;
			
   return Filter[pos];
}



/*



extern int     Price             =   0;  //Price Mode (0...6)
extern int     WindowSize        =   9;  //Window Size  
extern double  Sigma             = 6.0;  //Sigma parameter 
extern double  Offset            =0.85;  //Offset of Gaussian distribution (0...1)
extern double  PctFilter         =   0;  //Dynamic filter in decimal
extern int     Shift             =   0;  //
extern int     ColorMode         =   0;  //0-on,1-off
extern int     ColorBarBack      =   1;  //
extern int     AlertMode         =   0;  //Sound Alert switch (0-off,1-on) 
extern int     WarningMode       =   0;  //Sound Warning switch(0-off,1-on) 
//---- indicator buffers
double     ALMA[];
double     Uptrend[];
double     Dntrend[];
double     trend[];
double     Del[];

int        draw_begin;
bool       UpTrendAlert=false, DownTrendAlert=false;
double     wALMA[]; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   IndicatorBuffers(5);
   SetIndexBuffer(0,ALMA);
   SetIndexBuffer(1,Uptrend);
   SetIndexBuffer(2,Dntrend);
   SetIndexBuffer(3,trend);  
   SetIndexBuffer(4,Del);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   draw_begin = WindowSize;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexShift(0,Shift);
   SetIndexShift(1,Shift);
   SetIndexShift(2,Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ALMA("+WindowSize +")");
   SetIndexLabel(0,"ALMA");
   SetIndexLabel(1,"ALMA Uptrend");
   SetIndexLabel(2,"ALMA Dntrend");
//---- 
   
   double m = MathFloor(Offset * (WindowSize - 1));
	double s = WindowSize/Sigma;
	
	ArrayResize(wALMA,WindowSize);
	double wsum = 0;		
	for (int i=0;i < WindowSize;i++) 
	{
	wALMA[i] = MathExp(-((i-m)*(i-m))/(2*s*s));
   wsum += wALMA[i];
   }
   
   for (i=0;i < WindowSize;i++) wALMA[i] = wALMA[i]/wsum; 
   
   return(0);
  }
//+------------------------------------------------------------------+
//| ALMA_v1                                                          |
//+------------------------------------------------------------------+
int start()
{
   int limit,shift,i;
   int counted_bars=IndicatorCounted();
//---- 
   if(counted_bars<1)
   {
      for(i=Bars-1;i>0;i--) 
      {
      ALMA[i]=EMPTY_VALUE; 
      Uptrend[i]=EMPTY_VALUE;
      Dntrend[i]=EMPTY_VALUE;
      }
   }
//---- 
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

//---- 
   for(shift=limit; shift>=0; shift--)
   {
    
   if (shift > Bars - WindowSize) continue; 
   
	double sum  = 0;
	double wsum = 0;
			
      for(i=0;i < WindowSize;i++) 
      {
         if (i < WindowSize) 
         {
			sum += wALMA[i] * iMA(NULL,0,1,0,0,Price,shift + (WindowSize - 1 - i)); 
			
			}
		}
		
	//if(wsum != 0) 
	ALMA[shift] = sum;

      if(PctFilter>0)
      {
      Del[shift] = MathAbs(ALMA[shift] - ALMA[shift+1]);
   
      double sumdel=0;
      for (int j=0;j<=WindowSize-1;j++) sumdel = sumdel+Del[shift+j];
      double AvgDel = sumdel/WindowSize;
    
      double sumpow = 0;
      for (j=0;j<=WindowSize-1;j++) sumpow+=MathPow(Del[j+shift]-AvgDel,2);
      double StdDev = MathSqrt(sumpow/WindowSize); 
     
      double Filter = PctFilter * StdDev;
     
      if( MathAbs(ALMA[shift]-ALMA[shift+1]) < Filter ) ALMA[shift]=ALMA[shift+1];
      }
      else
      Filter=0;
   
      
      if (ColorMode>0)
      {
         trend[shift] = trend[shift+1];
         if (ALMA[shift] - ALMA[shift+1] > Filter) trend[shift] = 1;
         if (ALMA[shift+1] - ALMA[shift] > Filter) trend[shift] =-1;
    
         if (trend[shift]>0)
         {
            Uptrend[shift] = ALMA[shift]; 
            if (trend[shift+ColorBarBack]<0) Uptrend[shift+ColorBarBack]=ALMA[shift+ColorBarBack];
            Dntrend[shift] = EMPTY_VALUE;
            if (WarningMode>0 && trend[shift+1]<0 && i==0) PlaySound("alert2.wav");
         }
         else              
         if (trend[shift]<0)
         { 
            Dntrend[shift] = ALMA[shift]; 
            if (trend[shift+ColorBarBack]>0) Dntrend[shift+ColorBarBack]=ALMA[shift+ColorBarBack];
            Uptrend[shift] = EMPTY_VALUE;
            if (WarningMode>0 && trend[shift+1]>0 && i==0) PlaySound("alert2.wav");
         }               
      }
   }      
//----------   
   string Message;
   
   if ( trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": HMA Signal for BUY";
	if ( AlertMode>0 ) Alert (Message); 
	UpTrendAlert=true; DownTrendAlert=false;
	} 
	 	  
	if ( trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": HMA Signal for SELL";
	if ( AlertMode>0 ) Alert (Message); 
	DownTrendAlert=true; UpTrendAlert=false;
	} 	         



//---- done
   return(0);
}

*/