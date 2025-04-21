# Fetch Data Analyst Take-Home Project

## 📌 Overview

This repository contains my completed take-home assignment for the Data Analyst role at Fetch. The project includes data exploration, SQL analysis, and stakeholder communication using three unstructured datasets: users, transactions, and products.

---

## 🧭 Structure

- `notebooks/` – Jupyter notebook with full analysis (cleaning, visualizations, insights)
- `sql/` – SQL queries used to answer Part 2 questions
- `README.md` – Project summary (this file)

---

## ✅ Part 1: Data Exploration

Using Python (Pandas, Seaborn) and SQL, I explored and cleaned all datasets. Major issues found:

- `FINAL_QUANTITY` included the word `"zero"` as a string → replaced and cast to numeric
- `FINAL_SALE` had blank strings → converted to nulls
- `BARCODE` was in scientific notation → converted to full string format
- `CATEGORY_4`, `MANUFACTURER`, `BRAND` had significant missing values in products
- `USER_ID`s in transactions did not always match user records → filtered out
- Gender field contained inconsistent formatting → normalized


## 📊 Part 2: SQL Insights

### ✅ Closed-Ended Questions

1. **Top 5 Brands by Receipts (Users 21+)**  
2. **Top 5 Brands by Sales (Users with Accounts > 6 months)**  
3. **% of Sales in Health & Wellness by Generation**

### ✅ Open-Ended Questions (with Assumptions)

- **Leading Brand in Dips & Salsa**  
- **Monthly Sales Trend (Substitute for YoY due to single year data)**  
- **Power Users** (defined based on transaction frequency and spend)


## 📬 Part 3: Stakeholder Communication

As part of this exercise, I wrote a clear and concise summary for a product/business stakeholder. It includes:

- Key data quality issues
- One actionable insight (e.g., TOSTITOS is top in Dips & Salsa)
- Request for clarification (e.g., usage of `SCAN_DATE` vs `PURCHASE_DATE`, unmatched users)

🗒️ You can find this summary inside the final section of the notebook:


## 🛠 How to Run

### Install requirements:
```bash
pip install pandas matplotlib seaborn jupyter
