//+------------------------------------------------------------------+
//|                                                    Mierda-EA.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Raul Canessa"
#property link      "https://www.tecnicasdetrading.com"
#property version   "1.00"
#property strict
#property description "EA creado con fines ilustrativos. "
                      "Si tienen interés en automatizar sus estrategias "
                      "o crear un indicador técnico personalizado pueden contactarnos al correo rcanessa@gmail.com. "
                      
                      "Más información en www.tecnicasdetrading.com"
//Variables inidicales del Expert Advisor
extern double Lotes       =0.01;     //Tamaño de posición fijo
extern double Porc_Libre  =0.07;    // Tamaño lote x Porcentaje de margen libre
extern double Riesgo =0;               //Tamaño de lote x Riesgo por trade

extern double RE          =10;      //Periodo cálculo Relación Eficiencia
extern double EMA1        =2;       //EMA rápida
extern double EMA2        =30;      //EMA lenta
extern int CCI         =5;       //Periodo del CCI
extern bool Stop1=false;         //Stop loss & Take Profit fijos
extern bool Stop2=false;         //Stop loss basado en KAMA
 
bool Funcion=true;                    //Variable para definir si el EA funcionará
string Simbolo;                       // Nombre del instrumento
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Funcion de desinicializacion del EA                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Función de ejecución en cada tick                                |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Variables principales para el funcionamiento del EA
   int
   Total,                           // Número de órdenes en el simbolo
   TipoOrden=-1,                    // Tipo de la orden seleccionada (B=0,S=1)
   Ticket=0;                        // Número de orden
   double
   KAMA1,                           // Valor 1 del indicador KAMA
   KAMA2,                           // Valor 2 del indicador KAMA
   KAMA3,                           // Valor 3 del indicador KAMA
   KAMA4,                           // Valor 4 del indicador KAMA
   KAMA5,                           // Valor 5 del indicador KAMA
   KAMA6,                           // Valor 6 del indicador KAMA
   KAMA7,                           // Valor 7 del indicador KAMA
   KAMA8,                           // Valor 8 del indicador KAMA
   KAMA9,                           // Valor 9 del indicador KAMA
   KAMA10,                          // Valor 10 del indicador KAMA
   Lote=0,                          // Número de lotes en la orden seleccionada
   Num_Lotes,                       // Número de lotes en la orden abierta
   Min_Lote,                        // Monto mínimo de lotes
   Incremento,                      // Incremento del tamaño del lote
   M_Libre,                         //Margen libre actual
   Un_Lote,                         // Precio de un lote
   Precio,                          // Precio de una orden seleccionada
   stop_loss=0,                     //take profit órdenes nuevas
   take_profit=0,                   //stop loss órdenes nuevas
   SL,                              // Stop loss de orden seleccionada
   TP;                              // TP de orden seleccionada
   bool
   Cierre_orden=false,              // Respuesta del servidor ante cierre de orden
   Cierre_C=false,                  // Criterio para cierre de compra
   Cierre_V=false,                  // Criterio para cierre de venta
   Abrir_C=false,                   // Criterio para apertura de compra
   Abrir_V=false;                   // Criterio para apertura de venta
  //------------------------------------------------------------------------------------- 
  //Procesamiento preliminar
   if(Bars < 100)                       // No hay barras suficientes para ejecución de EA
     {
      Alert("No hay suficientes barras en la ventana. EA no funciona.");
      return;                                   // Salida de función OnTick()
     }
   if(Funcion==false)                              // Error crítico
     {
      Alert("Error crítico. EA no funciona.");
      return;                                   // Salida de función OnTick()
     }  
  //-------------------------------------------------------------------------------------
  //Conteo de órdenes
   Simbolo=Symbol();                               // Nombre del activo en que opera el EA
   Total=0;                                        // Número de órdenes
   for(int i=1; i<=OrdersTotal(); i++)          // Ciclo de análisis de órdenes
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // Si hay una orden activa o pendiente
        {                                       // Análisis de las órdenes:
         if (OrderSymbol()!=Simbolo)continue;   // La posición fue abierta en otro mercado
         if (OrderType()>1)                     // Orden pendiente detectada
           {
            Alert("Orden pendiente detectada. EA no se ejecuta.");
            return;                             //  Salida de función OnTick()
           }
         Total++;                               // Counter of market orders
         if (Total>1)                           // Si hay más de una orden de mercado
           {
            Alert("Varias órdenes de mercado abiertas. EA no se ejecuta.");
            return;                             //  Salida de función OnTick()
           }
         Ticket=OrderTicket();                  // Número de orden seleccionada
         TipoOrden=OrderType();                 // Tipo de orden seleccionada
         Precio=OrderOpenPrice();               // Precio de orden seleccionada
         SL=OrderStopLoss();                    // Stop loss de orden seleccionada
         TP=OrderTakeProfit();                  // Take profit de orden seleccionada
         Lote=OrderLots();                 // Número de lotes de la orden
        }
     }   
  //-----------------------------------------------------------------------------------
  //Criterio de apertura de posiciones
   KAMA1=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,0); //Valor del KAMA en la barra 0
   KAMA2=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,1); //Valor del KAMA en la barra 1
   KAMA3=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,2); //Valor del KAMA en la barra 2
   KAMA4=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,3); //Valor del KAMA en la barra 3
   KAMA5=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,4); //Valor del KAMA en la barra 4
   KAMA6=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,5); //Valor del KAMA en la barra 5
   KAMA7=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,6); //Valor del KAMA en la barra 6
   KAMA8=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,7); //Valor del KAMA en la barra 7
   KAMA9=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,8); //Valor del KAMA en la barra 8
   KAMA10=iCustom(NULL,0,"KAMA",RE,EMA1,EMA2,0,9); //Valor del KAMA en la barra 9
   if (KAMA9>KAMA10&&KAMA8>KAMA9&&KAMA7>KAMA8&&KAMA6>KAMA7&&
   KAMA5>KAMA6&&KAMA4>KAMA5&&KAMA3>KAMA4&&KAMA2>KAMA3&&KAMA1>KAMA2&&iCCI(Symbol(),0,CCI,PRICE_CLOSE,0)<=-100)   // Condiciones para apertura de posición de compra
     {                                          
      Abrir_C=true;                               //Apertura de posición de compra
      Cierre_V=true;                               //Cierre de posición de venta
     }
   if (KAMA9<KAMA10&&KAMA8<KAMA9&&KAMA7<KAMA8&&KAMA6<KAMA7&&
   KAMA5<KAMA6&&KAMA4<KAMA5&&KAMA3<KAMA4&&KAMA2<KAMA3&&KAMA1<KAMA2&&iCCI(Symbol(),0,CCI,PRICE_CLOSE,0)>=+100)  // Condiciones para apertura de posición de venta
     {                                          
      Abrir_V=true;                               //Apertura de posición de venta
      Cierre_C=true;                               //Cierre de posición de compra
     }
  //-------------------------------------------------------------------------------------

  //-------------------------------------------------------------------------------------
  //Código para el cálculo del valor del tamaño de las nuevas órdenes
   RefreshRates();                              //Obtención de nuevos precios
   Min_Lote=MarketInfo(Simbolo,MODE_MINLOT);     //Número mínimo de lotes
   M_Libre=AccountFreeMargin();                 //Margen libre actual
   Un_Lote=MarketInfo(Simbolo,MODE_MARGINREQUIRED);  //Precio de 1 lote en el simbolo actual
   Incremento=MarketInfo(Simbolo,MODE_LOTSTEP);     //Incremento mínimo de tamaño de lote
   if (Lotes > 0)                                //Si el tamaño de lote esta fijado desde el inicio,
      Num_Lotes =Lotes;                          //operar con él
   else                                         // o calcular el tamaño de lote con base en el margen libre
      Lotes=MathFloor(M_Libre*Porc_Libre/Un_Lote/Incremento)*Incremento;// Lotes para la apertura de la posición
 
   if(Lotes<Min_Lote) Lotes=Min_Lote;               //El tamaño del lote no puede ser menor al lote mínimo del broker
   if(Lotes*Un_Lote > M_Libre)                    //Tamaño de lote mayor que el margen actual. Posición no puede abrirse
     {
      Alert("No hay suficientes fondos para abrir ", Lotes," lotes");
      return;                                  // Salida de Ontick() para corregir errores
     } 
  //-------------------------------------------------------------------------------------
  //Código para la apertura de nuevas órdenes    
    while(true)                                  
     {               
 //Código para la apertura de posiciones de compra                       
      if (Total==0 && Abrir_C==true)            // Si no hay nuevas órdenes y
        {                                       // se cumple criterio para abrir nuevas órdenes de compra
         RefreshRates();                        // Obtención de nuevos precios 
         if(Stop1==true)  
          {
           stop_loss=Bid-75*Point*10;           //Stop loss posición de compra      
           take_profit=Bid+75*Point*10;         //Take profit posición de compra      
          }      
         if(Stop2==true)  
          {
           stop_loss=KAMA10-5*Point*10;           //Stop loss posición de compra      
           take_profit=Bid+stop_loss;         //Take profit posición de compra      
          }    
         if(Riesgo>0)
          {
           Lotes=(AccountFreeMargin()*Riesgo/100)/((Bid-stop_loss)*MathPow(10,Digits-1))*0.1/(MarketInfo(NULL,MODE_TICKVALUE));
           if(Lotes<Min_Lote) Lotes=Min_Lote;               //El tamaño del lote no puede ser menor al lote mínimo del broker
          }             
         Alert("Intento de abrir posición de compra. A la espera de respuesta..");
         Ticket=OrderSend(Simbolo,OP_BUY,Lotes,Ask,0,stop_loss,take_profit,NULL,0,0,clrBlue);  //Apertura de posición de compra
         if (Ticket > 0)                        // La posición fue abierta con éxito
           {
            Alert ("Orden de compra abierta ",Ticket);
            return;                             // Salida de Ontick()
           }
         if (Fun_Error(GetLastError())==1)      // Si hubo un error en la ejecución de la orden de compra
            continue;                           // Volver a tratar
         return;                                // Salida de Ontick() para corregir errores
        }
//Código para la apertura de posiciones de venta          
      if (Total==0 && Abrir_V==true)             // Si no hay nuevas órdenes y                                       
        {                                       // se cumple criterio para abrir nuevas órdenes de venta                                  
         RefreshRates();                        // Obtención de nuevos precios    
         if(Stop1==true)
          {         
           stop_loss=Ask+75*Point*10;           //Stop loss posición de venta       
           take_profit=Ask-75*Point*10;         //Take profit posición de venta   
          } 
         if(Stop2==true)
          {         
           stop_loss=KAMA10+5*Point*10;           //Stop loss posición de venta       
           take_profit=Ask-stop_loss;         //Take profit posición de venta   
          } 
          
         if(Riesgo>0)
          {
           Lotes=(AccountFreeMargin()*Riesgo/100)/((stop_loss-Ask)*MathPow(10,Digits-1))*0.1/(MarketInfo(NULL,MODE_TICKVALUE));
           if(Lotes<Min_Lote) Lotes=Min_Lote;               //El tamaño del lote no puede ser menor al lote mínimo del broker
          }      
         Alert("Intento de abrir posición de venta. A la espera de respuesta..",take_profit);
         Ticket=OrderSend(Simbolo,OP_SELL,Lotes,Bid,0,stop_loss,take_profit,NULL,0,0,clrRed);   //Apertura de posición de venta
         if (Ticket>0)                        // La posición fue abierta con éxito
           {
            Alert ("Orden de venta abierta ",Ticket);
            return;                             // Salida de Ontick()
           }
         if (Fun_Error(GetLastError())==1)      // Si hubo un error en la ejecución de la orden de venta
            continue;                           // Retrying
         return;                                // Exit start()
        }
      break;                                    // Exit while
     } 
  }
//-------------------------------------------------------------------------------------
//Función para el procesamiento de errores
int Fun_Error(int Error)                        // Inicio de la función
  {
   switch(Error)
     {                                          
      //Errores que no son cruciales          
      case  4: Alert("Servidor del broker ocupado.Volviendo a tratar..");
         Sleep(3000);                           // Solución simple. Esperar
         return(1);                             // Salida de la función
      case 135:Alert("Precios cambiaron. Tratando nuevamente..");
         RefreshRates();                        // Volver a obtener nuevos precios
         return(1);                             // Salida de la función
      case 136:Alert("No hay precios. Esperando por un nuevo tick..");
         while(RefreshRates()==false)           // Esperando hasta que haya un nuevo tick
            Sleep(1);                           // Pausa en el ciclo
         return(1);                             // Salida de la función
      case 137:Alert("Broker está ocupado. Tratar nuevamente..");
         Sleep(3000);                           // Solucíón simple. Esperar hasta que broker responda
         return(1);                             // Salida de la función
      case 146:Alert("Subsistema de trading está ocupado. Tratar nuevamente..");
         Sleep(500);                            // Solución simple. Esperar
         return(1);                             // Salida de la función
         // Errores críticos
      case  2: Alert("Error común.");
         return(0);                             // Salida de la función
      case  5: Alert("Versión vieja de la terminal.");
         Funcion=false;                            // Finalizar operación
         return(0);                             // Salida de la función
      case 64: Alert("Cuenta bloqueada.");
         Funcion=false;                            // Terminar operación
         return(0);                             // Salida de la función
      case 133:Alert("Operaciones prohibidas.");
         return(0);                             // Salida de la función
      case 134:Alert("No hay suficiente dinero para ejecutar operación.");
         return(0);                             // Salida de la función
      default: Alert("Error ocurrio: ",Error);  // Otros tipos de errores  
         return(0);                             // Salida de la función
     }
  }

  
//+------------------------------------------------------------------+
//https://book.mql4.com/samples/expert
//https://forexboat.com/ordersend-error-130/
//https://docs.mql4.com/indicators/icustom
//https://docs.mql4.com/basis/variables/inputvariables
//https://www.earnforex.com/metatrader-indicators/support-resistance-lines/
//https://www.mql5.com/en/forum/146808
//https://www.forexfactory.com/thread/624820-need-best-support-and-resistance-indicator
//https://tradingtact.com/kaufman-adaptive-moving-average/