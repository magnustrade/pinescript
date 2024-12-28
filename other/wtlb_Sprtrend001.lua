// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// by © therkut
//@version=6
//# * Use: Daily and 4H
//# * SuperTrend period: 
//# * for stock : 10,2/ 66,2/ 333,2/ 10,1/
//# * for Indx  : 10,2
var int max_bars_back = 5000
indicator("WaveTrend & SuperTrend", overlay= true, max_bars_back = max_bars_back)
//-----------------------------------------------------------------------------{
//1- SuperTrend
//# * Study       : SuperTrend 
//# * Author      : © KivancOzbilgic
////////////////////////
super_ok = input(true, title = '═══════════════ SuperTrend Settings ')

Periods = input(title = 'ATR Period', defval = 10)
st_src = input(hl2, title = 'Source')
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 3.0)
changeATR = input(false, title = 'Change ATR Calculation Method ?')
showsignals = input(false, title = 'Show Buy/Sell Signals ?')
highlighting = input(false, title = 'Highlighter On/Off ?')
atr2 = ta.sma(ta.tr, Periods)
atr = changeATR ? ta.atr(Periods) : atr2
up = st_src - Multiplier * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn = st_src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend
upPlot = plot(super_ok ? trend == 1 ? up : na : na, title = 'Up Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.green, 0))
buySignal = trend == 1 and trend[1] == -1
plotshape(super_ok ? buySignal ? up : na : na, title = 'UpTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.green, 0))
plotshape(super_ok ? buySignal and showsignals ? up : na : na, title = 'Buy', text = 'Buy', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.new(color.green, 0), textcolor = color.new(color.white, 0))
dnPlot = plot(super_ok ? trend == 1 ? na : dn : na, title = 'Down Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.red, 0))
sellSignal = trend == -1 and trend[1] == 1
plotshape(super_ok ? sellSignal ? dn : na : na, title = 'DownTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.red, 0))
plotshape(super_ok ? sellSignal and showsignals ? dn : na : na, title = 'Sell', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 0), textcolor = color.new(color.white, 0))
mPlot = plot(ohlc4, title = '', style = plot.style_circles, linewidth = math.max(1, math.max(1, 0)))
longFillColor = highlighting ? (trend == 1 ? color.new(color.green, 90) : color.new(color.white, 90)) : color.new(color.white, 90)
shortFillColor = highlighting ? (trend == -1 ? color.new(color.red, 90) : color.new(color.white, 90)) : color.new(color.white, 90)
fill(mPlot, upPlot, title = 'UpTrend Highligter', color = longFillColor)
fill(mPlot, dnPlot, title = 'DownTrend Highligter', color = shortFillColor)
alertcondition(buySignal, title = 'SuperTrend Buy', message = 'SuperTrend Buy!')
alertcondition(sellSignal, title = 'SuperTrend Sell', message = 'SuperTrend Sell!')
changeCond = trend != trend[1]
alertcondition(changeCond, title = 'SuperTrend Direction Change', message = 'SuperTrend has changed direction!')
//-----------------------------------------------------------------------------}


//-----------------------------------------------------------------------------{
//2- WaveTrend vX
//# * Study       : WaveTrend vX
//# * Author      : © LazyBear, modified by © dgtrd
////////////////////////
wtlb_ok = input(true, title = '═══════════════ WaveTrend Settings ')

// Functions  ----------------------------------------------------------------------------------- //

f_drawOnlyLabelX(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip) =>
    label.new(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip)

f_getWT(s, n1, n2, s1) =>
    esa = ta.ema(s, n1)
    d = ta.ema(math.abs(s - esa), n1)
    ci = (s - esa) / (0.015 * d)
    wt1 = ta.ema(ci, n2)
    wt2 = ta.sma(wt1, s1)

    [wt1, wt2]

alarm(_message) =>
    alert(syminfo.ticker + ' WT : ' + _message + ', price (' + str.tostring(close, format.mintick) + ')')

// ---------------------------------------------------------------------------------------------- //
// Inputs --------------------------------------------------------------------------------------- //

group_wave = 'WaveTrend Settings'
chLength = input.int(10, 'Channel Length', minval = 1, group = group_wave)
avgLength = input.int(21, 'Average Length', minval = 1, group = group_wave)
sigLength = input.int(4, 'Signal Length', minval = 1, group = group_wave)
upperBand1 = input.int(60, 'Upper Band Level-1', group = group_wave)
upperBand2 = input.int(53, 'Upper Band Level-2', group = group_wave)
lowerBand2 = input.int(-53, 'Lower Band Level-2', group = group_wave)
lowerBand1 = input.int(-60, 'Lower Band Level-1', group = group_wave)
tooltip_x = 'WaveTrend and Signal Line crosses\n - Strong : crosses in overbought/oversold zones\n' + ' - All : all crosses, bullish crosses both in bullish and bearish zone, and bearish corsses both in bullish and bearish zone\n\n' + 'where,\n * bullish zone when wavetrend is above midLine\n * bearish zone when wavetrend is below midLine'
crosses = input.string('Strong', 'Display Corsses', options = ['Strong', 'All', 'None'], group = group_wave, tooltip = tooltip_x)
valueLbl = input.bool(false, 'WaveTrend Values Label', group = group_wave)

compare = input.bool(false, 'Compare with ', inline = 'CPR')
symbol = input.symbol('BINANCE:BTCUSDT', '', inline = 'CPR')
// ---------------------------------------------------------------------------------------------- //
// Calculations --------------------------------------------------------------------------------- //

[wt1, wt2] = f_getWT(hlc3, chLength, avgLength, sigLength)
extSrc = request.security(symbol, timeframe.period, hlc3, barmerge.gaps_off, barmerge.lookahead_on)
[wt1x, wt2x] = f_getWT(extSrc, chLength, avgLength, sigLength)

lowerThreshold = math.avg(lowerBand1, lowerBand2)
upperThreshold = math.avg(upperBand1, upperBand2)

info = '\n\n * overbought level ' + str.tostring(upperThreshold, '#.##') + ',\n * oversold level ' + str.tostring(lowerThreshold, '#.##') + ',\n * 0 (zero) bull/bear equilibrium level\n    - below bear, above bull zone'

if ta.crossover(wt1, wt2)
    if crosses != 'None'
        if wt1 < lowerThreshold
            f_drawOnlyLabelX(bar_index, low, 'S', xloc.bar_index, yloc.price, #006400, label.style_label_up, color.white, size.normal, text.align_center, 'strong wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') below oversold threshold level' + info)
            alarm('strong cross below oversold threshold level, bullish sign')
        if crosses != 'Strong'
            if wt1 < 0 and wt1 > lowerThreshold
                f_drawOnlyLabelX(bar_index, low, '', xloc.bar_index, yloc.price, #388e3c, label.style_label_up, color.white, size.tiny, text.align_center, 'wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') in bear zone' + info)
            else if wt1 > 0
                f_drawOnlyLabelX(bar_index, low, '', xloc.bar_index, yloc.price, #7FFFD4, label.style_label_up, color.white, size.tiny, text.align_center, 'weak wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') in bull zone' + info)

if ta.crossunder(wt1, wt2)
    if crosses != 'None'
        if wt1 > upperThreshold
            f_drawOnlyLabelX(bar_index, high, 'S', xloc.bar_index, yloc.price, #910000, label.style_label_down, color.white, size.normal, text.align_center, 'strong wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') above overbought threshold level' + info)
            alarm('strong cross above overbought threshold level, bearish sign')
        if crosses != 'Strong'
            if wt1 > 0 and wt1 < upperThreshold
                f_drawOnlyLabelX(bar_index, high, '', xloc.bar_index, yloc.price, #f44336, label.style_label_down, color.white, size.tiny, text.align_center, 'wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') in bull zone' + info)
            else if wt1 < 0
                f_drawOnlyLabelX(bar_index, high, '', xloc.bar_index, yloc.price, #FF9800, label.style_label_down, color.white, size.tiny, text.align_center, 'weak wavetrend cross for ' + syminfo.tickerid + '\nwavetrend(' + str.tostring(wt1, '#.##') + ') in bear zone' + info)

//alertcondition(ta.cross(wt1, wt2), title='Trading Opportunity', message='Probable Trade Opportunity\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')

if ta.crossover(wt1x, wt2x) and compare
    if crosses != 'None'
        if wt1x < lowerThreshold
            f_drawOnlyLabelX(bar_index, low, 'S', xloc.bar_index, yloc.price, #787b86, label.style_label_up, color.white, size.tiny, text.align_center, 'strong wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') below oversold threshold level' + info)
        if crosses != 'Strong'
            if wt1x < 0 and wt1x > lowerThreshold
                f_drawOnlyLabelX(bar_index, low, '', xloc.bar_index, yloc.price, #787b86, label.style_label_up, color.white, size.tiny, text.align_center, 'wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') in bear zone' + info)
            else if wt1x > 0
                f_drawOnlyLabelX(bar_index, low, '', xloc.bar_index, yloc.price, #787b86, label.style_label_up, color.white, size.tiny, text.align_center, 'weak wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') in bull zone' + info)

if ta.crossunder(wt1x, wt2x) and compare
    if crosses != 'None'
        if wt1x > upperThreshold
            f_drawOnlyLabelX(bar_index, high, 'S', xloc.bar_index, yloc.price, #787b86, label.style_label_down, color.white, size.tiny, text.align_center, 'strong wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') above overbought threshold level' + info)
        if crosses != 'Strong'
            if wt1x > 0 and wt1x < upperThreshold
                f_drawOnlyLabelX(bar_index, high, '', xloc.bar_index, yloc.price, #787b86, label.style_label_down, color.white, size.tiny, text.align_center, 'wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') in bull zone' + info)
            else if wt1x < 0
                f_drawOnlyLabelX(bar_index, high, '', xloc.bar_index, yloc.price, #787b86, label.style_label_down, color.white, size.tiny, text.align_center, 'weak wavetrend cross for ' + symbol + ' (hlc3 : ' + str.tostring(extSrc, format.mintick) + ')\nwavetrend(' + str.tostring(wt1x, '#.##') + ') in bear zone' + info)

if valueLbl
    wt_text = wt1 < lowerThreshold ? '(oversold)' : wt1 > upperThreshold ? '(overbought)' : ''

    var lb_id = label.new(time + math.round(ta.change(time) * 5), close, '', xloc.bar_time, yloc.price, #4262ba, label.style_label_left, color.white, size.normal, text.align_left, syminfo.tickerid + ' current wavetrend(' + str.tostring(wt1, '#.##') + ')')
    label.set_xy(lb_id, time + math.round(ta.change(time) * 5), close)
    label.set_text(lb_id, str.tostring(wt1, '#.##') + ' : wavetrend ' + wt_text + '\n' + str.tostring(wt2, '#.##') + ' : signal level')
    label.set_tooltip(lb_id, compare ? syminfo.tickerid + '\nwavetrend : ' + str.tostring(wt1, '#.##') + ', signal :' + str.tostring(wt2, '#.##') + '\n\n' + symbol + '\nwavetrend : ' + str.tostring(wt1x, '#.##') + ', signal :' + str.tostring(wt2x, '#.##') : syminfo.tickerid + '\nwavetrend : ' + str.tostring(wt1, '#.##') + ', signal :' + str.tostring(wt2, '#.##'))

// ---------------------------------------------------------------------------------------------- //
// Overlay WaveTrend Plotting Settings  --------------------------------------------------------- //

group_ocs = 'Overlay WaveTrend Display Settings'
oscDisplay = input.bool(false, 'Overlay WaveTrend Display', group = group_ocs)
oscLookbackLength = input.int(200, 'Display Length', minval = 10, step = 10, maxval = 250, group = group_ocs)
oscPlacement = input.string('Middle', 'Placement', options = ['Top', 'Middle', 'Bottom'], group = group_ocs)
oscHight = 11 - input.int(7, 'Hight', minval = 1, maxval = 10, group = group_ocs)
oscVerticalOffset = input.int(3, 'Vertical Offset', minval = -3, maxval = 10, group = group_ocs) / 10
highlight = input.bool(false, 'Highlight WaveTrend/Signal Area')

osc = wt1
signal = wt2
histogram = wt1 - wt2

var a_lines = array.new_line()
var a_hist = array.new_box()
var a_fill = array.new_linefill()

priceHighest = ta.highest(high, oscLookbackLength)
priceLowest = ta.lowest(low, oscLookbackLength)
priceChangeRate = (priceHighest - priceLowest) / priceHighest
priceLowest := oscPlacement == 'Middle' ? priceLowest : priceLowest * (1 - priceChangeRate * oscVerticalOffset)
priceHighest := oscPlacement == 'Middle' ? priceHighest : priceHighest * (1 + priceChangeRate * oscVerticalOffset)
oscHighest = ta.highest(osc, oscLookbackLength)
oscLowest = ta.lowest(osc, oscLookbackLength)

if barstate.islast and oscDisplay
    if array.size(a_lines) > 0
        for i = 1 to array.size(a_lines) by 1
            line.delete(array.shift(a_lines))

    if array.size(a_hist) > 0
        for i = 1 to array.size(a_hist) by 1
            box.delete(array.shift(a_hist))

    if array.size(a_fill) > 0
        for i = 1 to array.size(a_fill) by 1
            linefill.delete(array.shift(a_fill))

    hight = priceChangeRate / oscHight
    oscColor = #008000
    signalColor = #FF0000
    histColor = #0000FF

    obLevel1 = oscPlacement == 'Middle' ? priceLowest + (upperBand1 - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + upperBand1 / oscHighest * hight)
    obLevel2 = oscPlacement == 'Middle' ? priceLowest + (upperBand2 - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + upperBand2 / oscHighest * hight)
    osLevel2 = oscPlacement == 'Middle' ? priceLowest + (lowerBand2 - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + lowerBand2 / oscHighest * hight)
    osLevel1 = oscPlacement == 'Middle' ? priceLowest + (lowerBand1 - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + lowerBand1 / oscHighest * hight)

    array.push(a_lines, line.new(bar_index[oscLookbackLength], obLevel1, bar_index, obLevel1, xloc.bar_index, extend.none, signalColor, line.style_solid, 1))
    array.push(a_lines, line.new(bar_index[oscLookbackLength], obLevel2, bar_index, obLevel2, xloc.bar_index, extend.none, signalColor, line.style_dotted, 2))
    array.push(a_lines, line.new(bar_index[oscLookbackLength], osLevel2, bar_index, osLevel2, xloc.bar_index, extend.none, oscColor, line.style_dotted, 2))
    array.push(a_lines, line.new(bar_index[oscLookbackLength], osLevel1, bar_index, osLevel1, xloc.bar_index, extend.none, oscColor, line.style_solid, 1))

    midLine = 0
    midLevel = oscPlacement == 'Middle' ? priceLowest + (midLine - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + midLine / oscHighest * hight)
    array.push(a_lines, line.new(bar_index[oscLookbackLength], midLevel, bar_index, midLevel, xloc.bar_index, extend.none, color.new(color.gray, 25), line.style_solid, 1))

    for barIndex = 0 to oscLookbackLength - 1 by 1
        if array.size(a_lines) < 498
            array.push(a_hist, box.new(bar_index[barIndex], oscPlacement == 'Top' ? priceHighest : priceLowest, bar_index[barIndex], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + histogram[barIndex] / oscHighest * hight), histColor[barIndex], 2))
            array.push(a_lines, line.new(bar_index[barIndex], oscPlacement == 'Middle' ? priceLowest + (osc[barIndex] - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : oscPlacement == 'Top' ? priceHighest * (1 + osc[barIndex] / oscHighest * hight) : priceLowest * (1 + osc[barIndex] / oscHighest * hight), bar_index[barIndex + 1], oscPlacement == 'Middle' ? priceLowest + (osc[barIndex + 1] - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : oscPlacement == 'Top' ? priceHighest * (1 + osc[barIndex + 1] / oscHighest * hight) : priceLowest * (1 + osc[barIndex + 1] / oscHighest * hight), xloc.bar_index, extend.none, highlight ? osc[barIndex] > signal[barIndex] ? oscColor : signalColor : oscColor, line.style_solid, 1))
            array.push(a_lines, line.new(bar_index[barIndex], oscPlacement == 'Middle' ? priceLowest + (signal[barIndex] - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : oscPlacement == 'Top' ? priceHighest * (1 + signal[barIndex] / oscHighest * hight) : priceLowest * (1 + signal[barIndex] / oscHighest * hight), bar_index[barIndex + 1], oscPlacement == 'Middle' ? priceLowest + (signal[barIndex + 1] - oscLowest) * (priceHighest - priceLowest) / (oscHighest - oscLowest) : oscPlacement == 'Top' ? priceHighest * (1 + signal[barIndex + 1] / oscHighest * hight) : priceLowest * (1 + signal[barIndex + 1] / oscHighest * hight), xloc.bar_index, extend.none, highlight ? osc[barIndex] > signal[barIndex] ? oscColor : signalColor : signalColor, line.style_solid, 1))
            if highlight
                array.push(a_fill, linefill.new(array.get(a_lines, 2 * barIndex + 5), array.get(a_lines, 2 * barIndex + 6), osc[barIndex] > signal[barIndex] ? color.new(oscColor, 50) : color.new(signalColor, 50)))

// Plotting  ------------------------------------------------------------------------------------ //

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(logo, 0, 0, '☼☾  ', text_size = size.normal, text_color = color.teal)


//-----------------------------------------------------------------------------}

// * alacağım hisseyi seçmeden önce son kontrolü yaptığım yer buranın forumu. ağlamalar kesildiyse hissede kimse kalmamış ve kağıt alınmaya hazır demektir.
// * source: https://eksisozluk.com/investing-com--3850583?p=30
// * Teknik olarak size yardımcı olacak 3 yardımcı araç var 👇

// * 1: Ortalamalar ( 8-22-55 )
// * 2: Ana Trend Çizgileri 
// * 3: Fibonacci 