

//-----------------------------------------------------------------------------{    
//4- Lines and Diagonal
//-----------------------------------------------------------------------------
diagonalSprs_ok = input(true, title = '═══════════════ Lines and Diagonal Settings ')

var int history_bars = input(title = 'History bars back', defval = 300)
show_balloons = input(false, title = 'Show Balloons')
col_sup = color.new(#17ff27, 50)
style_sup = line.style_solid
col_res = color.new(#ff77ad, 50)
style_res = line.style_solid

// Функция вычисляет цену в точке t3 для линии,
// заданной первыми четырьмя координатами (t1, p1, t2, p2)
price_at(t1, p1, t2, p2, t3) =>
    p1 + (p2 - p1) * (t3 - t1) / (t2 - t1)

// округление
round_to_tick(x) =>
    mult = 1 / syminfo.mintick
    value = math.ceil(x * mult) / mult
    value

// Тут храним линии для удаления при появлении нового бара
var array<line> supports = array.new_line()
var array<label> labels = array.new_label()
// Удаляем прошлые линии
line temp_line = na
if array.size(supports) > 0
    for i = array.size(supports) - 1 to 0 by 1
        temp_line := array.get(supports, i)
        line.delete(temp_line)
        array.remove(supports, i)
label temp_label = na
if array.size(labels) > 0
    for i = array.size(labels) - 1 to 0 by 1
        temp_label := array.get(labels, i)
        label.delete(temp_label)
        array.remove(labels, i)
        //supports := array.new_line()

// Определяем экстремумы
min_values = low
max_values = high
x1 = input(title = 'Resolution (bars)', defval = 6)
x2 = math.round(x1 / 2)
int minimums = 0
minimums := ta.lowestbars(min_values, x1) == -x2 ? x2 : minimums[1] + 1

int maximums = 0
maximums := ta.highestbars(max_values, x1) == -x2 ? x2 : maximums[1] + 1


int minimum1 = 0
int minimum2 = 0
int maximum1 = 0
int maximum2 = 0
int medium = 0
// Поддержка     
if barstate.islast
    //label.new(bar_index, close , style=label.style_labeldown, text=timeframe.period, color=color.new(color.red, 90))
    line last_line = na
    label last_label = na
    for k1 = 0 to 50 by 1
        if minimum1 >= history_bars
            break
        minimum1 := minimum1 + minimums[minimum1]
        minimum2 := minimum1 * 2
        for k2 = 0 to 50 by 1
            if minimum2 >= minimum1 * 8 or minimum2 >= history_bars
                break
            minimum2 := minimum2 + minimums[minimum2]

            if minimum1 >= history_bars or minimum2 >= history_bars
                break

            bar1 = bar_index - minimum1
            bar2 = bar_index - minimum2

            price1 = low[minimum1]
            price2 = low[minimum2]

            current_price = price_at(bar2, price2, bar1, price1, bar_index)
            // Если поддержка проходит ниже текущей цены
            if current_price < high[1]

                // проверяем пересечения
                crossed = 0
                medium := 0
                for k3 = 0 to 50 by 1
                    if medium >= minimum2
                        break
                    medium := medium + minimums[medium]
                    if medium >= minimum2
                        break
                    if price_at(bar2, price2, bar1, price1, bar_index - medium) > math.min(open[medium], close[medium])
                        crossed := 1
                        break

                // если нет пересечений        
                if crossed == 0 // and overtilt == 0
                    // сравниваем с прошлой созданной линией
                    if not na(last_line)
                        last_price = price_at(line.get_x1(last_line), line.get_y1(last_line), line.get_x2(last_line), line.get_y2(last_line), bar_index)
                        if bar1 == line.get_x2(last_line)
                            if current_price > last_price
                                line.set_xy1(last_line, bar2, price2)
                                line.set_xy2(last_line, bar1, price1)
                                line.set_color(last_line, col_sup)
                                label.set_xy(last_label, bar_index, current_price)
                                label.set_text(last_label, str.tostring(round_to_tick(current_price)))
                                true
                        else
                            last_line := line.new(bar2, price2, bar1, price1, extend = extend.right, color = col_sup, style = style_sup)
                            if show_balloons
                                last_label := label.new(bar_index, current_price, color = col_sup, style = label.style_label_upper_left, text = str.tostring(round_to_tick(current_price)))
                            array.push(labels, last_label)
                            array.push(supports, last_line)
                            true
                    else // добавляем линию
                        last_line := line.new(bar2, price2, bar1, price1, extend = extend.right, color = col_sup, style = style_sup)
                        if show_balloons
                            last_label := label.new(bar_index, current_price, color = col_sup, style = label.style_label_upper_left, text = str.tostring(round_to_tick(current_price)))
                        array.push(labels, last_label)
                        array.push(supports, last_line)
                        true

    last_line := na
    last_label := na
    for k1 = 0 to 100 by 1
        if maximum1 >= history_bars
            break
        maximum1 := maximum1 + maximums[maximum1]
        maximum2 := maximum1 * 2
        for k2 = 0 to 50 by 1
            if maximum2 >= maximum1 * 8 or maximum2 >= history_bars
                break
            maximum2 := maximum2 + maximums[maximum2]

            if maximum1 >= history_bars or maximum2 >= history_bars
                break

            bar1 = bar_index - maximum1
            bar2 = bar_index - maximum2

            price1 = high[maximum1]
            price2 = high[maximum2]

            current_price = price_at(bar2, price2, bar1, price1, bar_index)
            // Если сопротивоение проходит выше текущей цены
            if current_price > low[1]

                // проверяем пересечения
                crossed = 0
                medium := 0
                for k3 = 0 to 100 by 1
                    if medium >= maximum2
                        break
                    medium := medium + maximums[medium]
                    if medium >= maximum2
                        break
                    if price_at(bar2, price2, bar1, price1, bar_index - medium) < math.max(open[medium], close[medium])
                        crossed := 1
                        break

                // если нет пересечений        
                if crossed == 0 // and overtilt == 0
                    // сравниваем с прошлой созданной линией
                    if not na(last_line)
                        last_price = price_at(line.get_x1(last_line), line.get_y1(last_line), line.get_x2(last_line), line.get_y2(last_line), bar_index)
                        if bar1 == line.get_x2(last_line)
                            if current_price < last_price
                                line.set_xy1(last_line, bar2, price2)
                                line.set_xy2(last_line, bar1, price1)
                                line.set_color(last_line, col_res)
                                label.set_xy(last_label, bar_index, current_price)
                                label.set_text(last_label, str.tostring(round_to_tick(current_price)))

                                true
                        else
                            last_line := line.new(bar2, price2, bar1, price1, extend = extend.right, color = col_res, style = style_res)
                            if show_balloons
                                last_label := label.new(bar_index, current_price, color = col_res, style = label.style_label_lower_left, text = str.tostring(round_to_tick(current_price)))
                            array.push(labels, last_label)
                            array.push(supports, last_line)
                            true
                    else // добавляем линию
                        last_line := line.new(bar2, price2, bar1, price1, extend = extend.right, color = col_res, style = style_res)
                        if show_balloons
                            last_label := label.new(bar_index, current_price, color = col_res, style = label.style_label_lower_left, text = str.tostring(round_to_tick(current_price)))

                        array.push(labels, last_label)
                        array.push(supports, last_line)
                        true



volMALength = input(20, title = 'STDDEV: Volume MA Length')
stdevLength = input(20, title = 'STDDEV: Length')
stdevHigh = input(2.50, title = 'STDDEV: Threshold High')
stdevExtreme = input(3.00, title = 'STDDEV: Threshold Extreme')
wickminimum = input(50.00, title = 'Minimum Wick Length [% of Body]')
linelength = input(300, title = 'Length of Lines (No of Candles)')
colorstrength = input.string(title = 'Line Color Intensity', defval = 'STRONG', options = ['STRONG', 'WEAK'])
display = input.string(title = 'Display Support/Resistance', defval = 'ALL', options = ['RESISTANCE', 'SUPPORT', 'ALL'])
display2 = input.string(title = 'Display High/Extreme Volume', defval = 'ALL', options = ['HIGH', 'EXTREME', 'ALL'])
display3 = input.string(title = 'Display WICK / WICK Range', defval = 'WICK', options = ['RANGE', 'WICK'])
signals = input(false, title = 'Show Signal Triangles?')


// Calculation
volumeVal = volume
volumeMA = ta.sma(volumeVal, volMALength)
stdevValue = ta.stdev(volumeVal, stdevLength)

extremeVol = volumeMA + stdevExtreme * stdevValue // Extreme Volume Threshold
highVol = volumeMA + stdevHigh * stdevValue // High Volume Threshold

bullcandle = close >= open
bearcandle = close < open

bodylength = math.abs(open - close)
wicklength = bearcandle ? math.abs(low - close) : math.abs(high - close)
wickratio = wicklength / bodylength * 100

rel_wick = wickratio >= wickminimum // Relevant Wick?

vol_above_limit1 = volumeVal > highVol and volumeVal < extremeVol and rel_wick
vol_above_limit2 = volumeVal >= extremeVol and rel_wick

// Strong Colors
Scol_green1 = color.new(color.green, 40) // Weak Green
Scol_green2 = color.new(color.green, 10) // Strong Green
Scol_red1 = color.new(color.red, 40) // Weak Red
Scol_red2 = color.new(color.red, 10) // Strong Red

// Weak Colors
Wcol_green1 = color.new(color.green, 80) // Weak Green
Wcol_green2 = color.new(color.green, 50) // Strong Green
Wcol_red1 = color.new(color.red, 80) // Weak Red
Wcol_red2 = color.new(color.red, 50) // Strong Red

col_green1 = colorstrength == 'STRONG' ? Scol_green1 : Wcol_green1
col_green2 = colorstrength == 'STRONG' ? Scol_green2 : Wcol_green2
col_red1 = colorstrength == 'STRONG' ? Scol_red1 : Wcol_red1
col_red2 = colorstrength == 'STRONG' ? Scol_red2 : Wcol_red2

if diagonalSprs_ok
  plotshape(vol_above_limit1 and bullcandle and signals ? close : na, title = 'Resistance - Volume above Threshold', style = shape.triangledown, location = location.abovebar, color = col_red2, size = size.tiny)
  plotshape(vol_above_limit2 and bullcandle and signals ? close : na, title = 'Resistance - Volume above Threshold x 2', style = shape.triangledown, location = location.abovebar, color = col_red1, size = size.tiny)
  plotshape(vol_above_limit1 and bearcandle and signals ? close : na, title = 'Support - Volume above Threshold', style = shape.triangleup, location = location.belowbar, color = col_green2, size = size.tiny)
  plotshape(vol_above_limit2 and bearcandle and signals ? close : na, title = 'Support - Volume above Threshold x 2', style = shape.triangleup, location = location.belowbar, color = col_green1, size = size.tiny)


chper = time - time[1]
chper := ta.change(chper) > 0 ? chper[1] : chper


if vol_above_limit1 and bullcandle and (display == 'ALL' or display == 'RESISTANCE') and (display2 == 'ALL' or display2 == 'HIGH') and display3 == 'RANGE'
    bull1 = line.new(time, close, time + chper * linelength, close, xloc = xloc.bar_time, color = col_red1, style = line.style_solid, width = 1)
    bull2 = line.new(time, high, time + chper * linelength, high, xloc = xloc.bar_time, color = col_red1, style = line.style_solid, width = 1)
    bull3 = line.new(time, (high + close) / 2, time + chper * linelength, (high + close) / 2, xloc = xloc.bar_time, color = col_red1, style = line.style_solid, width = 2)
    bull3
if vol_above_limit1 and bullcandle and (display == 'ALL' or display == 'RESISTANCE') and (display2 == 'ALL' or display2 == 'HIGH') and display3 == 'WICK'
    bull4 = line.new(time, high, time + chper * linelength, high, xloc = xloc.bar_time, color = col_red1, style = line.style_solid, width = 2)
    bull4


if vol_above_limit2 and bullcandle and (display == 'ALL' or display == 'RESISTANCE') and (display2 == 'ALL' or display2 == 'EXTREME') and display3 == 'RANGE'
    bull1 = line.new(time, close, time + chper * linelength, close, xloc = xloc.bar_time, color = col_red2, style = line.style_solid, width = 1)
    bull2 = line.new(time, high, time + chper * linelength, high, xloc = xloc.bar_time, color = col_red2, style = line.style_solid, width = 1)
    bull3 = line.new(time, (high + close) / 2, time + chper * linelength, (high + close) / 2, xloc = xloc.bar_time, color = col_red2, style = line.style_solid, width = 2)
    bull3
if vol_above_limit2 and bullcandle and (display == 'ALL' or display == 'RESISTANCE') and (display2 == 'ALL' or display2 == 'EXTREME') and display3 == 'WICK'
    bull4 = line.new(time, high, time + chper * linelength, high, xloc = xloc.bar_time, color = col_red2, style = line.style_solid, width = 2)
    bull4


if vol_above_limit1 and bearcandle and (display == 'ALL' or display == 'SUPPORT') and (display2 == 'ALL' or display2 == 'HIGH') and display3 == 'RANGE'
    bear1 = line.new(time, close, time + chper * linelength, close, xloc = xloc.bar_time, color = col_green1, style = line.style_solid, width = 1)
    bear2 = line.new(time, low, time + chper * linelength, low, xloc = xloc.bar_time, color = col_green1, style = line.style_solid, width = 1)
    bear3 = line.new(time, (low + close) / 2, time + chper * linelength, (low + close) / 2, xloc = xloc.bar_time, color = col_green1, style = line.style_solid, width = 2)
    bear3
if vol_above_limit1 and bearcandle and (display == 'ALL' or display == 'SUPPORT') and (display2 == 'ALL' or display2 == 'HIGH') and display3 == 'WICK'
    bear4 = line.new(time, low, time + chper * linelength, low, xloc = xloc.bar_time, color = col_green1, style = line.style_solid, width = 2)
    bear4

if vol_above_limit2 and bearcandle and (display == 'ALL' or display == 'SUPPORT') and (display2 == 'ALL' or display2 == 'EXTREME') and display3 == 'RANGE'
    bear1 = line.new(time, close, time + chper * linelength, close, xloc = xloc.bar_time, color = col_green2, style = line.style_solid, width = 1)
    bear2 = line.new(time, low, time + chper * linelength, low, xloc = xloc.bar_time, color = col_green2, style = line.style_solid, width = 1)
    bear3 = line.new(time, (low + close) / 2, time + chper * linelength, (low + close) / 2, xloc = xloc.bar_time, color = col_green2, style = line.style_solid, width = 2)
    bear3
if vol_above_limit2 and bearcandle and (display == 'ALL' or display == 'SUPPORT') and (display2 == 'ALL' or display2 == 'EXTREME') and display3 == 'WICK'
    bear4 = line.new(time, low, time + chper * linelength, low, xloc = xloc.bar_time, color = col_green2, style = line.style_solid, width = 2)
    bear4

//-----------------------------------------------------------------------------}
