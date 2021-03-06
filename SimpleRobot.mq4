
extern int    StopLoss     = 2200;     // Stop Loss
extern int    TakeProfit   = 1900;     // Take Profit
extern int    Profit       = 0;        // Profit in cash
extern int    Slip         = 30;       // Slippage
extern int    StartHour    = 0;        // Trading start hour
extern int    EndHour      = 11;       // Trading end hour
extern int    Type         = 0;        // 0-Buy,1-Sell
extern int    Try          = 5;        // Number of tryouts
extern int    Magic        = 09052015; // Magic
extern double Lots         = 0.1;      // Volume

double stop=0,take=0,slip=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
  }
//+------------------------------------------------------------------+
double fND(double d,int n=-1)
  {
   if(n<0) return(NormalizeDouble(d, Digits));
   return(NormalizeDouble(d, n));
  }
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar=0;
   datetime curbar=Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return (true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               count++;
           }
        }
     }
   return(count);
  }
//+----------------------------------------------------------------------------+
void CloseAll()
  {
   int k;
   bool cl;
   for(k=OrdersTotal()-1;k>=0;k--)
     {
      bool sel=OrderSelect(k,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType() == OP_BUY)  cl=OrderClose(OrderTicket(), OrderLots(), Bid, Slip, Blue);
            if(OrderType() == OP_SELL) cl=OrderClose(OrderTicket(), OrderLots(), Ask, Slip, Red);
           }
         Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+  
double AllProfit() 
  {
   double profit=0;
   for(int i=OrdersTotal()-1;i>=0;i--) 
     {
      bool s=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         if(OrderType()==OP_BUY || OrderType()==OP_SELL) profit+=OrderProfit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- Коды ошибок, возвращаемые торговым сервером:
      case 0:   error_string="Нет ошибок";                                                     break;
      case 1:   error_string="Нет ошибки, но результат неизвестен";                            break;
      case 2:   error_string="Общая ошибка";                                                   break;
      case 3:   error_string="Неправильные параметры";                                         break;
      case 4:   error_string="Торговый сервер занят";                                          break;
      case 5:   error_string="Старая версия клиентского терминала";                            break;
      case 6:   error_string="Нет связи с торговым сервером";                                  break;
      case 7:   error_string="Недостаточно прав";                                              break;
      case 8:   error_string="Слишком частые запросы";                                         break;
      case 9:   error_string="Недопустимая операция нарушающая функционирование сервера";      break;
      case 64:  error_string="Счет заблокирован";                                              break;
      case 65:  error_string="Неправильный номер счета";                                       break;
      case 128: error_string="Истек срок ожидания совершения сделки";                          break;
      case 129: error_string="Неправильная цена";                                              break;
      case 130: error_string="Неправильные стопы";                                             break;
      case 131: error_string="Неправильный объем";                                             break;
      case 132: error_string="Рынок закрыт";                                                   break;
      case 133: error_string="Торговля запрещена";                                             break;
      case 134: error_string="Недостаточно денег для совершения операции";                     break;
      case 135: error_string="Цена изменилась";                                                break;
      case 136: error_string="Нет цен";                                                        break;
      case 137: error_string="Брокер занят";                                                   break;
      case 138: error_string="Новые цены";                                                     break;
      case 139: error_string="Ордер заблокирован и уже обрабатывается";                        break;
      case 140: error_string="Разрешена только покупка";                                       break;
      case 141: error_string="Слишком много запросов";                                         break;
      case 145: error_string="Модификация запрещена, так как ордер слишком близок к рынку";    break;
      case 146: error_string="Подсистема торговли занята";                                     break;
      case 147: error_string="Использование даты истечения ордера запрещено брокером";         break;
      case 148: error_string="Количество открытых и отложенных ордеров достигло предела, установленного брокером.";break;
      default:  error_string="Неизвестная ошибка.";
     }
//----
   return(error_string);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void OpenPos()
  {
   int res=0,err=0;
//---- buy conditions
   if(Type==0)
     {
      if(StopLoss>0)   stop=Bid-StopLoss*Point;   else stop=0;
      if(TakeProfit>0) take=Ask+TakeProfit*Point; else take=0;

      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,fND(stop),fND(take),"",Magic,0,Blue);
      if(res<0)
        {
         Print("Ошибка: ",Error(GetLastError()));
         err++;
         Sleep(500);
         RefreshRates();
        }
      else
         Print("OK Order Buy");
      return;
     }

//---- sell conditions
   if(Type==1)
     {
      if(StopLoss>0)   stop=Ask+StopLoss*Point;   else stop=0;
      if(TakeProfit>0) take=Bid-TakeProfit*Point; else take=0;

      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,fND(stop),fND(take),"",Magic,0,Red);
      if(res<0)
        {
         Print("Ошибка: ",Error(GetLastError()));
         err++;
         Sleep(500);
         RefreshRates();
        }
      else
         Print("OK Order Sell");
      return;
     }
//----
   if(err>Try) return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//--- go trading only for first tiks of new bar
   if(NewBar()==true)
     {
      if(Hour()>=StartHour && Hour()<=EndHour)OpenPos();
      if(AllProfit()>=Profit) CloseAll();
     }

   Comment("\n    Компания: ",AccountInfoString(ACCOUNT_COMPANY),
           //"\n  Имя клиента: ",AccountInfoString(ACCOUNT_NAME),
           "\n    Плечо: ",AccountInfoInteger(ACCOUNT_LEVERAGE),
           "\n    Количество ордеров: ",AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),
           "\n    Коля Маржин: ",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL),
           "\n    Стопаут: ",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),
           "\n    Стоплевел: ",MarketInfo(Symbol(),MODE_STOPLEVEL),
           "\n ",
           "\n    Открыто ордеров: ",CountTrades(),
           "\n ",
           "\n    Баланс: ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2),
           "\n    Средства: ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2),
           "\n    Прибыль: ",DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT)),2);

//----   
  }
//+------------------------------------------------------------------+
