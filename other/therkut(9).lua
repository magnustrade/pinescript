// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// by © therkut
//@version=6
var int max_bars_back = 5000
indicator("therkut(9)", overlay= true, max_bars_back = max_bars_back)
//-----------------------------------------------------------------------------{}

//-----------------------------------------------------------------------------{
//1- SuperTrend
////////////////////////
super_ok = input(true, title = '═══════════════ SuperTrend Settings ')

Periods = input(title = 'ATR Period', defval = 10)
st_src = input(hl2, title = 'Source')
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 3.0)
changeATR = input(title = 'Change ATR Calculation Method ?', defval = false)
showsignals = input(title = 'Show Buy/Sell Signals ?', defval = true)
highlighting = input(title = 'Highlighter On/Off ?', defval = false)
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


//-----------------------------------------------------------------------------
//2- Support and Resistance on Multi Timeframe (Sup&Res&Trends)
//-----------------------------------------------------------------------------
// Inputs
SupResTrends_ok = input(false, title = '═══════════════ Sup&Res&Trends Enabled')

psin_syuv = input.bool(true, 'show trend lines?', group = 'settings')
ssoi_eib = input.timeframe('', 'choose higher time frame', group = 'sup & res')
aldj_asd = input.int(15, minval = 1, title = 'Pivot Length Left Hand Side (current)', group = 'current time frame sup & res')
aau_fpa = input.int(20, minval = 1, title = 'Pivot Length Left Hand Side (HTF)', group = 'higher time frame sup & res')
asdm_qdpo = input.source(low, 'pivot low source', group = 'Trend 1 pivots')
asdm_qdpo2 = input.source(low, 'pivot low source2', group = 'Trend 2 piovots')
dko_adj = input.int(10, minval = 1, title = 'Pivot Length Right Hand Side (current)', group = 'current time frame sup & res')
soef = input.int(title = 'Lower time frame line width  ', defval = 5, group = 'sup & res')
anfl_sfjd = input.source(high, 'pivot high source', group = 'Trend 1 pivots')
dapn_dwen = input.int(15, minval = 1, title = 'Pivot Length Right Hand Side (HTF)', group = 'higher time frame sup & res')
sdnt_sadm = input.bool(true, 'show sup & res ?', group = 'settings', inline = 'ptu')
anfl_sfjd2 = input.source(high, 'pivot high source2', group = 'Trend 2 piovots')
rowb_sqpf = input(20, 'left bars for pivot', group = 'Trend 1 pivots')
weo_sef = input.int(2, 'number of current TF pivots', group = 'settings', minval = 2, inline = 'ptu')
htf1_soef = input.int(title = 'Higher time frame line width ', defval = 18, group = 'sup & res')
rowb_sqpf2 = input(10, 'left bars for pivot2', group = 'Trend 2 piovots')
qurn_asmd = rowb_sqpf
afns_fkep = input(15, 'right bars for pivot', group = 'Trend 1 pivots')
afns_fkep2 = input(10, 'right bars for pivot2', group = 'Trend 2 piovots')
fsdn_scan = input.int(2, 'number of higher  TF pivots', group = 'settings', minval = 2, inline = 'fspon')
qurn_asmd2 = rowb_sqpf2
sow_dow2 = afns_fkep2
weu_seib = input.int(5, 'number of pivots', minval = 0, maxval = 10)
sow_dow = afns_fkep
find_pivot_low_function(wte_wqe, qfpn_Asej, eqmw, weu_seib) =>
    var wote_nfd = array.new_float(weu_seib)
    var dfnl_sdef = array.new_int(weu_seib)
    sfin = nz(ta.pivotlow(wte_wqe, qfpn_Asej, eqmw))
    if not na(ta.pivotlow(wte_wqe, qfpn_Asej, eqmw))
        array.unshift(wote_nfd, sfin)
        array.unshift(dfnl_sdef, bar_index[eqmw])
    [array.get(dfnl_sdef, 1), array.get(wote_nfd, 1), array.get(dfnl_sdef, 0), array.get(wote_nfd, 0)]
[wpyr_cxm, rpwn_xbvc, cxlv_shfe, xkcn_egso] = find_pivot_low_function(asdm_qdpo, rowb_sqpf, afns_fkep, weu_seib)
[wpyr_cxm2, rpwn_xbvc2, cxlv_shfe2, xkcn_egso2] = find_pivot_low_function(asdm_qdpo2, rowb_sqpf2, afns_fkep2, weu_seib)
find_pivot_high_function(vskb_seog, qfpn_Asej, eqmw, weu_seib) =>
    var pvtm_zoem = array.new_float(weu_seib)
    var avxc_rpsd = array.new_int(weu_seib)
    dpag = nz(ta.pivothigh(vskb_seog, qfpn_Asej, eqmw))
    if not na(ta.pivothigh(vskb_seog, qfpn_Asej, eqmw))
        array.unshift(pvtm_zoem, dpag)
        array.unshift(avxc_rpsd, bar_index[eqmw])
    [array.get(avxc_rpsd, 1), array.get(pvtm_zoem, 1), array.get(avxc_rpsd, 0), array.get(pvtm_zoem, 0)]
[vpan_ekfn, vamv_sdrj, svpn_masb, svdp_qrhp] = find_pivot_high_function(anfl_sfjd, qurn_asmd, sow_dow, weu_seib)
[vpan_ekfn2, vamv_sdrj2, svpn_masb2, svdp_qrhp2] = find_pivot_high_function(anfl_sfjd2, qurn_asmd2, sow_dow2, weu_seib)
aspfn = svpn_masb - vpan_ekfn
plotshape(not na(ta.pivothigh(high, qurn_asmd, sow_dow)) ? close : na, '', shape.triangledown, location.abovebar, color.rgb(229, 255, 82), -sow_dow, size = size.auto)

plotshape(not na(ta.pivotlow(low, rowb_sqpf, afns_fkep)) ? close : na, '', shape.triangleup, location.belowbar, color.rgb(211, 0, 230), -afns_fkep, size = size.auto)
var line avpb_epsf = na
var line vsln_epvi = na
var line afke_epnv = na
var line qmvz_flkd = na
var line avpb_epsf2 = na
var line vsln_epvi2 = na
if psin_syuv
    line.delete(avpb_epsf)
    line.delete(vsln_epvi)
    avpb_epsf := line.new(vpan_ekfn, vamv_sdrj, svpn_masb, svdp_qrhp, extend = extend.right, color = color.rgb(249, 82, 255), width = 3)
    vsln_epvi := line.new(wpyr_cxm, rpwn_xbvc, cxlv_shfe, xkcn_egso, extend = extend.right, color = color.rgb(15, 76, 241), width = 3)
    line.delete(afke_epnv)
    line.delete(qmvz_flkd)
    line.delete(avpb_epsf2)
    line.delete(vsln_epvi2)
    avpb_epsf2 := line.new(vpan_ekfn2, vamv_sdrj2, svpn_masb2, svdp_qrhp2, extend = extend.right, color = color.rgb(239, 144, 144), width = 1, style = line.style_dashed)
    vsln_epvi2 := line.new(wpyr_cxm2, rpwn_xbvc2, cxlv_shfe2, xkcn_egso2, extend = extend.right, color = color.rgb(185, 220, 203), width = 1, style = line.style_dashed)
    if svdp_qrhp >= vamv_sdrj and xkcn_egso >= rpwn_xbvc
        line.delete(afke_epnv)
        line.delete(qmvz_flkd)
        line.delete(avpb_epsf)
        line.delete(vsln_epvi)
        qmvz_flkd := line.new(wpyr_cxm, rpwn_xbvc, cxlv_shfe, xkcn_egso, extend = extend.right, color = color.rgb(230, 176, 0), width = 5)
        qmvz_flkd
    if svdp_qrhp <= vamv_sdrj and xkcn_egso <= rpwn_xbvc
        line.delete(afke_epnv)
        line.delete(qmvz_flkd)
        line.delete(avpb_epsf)
        line.delete(vsln_epvi)
        afke_epnv := line.new(vpan_ekfn, vamv_sdrj, svpn_masb, svdp_qrhp, extend = extend.right, color = color.rgb(236, 42, 236, 70), width = 5)
        afke_epnv
vqpb_Sdva = extend.right
pivot_line_function(weu_seib, vvmf_igsf, qpfb_Sfg) =>
    var wote_nfd = array.new_float(weu_seib, 0.0)
    var zvbd_eotx = array.new_int(weu_seib, 0)
    var pvtm_zoem = array.new_float(weu_seib, 0.0)
    var pbnr_adiov = array.new_int(weu_seib, 0)
    vzfk_vkcv = ta.pivothigh(high, vvmf_igsf, qpfb_Sfg)
    vewp_enab = ta.pivotlow(low, vvmf_igsf, qpfb_Sfg)
    not_nz_vzfk_vkcv = nz(vzfk_vkcv)
    not_nz_vewp_enab = nz(vewp_enab)
    vzfk_vkcvs = fixnan(vzfk_vkcv)
    vewp_enabs = fixnan(vewp_enab)
    sofib = not na(vzfk_vkcv)
    spnbf = not na(vewp_enab)
    if spnbf
        array.unshift(wote_nfd, not_nz_vewp_enab)
        array.unshift(zvbd_eotx, time[qpfb_Sfg])
    if sofib
        array.unshift(pvtm_zoem, not_nz_vzfk_vkcv)
        array.unshift(pbnr_adiov, time[qpfb_Sfg])
    fsobfs = array.get(wote_nfd, 0)
    sfpnb = array.get(wote_nfd, 1)
    sdFdn = array.get(zvbd_eotx, 0)
    nDkG = array.get(zvbd_eotx, 1)
    sFtHJ = array.get(pvtm_zoem, 0)
    fsPEjf = array.get(pvtm_zoem, 1)
    eipvn_sj = array.get(pbnr_adiov, 0)
    sdbp_eFzs = array.get(pbnr_adiov, 1)
    if spnbf
        if sdFdn - nDkG < sdFdn - eipvn_sj
            if fsobfs <= sfpnb
                array.remove(wote_nfd, 1)
                array.remove(zvbd_eotx, 1)
            else
                array.remove(wote_nfd, 0)
                array.remove(zvbd_eotx, 0)
        if array.size(wote_nfd) > weu_seib
            array.pop(wote_nfd)
        if array.size(zvbd_eotx) > weu_seib
            array.pop(zvbd_eotx)
    if sofib
        if eipvn_sj - sdbp_eFzs < eipvn_sj - sdFdn
            if sFtHJ >= fsPEjf
                array.remove(pvtm_zoem, 1)
                array.remove(pbnr_adiov, 1)
            else
                array.remove(pvtm_zoem, 0)
                array.remove(pbnr_adiov, 0)
        if array.size(pvtm_zoem) > weu_seib
            array.pop(pvtm_zoem)
        if array.size(pbnr_adiov) > weu_seib
            array.pop(pbnr_adiov)
    [wote_nfd, zvbd_eotx, pvtm_zoem, pbnr_adiov, vzfk_vkcvs, vewp_enabs, vzfk_vkcv, vewp_enab]
[wote_nfd, zvbd_eotx, pvtm_zoem, pbnr_adiov, vzfk_vkcvs, vewp_enabs, vzfk_vkcv, vewp_enab] = pivot_line_function(weo_sef, aldj_asd, dko_adj)
[htf_wote_nfd, htf_zvbd_eotx, htf_pvtm_zoem, htf_pbnr_adiov, htf_vzfk_vkcvs, htf_vewp_enabs, htf_vzfk_vkcv, htf_vewp_enab] = request.security(syminfo.tickerid, ssoi_eib, pivot_line_function(fsdn_scan, aau_fpa, dapn_dwen))
var line wprib_abDs = na
var line sdpb_ebQW = na
var line WEe_snS = na
var line peU_snDK = na
var Geo_Snhd = array.new<line>(weo_sef, line.new(0, 1, 2, 3))
var eowb_wndS = array.new<line>(weo_sef, line.new(0, 1, 2, 3))
var dsalb_adaG = array.new<line>(fsdn_scan, line.new(0, 1, 2, 3))
var sda_sdn_s = array.new<line>(fsdn_scan, line.new(0, 1, 2, 3))
if not na(vewp_enab) or not na(vzfk_vkcv)
    if sdnt_sadm
        nvpW_ncS = line.all
        if array.size(nvpW_ncS) > weo_sef - 1
            for i = 0 to array.size(nvpW_ncS) - 1 by 1
                line.delete(array.get(nvpW_ncS, i))
        for i = 0 to weo_sef - 1 by 1
            line.delete(array.get(Geo_Snhd, i))
            sdpb_ebQW := line.new(x1 = array.get(zvbd_eotx, i), y1 = array.get(wote_nfd, i), x2 = time, y2 = array.get(wote_nfd, i), extend = vqpb_Sdva, color = color.aqua, width = soef, xloc = xloc.bar_time)
            array.unshift(Geo_Snhd, sdpb_ebQW)
            if array.size(Geo_Snhd) > weo_sef
                array.pop(Geo_Snhd)
        for i = 0 to weo_sef - 1 by 1
            line.delete(array.get(eowb_wndS, i))
            wprib_abDs := line.new(x1 = array.get(pbnr_adiov, i), y1 = array.get(pvtm_zoem, i), x2 = time, y2 = array.get(pvtm_zoem, i), extend = vqpb_Sdva, color = color.aqua, width = soef, xloc = xloc.bar_time)
            array.unshift(eowb_wndS, wprib_abDs)
            if array.size(eowb_wndS) > weo_sef
                array.pop(eowb_wndS)
    if sdnt_sadm
        if array.size(dsalb_adaG) > 0
            for i = 0 to fsdn_scan - 1 by 1
                line.delete(array.get(dsalb_adaG, i))
                peU_snDK := line.new(x1 = array.get(htf_zvbd_eotx, i), y1 = array.get(htf_wote_nfd, i), x2 = time, y2 = array.get(htf_wote_nfd, i), extend = vqpb_Sdva, color = color.aqua, width = htf1_soef, xloc = xloc.bar_time)
                array.unshift(dsalb_adaG, peU_snDK)
                if array.size(dsalb_adaG) > fsdn_scan
                    array.pop(dsalb_adaG)
        if array.size(sda_sdn_s) > 0
            for i = 0 to fsdn_scan - 1 by 1
                line.delete(array.get(sda_sdn_s, i))
                WEe_snS := line.new(x1 = array.get(htf_pbnr_adiov, i), y1 = array.get(htf_pvtm_zoem, i), x2 = time, y2 = array.get(htf_pvtm_zoem, i), extend = vqpb_Sdva, color = color.aqua, width = htf1_soef, xloc = xloc.bar_time)
                array.unshift(sda_sdn_s, WEe_snS)
                if array.size(sda_sdn_s) > fsdn_scan
                    array.pop(sda_sdn_s)
if sdnt_sadm
    for i in Geo_Snhd
        line.set_color(i, close > line.get_y1(i) ? color.rgb(0, 230, 119, 51) : color.rgb(255, 82, 82, 51))
    for i in eowb_wndS
        line.set_color(i, close > line.get_y1(i) ? color.rgb(0, 230, 119, 50) : color.rgb(255, 82, 82, 51))
if sdnt_sadm
    for i in dsalb_adaG
        line.set_color(i, close > line.get_y1(i) ? color.rgb(0, 230, 119, 74) : color.rgb(255, 82, 82, 74))
    for i in sda_sdn_s
        line.set_color(i, close > line.get_y1(i) ? color.rgb(0, 230, 119, 79) : color.rgb(255, 82, 82, 74))
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------{    
//3- Lines and Diagonal
//-----------------------------------------------------------------------------
diagonalSprs_ok = input(false, title = '═══════════════ Lines and Diagonal Settings ')

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


//-----------------------------------------------------------------------------{    
//4- Support Resistance - Dynamic v2
//-----------------------------------------------------------------------------
Sprs_ok = input(true, title = '═══════════════ Support Resistance - Dynamic v2 Settings ')

SprsPrd = input.int(defval = 10, title = 'Pivot Period', minval = 4, maxval = 30, group = 'Setup')
ppsrc = input.string(defval = 'High/Low', title = 'Source', options = ['High/Low', 'Close/Open'], group = 'Setup')
maxnumpp = input.int(defval = 20, title = ' Maximum Number of Pivot', minval = 5, maxval = 100, group = 'Setup')
ChannelW = input.int(defval = 10, title = 'Maximum Channel Width %', minval = 1, group = 'Setup')
maxnumsr = input.int(defval = 5, title = ' Maximum Number of S/R', minval = 1, maxval = 10, group = 'Setup')
min_strength = input.int(defval = 2, title = ' Minimum Strength', minval = 1, maxval = 10, group = 'Setup')
labellocSprs = input.int(defval = 20, title = 'Label Location', group = 'Colors', tooltip = 'Positive numbers reference future bars, negative numbers reference histical bars')
linestyle = input.string(defval = 'Dashed', title = 'Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = 'Colors')
linewidth = input.int(defval = 2, title = 'Line Width', minval = 1, maxval = 4, group = 'Colors')
resistancecolor = input.color(defval = color.red, title = 'Resistance Color', group = 'Colors')
supportcolor = input.color(defval = color.lime, title = 'Support Color', group = 'Colors')
showpp = input(false, title = 'Show Point Points')

float src1 = ppsrc == 'High/Low' ? high : math.max(close, open)
float src2 = ppsrc == 'High/Low' ? low : math.min(close, open)
float phSprs = ta.pivothigh(src1, SprsPrd, SprsPrd)
float plSprs = ta.pivotlow(src2, SprsPrd, SprsPrd)

plotshape(bool(phSprs) and showpp, text = 'H', style = shape.labeldown, color = na, textcolor = color.new(color.red, 0), location = location.abovebar, offset = -SprsPrd)
plotshape(bool(plSprs) and showpp, text = 'L', style = shape.labelup, color = na, textcolor = color.new(color.lime, 0), location = location.belowbar, offset = -SprsPrd)

Lstyle = linestyle == 'Dashed' ? line.style_dashed : linestyle == 'Solid' ? line.style_solid : line.style_dotted

//calculate maximum S/R channel zone width
prdhighest = ta.highest(300)
prdlowest = ta.lowest(300)
cwidth = (prdhighest - prdlowest) * ChannelW / 100

var pivotvals = array.new_float(0)

if bool(phSprs) or bool(plSprs)
    array.unshift(pivotvals, bool(phSprs) ? phSprs : plSprs)
    if array.size(pivotvals) > maxnumpp // limit the array size
        array.pop(pivotvals)

get_sr_vals(ind) =>
    float lo = array.get(pivotvals, ind)
    float hi = lo
    int numpp = 0
    for y = 0 to array.size(pivotvals) - 1 by 1
        float cpp = array.get(pivotvals, y)
        float wdth = cpp <= lo ? hi - cpp : cpp - lo
        if wdth <= cwidth // fits the max channel width?
            if cpp <= hi
                lo := math.min(lo, cpp)
                lo
            else
                hi := math.max(hi, cpp)
                hi

            numpp := numpp + 1
            numpp
    [hi, lo, numpp]

var sr_up_level = array.new_float(0)
var sr_dn_level = array.new_float(0)
sr_strength = array.new_float(0)

find_loc(strength) =>
    ret = array.size(sr_strength)
    for i = ret > 0 ? array.size(sr_strength) - 1 : na to 0 by 1
        if strength <= array.get(sr_strength, i)
            break
        ret := i
        ret
    ret

check_sr(hi, lo, strength) =>
    ret = true
    for i = 0 to array.size(sr_up_level) > 0 ? array.size(sr_up_level) - 1 : na by 1
        //included?
        if array.get(sr_up_level, i) >= lo and array.get(sr_up_level, i) <= hi or array.get(sr_dn_level, i) >= lo and array.get(sr_dn_level, i) <= hi
            if strength >= array.get(sr_strength, i)
                array.remove(sr_strength, i)
                array.remove(sr_up_level, i)
                array.remove(sr_dn_level, i)
                ret
            else
                ret := false
                ret
            break
    ret

var sr_lines = array.new_line(11, na)
var sr_labels = array.new_label(11, na)

for x = 1 to 10 by 1
    rate = 100 * (label.get_y(array.get(sr_labels, x)) - close) / close
    label.set_text(array.get(sr_labels, x), text = str.tostring(label.get_y(array.get(sr_labels, x))) + '(' + str.tostring(rate, '#.##') + '%)')
    label.set_x(array.get(sr_labels, x), x = bar_index + labellocSprs)
    label.set_color(array.get(sr_labels, x), color = label.get_y(array.get(sr_labels, x)) >= close ? color.red : color.lime)
    label.set_textcolor(array.get(sr_labels, x), textcolor = label.get_y(array.get(sr_labels, x)) >= close ? color.white : color.black)
    label.set_style(array.get(sr_labels, x), style = label.get_y(array.get(sr_labels, x)) >= close ? label.style_label_down : label.style_label_up)
    line.set_color(array.get(sr_lines, x), color = line.get_y1(array.get(sr_lines, x)) >= close ? resistancecolor : supportcolor)

if bool(phSprs) or bool(plSprs)
    //because of new calculation, remove old S/R levels
    array.clear(sr_up_level)
    array.clear(sr_dn_level)
    array.clear(sr_strength)
    //find S/R zones
    for x = 0 to array.size(pivotvals) - 1 by 1
        [hi, lo, strength] = get_sr_vals(x)
        if check_sr(hi, lo, strength)
            loc = find_loc(strength)
            // if strength is in first maxnumsr sr then insert it to the arrays 
            if loc < maxnumsr and strength >= min_strength
                array.insert(sr_strength, loc, strength)
                array.insert(sr_up_level, loc, hi)
                array.insert(sr_dn_level, loc, lo)
                // keep size of the arrays = 5
                if array.size(sr_strength) > maxnumsr
                    array.pop(sr_strength)
                    array.pop(sr_up_level)
                    array.pop(sr_dn_level)

    for x = 1 to 10 by 1
        line.delete(array.get(sr_lines, x))
        label.delete(array.get(sr_labels, x))

    for x = 0 to array.size(sr_up_level) > 0 ? array.size(sr_up_level) - 1 : na by 1
        float mid = math.round_to_mintick((array.get(sr_up_level, x) + array.get(sr_dn_level, x)) / 2)
        rate = 100 * (mid - close) / close
        array.set(sr_labels, x + 1, label.new(x = bar_index + labellocSprs, y = mid, text = str.tostring(mid) + '(' + str.tostring(rate, '#.##') + '%)', color = mid >= close ? color.red : color.lime, textcolor = mid >= close ? color.white : color.black, style = mid >= close ? label.style_label_down : label.style_label_up))

        array.set(sr_lines, x + 1, line.new(x1 = bar_index, y1 = mid, x2 = bar_index - 1, y2 = mid, extend = extend.both, color = mid >= close ? resistancecolor : supportcolor, style = Lstyle, width = linewidth))

f_crossed_over() =>
    ret = false
    for x = 0 to array.size(sr_up_level) > 0 ? array.size(sr_up_level) - 1 : na by 1
        float mid = math.round_to_mintick((array.get(sr_up_level, x) + array.get(sr_dn_level, x)) / 2)
        if close[1] <= mid and close > mid
            ret := true
            ret
    ret

f_crossed_under() =>
    ret = false
    for x = 0 to array.size(sr_up_level) > 0 ? array.size(sr_up_level) - 1 : na by 1
        float mid = math.round_to_mintick((array.get(sr_up_level, x) + array.get(sr_dn_level, x)) / 2)
        if close[1] >= mid and close < mid
            ret := true
            ret
    ret
crossed_over = f_crossed_over()
crossed_under = f_crossed_under()
alertcondition(crossed_over, title = 'Resistance Broken', message = 'Resistance Broken')
alertcondition(crossed_under, title = 'Support Broken', message = 'Support Broken')
alertcondition(crossed_over or crossed_under, title = 'Support or Resistance Broken', message = 'Support or Resistance Broken')

//-----------------------------------------------------------------------------}


//-----------------------------------------------------------------------------{    
//5- ZigZag with Fibonacci Levels
//-----------------------------------------------------------------------------
fibrect_ok = input(false, title='═══════════════ ZigZag with Fibonacci Levels Settings')

prd = input.int(50, title='ZigZag Period', minval=2, maxval=50)
showzigzag = input(false, title='Show Zig Zag')
showfibo = input(true, title='Show Fibonacci Ratios')
labelcol = input.color(color.blue, title='Text Color for Fibo Levels')
fibolinecol = input.color(color.lime, title='Line Color for Fibo Levels')
upcol = input.color(color.lime, title='Zigzag Colors', inline='zzcol')
dncol = input.color(color.red, title='', inline='zzcol')
labelloc = input.string('Right', title='Label Location', options=['Right', 'Left'])
enable236 = input(true, title='Enable Level 0.236')
enable382 = input(true, title='Enable Level 0.382')
enable500 = input(true, title='Enable Level 0.500')
enable618 = input(true, title='Enable Level 0.618')
enable786 = input(true, title='Enable Level 0.786')

var fibo_ratios = array.new_float(0)
var shownlevels = 1

if barstate.isfirst
    array.push(fibo_ratios, 0.000)
    if enable236
        array.push(fibo_ratios, 0.236)
        shownlevels += 1
    if enable382
        array.push(fibo_ratios, 0.382)
        shownlevels += 1
    if enable500
        array.push(fibo_ratios, 0.500)
        shownlevels += 1
    if enable618
        array.push(fibo_ratios, 0.618)
        shownlevels += 1
    if enable786
        array.push(fibo_ratios, 0.786)
        shownlevels += 1
    // Add Fibonacci ratios for common intervals
    for x = 1 to 5
        array.push(fibo_ratios, x)
        array.push(fibo_ratios, x + 0.272)
        array.push(fibo_ratios, x + 0.414)
        array.push(fibo_ratios, x + 0.618)

ph = ta.highestbars(high, prd) == 0 ? high : na
pl = ta.lowestbars(low, prd) == 0 ? low : na
var dir = 0
iff_1 = bool(pl) and na(ph) ? -1 : dir
dir := bool(ph) and na(pl) ? 1 : iff_1
var max_array_size = 10
var zigzag = array.new_float(0)
oldzigzag = array.copy(zigzag)

add_to_zigzag(value, bindex) =>
    array.unshift(zigzag, bindex)
    array.unshift(zigzag, value)
    if array.size(zigzag) > max_array_size
        array.pop(zigzag)
        array.pop(zigzag)

update_zigzag(value, bindex) =>
    if array.size(zigzag) == 0
        add_to_zigzag(value, bindex)
    else
        if (dir == 1 and value > array.get(zigzag, 0)) or (dir == -1 and value < array.get(zigzag, 0))
            array.set(zigzag, 0, value)
            array.set(zigzag, 1, bindex)
        0.

dirchanged = dir != dir[1]
if bool(ph) or bool(pl)
    if dirchanged
        add_to_zigzag(dir == 1 ? ph : pl, bar_index)
    else
        update_zigzag(dir == 1 ? ph : pl, bar_index)

// Only show ZigZag if `fibrect_ok` is true
if fibrect_ok and showzigzag and array.size(zigzag) >= 4 and array.size(oldzigzag) >= 4
    var line zzline = na
    if array.get(zigzag, 0) != array.get(oldzigzag, 0) or array.get(zigzag, 1) != array.get(oldzigzag, 1)
        if array.get(zigzag, 2) == array.get(oldzigzag, 2) and array.get(zigzag, 3) == math.round(array.get(oldzigzag, 3))
            line.delete(zzline)
        zzline := line.new(x1=math.round(array.get(zigzag, 1)), y1=array.get(zigzag, 0), x2=math.round(array.get(zigzag, 3)), y2=array.get(zigzag, 2), color=dir == 1 ? upcol : dncol, width=2)
        zzline

var fibolines = array.new_line(0)
var fibolabels = array.new_label(0)

// Only show Fibonacci levels if `fibrect_ok` is true
if fibrect_ok and showfibo and array.size(zigzag) >= 6 and barstate.islast
    // Delete previous lines and labels only if necessary
    if array.size(fibolines) > 0
        for x = 0 to array.size(fibolines) - 1
            line.delete(array.get(fibolines, x))
            label.delete(array.get(fibolabels, x))

    diff = array.get(zigzag, 4) - array.get(zigzag, 2)
    stopit = false
    for x = 0 to array.size(fibo_ratios) - 1
        if stopit and x > shownlevels
            break
        // Draw Fibonacci lines and labels
        array.unshift(fibolines, line.new(x1=math.round(array.get(zigzag, 5)), y1=array.get(zigzag, 2) + diff * array.get(fibo_ratios, x), x2=bar_index, y2=array.get(zigzag, 2) + diff * array.get(fibo_ratios, x), color=fibolinecol, extend=extend.right))
        label_x_loc = labelloc == 'Left' ? math.round(array.get(zigzag, 5)) - 1 : bar_index + 15
        array.unshift(fibolabels, label.new(x=label_x_loc, y=array.get(zigzag, 2) + diff * array.get(fibo_ratios, x), text=str.tostring(array.get(fibo_ratios, x), '#.###') + '(' + str.tostring(math.round_to_mintick(array.get(zigzag, 2) + diff * array.get(fibo_ratios, x))) + ')', textcolor=labelcol, style=label.style_none))
        if (dir == 1 and array.get(zigzag, 2) + diff * array.get(fibo_ratios, x) > array.get(zigzag, 0)) or (dir == -1 and array.get(zigzag, 2) + diff * array.get(fibo_ratios, x) < array.get(zigzag, 0))
            stopit := true

//-----------------------------------------------------------------------------}
    

//-----------------------------------------------------------------------------{
//6- Magic 8-Ball
////////////////////////
magicball_enabled = input(false, title = "═══════════════ Magic 8-Ball")

// Some constants for digit processing
DECIMAL_POINT = 0.1
MINUS = -1.0

// Function to handle errors
error() => label.new(na, na, "Error in processing")

// Function to remove the last digit from a string and return the remaining string and digit value
cutLastDigit(str) =>
    s = str + ";"
    r = str.replace_all(s, "1;", "")
    if r != s
        [r, 1.0]
    else
        r := str.replace_all(s, "2;", "")
        if r != s
            [r, 2.0]
        else
            r := str.replace_all(s, "3;", "")
            if r != s
                [r, 3.0]
            else
                r := str.replace_all(s, "4;", "")
                if r != s
                    [r, 4.0]
                else
                    r := str.replace_all(s, "5;", "")
                    if r != s
                        [r, 5.0]
                    else
                        r := str.replace_all(s, "6;", "")
                        if r != s
                            [r, 6.0]
                        else
                            r := str.replace_all(s, "7;", "")
                            if r != s
                                [r, 7.0]
                            else
                                r := str.replace_all(s, "8;", "")
                                if r != s
                                    [r, 8.0]
                                else
                                    r := str.replace_all(s, "9;", "")
                                    if r != s
                                        [r, 9.0]
                                    else
                                        r := str.replace_all(s, "0;", "")
                                        if r != s
                                            [r, 0.0]
                                        else
                                            r := str.replace_all(s, ".;", "")
                                            if r != s
                                                [r, DECIMAL_POINT]
                                            else
                                                r := str.replace_all(s, "-;", "")
                                                if r != s
                                                    [r, MINUS]
                                                else
                                                    error()
                                                    [str, -1.0]

// Function to calculate the sum of all digits in a string representation of a number
strToSumNum(str) =>
    integer = 0.0
    s_new = str

    for i = 0 to 10
        [s, digit] = cutLastDigit(s_new)
        integer := integer + digit

        if s == ""
            break
        s_new := s

    integer

// Convert the ticker symbol into a numeric string
// Replace each letter with a corresponding number
t = syminfo.ticker
alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i = 0 to 25
    t := str.replace_all(t, str.substring(alphabet, i, i + 1), str.tostring(i % 10))

// Calculate the sum of all digits in the ticker symbol
t_value = strToSumNum(t)

// Calculate the bar number
bar_number = nz(math.round(time / (time - nz(time[1], time))), 1)

// Generate the magic value and map it to a message
magic_value = math.round((t_value * 997 + bar_number * 919 + 971) % 10)
magic_text = magic_value == 0 ? "Buy" :
             magic_value == 1 ? "Strong Buy" :
             magic_value == 2 ? "HODL" :
             magic_value == 3 ? "Sell" :
             magic_value == 4 ? "Strong Sell" :
             magic_value == 5 ? "Ask Again Later" :
             magic_value == 6 ? "Better Not Say Now" :
             magic_value == 7 ? "Neutral" :
             magic_value == 8 ? "Cannot Predict Now" :
             magic_value == 9 ? "Very Doubtful" : na

// Display the Magic 8-Ball message if enabled
if magicball_enabled
    td = time - nz(time[1], time)
    label1 = label.new(bar_index, close, magic_text, xloc=xloc.bar_index, style=label.style_circle, color=color.black, textcolor=color.white, size=size.huge)
    label2 = label.new(bar_index, close, "8", xloc=xloc.bar_index, style=label.style_none, textcolor=color.white, size=size.large)
    if not na(label1[1])
        label.delete(label1[1])
    if not na(label2[1])
        label.delete(label2[1])
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//7- 5/22 Cross
////////////////////////
cross_ok = input.bool(false, title = '═══════════════ 5/22 CRoss Settings ')

ema5 = ta.ema(close, 5)
ema22 = ta.ema(close, 22)

plot(ema5, title = "ema5", color = color.green, linewidth = 2)
plot(ema22, title = "ema22", color = color.red, linewidth = 2)

// Store the results of crossovers and crossunders in variables
crossover_condition = ta.crossover(ema5, ema22)
crossunder_condition = ta.crossunder(ema5, ema22)

plotshape(cross_ok and crossover_condition and ema5[1] < ema22[1],  style=shape.triangleup, text="AL", color=color.green, size=size.normal, location=location.belowbar)
plotshape(cross_ok and crossunder_condition and ema5[1] > ema22[1], style=shape.triangledown, text="SAT", color=color.red, size=size.normal, location=location.abovebar)

plot(close)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//8- EMA 200
////////////////////////
ema200_ok = input.bool(true, title = '═══════════════ EMA 200 Settings ')

len = input.int(200, minval = 1, title = 'Length')  // EMA 200
src = input.source(close, title = 'Source')
offset = input.int(title = 'Offset', defval = 0, minval = -500, maxval = 500)
out = ta.ema(src, len)
plot(ema200_ok ? out : na, title = '200', color = color.yellow, offset = offset, linewidth = 4)

ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'SMMA (RMA)' => ta.rma(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)

// Inputs for moving average type and smoothing length
typeMA = input.string(title = 'Method', defval = 'SMA', options = ['SMA', 'EMA', 'SMMA (RMA)', 'WMA', 'VWMA'], group = 'Smoothing')
smoothingLength = input.int(title = 'Length', defval = 5, minval = 1, maxval = 100, group = 'Smoothing')

smoothingLine = ma(out, smoothingLength, typeMA)
plot(smoothingLine, title = 'Smoothing Line', color = #f37f20, offset = offset, linewidth = 1)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------{
//9- Volume Based Bars
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

//-----------------------------------------------------------------------------{
//                                                                                
//           .              __.....__                  .                            
//         .'|          .-''         '.              .'|                            
//     .| <  |         /     .-''"'-.  `. .-,.--.  .'  |                       .|   
//   .' |_ | |        /     /________\   \|  .-. |<    |                     .' |_  
// .'     || | .'''-. |                  || |  | | |   | ____      _    _  .'     | 
// '--.  .-'| |/.'''. \\    .-------------'| |  | | |   | \ .'     | '  / |'--.  .-' 
//   |  |  |  /    | | \    '-.____...---.| |  '-  |   |/  .     .' | .' |   |  |   
//   |  |  | |     | |  `.             .' | |      |    /\  \    /  | /  |   |  |   
//   |  '.'| |     | |    `''-...... -'   | |      |   |  \  \  |   `'.  |   |  '.' 
//   |   / | '.    | '.                   |_|      '    \  \  \ '   .'|  '/  |   /  
//   `'-'  '---'   '---'                          '------'  '---'`-'  `--'   `'-'   
//
//-----------------------------------------------------------------------------}
