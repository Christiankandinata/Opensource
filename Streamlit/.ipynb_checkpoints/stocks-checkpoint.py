import yfinance as yf
import streamlit as st
import pandas as pd
import datetime as dt
import cufflinks as cf

st.title("Simple Stock Price Apps! ")

# Sidebar
st.sidebar.subheader("Your query parameters here")
start_date = st.sidebar.date_input("Start date", dt.date(2020, 1, 1))
end_date = st.sidebar.date_input("End date", dt.date(2021, 7, 25))


tickerList = pd.read_csv('https://raw.githubusercontent.com/Christiankandinata/Opensource/main/Streamlit/data/ihsg.txt')
tickerList.reset_index(drop=True, inplace=True)
tickerList.columns = ['Stocks']
df2 = {'Stocks': 'AALI.JK'}
tickerList = tickerList.append(df2, ignore_index = True)
tickerList = tickerList['Stocks'].tolist()
tickerSymbol = st.sidebar.selectbox('Stock ticker', tickerList)
tickerData = yf.Ticker(tickerSymbol) # Get ticker data
tickerDf = tickerData.history(period='1d', start=start_date, end=end_date) #get the historical prices for this ticker


# Ticker information
string_logo = '<img src=%s>' % tickerData.info['logo_url']
st.markdown(string_logo, unsafe_allow_html=True)

string_name = tickerData.info['longName']
st.header('**%s**' % string_name)

string_summary = tickerData.info['longBusinessSummary']
st.info(string_summary)


# Ticker data
st.header('**Ticker data**')
st.write(tickerDf)

st.header("**History Price**")
st.line_chart(tickerDf.Close)

st.header("**History Volume**")
st.line_chart(tickerDf.Volume)


# Bollinger bands
st.header('**Bollinger Bands**')
qf=cf.QuantFig(tickerDf,title='First Quant Figure',legend='top',name='GS')
qf.add_bollinger_bands()
fig = qf.iplot(asFigure=True)
st.plotly_chart(fig)