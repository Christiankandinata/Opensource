import yfinance as yf
import streamlit as st
import pandas as pd
import datetime as dt

st.title("Simple Stock Price Apps! ")

# Sidebar
st.sidebar.subheader("Your query parameters here")
start_date = st.sidebar.date_input("Start date", dt.date(2020, 1, 1))
end_date = st.sidebar.date_input("End date", dt.date(2021, 7, 25))


tickerSymbol = 'BMRI.JK'
tickerData = yf.Ticker(tickerSymbol)
tickerDf = tickerData.history(period='1d', start='2020-01-01', end='2021-07-25')
st.write("**BMRI History Price**")
st.line_chart(tickerDf.Close)
st.write("**BMRI History Volume**")
st.line_chart(tickerDf.Volume)