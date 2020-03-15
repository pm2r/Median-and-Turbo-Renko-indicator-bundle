//
// Copyright 2017-2020, Artur Zas
// https://www.az-invest.eu 
// https://www.mql5.com/en/users/arturz
//

#property copyright "Copyright 2017-2020, Artur Zas"
#property link      "https://www.az-invest.eu"
#property version   "1.11"
#property description "Example EA showing the way to use the MedianRenko class defined in MedianRenko.mqh" 
#property description "as well as external indicators attached to the RenkoCharts" 

input int InpRSIPeriod=14; // RSI Period

//
// SHOW_INDICATOR_INPUTS *NEEDS* to be defined, if the EA needs to be *tested in MT5's backtester*
// -------------------------------------------------------------------------------------------------
// Using '#define SHOW_INDICATOR_INPUTS' will show the MedianRenko indicator's inputs 
// NOT using the '#define SHOW_INDICATOR_INPUTS' statement will read the settigns a chart with 
// the MedianRenko indicator attached.
//

#define SHOW_INDICATOR_INPUTS

//
// You need to include the MedianRenko.mqh header file
//

#include <AZ-INVEST/SDK/MedianRenko.mqh>
//
//  To use the MedainRenko indicator in your EA you need do instantiate the indicator class (MedianRenko)
//  and call the Init() method in your EA's OnInit() function.
//  Don't forget to release the indicator when you're done by calling the Deinit() method.
//  Example shown in OnInit & OnDeinit functions below:
//

MedianRenko    *medianRenko   = NULL;
int            RsiHandle      = -1;

double         RsiBuffer[];            // This array will store the RSI values for the renko chart
MqlRates       RenkoRatesInfoArray[];  // This array will store the MqlRates data for renkos

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(medianRenko == NULL)
       medianRenko = new MedianRenko(MQLInfoInteger((int)MQL5_TESTING) ? false : true);

   medianRenko.Init();
   if(medianRenko.GetHandle() == INVALID_HANDLE)
      return(INIT_FAILED);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   medianRenko.Deinit();

   // 
   // delete MedianRenko class
   //
   
   if(medianRenko != NULL)
   {
      delete medianRenko;
      medianRenko = NULL;
   }   

   //
   //  your custom code goes here...
   //
}

//
//  At this point you may use the renko data fetching methods in your EA.
//  Brief demonstration presented below in the OnTick() function:
//

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //
   // Initialize all additional indicators here! (not in the OnInit() function).
   // Otherwise they will not work in the backtest.
   // When backtesting please select the "Daily" timeframe.
   //
   
   if(RsiHandle == INVALID_HANDLE)
   {
      RsiHandle = iCustom(_Symbol, _Period, "MedianRenko\\MedianRenko_RSI", InpRSIPeriod, true);
   }

   //
   // It is considered good trading & EA coding practice to perform calculations
   // when a new bar is fully formed. 
   // The IsNewBar() method is used for checking if a new renko bar has formed 
   //
   
   if(medianRenko.IsNewBar())
   {
      if(RsiHandle != INVALID_HANDLE)
      {
         int startAtBar = 0;   // get value starting from the most current (uncompleted) bar.
         int numberOfBars = 3; // gat a total of 3 values (for the 3 latest bars)
        
         //
         // Read MqlRates for renko and use the time stams for the output of RSI values
         //

         if(!medianRenko.GetMqlRates(RenkoRatesInfoArray,startAtBar,numberOfBars))
         {
            Print("Error getting MqlRates");
            return;
         }
                
         //
         // Populate the RsiBuffer with RSI values (data buffer 0 of the RSI indicator) of the last 3 bars
         //

         if(CopyBuffer(RsiHandle,0,startAtBar,numberOfBars,RsiBuffer)<=0)
         {
            Print("Getting RsiBuffer is failed! Error",GetLastError());
            return;
         }
         
         //
         //  Set the buffer indexing to timeseries which will be inline with the indexing of the RenkoRatesInfoArray
         //
         
         ArraySetAsSeries(RsiBuffer,true);
         
         //
         // Output the RSI values to the log file
         //
         
         Print("RsiBuffer["+(string)RenkoRatesInfoArray[0].time+"] = "+DoubleToString(RsiBuffer[0],_Digits)+
             ", RsiBuffer["+(string)RenkoRatesInfoArray[1].time+"] = "+DoubleToString(RsiBuffer[1],_Digits)+
             ", RsiBuffer["+(string)RenkoRatesInfoArray[2].time+"] = "+DoubleToString(RsiBuffer[2],_Digits));
      }  
   } 
}
