//Ut bot Alerts, Bj SuperScript, Smart Money 

//@version=5
indicator ("Ut bot Alerts, Smart money, Bj SuperScript", "USB Toolbox", true,  max_bars_back=5000, max_labels_count=500, max_lines_count=500)

src = input(close, title='Source')


//Ut bot Alerts 
// by QuantNomad
// source: https://tr.tradingview.com/v/n8ss8BID/
////////////////////////////////////
utbotalerts_ok = input(title='═══════════════ Ut bot Alerts ', defval=true)

// Inputs
a = input(1, title='Key Vaule. \'This changes the sensitivity\'')
c = input(10, title='ATR Period')
h = input(false, title='Signals from Heikin Ashi Candles')

xATR = ta.atr(c)
nLoss = a * xATR

srcUT = h ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

xATRTrailingStop = 0.0
iff_1 = srcUT > nz(xATRTrailingStop[1], 0) ? srcUT - nLoss : srcUT + nLoss
iff_2 = srcUT < nz(xATRTrailingStop[1], 0) and srcUT[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), srcUT + nLoss) : iff_1
xATRTrailingStop := srcUT > nz(xATRTrailingStop[1], 0) and srcUT[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), srcUT - nLoss) : iff_2

pos = 0
iff_3 = srcUT[1] > nz(xATRTrailingStop[1], 0) and srcUT < nz(xATRTrailingStop[1], 0) ? -1 : nz(pos[1], 0)
pos := srcUT[1] < nz(xATRTrailingStop[1], 0) and srcUT > nz(xATRTrailingStop[1], 0) ? 1 : iff_3

xcolor = pos == -1 ? color.red : pos == 1 ? color.green : color.blue

ema = ta.ema(srcUT, 1)
above = ta.crossover(ema, xATRTrailingStop)
below = ta.crossover(xATRTrailingStop, ema)

buyUT = srcUT > xATRTrailingStop and above
sellUT = srcUT < xATRTrailingStop and below

barbuy = srcUT > xATRTrailingStop
barsell = srcUT < xATRTrailingStop

plotshape(buyUT, title='Buy', text='Buy', style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.new(color.white, 0), size=size.tiny)
plotshape(sellUT, title='Sell', text='Sell', style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.new(color.white, 0), size=size.tiny)

barcolor(barbuy ? color.green : na)
barcolor(barsell ? color.red : na)

alertcondition(buyUT, 'UT Long', 'UT Long')
alertcondition(sellUT, 'UT Short', 'UT Short')

//Bj SuperScript
////////////////////////////////////
// by Bjorgum
// source: https://tr.tradingview.com/v/dRvnp3hs/
bjorgumsuperscript_ok = input(title='═══════════════ Bj SuperScrip Settings ', defval=false)

// ================================== //
// ---------> User Input <----------- //
// ================================== //

strat           =  input.string ("Bj Reversal", "Select a Strategy"             ,   group= "Strategy Selector"  ,   options= ["Bj Reversal", "MA", "TRM", "RSI Color"])
source          =  input.source (close        , "MA source"                     ,   group= "Strategy Selector")
alphaInput      =  input.float  (0.7          , "T3 Alpha"                      ,   group= "Strategy Selector")

t3vis           =  input.bool   (false        , "Show Tilson MA's"              ,   group= "Strategy Overides"  )
hemavis         =  input.bool   (false        , "Show HEMA MA's"                ,   group= "Strategy Overides"  )  
psarvis         =  input.bool   (false        , "Show PSAR"                     ,   group= "Strategy Overides"  )  
arrowvis        =  input.bool   (false        , "Show Arrows"                   ,   group= "Strategy Overides"  ) 
showTable       =  input.bool   (false        , "Show Bjorgum Buy Rating"       ,   group= "Strategy Overides"  ) 
disable         =  input.bool   (false        , "Disable Current MA"            ,   group= "Strategy Overides"  )

tsistrat        =  input.string ("Fast"       , "TRM Speed Control"             ,   group= "Select a Speed"     ,   options= ["Fast", "Slow"])
rsistrat        =  input.string ("Slow"       , "RSI Bar Color Speed Control"   ,   group= "Select a Speed"     ,   options= ["Slow", "Fast"])

type            =  input.string ("Hollow"     , "Candle Type"                   ,   group= "Heikin-Ashi Overlay",   options= ["Hollow", "Bars", "Candles"])
haover          =  input.bool   (false        , "Overlays HA Plotcandle"        ,   group= "Heikin-Ashi Overlay",   tooltip= "(Must 'mute' main candle series while in use. Toggle '👁' symbol next to ticker name to hide candles)")
rPrice          =  input.bool   (false        , "Actual Close Value"            ,   group= "Heikin-Ashi Overlay",   tooltip= "Displays real close value - useful when using HA overlay")

i_alert_mode    =  input.string (alert.freq_once_per_bar_close, "Alerts Mode"   ,   group= "Variable Alerts"    ,   options= [alert.freq_once_per_bar, alert.freq_once_per_bar_close], tooltip="Using the alert() function call will allow use of only one alert for any of the following selected. Any current settings in the script will be what is saved at the time the alert is set")

BUY4            =  input.bool   (false        , "TRM Buy"                       ,   group= "Variable Alerts"    )
SELL4           =  input.bool   (false        , "TRM Sell"                      ,   group= "Variable Alerts"    )
REVUP           =  input.bool   (false        , "Reversal Up"                   ,   group= "Variable Alerts"    )
REVDWN          =  input.bool   (false        , "Reversal Down"                 ,   group= "Variable Alerts"    )
HCROSSUP        =  input.bool   (false        , "MA Cross Up"                   ,   group= "Variable Alerts"    )
HCROSSDWN       =  input.bool   (false        , "MA Cross Down"                 ,   group= "Variable Alerts"    ) 
RSIUP           =  input.bool   (false        , "RSI Cross Up 50"               ,   group= "Variable Alerts"    )
RSIDWN          =  input.bool   (false        , "RSI Cross Down 50"             ,   group= "Variable Alerts"    )
RSIOB           =  input.bool   (false        , "RSI Cross Up 70"               ,   group= "Variable Alerts"    )
RSIOS           =  input.bool   (false        , "RSI Cross Down 30"             ,   group= "Variable Alerts"    )
RSICD           =  input.bool   (false        , "RSI Cross Down 70"             ,   group= "Variable Alerts"    )
RSICU           =  input.bool   (false        , "RSI Cross Up 30"               ,   group= "Variable Alerts"    )
DATA            =  input.bool   (false        , "TSI Curl Up"                   ,   group= "Variable Alerts"    )
DTAT            =  input.bool   (false        , "TSI Curl Down"                 ,   group= "Variable Alerts"    )
SARUP           =  input.bool   (false        , "Sar Up"                        ,   group= "Variable Alerts"    )
SARDWN          =  input.bool   (false        , "Sar Down"                      ,   group= "Variable Alerts"    )

textSize        =  input.string ("small"      , "Text Size"                     ,   group= "Table"              ,   options= ["tiny", "small", "normal", "large", "huge", "auto"])
tableYpos       =  input.string ("bottom"     , "Position"                      ,   group= "Table"              ,   options= ["top", "middle", "bottom"])
tableXpos       =  input.string ("right"      , ""                              ,   group= "Table"              ,   options= ["left", "center", "right"])

bullRev5        =  input.color  (color.new    (#64b5f6,  0), "", inline= "1"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )
bearRev5        =  input.color  (color.new    (#ef5350,  0), "", inline= "1"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )

bullRev8        =  input.color  (color.new    (#64b5f6,  0), "", inline= "2"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )
bearRev8        =  input.color  (color.new    (#ef5350,  0), "", inline= "2"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )

bullRevF        =  input.color  (color.new    (#64b5f6, 80), "", inline= "1"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )
bearRevF        =  input.color  (color.new    (#ef5350, 80), "", inline= "2"    ,   group= "T3 MA (Bull, Bear, Fill, Length)"    ) 

bullHema1       =  input.color  (color.new    (#64b5f6, 55), "", inline= "4"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema1       =  input.color  (color.new    (#d32f2f, 55), "", inline= "4"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullHema2       =  input.color  (color.new    (#64b5f6, 45), "", inline= "5"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema2       =  input.color  (color.new    (#d32f2f, 45), "", inline= "5"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullHema3       =  input.color  (color.new    (#64b5f6, 35), "", inline= "6"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema3       =  input.color  (color.new    (#d32f2f, 35), "", inline= "6"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullHema1F      =  input.color  (color.new    (#64b5f6, 85), "", inline= "4"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema1F      =  input.color  (color.new    (#d32f2f, 85), "", inline= "4"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullHema2F      =  input.color  (color.new    (#64b5f6, 80), "", inline= "5"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema2F      =  input.color  (color.new    (#d32f2f, 80), "", inline= "5"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullHema3F      =  input.color  (color.new    (#64b5f6, 75), "", inline= "6"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
bearHema3F      =  input.color  (color.new    (#d32f2f, 75), "", inline= "6"    ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

bullSar         =  input.color  (color.new    (#64b5f6,  0), "", inline= "7"    ,   group= "SAR (Bull, Bear)"                    )
bearSar         =  input.color  (color.new    (#ef5350,  0), "", inline= "7"    ,   group= "SAR (Bull, Bear)"                    )

aLength         =  input.int    (5            , ""  ,   inline="1"              ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )
Length          =  input.int    (8            , ""  ,   inline="2"              ,   group= "T3 MA (Bull, Bear, Fill, Length)"    )

hemaslow        =  input.int    (5            , ""  ,   inline="4"              ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
hemaslow2       =  input.int    (9            , ""  ,   inline="5"              ,   group= "MA (Bull, Bear, Fill, Length, Type)" )
hemaslow3       =  input.int    (21           , ""  ,   inline="6"              ,   group= "MA (Bull, Bear, Fill, Length, Type)" )

maType1         =  input.string ("HEMA"       , ""  ,   inline= "4"             ,   group= "MA (Bull, Bear, Fill, Length, Type)",     options= ["SMA", "EMA", "HEMA", "T3", "DEMA", "TEMA", "HMA", "WMA", "VWMA", "SWMA", "VWAP"])
maType2         =  input.string ("HEMA"       , ""  ,   inline= "5"             ,   group= "MA (Bull, Bear, Fill, Length, Type)",     options= ["SMA", "EMA", "HEMA", "T3", "DEMA", "TEMA", "HMA", "WMA", "VWMA", "SWMA", "VWAP"])
maType3         =  input.string ("HEMA"       , ""  ,   inline= "6"             ,   group= "MA (Bull, Bear, Fill, Length, Type)",     options= ["SMA", "EMA", "HEMA", "T3", "DEMA", "TEMA", "HMA", "WMA", "VWMA", "SWMA", "VWAP"])

bullcol         =  input.color  (#64b5f6      , "Bull Trend Color"              ,   group= "Bar Color"              )
bearcol         =  input.color  (#ef5350      , "Bear Trend Color"              ,   group= "Bar Color"              )
bullrev         =  input.color  (#fff176      , "Bullish Reversal Color"        ,   group= "Bar Color"              )
bearrev         =  input.color  (#fff176      , "Bearish Reversal Color"        ,   group= "Bar Color"              )

hemabull        =  input.color  (#64b5f6      , "MA Bull Color"                 ,   group= "Bar Color"              )
hemabear        =  input.color  (#e91e63      , "MA Bear Color"                 ,   group= "Bar Color"              )
hemahold        =  input.color  (#b2b5be      , "MA Hold Color"                 ,   group= "Bar Color"              )

trmbull         =  input.color  (#3BB3E4      , "TRM Buy"                       ,   group= "Bar Color"              )
trmbear         =  input.color  (#ffeb3b      , "TRM Sell"                      ,   group= "Bar Color"              )
trmhold         =  input.color  (#b2b5be      , "TRM Hold"                      ,   group= "Bar Color"              )

rsi5            =  input.color  (#17ff00      , "RSI 0-5"                       ,   group= "Bar Color"              )
rsi10           =  input.color  (#17ff00      , "RSI 5-10"                      ,   group= "Bar Color"              )
rsi15           =  input.color  (#ffffff      , "RSI 10-15"                     ,   group= "Bar Color"              )
rsi20           =  input.color  (#ffffff      , "RSI 15-20"                     ,   group= "Bar Color"              )
rsi25           =  input.color  (#ffffff      , "RSI 20-25"                     ,   group= "Bar Color"              )
rsi30           =  input.color  (#ffffff      , "RSI 25-30"                     ,   group= "Bar Color"              )
rsi35           =  input.color  (#ffffff      , "RSI 30-35"                     ,   group= "Bar Color"              )
rsi40           =  input.color  (#ffffff      , "RSI 35-40"                     ,   group= "Bar Color"              )
rsi45           =  input.color  (#ffffff      , "RSI 40-45"                     ,   group= "Bar Color"              )
rsi50           =  input.color  (#ffffff      , "RSI 45-50"                     ,   group= "Bar Color"              )
rsi55           =  input.color  (#2196f3      , "RSI 50-55"                     ,   group= "Bar Color"              )
rsi60           =  input.color  (#2196f3      , "RSI 55-60"                     ,   group= "Bar Color"              )
rsi65           =  input.color  (#2196f3      , "RSI 60-65"                     ,   group= "Bar Color"              )
rsi70           =  input.color  (#2196f3      , "RSI 65-70"                     ,   group= "Bar Color"              )
rsi75           =  input.color  (#2196f3      , "RSI 70-75"                     ,   group= "Bar Color"              )
rsi80           =  input.color  (#2196f3      , "RSI 75-80"                     ,   group= "Bar Color"              )
rsi85           =  input.color  (#9c27b0      , "RSI 80-85"                     ,   group= "Bar Color"              )
rsi90           =  input.color  (#9c27b0      , "RSI 85-90"                     ,   group= "Bar Color"              )
rsi95           =  input.color  (#ff0000      , "RSI 90-95"                     ,   group= "Bar Color"              )
rsi100          =  input.color  (#ff0000      , "RSI 95-100"                    ,   group= "Bar Color"              )

longf           =  input.int    (25           , "Long Length"                   ,   group= "TSI Fast Settings"      )
shortf          =  input.int    (5            , "Short Length"                  ,   group= "TSI Fast Settings"      )
signalf         =  input.int    (14           , "Signal Length"                 ,   group= "TSI Fast Settings"      )
lenf            =  input.int    (5            , "RSI Length"                    ,   group= "TSI Fast Settings"      )

longs           =  input.int    (25           , "Long Length"                   ,   group= "TSI Slow Settings"      )
shorts          =  input.int    (13           , "Short Length"                  ,   group= "TSI Slow Settings"      )
signals         =  input.int    (13           , "Signal Length"                 ,   group= "TSI Slow Settings"      )
lens            =  input.int    (14           , "RSI Length"                    ,   group= "TSI Slow Settings"      )

start           =  input.float  (.043         , "Start"                         ,   group="PSAR"                    )   
inc             =  input.float  (.043         , "Increment"                     ,   group="PSAR"                    )
max             =  input.float  (.34          , "Max"                           ,   group="PSAR"                    )

// ================================== //
// -----> Immutable Constants <------ //
// ================================== //

cell1           =  color.new    (color.silver , 80)

bjrev           =  strat        == "Bj Reversal"
hema            =  strat        == "MA"
trm             =  strat        == "TRM" 
rsicol          =  strat        == "RSI Color"

tsifast         =  tsistrat     == "Fast"
tsislow         =  tsistrat     == "Slow" 

rsifast         =  rsistrat     == "Fast"
rsislow         =  rsistrat     == "Slow"

hollow          =  type         == "Hollow" 
bars            =  type         == "Bars"
candle          =  type         == "Candles"

shortvar        =  tsifast ?    shortf  : shorts   
longvar         =  tsifast ?    longf   : longs    
signalvar       =  tsifast ?    signalf : signals  

len             =  tsifast ?    lenf    :
                   tsislow ?    lens    :
                   rsifast ?    lenf    :
                   rsislow ?    lens    : lens

// ================================== //
// ---> Functional Declarations <---- //
// ================================== //

_gd(src, length, alpha) =>
    float result = ta.ema(src, length) * (1 + alpha) - ta.ema(ta.ema(src, length), length) * alpha

_t3(src, length, alpha = 0.7) =>
    float result = _gd(_gd(_gd(src, length, alpha), length, alpha), length, alpha)

_dema(src, length) =>
    float ema1   = ta.ema(src,  length)
    float ema2   = ta.ema(ema1, length)
    float result = 2 * ema1 - ema2

_tema(src, length) =>
    float ema1   = ta.ema(src,  length)
    float ema2   = ta.ema(ema1, length)
    float ema3   = ta.ema(ema2, length)
    float result = 3 * (ema1 - ema2) + ema3

_haVal()         =>
    float _c     =  (open + high + low + close) / 4
    float _o     =  float(na)
    _o          :=  na(_o[1])  ? (open + close) / 2 : (nz(_o[1]) + nz(_c[1])) / 2
    float _h     =  math.max     (high , math.max     (_o,  _c))
    float _l     =  math.min     (low  , math.min     (_o,  _c))
    [_o, _h, _l, _c]

[o_,h_,l_,c_]   =  _haVal       ()

_ma(src, type, length) =>
    float result = switch type
        "EMA"  => ta.ema (src, length)
        "HEMA" => ta.ema (o_,  length)
        "SMA"  => ta.sma (src, length)
        "HMA"  => ta.hma (src, length)
        "WMA"  => ta.wma (src, length)
        "VWMA" => ta.vwma(src, length)
        "DEMA" => _dema  (src, length)
        "TEMA" => _tema  (src, length)
        "T3"   => _t3    (src, length, alphaInput)
        "SWMA" => ta.swma(src)
        "VWAP" => ta.vwap(src)

_alert(cond, txt)  =>
    if cond
        alert      (txt + timeframe.period + ' chart. Price is ' + str.tostring(close), i_alert_mode)

_triGrad(src, min, max, midCol, bearCol, bullCol) =>
    float center = min + (max - min) / 2
    color result = src >= center ? 
      color.from_gradient(src, center, max, midCol, bullCol) : 
      color.from_gradient(src, min, center, bearCol, midCol)

_populate(id, names, syms, col1, col2) =>
    if showTable 
        for [i, aSJ] in names
            s = array.get(syms, i)
            table.cell(table_id= id, column= 0, row= i, bgcolor= cell1,     text= aSJ, text_color= col1, text_size= textSize)
            table.cell(table_id= id, column= 1, row= i, bgcolor= color(na), text= s, text_color= col2, text_size= textSize)

// ================================== //
// ----> Variable Calculations <----- //
// ================================== //

tsi             =  ta.tsi           (close ,    shortvar,   longvar   )
tsl             =  ta.ema           (tsi   ,    signalvar             )
rsi             =  ta.rsi           (close ,    len                   )

anT3Average     =  _t3              (source,    aLength,    alphaInput)
nT3Average      =  _t3              (source,    Length,     alphaInput)

bjhemaslow      =  _ma              (source,    maType1,    hemaslow  )
bjhemaslow2     =  _ma              (source,    maType2,    hemaslow2 )
bjhemaslow3     =  _ma              (source,    maType3,    hemaslow3 )
bjhemafast      =  ta.ema           (hl2   ,    1                     )

sar             =  ta.sar           (start ,    inc,        max       )

// ================================== //
// ----> Conditional Parameters <---- //
// ================================== //

hadu            =  c_ >= o_

buy1            =  ta.crossover     (tsi,tsl) and   rsi > 50
buy2            =  ta.crossover     (rsi,50)  and   tsi > tsl
buy3            =  ta.crossover     (tsi,tsl) and   ta.crossover    (rsi,50)

sell1           =  ta.crossunder    (tsi,tsl) and   rsi < 50
sell2           =  ta.crossunder    (rsi,50)  and   tsi < tsl
sell3           =  ta.crossunder    (tsi,tsl) and   ta.crossunder   (rsi,50)

rsicross        =  ta.cross         (rsi,           50) 
rsiup           =  ta.crossover     (rsi,           50) 
rsidwn          =  ta.crossunder    (rsi,           50) 
rsiob           =  ta.crossover     (rsi,           70) 
rsios           =  ta.crossunder    (rsi,           30) 
rsicd           =  ta.crossunder    (rsi,           70) 
rsicu           =  ta.crossover     (rsi,           30) 

revbar          =  ta.cross         (close,         nT3Average)
trendbar        =  ta.cross         (nT3Average,    anT3Average)
revup           =  ta.crossover     (close,         nT3Average)
revdwn          =  ta.crossunder    (close,         nT3Average)

emasig          =  ta.cross         (close,         bjhemaslow)     and     ta.cross     (close,    bjhemaslow2)

hemauc          =                   (close>         bjhemaslow)     and     (close >                bjhemaslow2)
hemadc          =                   (close<         bjhemaslow)     and     (close <                bjhemaslow2)

crossup1        =  ta.crossover     (close,         bjhemaslow)     and     (close >                bjhemaslow2)
crossup2        =  ta.crossover     (close,         bjhemaslow2)    and     (close >                bjhemaslow)
crossup3        =  ta.crossover     (close,         bjhemaslow2)    and     ta.crossover (close,    bjhemaslow)

crossdown1      =  ta.crossunder    (close,         bjhemaslow)     and     (close <                bjhemaslow2)
crossdown2      =  ta.crossunder    (close,         bjhemaslow2)    and     (close <                bjhemaslow)
crossdown3      =  ta.crossunder    (close,         bjhemaslow2)    and     ta.crossunder(close,    bjhemaslow)

sarup           =  ta.crossover     (close,         sar)
sardwn          =  ta.crossunder    (close,         sar)

Hcrossup        =  crossup1   or    crossup2   or   crossup3
Hcrossdwn       =  crossdown1 or    crossdown2 or   crossdown3

buy4            =  buy1  or buy2    or buy3
sell4           =  sell1 or sell2   or sell3

buy             =  tsi > tsl  and   rsi > 50
sell            =  tsi < tsl  and   rsi < 50 

data            =  tsi < tsl  and   tsi > tsi   [1]  
dtat            =  tsi > tsl  and   tsi < tsi   [1]  

colOne          =  anT3Average  >   anT3Average [1] 
upCol           =  nT3Average   >   nT3Average  [1] 
fillData        =  anT3Average  >   nT3Average   

uc              =  (anT3Average >=  nT3Average) and (close > nT3Average) 
dc              =  (anT3Average <=  nT3Average) and (close < nT3Average)   
dr              =  (anT3Average >=  nT3Average) and (close < nT3Average)  
ur              =  (anT3Average <=  nT3Average) and (close > nT3Average)  
  
hauc            =  (anT3Average >=  nT3Average) and (c_    > nT3Average) 
hadc            =  (anT3Average <=  nT3Average) and (c_    < nT3Average) 
hadr            =  (anT3Average >=  nT3Average) and (c_    < nT3Average) 
haur            =  (anT3Average <=  nT3Average) and (c_    > nT3Average) 

up              =  bjhemaslow   >   bjhemaslow  [1]
up2             =  bjhemaslow2  >   bjhemaslow2 [1]
up3             =  bjhemaslow3  >   bjhemaslow3 [1]

hfillData       =  bjhemaslow   <   bjhemafast
hfillDtat       =  bjhemaslow2  <   bjhemaslow
hfillDat        =  bjhemaslow3  <   bjhemaslow2

ema1            =  bjhemaslow   <   close
ema2            =  bjhemaslow2  <   close
ema3            =  bjhemaslow3  <   close

sarUp           =  close        >=  sar
rsiUp           =  rsi          >   50
tsiUp           =  tsi          >   tsl
rsiH            =  rsi          >=  90 or      rsi <= 10

// ================================== //
// ------> Statistical Rating <------ //
// ================================== //

names           =  array.from(
                   "TRM"                                    ,
                   "Rev"                                    ,
                   "Curl"                                   ,
                   "RSI"                                    ,
                   "TSI"                                    ,
                   str.format("{0} {1}", maType1, hemaslow) ,
                   str.format("{0} {1}", maType2, hemaslow2),
                   str.format("{0} {1}", maType3, hemaslow3),
                   "SAR"                                    )

syms            =  array.from(
                   buy   ? "✅" : sell ? "❌" : "➖" ,
                   uc    ? "✅" : dc   ? "❌" : "🔸" , 
                   data  ? "✅" : dtat ? "❌" : "➖" ,
                   rsiH  ? "🔥": rsiUp ? "✅" : "❌" ,                           
                   tsiUp ? "✅" :        "❌"        ,
                   ema1  ? "✅" :        "❌"        ,
                   ema2  ? "✅" :        "❌"        ,
                   ema3  ? "✅" :        "❌"        ,
                   sarUp ? "✅" :        "❌"        ) 

sigs            =  array.from(
                   buy   ?  1   : sell ?  -1   : 0    ,
                   uc    ?  1   : dc   ?  -1   : 0    ,
                   data  ?  1   : dtat ?  -1   : 0    ,
                   rsiUp ?  1   :         -1          ,
                   tsiUp ?  1   :         -1          ,
                   ema1  ?  1   :         -1          ,
                   ema2  ?  1   :         -1          ,
                   ema3  ?  1   :         -1          ,
                   sarUp ?  1   :         -1          ) 

sigSum          = array.sum (sigs)

tabCol          = _triGrad  (sigSum, -6, 6, color.gray, #ff0000, color.green)

var stats       = table.new (position=tableYpos + "_" + tableXpos, columns=2, rows=9, border_color= color.new(color.gray, 60), border_width=1)

_populate         (stats, names, syms, tabCol, tabCol)

// ================================== //
// ------> Graphical Display <------- //
// ================================== //

color2          =  colOne    ?  bullRev5      : bearRev5 
myColor         =  upCol     ?  bullRev8      : bearRev8 

revFillCol      =  fillData  ?  bullRevF      : bearRevF 
hfillCol1       =  hfillData ?  bullHema1F    : bearHema1F 
hfillCol2       =  hfillDtat ?  bullHema2F    : bearHema2F
hfillCol3       =  hfillDat  ?  bullHema3F    : bearHema3F 

mycolor         =  up        ?  bullHema1     : bearHema1
mycolor2        =  up2       ?  bullHema2     : bearHema2
mycolor3        =  up3       ?  bullHema3     : bearHema3

colUp           =  sarUp     ?  bullSar       : bearSar
hadefval        =  hadu      ?  bullcol       : bearcol

trmcolor        =  buy       ?  trmbull       : sell        ?       trmbear     :   trmhold
hemabar         =  hemauc    ?  hemabull      : hemadc      ?       hemabear    :   hemahold 

rsicon          =  rsi > 0  and rsi <= 5  ? rsi5  :
                   rsi > 5  and rsi <= 10 ? rsi10 :
                   rsi > 10 and rsi <= 15 ? rsi15 :
                   rsi > 15 and rsi <= 20 ? rsi20 :
                   rsi > 20 and rsi <= 25 ? rsi25 :
                   rsi > 25 and rsi <= 30 ? rsi30 :
                   rsi > 30 and rsi <= 35 ? rsi35 :
                   rsi > 35 and rsi <= 40 ? rsi40 :
                   rsi > 40 and rsi <= 45 ? rsi45 :
                   rsi > 45 and rsi <= 50 ? rsi50 :
                   rsi > 50 and rsi <= 55 ? rsi55 :
                   rsi > 55 and rsi <= 60 ? rsi60 :
                   rsi > 60 and rsi <= 65 ? rsi65 :
                   rsi > 65 and rsi <= 70 ? rsi70 :
                   rsi > 70 and rsi <= 75 ? rsi75 :
                   rsi > 75 and rsi <= 80 ? rsi80 :
                   rsi > 80 and rsi <= 85 ? rsi85 :
                   rsi > 85 and rsi <= 90 ? rsi90 :
                   rsi > 90 and rsi <= 95 ? rsi95 :
                   rsi > 95 and rsi <= 100? rsi100: hadefval

bjrevcol        =  uc        ?  bullcol       : 
                   dc        ?  bearcol       :
                   dr        ?  bearrev       :
                   ur        ?  bullrev       : na
 
habjrevcol      =  hauc      ?  bullcol       :
                   hadc      ?  bearcol       :
                   hadr      ?  bearrev       :
                   haur      ?  bullrev       : hadefval

barColor        =  trm       ?  trmcolor      : 
                   bjrev     ?  bjrevcol      : 
                   rsicol    ?  rsicon        : 
                   hema      ?  hemabar       : na

habarColor      =  trm       ?  trmcolor      : 
                   bjrev     ?  habjrevcol    : 
                   rsicol    ?  rsicon        : 
                   hema      ?  hemabar       : na

p2              =  plot     ((t3vis   or (not disable and bjrev)) ? anT3Average : na, "T3 Fast" , color2  )
p1              =  plot     ((t3vis   or (not disable and bjrev)) ? nT3Average  : na, "T3 Slow" , myColor )

hemaslowplot    =  plot     ((hemavis or (not disable and hema))  ? bjhemaslow  : na, 'EMA 5'   , mycolor )
hemaslowplot2   =  plot     ((hemavis or (not disable and hema))  ? bjhemaslow2 : na, 'EMA 9'   , mycolor2)
hemaslowplot3   =  plot     ((hemavis or (not disable and hema))  ? bjhemaslow3 : na, 'EMA 21'  , mycolor3)

hemafastplot    =  plot     (bjhemafast , 'EMA fast', #FF000000 , display=display.none, editable=false)

fill               (hemaslowplot , hemafastplot , color= hemavis or hema  ? hfillCol1  : na, title= "5 - Plot Fill")
fill               (hemaslowplot , hemaslowplot2, color= hemavis or hema  ? hfillCol2  : na, title= "5 - 9 Fill"   )
fill               (hemaslowplot2, hemaslowplot3, color= hemavis or hema  ? hfillCol3  : na, title= "9 - 21 Fill"  )
fill               (p1           , p2           , color= t3vis   or bjrev ? revFillCol : na, title= "T3 Fill"      )

plotshape          (arrowvis ? data   : na, style=shape.triangleup,   location=location.belowbar, color= #17ff00, title="Curl Up"  )
plotshape          (arrowvis ? dtat   : na, style=shape.triangledown, location=location.abovebar, color= #FFEB3B, title="Curl Down")

plot               (psarvis  ? sar    : na, "SAR"       , colUp     , style=   plot.style_circles  , linewidth= 1)
plot               (rPrice   ? close  : na, "Real Close", habarColor, trackprice=true, offset=-9999, editable=  false)

candleCol       =  haover and hollow  ? c_ < o_  ? habarColor : na :
                   haover and candle  ?            habarColor : na

wickCol         =  (hollow or candle) and haover ? #b2b5be    : na
borderCol       =  (hollow or candle) and haover ? habarColor : na
barCol          =  haover and bars               ? habarColor : na

plotcandle         (o_, h_, l_, c_, "Hollow Candles", candleCol, wickCol, bordercolor= borderCol)
plotbar            (o_, h_, l_, c_, 'Heikin-Ashi'   , barCol) 

barcolor           (color=barColor)

// ================================== //
// -----> Alert Functionality <------ //
// ================================== //

alertcondition     (buy4        ,   "TRM Buy"           ,   "TRM Buy on {{interval}} chart. Price is {{close}}"                     )
alertcondition     (sell4       ,   "TRM Sell"          ,   "TRM Sell on {{interval}} chart. Price is {{close}}"                    )
alertcondition     (revbar      ,   "Bj Reversal"       ,   "Reversal candle is forming on {{interval}} chart. Price is {{close}}"  )
alertcondition     (trendbar    ,   "T3 Crossing T3"    ,   "A new trend may be forming on {{interval}} chart. Price is {{close}}"  )
alertcondition     (revup       ,   "Reversal Up"       ,   "Reversal up on {{interval}} chart. Price is {{close}}"                 )
alertcondition     (revdwn      ,   "Reversal Down"     ,   "Reversal down on {{interval}} chart. Price is {{close}}"               )
alertcondition     (emasig      ,   "MA Alert"          ,   "Price is crossing MAs on {{interval}} chart. Price is {{close}}"       )
alertcondition     (Hcrossup    ,   "MA Cross Up"       ,   "MA crossed up on {{interval}} chart. Price is {{close}}"               )    
alertcondition     (Hcrossdwn   ,   "MA Cross Down"     ,   "MA crossed down on {{interval}} chart. Price is {{close}}"             )
alertcondition     (rsicross    ,   "RSI Signal"        ,   "RSI crossed 50 on {{interval}} chart. Price is {{close}}"              )
alertcondition     (rsiup       ,   "RSI Cross Up"      ,   "RSI crossed up 50 on {{interval}} chart. Price is {{close}}"           )
alertcondition     (rsidwn      ,   "RSI Cross Down"    ,   "RSI crossed down 50 on {{interval}} chart. Price is {{close}}"         )
alertcondition     (rsiob       ,   "RSI Overbought"    ,   "RSI crossed overbought on {{interval}} chart. Price is {{close}}"      )
alertcondition     (rsios       ,   "RSI Oversold"      ,   "RSI crossed oversold on {{interval}} chart. Price is {{close}}"        )
alertcondition     (rsicd       ,   "RSI momo down"     ,   "RSI crossed down 70 on {{interval}} chart. Price is {{close}}"         )
alertcondition     (rsicu       ,   "RSI momo up"       ,   "RSI crossed up 30 on {{interval}} chart. Price is {{close}}"           )
alertcondition     (data        ,   "TSI Curl Up"       ,   "TSI curled up on {{interval}} chart. Price is {{close}}"               )
alertcondition     (dtat        ,   "TSI Curl Down"     ,   "TSI curled down on {{interval}} chart. Price is {{close}}"             )
alertcondition     (sarup       ,   "Sar Up"            ,   "SAR triggered up {{interval}} chart. Price is {{close}}"               )
alertcondition     (sardwn      ,   "Sar Down"          ,   "SAR triggered down {{interval}} chart. Price is {{close}}"             )

_alert             (buy4        and BUY4                ,   'TRM Buy on '               )
_alert             (sell4       and SELL4               ,   'TRM Sell on '              )
_alert             (revup       and REVUP               ,   'Reversal up on '           )
_alert             (revdwn      and REVDWN              ,   'Reversal down on '         )
_alert             (Hcrossup    and HCROSSUP            ,   'MA crossed up on '         )
_alert             (Hcrossdwn   and HCROSSDWN           ,   'MA crossed down on '       )
_alert             (rsiup       and RSIUP               ,   'RSI crossed up 50 on '     )
_alert             (rsidwn      and RSIDWN              ,   'RSI crossed down 50 on '   )
_alert             (rsiob       and RSIOB               ,   'RSI crossed up 70 on '     )
_alert             (rsios       and RSIOS               ,   'RSI crossed down 30 on '   )
_alert             (rsicd       and RSICD               ,   'RSI crossed down 70 on '   )
_alert             (rsicu       and RSICU               ,   'RSI crossed up 30 on '     )
_alert             (data        and DATA                ,   'TSI curled up on '         )
_alert             (dtat        and DTAT                ,   'TSI curled down on '       )
_alert             (sarup       and SARUP               ,   'SAR triggered up '         )
_alert             (sardwn      and SARDWN              ,   'SAR triggered down '       )




//Smart Money Concepts Probability (Expo)
////////////////////////////////////
// Smart Money Concepts Probability (Expo) by zeiierman
// source: https://tr.tradingview.com/v/mBINsJlf/

smartmoney_ok = input(title='═══════════════ Smart Money Concepts Probability (Expo)', defval=false) 


// ~~ Tooltips {
string t1 = "Set the pivot period"
string t2 = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
prd    = input.int(20,minval=1,title="Structure Period",tooltip=t1)
s1     = input.bool(true,title="Structure Response  ", inline="resp")
resp   = input.int(7,minval=1,title="",inline="resp",tooltip=t2)
bull   = input.bool(true,"Bullish Structure     ",inline="Bullish"), bull2 = input.color(color.rgb(8, 236, 126),"",inline="Bullish"), bull3 = input.color(color.rgb(8, 236, 126),"",inline="Bullish")
bear   = input.bool(true,"Bearish Structure    ",inline="Bearish"), bear2 = input.color(color.rgb(255, 34, 34),"",inline="Bearish"), bear3 = input.color(color.rgb(255, 34, 34),"",inline="Bearish")
showPD = input.bool(true,"Premium & Discount",inline="pd"), prem = input.color(color.new(color.rgb(255, 34, 34),80),"",inline="pd"), disc = input.color(color.new(color.rgb(8, 236, 126),80),"",inline="pd")
hlloc  = input.string("Right","", options=["Left","Right"],inline="pd")
var bool [] alert_bool  = array.from(
 input.bool(true,title="Ticker ID",group="Any alert() function call"),
 input.bool(true,title="Timeframe",group="Any alert() function call"),
 input.bool(true,title="Probability Percentage",group="Any alert() function call"))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Variables {
b       = bar_index
var Up  = float(na)
var Dn  = float(na)
var iUp = int(na)
var iDn = int(na)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Matrix & Array {
var vals          = matrix.new<float>(9,4,0.0)
var string [] txt = array.new<string>(2,"")
var tbl           = matrix.new<table>(1,1,table.new(position.top_right,2,3,
 frame_color      =color.new(color.gray,50),frame_width=3,
 border_color     =chart.bg_color,border_width=-2))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Functions {
//Labels
CreateLabel(x,y,txt,col,z)=>
    label.new(x,y,txt,textcolor=col,style=z?label.style_label_down:label.style_label_up,color=color(na))
//Lines
CreateLine(x1,x2,y,col)=>
    line.new(x1,x2,b,y,color=col)
//Current
Current(v)=>
    str = ""
    val1 = float(na)
    val2 = float(na)
    if v>=0
        if v==1
            str  := "SMS: "
            val1 := matrix.get(vals,0,1)
            val2 := matrix.get(vals,0,3) 
        else if v==2
            str  := "BMS: "
            val1 := matrix.get(vals,1,1)
            val2 := matrix.get(vals,1,3) 
        else if v>2
            str  := "BMS: "
            val1 := matrix.get(vals,2,1)
            val2 := matrix.get(vals,2,3) 
    else if v<=0
        if v==-1
            str  := "SMS: "
            val1 := matrix.get(vals,3,1)
            val2 := matrix.get(vals,3,3) 
        else if v==-2
            str  := "BMS: "
            val1 := matrix.get(vals,4,1)
            val2 := matrix.get(vals,4,3) 
        else if v<-2
            str  := "BMS: "
            val1 := matrix.get(vals,5,1)
            val2 := matrix.get(vals,5,3)
    [str,val1,val2]
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Pivots {
Up   := math.max(Up[1],high)
Dn   := math.min(Dn[1],low)
pvtHi = ta.pivothigh(high,prd,prd)
pvtLo = ta.pivotlow(low,prd,prd)
if pvtHi
    Up := pvtHi
if pvtLo
    Dn := pvtLo
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Structure {
var posSM = 0
if Up>Up[1]
    iUp := b
    centerBull = math.round(math.avg(iUp[1],b))
    if posSM<=0
        if bull
            CreateLabel(centerBull,Up[1],"CHoCH",bull3,true)
            CreateLine(iUp[1],Up[1],Up[1],bull2)
        posSM := 1
        matrix.set(vals,6,0,matrix.get(vals,6,0)+1)
    else if posSM==1 and Up>Up[1] and Up[1]==Up[s1?resp:prd]
        if bull
            CreateLabel(centerBull,Up[1],"SMS",bull3,true)
            CreateLine(iUp[1],Up[1],Up[1],bull2)
        posSM := 2
        matrix.set(vals,6,1,matrix.get(vals,6,1)+1)
    else if posSM>1 and Up>Up[1] and Up[1]==Up[s1?resp:prd]
        if bull
            CreateLabel(centerBull,Up[1],"BMS",bull3,true)
            CreateLine(iUp[1],Up[1],Up[1],bull2)
        posSM := posSM + 1
        matrix.set(vals,6,2,matrix.get(vals,6,2)+1)
else if Up<Up[1]
    iUp := b-prd
if Dn<Dn[1]
    iDn := b
    centerBear = math.round(math.avg(iDn[1],b))
    if posSM>=0
        if bear
            CreateLabel(centerBear,Dn[1],"CHoCH",bear3,false)
            CreateLine(iDn[1],Dn[1],Dn[1],bear2)
        posSM := -1
        matrix.set(vals,7,0,matrix.get(vals,7,0)+1)
    else if posSM==-1 and Dn<Dn[1] and Dn[1]==Dn[s1?resp:prd]
        if bear
            CreateLabel(centerBear,Dn[1],"SMS",bear3,false)
            CreateLine(iDn[1],Dn[1],Dn[1],bear2)
        posSM := -2
        matrix.set(vals,7,1,matrix.get(vals,7,1)+1)
    else if posSM<-1 and Dn<Dn[1] and Dn[1]==Dn[s1?resp:prd]
        if bear
            CreateLabel(centerBear,Dn[1],"BMS",bear3,false)
            CreateLine(iDn[1],Dn[1],Dn[1],bear2)
        posSM := posSM - 1
        matrix.set(vals,7,2,matrix.get(vals,7,2)+1)
else if Dn>Dn[1]
    iDn := b-prd
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Probability Calculation {
if ta.change(posSM)
    //Results
    if posSM>0 and posSM[1]>0 or posSM<0 and posSM[1]<0
        if  matrix.get(vals,8,0)<matrix.get(vals,8,1)
            matrix.set(vals,8,2,matrix.get(vals,8,2)+1)
        else
            matrix.set(vals,8,3,matrix.get(vals,8,3)+1)
    else
        if  matrix.get(vals,8,0)>matrix.get(vals,8,1)
            matrix.set(vals,8,2,matrix.get(vals,8,2)+1)
        else
            matrix.set(vals,8,3,matrix.get(vals,8,3)+1)

    //Score Calulation
    //Variables
    buC0 = matrix.get(vals,0,0)
    buC1 = matrix.get(vals,0,2)
    buS0 = matrix.get(vals,1,0)
    buS1 = matrix.get(vals,1,2)
    buB0 = matrix.get(vals,2,0)
    buB1 = matrix.get(vals,2,2)
    beC0 = matrix.get(vals,3,0)
    beC1 = matrix.get(vals,3,2)
    beS0 = matrix.get(vals,4,0)
    beS1 = matrix.get(vals,4,2)
    beB0 = matrix.get(vals,5,0)
    beB1 = matrix.get(vals,5,2)
    tbuC = matrix.get(vals,6,0)
    tbuS = matrix.get(vals,6,1)
    tbuB = matrix.get(vals,6,2)
    tbeC = matrix.get(vals,7,0)
    tbeS = matrix.get(vals,7,1)
    tbeB = matrix.get(vals,7,2)

    //Bull
    if (posSM[1]==1 or posSM[1]==0) and posSM<0
        matrix.set(vals,0,0,buC0+1)
        matrix.set(vals,0,1,math.round(((buC0+1)/tbuC)*100,2))
    if (posSM[1]==1 or posSM[1]==0) and posSM==2
        matrix.set(vals,0,2,buC1+1)
        matrix.set(vals,0,3,math.round(((buC1+1)/tbuC)*100,2))
    if posSM[1]==2 and posSM<0
        matrix.set(vals,1,0,buS0+1)
        matrix.set(vals,1,1,math.round(((buS0+1)/tbuS)*100,2))
    if posSM[1]==2 and posSM>2
        matrix.set(vals,1,2,buS1+1)
        matrix.set(vals,1,3,math.round(((buS1+1)/tbuS)*100,2))
    if posSM[1]>2 and posSM<0
        matrix.set(vals,2,0,buB0+1)
        matrix.set(vals,2,1,math.round(((buB0+1)/tbuB)*100,2))
    if posSM[1]>2 and posSM>posSM[1]
        matrix.set(vals,2,2,buB1+1)
        matrix.set(vals,2,3,math.round(((buB1+1)/tbuB)*100,2))
    //Bear
    if (posSM[1]==-1 or posSM[1]==0) and posSM>0
        matrix.set(vals,3,0,beC0+1)
        matrix.set(vals,3,1,math.round(((beC0+1)/tbeC)*100,2))
    if (posSM[1]==-1 or posSM[1]==0) and posSM==-2
        matrix.set(vals,3,2,beC1+1)
        matrix.set(vals,3,3,math.round(((beC1+1)/tbeC)*100,2))
    if posSM[1]==-2 and posSM>0
        matrix.set(vals,4,0,beS0+1)
        matrix.set(vals,4,1,math.round(((beS0+1)/tbeS)*100,2))
    if posSM[1]==-2 and posSM<-2
        matrix.set(vals,4,2,beS1+1)
        matrix.set(vals,4,3,math.round(((beS1+1)/tbeS)*100,2))
    if posSM[1]<-2 and posSM>0
        matrix.set(vals,5,0,beB0+1)
        matrix.set(vals,5,1,math.round(((beB0+1)/tbeB)*100,2))
    if posSM[1]<-2 and posSM<posSM[1]
        matrix.set(vals,5,2,beB1+1)
        matrix.set(vals,5,3,math.round(((beB1+1)/tbeB)*100,2))
    [str,val1,val2] = Current(posSM)
    array.set(txt,0,"CHoCH: "+str.tostring(val1,format.percent))
    array.set(txt,1,str+str.tostring(val2,format.percent))
    matrix.set(vals,8,0,val1)
    matrix.set(vals,8,1,val2)
    //Alerts
    if array.includes(alert_bool,true)
        st1 = syminfo.ticker
        st2 = timeframe.period 
        st3 = str.tostring(array.join(txt,'\n'))
        string [] str_vals = array.from(st1,st2,st3)
        output = array.new_string()
        for x=0 to array.size(alert_bool)-1
            if array.get(alert_bool,x)
                array.push(output,array.get(str_vals,x))
        alert(array.join(output,'\n'),alert.freq_once_per_bar_close)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Premium & Discount {
var hi       = line.new(na,na,na,na,color=bear2)
var lo       = line.new(na,na,na,na,color=bull2)
var fill     = linefill.new(hi,lo,na)
var premium  = box.new(na,na,na,na,na,bgcolor=prem)
var discount = box.new(na,na,na,na,na,bgcolor=disc)
var mid      = box.new(na,na,na,na,na,bgcolor=color.new(color.gray,80))

PremiumTop   = Up-(Up-Dn)*.1
PremiumBot   = Up-(Up-Dn)*.25
DiscountTop  = Dn+(Up-Dn)*.25
DiscountBot  = Dn+(Up-Dn)*.1
MidTop       = Up-(Up-Dn)*.45
MidBot       = Dn+(Up-Dn)*.45

if barstate.islast and showPD
    loc = hlloc=="Left"?math.min(iUp,iDn):math.max(iUp,iDn)
    //High & Low
    line.set_xy1(hi,loc,Up)
    line.set_xy2(hi,b,Up)
    line.set_xy1(lo,loc,Dn)
    line.set_xy2(lo,b,Dn)
    linefill.set_color(fill,color.new(color.gray,90))
    //Premium & Mid & Discount
    box.set_lefttop(premium,loc,PremiumTop)
    box.set_rightbottom(premium,b,PremiumBot)
    box.set_lefttop(discount,loc,DiscountTop)
    box.set_rightbottom(discount,b,DiscountBot)
    box.set_lefttop(mid,loc,MidTop)
    box.set_rightbottom(mid,b,MidBot)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Probability {
var prob1 = label.new(na,na,na,color=color(na),textcolor=chart.fg_color,style=label.style_label_left)
var prob2 = label.new(na,na,na,color=color(na),textcolor=chart.fg_color,style=label.style_label_left)

if barstate.islast
    str1 = posSM<0?array.get(txt,0):array.get(txt,1)
    str2 = posSM>0?array.get(txt,0):array.get(txt,1)
    label.set_xy(prob1,b,Up)
    label.set_text(prob1,str1)
    label.set_xy(prob2,b,Dn)
    label.set_text(prob2,str2)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Table {
if barstate.islast
    //Calulate WinRatio
    W  = matrix.get(vals,8,2)
    L  = matrix.get(vals,8,3)
    WR = math.round(W/(W+L)*100,2)
    string [] tbl_vals = array.from("WIN: "+str.tostring(W),
     "LOSS: "+str.tostring(L),
     "Profitability: "+str.tostring(WR,format.percent))
    color [] tbl_col = array.from(color.green,color.red,chart.fg_color)
    for i=0 to 2
        table.cell(matrix.get(tbl,0,0),0,i,array.get(tbl_vals,i),
         text_halign=text.align_center,bgcolor=chart.bg_color,
         text_color=array.get(tbl_col,i),text_size=size.auto)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}