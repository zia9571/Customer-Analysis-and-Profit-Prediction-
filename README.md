# Customer Analytics & Profit Prediction Dashboard

[![R](https://img.shields.io/badge/R-4.3.1-blue.svg)](https://www.r-project.org/)  
[![Shiny](https://img.shields.io/badge/Shiny-App-orange.svg)](https://shiny.rstudio.com/)  
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)  

**Author:** Zahra Shaikh  
**Live App:** [Shiny Dashboard Link](https://d1pqse-thya-shaikh.shinyapps.io/CustomerSegmentationApp/)  

---

## Project Overview

This project explores **retail customer behavior** using transaction data from an online retail store.  
It combines **data cleaning, exploratory analysis, predictive modeling, customer segmentation, and interactive dashboards** to provide actionable business insights.

**Workflow:**

1. Data Cleaning  
2. Exploratory Data Analysis (EDA)  
3. Predictive Modeling for Revenue  
4. RFM Analysis & Customer Segmentation  
5. Interactive Dashboard using Shiny, Plotly & shinydashboard  

---

## 1. Data Cleaning

- Dataset: Online retail transactions (~1M rows)  
- Tasks:  
  - Remove missing or invalid values  
  - Clean column names  
  - Convert data types  

## 2. Exploratory Data Analysis (EDA)
- Analyze customer purchase patterns: quantity, price, revenue
- Explore top performing countries
- Visualizations using ggplot2 and Plotly

# 3. Predictive Modeling
Goal: Predict customer revenue/profit
Models used: Linear Regression, Random Forest, Lasso, XGBoost
Evaluation metric: RMSE

| Model             | RMSE       |
|------------------|-----------|
| Linear Regression | 9321.89   |
| Random Forest     | 10688     |
| Lasso             | 9302.50   |
| XGBoost (tuned)   | 10608.45  |


Insight: Lasso & Linear Regression performed best for predicting customer revenue.

# 4. Customer Segmentation (RFM + Clustering)
- RFM Analysis: Recency, Frequency, Monetary value
- K-Means Clustering: Segment customers into meaningful groups
- Visualizations: Scatterplots and boxplots per cluster

# 5. Shiny Dashboard
Features:
- Dynamic KPIs: Total revenue, total customers, average purchase
- Cluster visualizations: Interactive scatterplots & boxplots
- Customer profile dashboards: View individual metrics and purchase history
- Dropdown menus to filter by segment, country, or customer

# 6. Key Insights
- High-value customers generate most revenue → focus marketing campaigns here
- At-risk customers → provide incentives or offers to retain
- Predictive modeling enables revenue forecasting per customer

# 7. Technologies Used
- R & tidyverse → Data cleaning & analysis
- ggplot2 & Plotly → Visualizations
- Shiny & shinydashboard → Interactive dashboard
- K-Means, Linear Regression, Random Forest, Lasso, XGBoost → Analytics & predictions

