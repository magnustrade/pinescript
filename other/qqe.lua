

//-----------------------------------------------------------------------------{
//10- Quantitative Qualitative Estimation
////////////////////////
qqe_ok = input(true, title = '═══════════════ Quantitative Qualitative Estimation Settings')

srcQqe = input(close)
lengthQqe = input.int(14, 'RSI lengthQqe', minval = 1)
SSF = input.int(5, 'SF RSI SMoothing Factor', minval = 1)
QQEshowsignals = input(title = 'Show Crossing Signals?', defval = true)
QQEhighlighting = input(title = 'Highlighter On/Off ?', defval = true)
RSII = ta.ema(ta.rsi(srcQqe, lengthQqe), SSF)
TR = math.abs(RSII - RSII[1])
wwalpha = 1 / lengthQqe
WWMA = 0.0
WWMA := wwalpha * TR + (1 - wwalpha) * nz(WWMA[1])
ATRRSI = 0.0
ATRRSI := wwalpha * WWMA + (1 - wwalpha) * nz(ATRRSI[1])
QQEF = ta.ema(ta.rsi(srcQqe, lengthQqe), SSF)
QUP = QQEF + ATRRSI * 4.236
QDN = QQEF - ATRRSI * 4.236
QQES = 0.0
QQES := QUP < nz(QQES[1]) ? QUP : QQEF > nz(QQES[1]) and QQEF[1] < nz(QQES[1]) ? QDN : QDN > nz(QQES[1]) ? QDN : QQEF < nz(QQES[1]) and QQEF[1] > nz(QQES[1]) ? QUP : nz(QQES[1])
QQF = plot(QQEF, 'FAST', color.new(color.maroon, 0), 2)
QQS = plot(QQES, 'SLOW', color = color.new(color.blue, 0), linewidth = 1)
plot(50, color = color.new(color.gray, 0), style = plot.style_circles, force_overlay=false)
QQElongFillColor = QQEhighlighting ? QQEF > QQES ? color.green : na : na
QQEshortFillColor = QQEhighlighting ? QQEF < QQES ? color.red : na : na
fill(QQF, QQS, title = 'UpTrend Highligter', color = QQElongFillColor)
fill(QQF, QQS, title = 'DownTrend Highligter', color = QQEshortFillColor)
buySignalr = ta.crossover(QQEF, QQES)
plotshape(buySignalr and QQEshowsignals ? QQES * 0.995 : na, title = 'Buy', text = 'Buy', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.new(color.green, 0), textcolor = color.new(color.white, 0), force_overlay=false)
sellSignallr = ta.crossunder(QQEF, QQES)
plotshape(sellSignallr and QQEshowsignals ? QQES * 1.005 : na, title = 'Sell', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 0), textcolor = color.new(color.white, 0), force_overlay=false)
alertcondition(ta.cross(QQEF, QQES), title = 'Cross Alert', message = 'QQE Crossing Signal!')
alertcondition(ta.crossover(QQEF, QQES), title = 'Crossover Alarm', message = 'QQE BUY SIGNAL!')
alertcondition(ta.crossunder(QQEF, QQES), title = 'Crossunder Alarm', message = 'QQE SELL SIGNAL!')
alertcondition(ta.crossover(QQEF, 50), title = 'Cross 50 Up Alert', message = 'QQE FAST Crossing 50 UP!')
alertcondition(ta.crossunder(QQEF, 50), title = 'Cross 50 Down Alert', message = 'QQE FAST Crossing 50 DOWN!')
//-----------------------------------------------------------------------------}
