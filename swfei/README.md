## Overview

This indicator is an extension based on the strategy described at the following link:
[Strategy Document](https://drive.google.com/file/d/11hIEjxSnyfGx1IyKce1SzKlHS1uUpzTq/view)

Bu indikatör, aşağıdaki linkte yer alan strateji temel alınarak genişletilmiştir:
[Strateji Dökümanı](https://drive.google.com/file/d/11hIEjxSnyfGx1IyKce1SzKlHS1uUpzTq/view)

---

# SuperWaveTrend Fibonacci EMA Ichimoku Indicator

## Overview

The "SuperWaveTrend Fibonacci EMA Ichimoku Indicator" is a comprehensive trading indicator that combines multiple technical analysis tools to provide traders with a robust decision-making system. This indicator includes the SuperTrend, WaveTrend, Fibonacci Retracement, Exponential Moving Averages (EMA), and Ichimoku Cloud, along with volume-based colored bars for enhanced market insights.

## Features

- **SuperTrend**: Identifies the prevailing trend and provides buy/sell signals.
- **WaveTrend**: Detects overbought/oversold conditions and signals potential reversals.
- **Fibonacci Retracement**: Plots key Fibonacci levels to identify potential support and resistance.
- **EMA**: Tracks short, medium, and long-term price trends using Exponential Moving Averages.
- **Ichimoku Cloud**: Provides a comprehensive view of support, resistance, trend direction, and momentum.
- **Volume-Based Colored Bars**: Adds volume analysis to price movements for better trade validation.

## Installation

To use this indicator, copy the provided Pine Script code into a new TradingView script and add it to your chart.

## Indicator Components

### SuperTrend

The SuperTrend indicator identifies the trend direction using ATR-based calculations and provides buy/sell signals.

**Settings:**
- ATR Period
- Source
- ATR Multiplier
- Change ATR Calculation Method
- Show Buy/Sell Signals
- Highlighter On/Off
- Show Buy Signals
- Show Sell Signals

### WaveTrend

The WaveTrend indicator detects overbought and oversold conditions and provides buy/sell signals based on crossovers.

**Settings:**
- Channel Length
- Average Length
- Signal Length
- Upper Band Levels
- Lower Band Levels
- Display Crosses
- Show WaveTrend Buy/Sell Signals

### Fibonacci Retracement

The Fibonacci Retracement tool plots key Fibonacci levels to identify potential support and resistance areas.

**Settings:**
- Show Fibonacci Retracement
- Fibonacci Extend Right
- Fibonacci Show Data
- Fibonacci Distance
- Fibonacci Levels

### EMA

The EMA indicator tracks short, medium, and long-term price trends using Exponential Moving Averages.

**Settings:**
- EMA 1 Period (EMA 8)
- EMA 2 Period (EMA 22)
- EMA 3 Period (EMA 55)
- EMA 4 Period (EMA 200)
- Show EMA Lines

### Ichimoku

The Ichimoku Cloud provides a comprehensive view of support, resistance, trend direction, and momentum.

**Settings:**
- Conversion Line Length
- Base Line Length
- Leading Span B Length
- Lagging Span

### Volume-Based Colored Bars

Volume-Based Colored Bars add volume analysis to price movements by coloring the bars based on volume conditions.

**Settings:**
- Volume Based Coloured Bars Length

## Usage

1. Copy the provided Pine Script code into a new TradingView script.
2. Add the script to your chart.
3. Adjust the settings as per your trading strategy.
4. Use the buy/sell signals, trend direction, and support/resistance levels to make informed trading decisions.

## Table Explanation

**Indicators**:
- `infotbl_ok`: Boolean input to enable or disable the info table.
- `textColor`: Color input for the text displayed in the table.
- `isMobile`: Boolean input to check if the user is on a mobile device.
- `showTable`: Boolean input to decide if the desktop table should be displayed.
- `tablePosition`: String input to set the position of the table on the chart.
- `tableSize`: String input to set the size of the table.

**Operations**:
- `emaPeriod1`, `emaPeriod2`, `emaPeriod3`: Integer inputs for the periods of the Exponential Moving Averages.
- `showEma1`, `showEma2`, `showEma3`: Boolean inputs to show or hide the EMAs.
- `emaColor1`, `emaColor2`, `emaColor3`: Color inputs for the EMAs.
- `smaPeriod1`, `smaPeriod2`, `smaPeriod3`: Integer inputs for the periods of the Simple Moving Averages.
- `showSma1`, `showSma2`, `showSma3`: Boolean inputs to show or hide the SMAs.
- `smaColor1`, `smaColor2`, `smaColor3`: Color inputs for the SMAs.
- `openPrice`, `closePrice`, `volumeData`, `changePercent`, `rsi`: Variables to hold the respective data values.
- `table.cell`: Function to create and populate table cells with the specified data and formatting.

---

![image](https://github.com/user-attachments/assets/1a7287db-dc74-4a1a-84b9-979844e0b7b9)

---

### Türkçe

# SuperWaveTrend Fibonacci EMA Ichimoku İndikatörü

## Genel Bakış

Bu indikatör, aşağıdaki linkte yer alan strateji temel alınarak genişletilmiştir:
[Strateji Dökümanı](https://drive.google.com/file/d/11hIEjxSnyfGx1IyKce1SzKlHS1uUpzTq/view)

"SuperWaveTrend Fibonacci EMA Ichimoku İndikatörü", trader'lara sağlam bir karar verme sistemi sunmak için birden fazla teknik analiz aracını bir araya getiren kapsamlı bir ticaret indikatörüdür. Bu indikatör, SuperTrend, WaveTrend, Fibonacci Retracement, Üssel Hareketli Ortalamalar (EMA), Ichimoku Bulutu ve hacim bazlı renkli çubukları içerir.

## Özellikler

- **SuperTrend**: Mevcut trendi belirler ve al/sat sinyalleri sağlar.
- **WaveTrend**: Aşırı alım/aşırı satım koşullarını tespit eder ve potansiyel dönüş sinyalleri verir.
- **Fibonacci Retracement**: Anahtar Fibonacci seviyelerini çizerek potansiyel destek ve direnç seviyelerini belirler.
- **EMA**: Üssel Hareketli Ortalamalar kullanarak kısa, orta ve uzun vadeli fiyat trendlerini takip eder.
- **Ichimoku Bulutu**: Destek, direnç, trend yönü ve momentum hakkında kapsamlı bir görünüm sağlar.
- **Hacim Bazlı Renkli Çubuklar**: Fiyat hareketlerine hacim analizini ekleyerek daha iyi ticaret doğrulaması sağlar.

## Kurulum

Bu indikatörü kullanmak için, sağlanan Pine Script kodunu yeni bir TradingView script'ine kopyalayın ve grafiğinize ekleyin.

## İndikatör Bileşenleri

### SuperTrend

SuperTrend indikatörü, ATR tabanlı hesaplamalar kullanarak trend yönünü belirler ve al/sat sinyalleri sağlar.

**Ayarlar:**
- ATR Periyodu
- Kaynak
- ATR Çarpanı
- ATR Hesaplama Yöntemini Değiştir
- Al/Sat Sinyallerini Göster
- Vurgulayıcı Açık/Kapalı
- Al Sinyallerini Göster
- Sat Sinyallerini Göster

### WaveTrend

WaveTrend indikatörü, aşırı alım ve aşırı satım koşullarını tespit eder ve kesişimlere dayalı al/sat sinyalleri sağlar.

**Ayarlar:**
- Kanal Uzunluğu
- Ortalama Uzunluğu
- Sinyal Uzunluğu
- Üst Bant Seviyeleri
- Alt Bant Seviyeleri
- Kesişimleri Göster
- WaveTrend Al/Sat Sinyallerini Göster

### Fibonacci Retracement

Fibonacci Retracement aracı, potansiyel destek ve direnç alanlarını belirlemek için anahtar Fibonacci seviyelerini çizer.

**Ayarlar:**
- Fibonacci Retracement Göster
- Fibonacci Sağ'a Uzat
- Fibonacci Verilerini Göster
- Fibonacci Mesafesi
- Fibonacci Seviyeleri

### EMA

EMA indikatörü, Üssel Hareketli Ortalamalar kullanarak kısa, orta ve uzun vadeli fiyat trendlerini takip eder.

**Ayarlar:**
- EMA 1 Periyodu (Ema 8)
- EMA 2 Periyodu (Ema 22)
- EMA 3 Periyodu (Ema 55)
- EMA 4 Periyodu ((Ema 200)
- EMA Çizgilerini Göster

### Ichimoku

Ichimoku Bulutu, destek, direnç, trend yönü ve momentum hakkında kapsamlı bir görünüm sağlar.

**Ayarlar:**
- Dönüşüm Çizgisi Uzunluğu
- Temel Çizgi Uzunluğu
- Öncü Span B Uzunluğu
- Gecikmeli Span

### Hacim Bazlı Renkli Çubuklar

Hacim Bazlı Renkli Çubuklar, fiyat hareketlerine hacim analizini ekleyerek çubukları hacim koşullarına göre renklendirir.

**Ayarlar:**
- Hacim Bazlı Renkli Çubuklar Uzunluğu

## Kullanım

1. Sağlanan Pine Script kodunu yeni bir TradingView script'ine kopyalayın.
2. Script'i grafiğinize ekleyin.
3. Ayarları ticaret stratejinize göre ayarlayın.
4. Al/sat sinyallerini, trend yönünü ve destek/direnç seviyelerini kullanarak bilinçli ticaret kararları verin.

## Tablo Açıklaması

**Values**:
- `infotbl_ok`: Bilgi tablosunu etkinleştirmek veya devre dışı bırakmak için kullanılan boolean girişi.
- `textColor`: Tabloda gösterilen metin için renk girişi.
- `isMobile`: Kullanıcının mobil cihazda olup olmadığını kontrol eden boolean girişi.
- `showTable`: Masaüstü tablosunun gösterilip gösterilmeyeceğini belirleyen boolean girişi.
- `tablePosition`: Tablonun grafikteki konumunu belirlemek için kullanılan string girişi.
- `tableSize`: Tablonun boyutunu belirlemek için kullanılan string girişi.

**İşlemler**:
- `emaPeriod1`, `emaPeriod2`, `emaPeriod3`: Üssel Hareketli Ortalamalar için periyotları belirleyen integer girişler.
- `showEma1`, `showEma2`, `showEma3`: EMA'ların gösterilip gösterilmeyeceğini belirleyen boolean girişler.
- `emaColor1`, `emaColor2`, `emaColor3`: EMA'lar için renk girişleri.
- `smaPeriod1`, `smaPeriod2`, `smaPeriod3`: Basit Hareketli Ortalamalar için periyotları belirleyen integer girişler.
- `showSma1`, `showSma2`, `showSma3`: SMA'ların gösterilip gösterilmeyeceğini belirleyen boolean girişler.
- `smaColor1`, `smaColor2`, `smaColor3`: SMA'lar için renk girişleri.
- `openPrice`, `closePrice`, `volumeData`, `changePercent`, `rsi`: İlgili veri değerlerini tutmak için kullanılan değişkenler.
- `table.cell`: Belirtilen veri ve formatla tablo hücreleri oluşturmak ve doldurmak için kullanılan fonksiyon.

---

This README provides a detailed explanation of the indicator's components and how to use them effectively in both English and Turkish.
