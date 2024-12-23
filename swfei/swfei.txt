// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// by © therkut
//@version=6
//# * Github: https://github.com/therkut/PineScript/tree/main/swfei
//# * Strategic: https://drive.google.com/file/d/11hIEjxSnyfGx1IyKce1SzKlHS1uUpzTq/view
indicator("SuperWaveTrend Fibonacci Ema Ichimoku Indicator", "SWFEI", overlay= true, max_bars_back = 5000)
//-----------------------------------------------------------------------------{
//1- SUPERTREND
//# * Author      : © KivancOzbilgic
//# * Use: Daily and 4H
//# * SuperTrend period: 
//# * for stock : 10,2/ 66,2/ 333,2/ 10,1/
//# * for Indx  : 10,2
////////////////////////
super_ok = input(true, title = '═══════════════ SuperTrend Settings ')

Periods = input.int(title = 'ATR Period', defval = 10, group = 'SuperTrend')
st_src = input.source(hl2, title = 'Source', group = 'SuperTrend')
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 1.0, group = 'SuperTrend')
changeATR = input.bool(false, title = 'Change ATR Calculation Method ?', group = 'SuperTrend')
showsignals = input.bool(true, title = 'Show Buy/Sell Signals ?', group = 'SuperTrend')
highlighting = input.bool(false, title = 'Highlighter On/Off ?', group = 'SuperTrend')
showBuySignal = input.bool(false, title = 'Show Buy Signals', group = 'SuperTrend')
showSellSignal = input.bool(true, title = 'Show Sell Signals', group = 'SuperTrend')

// ATR Calculation
atr = changeATR ? ta.atr(Periods) : ta.sma(ta.tr, Periods)
up = st_src - Multiplier * atr
dn = st_src + Multiplier * atr
up1 = nz(up[1], up)
dn1 = nz(dn[1], dn)
up := close[1] > up1 ? math.max(up, up1) : up
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

// Initialize trend variable
var float trend = na
trend := nz(trend[1], 1)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend

// Plot SuperTrend
upPlot = plot(super_ok and trend == 1 ? up : na, title = 'Up Trend', style = plot.style_linebr, linewidth = 2, color = color.green)
dnPlot = plot(super_ok and trend == -1 ? dn : na, title = 'Down Trend', style = plot.style_linebr, linewidth = 2, color = color.red)
buySignal = trend == 1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] == 1
plotshape(super_ok and showBuySignal and buySignal ? up : na, title = 'UpTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.green)
plotshape(super_ok and showSellSignal and sellSignal ? dn : na, title = 'DownTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.red)
plotshape(super_ok and showBuySignal and buySignal and showsignals ? up : na, title = 'Buy', text = 'Buy', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.green, textcolor = color.white)
plotshape(super_ok and showSellSignal and sellSignal and showsignals ? dn : na, title = 'Sell', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.red, textcolor = color.white)

// Alerts
alertcondition(buySignal, title = 'SuperTrend Buy', message = 'SuperTrend Buy!')
alertcondition(sellSignal, title = 'SuperTrend Sell', message = 'SuperTrend Sell!')
alertcondition(trend != trend[1], title = 'SuperTrend Direction Change', message = 'SuperTrend has changed direction!')
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//2- WAVETREND VT
//# * Author      : © LazyBear, modified by © therkut
////////////////////////
wave_ok = input(true, title = '═══════════════ WaveTrend Settings ')

group_wave = 'WaveTrend Settings'
chLength = input.int(10, 'Channel Length', minval = 1, group = group_wave)
avgLength = input.int(21, 'Average Length', minval = 1, group = group_wave)
sigLength = input.int(4, 'Signal Length', minval = 1, group = group_wave)
upperBand1 = input.int(60, 'Upper Band Level-1', group = group_wave)
upperBand2 = input.int(53, 'Upper Band Level-2', group = group_wave)
lowerBand2 = input.int(-53, 'Lower Band Level-2', group = group_wave)
lowerBand1 = input.int(-60, 'Lower Band Level-1', group = group_wave)
crosses = input.string('Strong', 'Display Crosses', options = ['Strong', 'All', 'None'], group = group_wave)
showWaveBuySignal = input.bool(true, title = 'Show WaveTrend Buy Signals', group = 'WaveTrend Settings')
showWaveSellSignal = input.bool(false, title = 'Show WaveTrend Sell Signals', group = 'WaveTrend Settings')

// WaveTrend Calculation
f_getWT(s, n1, n2, s1) =>
    esa = ta.ema(s, n1)
    d = ta.ema(math.abs(s - esa), n1)
    ci = (s - esa) / (0.015 * d)
    wt1 = ta.ema(ci, n2)
    wt2 = ta.sma(wt1, s1)
    [wt1, wt2]

[wt1, wt2] = f_getWT(hlc3, chLength, avgLength, sigLength)
lowerThreshold = math.avg(lowerBand1, lowerBand2)
upperThreshold = math.avg(upperBand1, upperBand2)

// Store crossover and crossunder results in global variables
crossover_wt = ta.crossover(wt1, wt2)
crossunder_wt = ta.crossunder(wt1, wt2)

// Plot WaveTrend
if wave_ok
    if crossover_wt and crosses != 'None'
        if wt1 < lowerThreshold and showWaveBuySignal
            label.new(bar_index, low, 'Buy', xloc.bar_index, yloc.price, color.green, label.style_label_up, color.white, size.normal)
        else if crosses != 'Strong' and wt1 < 0 and showWaveBuySignal
            label.new(bar_index, low, '', xloc.bar_index, yloc.price, color.green, label.style_label_up, color.white, size.tiny)

    if crossunder_wt and crosses != 'None'
        if wt1 > upperThreshold and showWaveSellSignal
            label.new(bar_index, high, 'Sell', xloc.bar_index, yloc.price, color.red, label.style_label_down, color.white, size.normal)
        else if crosses != 'Strong' and wt1 > 0 and showWaveSellSignal
            label.new(bar_index, high, '', xloc.bar_index, yloc.price, color.red, label.style_label_down, color.white, size.tiny)

// WaveTrend Alerts
alertcondition(wave_ok and crossover_wt and wt1 < lowerThreshold and showWaveBuySignal, title = 'WaveTrend Buy', message = 'WaveTrend Buy!')
alertcondition(wave_ok and crossunder_wt and wt1 > upperThreshold and showWaveSellSignal, title = 'WaveTrend Sell', message = 'WaveTrend Sell!')
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//3- FIBONACCI RETRACEMENT
////////////////////////
fibonacci_ok = input(true, title = '═══════════════ Fibonacci Retracement Settings ')

showFibonacci = input.bool(true, 'Show Fibonacci Retracement', group = 'Fibonacci', inline = 'Fib')
extendRight = input.bool(true, title = 'Fibonacci Extend Right', group = 'Fibonacci', inline = 'Fib')
showFibData = input.bool(true, title = 'Fibonacci Show Data', group = 'Fibonacci', inline = 'Fib')
length = input.int(233, minval = 8, title = 'Fibonacci Distance', group = 'Fibonacci')

fibHigh = ta.highest(length)
fibLow = ta.lowest(length)
fibColor = input.color(color.black, title = 'Fibonacci Color', group = 'Fibonacci')
highestBars = ta.highestbars(length)
lowestBars = ta.lowestbars(length)

fibLevel1 = input.int(618, title = 'Fib Level 1', group = 'Fibonacci', maxval = 1618)
fibLevel2 = input.int(382, title = 'Fib Level 2', group = 'Fibonacci', maxval = 1618)
fibLevel3 = input.int(786, title = 'Fib Level 3', group = 'Fibonacci', maxval = 1618)

if fibonacci_ok and barstate.islast
    fib618 = lowestBars > highestBars ? fibHigh - (fibHigh - fibLow) * fibLevel1 / 1000 : fibLow + (fibHigh - fibLow) * fibLevel1 / 1000
    fib50 = lowestBars > highestBars ? fibHigh - (fibHigh - fibLow) * 500 / 1000 : fibLow + (fibHigh - fibLow) * 500 / 1000
    fib382 = lowestBars > highestBars ? fibHigh - (fibHigh - fibLow) * fibLevel2 / 1000 : fibLow + (fibHigh - fibLow) * fibLevel2 / 1000
    fib786 = lowestBars > highestBars ? fibHigh - (fibHigh - fibLow) * fibLevel3 / 1000 : fibLow + (fibHigh - fibLow) * fibLevel3 / 1000
    line.new(bar_index - highestBars, fibHigh, bar_index + 50, fibHigh, color = fibColor, width = 1, extend = extendRight ? extend.right : extend.none)
    line.new(bar_index - lowestBars, fibLow, bar_index + 50, fibLow, color = fibColor, width = 1, extend = extendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib382, bar_index + 50, fib382, color = fibColor, style = line.style_dashed, extend = extendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib50, bar_index + 50, fib50, color = fibColor, style = line.style_dashed, extend = extendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib618, bar_index + 50, fib618, color = fibColor, style = line.style_dashed, extend = extendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib786, bar_index + 50, fib786, color = fibColor, style = line.style_dashed, extend = extendRight ? extend.none : extend.none)
    if showFibData
        label.new(bar_index + 55, fibHigh, 'Top ( ' + str.tostring(math.round_to_mintick(fibHigh)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
        label.new(bar_index + 55, fibLow, 'Bottom ( ' + str.tostring(math.round_to_mintick(fibLow)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
        label.new(bar_index + 55, fib382, str.tostring(fibLevel2 / 1000) + ' ( ' + str.tostring(math.round_to_mintick(fib382)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
        label.new(bar_index + 55, fib618, str.tostring(fibLevel1 / 1000) + ' ( ' + str.tostring(math.round_to_mintick(fib618)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
        label.new(bar_index + 55, fib50, '% 50 ( ' + str.tostring(math.round_to_mintick(fib50)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
        label.new(bar_index + 55, fib786, str.tostring(fibLevel3 / 1000) + ' ( ' + str.tostring(math.round_to_mintick(fib786)) + ' )', color = color.gray, style = label.style_none, textcolor = color.black)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//4- EMA 8/22/55
////////////////////////
ema_ok = input(true, title = '═══════════════ EMA Settings ')

ema1 = input.int(defval = 8, title = 'EMA 1', group = 'MA', inline = 'E1')
ema1Show = input.bool(defval = true, group = 'MA', inline = 'E1', title = '')

ema2 = input.int(defval = 22, title = 'EMA 2', group = 'MA', inline = 'E23')
ema2Show = input.bool(defval = true, group = 'MA', inline = 'E23', title = '')

ema3 = input.int(defval = 55, title = 'EMA 3', group = 'MA', inline = 'E3')
ema3Show = input.bool(defval = true, group = 'MA', inline = 'E3', title = '')

ema4 = input.int(defval = 200, title = 'EMA 4', group = 'MA', inline = 'E4')
ema4Show = input.bool(defval = true, group = 'MA', inline = 'E4', title = '')

// EMA Calculation
ema8 = ta.ema(close, ema1)
ema22 = ta.ema(close, ema2)
ema55 = ta.ema(close, ema3)
ema200 = ta.ema(close, ema4)

// Plot EMAs
// plot(ema1Show ? ema8 : na, title = 'EMA 8', color = color.blue, linewidth = 2)
// plot(ema2Show ? ema22 : na, title = 'EMA 22', color = color.red, linewidth = 2)
// plot(ema3Show ? ema55 : na, title = 'EMA 55', color = color.green, linewidth = 2)
plot(ema4Show ? ema200 : na, title = 'EMA 200', color = color.yellow, linewidth = 4)

// Display EMA 200 Value
if ema_ok and ema4Show and barstate.islast
    var label_id_200 = label.new(bar_index, na, "", xloc.bar_index, yloc.price, color.blue, label.style_label_left, color.white, size.normal, text.align_left)
    label.set_xy(label_id_200, bar_index, ema200)
    label.set_text(label_id_200, "EMA 200: " + str.tostring(ema200, format.mintick))

// Display Other EMA Values
if ema_ok and ema1Show and barstate.islast
    var label_id = label.new(bar_index, na, "", xloc.bar_index, yloc.price, color.blue, label.style_label_left, color.white, size.normal, text.align_left)
    ema_text = (ema3Show ? "EMA " + str.tostring(ema3) + ": " + str.tostring(math.round_to_mintick(ema55)) + "\n" : "") +
               (ema2Show ? "EMA " + str.tostring(ema2) + ": " + str.tostring(math.round_to_mintick(ema22)) + "\n" : "") +
               (ema1Show ? "EMA " + str.tostring(ema1) + ": " + str.tostring(math.round_to_mintick(ema8)) + "" : "")
    label.set_xy(label_id, bar_index + 5, ema8) 
    label.set_text(label_id, ema_text)
    label.set_tooltip(label_id, ema_text)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//4- ICHIMOKU
////////////////////////
ichimoku_ok = input(true, title = '═══════════════ Ichimoku Settings ')

conversionPeriods = input.int(9, minval = 1, title = 'Conversion Line Length', group = 'ICHIMOKU', inline = 'ICHIMOKU')
ichShow = input.bool(defval = true, group = 'ICHIMOKU', inline = 'ICHIMOKU', title = '')
basePeriods = input.int(26, minval = 1, title = 'Base Line Length', group = 'ICHIMOKU')
laggingSpan2Periods = input.int(52, minval = 1, title = 'Leading Span B Length', group = 'ICHIMOKU')
displacement = input.int(26, minval = 1, title = 'Lagging Span', group = 'ICHIMOKU')

// Ichimoku Calculation
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))
leadLine1 = math.avg(donchian(conversionPeriods), donchian(basePeriods))
leadLine2 = donchian(laggingSpan2Periods)
p1i = plot(ichimoku_ok and ichShow ? leadLine1 : na, offset = displacement - 1, color = #A5D6A7, title = 'Leading Span A')
p2i = plot(ichimoku_ok and ichShow ? leadLine2 : na, offset = displacement - 1, color = #EF9A9A, title = 'Leading Span B')
fill(p1i, p2i, color = leadLine1 > leadLine2 ? color.rgb(67, 160, 71, ichimoku_ok and ichShow ? 90 : 0) : color.rgb(244, 67, 54, ichimoku_ok and ichShow ? 90 : 0))
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//5- VOLUME BASED BARS
////////////////////////
vbcb_ok = input.bool(true, title = '═══════════════ Volume Based Coloured Bars Settings')
vbcb_length = input.int(21, 'Volume Based Bars Length', minval = 1)
vbcb_avrg = ta.sma(volume, vbcb_length)

// Volume and price conditions
vbcb_vold1 = volume > vbcb_avrg * 1.5 and close < open
vbcb_vold2 = volume >= vbcb_avrg * 0.5 and volume <= vbcb_avrg * 1.5 and close < open
vbcb_vold3 = volume < vbcb_avrg * 0.5 and close < open
vbcb_volu1 = volume > vbcb_avrg * 1.5 and close > open
vbcb_volu2 = volume >= vbcb_avrg * 0.5 and volume <= vbcb_avrg * 1.5 and close > open
vbcb_volu3 = volume < vbcb_avrg * 0.5 and close > open

// Define colors
vbcb_cold1 = #800000
vbcb_cold2 = #FF0000
vbcb_cold3 = color.orange
vbcb_colu1 = #006400
vbcb_colu2 = color.lime
vbcb_colu3 = #7FFFD4

vbcb_VolColor = vbcb_vold1 ? vbcb_cold1 : vbcb_vold2 ? vbcb_cold2 : vbcb_vold3 ? vbcb_cold3 : vbcb_volu1 ? vbcb_colu1 : vbcb_volu2 ? vbcb_colu2 : vbcb_volu3 ? vbcb_colu3 : na

barcolor(vbcb_ok ? vbcb_VolColor : na, title = 'Volume Based Coloured Bars')
//-----------------------------------------------------------------------------}

