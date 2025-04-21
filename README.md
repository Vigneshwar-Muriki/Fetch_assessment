# Fetch_assessment part 3
Stakeholder Message (Email/Slack)
Subject: Summary of Data Quality Review and Key Insights from Fetch Analysis

Hi team,

I’ve completed an initial analysis of our transaction, user, and product datasets. Here’s a summary of my findings:

Key Data Quality Issues:

The final_sale field contained blank strings and had to be cleaned before analysis could proceed. We converted these to NULLs for accurate aggregation.

Several product entries were missing key attributes like brand and category_4. In fact, over 70% of rows lacked a value in category_4, limiting deeper category-level analysis.

Barcodes in the transaction data were originally stored in scientific notation (e.g., 7.83E+11) due to Excel formatting. We converted these to numeric format for consistent joins with product metadata.

Interesting Trend Identified: Among users aged 21 and over, TOSTITOS emerged as the top-selling brand in the Dips & Salsa category, outperforming other brands in total receipt count and sales volume. This could indicate strong loyalty or market positioning in this demographic.

Outstanding Questions & Request for Action:

We currently only have transaction data for 2024, which limits our ability to assess Fetch's year-over-year growth. Could we get access to 2023 data to enable a full YoY performance analysis?

Several products have no brand or category associated — are there upstream data quality rules we can enforce to reduce missing metadata?

Let me know if you’d like a walkthrough of the insights dashboard or if there's a specific hypothesis you'd like me to explore next.

Best,
Vigneshwar Muriki
