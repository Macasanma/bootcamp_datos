import streamlit as st
import numpy as np

st.title('hello macasama!')
st.subheader('hello arnau')

lista = [4,5,6,6,97,23,54,43,67,78,33,98,90]
media = np.mean(lista)
st.selectbox(media)


