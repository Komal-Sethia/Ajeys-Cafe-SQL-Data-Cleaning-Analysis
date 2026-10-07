# Ajey's Cafe — SQL Data Cleaning & Business Analysis

## Project Overview

This project focuses on cleaning, validating, transforming and analyzing an uncleaned Ajey's Cafe franchise dataset using MySQL.

The project covers practical SQL data cleaning techniques, exploratory data analysis, business-level analysis and advanced SQL concepts such as window functions, subqueries, EXISTS and stored procedures.

The original dataset contains 406,000 records and 11 columns related to cafe orders, outlets, customers, products, payments and ratings.

---

## Dataset

The dataset contains the following fields:

- Order ID
- Outlet Name
- City
- Order Date/Time
- Item Name
- Quantity
- Price
- Payment Mode
- Customer Name
- Rating
- Franchise Owner

The original dataset contains inconsistent spellings, formatting issues, missing values, duplicate records, multiple date formats and invalid values.

---

# Data Cleaning Tasks

### 1. Standardize Outlet Name and City

Standardized different spelling and formatting variations of outlet names and cities.

Examples of variations handled include:

- `surat`
- `SURAT`
- `Ajey Cafe Surat`
- Different spellings of Bengaluru/Bangalore
- Different spellings of Ahmedabad/Ahmadabad
- Baroda/Vadodara variations

All identified variants were mapped to standardized outlet and city names.

### 2. Identify and Remove Duplicate Rows

Duplicate records were identified using `ROW_NUMBER()` based on the relevant columns and duplicate rows were removed while retaining the original record.

### 3. Handle Invalid Quantity and Price Values

Quantity and price values were validated using status columns.

Each value was classified as:

- `Valid`
- `Invalid`
- `Missing`

Negative and zero values were classified as invalid, while NULL values were classified as missing.

### 4. Standardize Order Date

The dataset contained multiple date formats.

The different formats were converted into a standardized MySQL `DATE` format.

Missing or unrecognized dates were converted to `NULL`.

### 5. Clean Customer Names

Customer names were cleaned by:

- Removing extra spaces
- Standardizing capitalization
- Handling blank values
- Replacing missing customer names with `Not Known`

### 6. Validate Ratings

Ratings were checked for invalid values.

Ratings such as `0` and `6` were classified as `Invalid`.

A separate `rating_status` column was created to classify ratings as:

- `Valid`
- `Invalid`
- `Missing`

### 7. Standardize Franchise Owner

Different franchise owner formatting/spelling variations were standardized into a consistent value.

---

# Exploratory Data Analysis

The cleaned dataset was analyzed to answer the following questions:

### 8. Revenue by Outlet / City

Calculated total revenue for each outlet/city using:

`Quantity × Price`

### 9. Best-Selling Items

Identified:

- Overall best-selling item
- Best-selling item for each outlet

Outlet-wise ranking was performed using the `RANK()` window function.

### 10. Monthly and Yearly Sales Trend

Analyzed sales by:

- Year
- Month

to understand sales trends over time.

### 11. Payment Mode Distribution

Analyzed transaction distribution across payment modes such as:

- UPI
- Cash
- Card

### 12. Average Order Value (AOV)

Calculated Average Order Value for each outlet based on individual order values.

### 13. Rating vs Sales Analysis

Analyzed the relationship between customer ratings and sales using:

- Number of orders
- Average order value
- Revenue

---

# Business-Level Analysis

### 14. Outlet Year-over-Year Growth

Compared yearly revenue for each outlet and calculated Year-over-Year (YOY) revenue growth using the `LAG()` window function.

### 15. Weekday vs Weekend Sales

Compared:

- Total orders
- Total sales
- Average order value

between weekdays and weekends.

### 16. Low-Rated but High-Selling Items

Identified items with:

- Average rating below `3.5`
- Total sales above `500,000`

These items may require product/service improvement despite strong sales performance.

### 17. Customer Repeat-Purchase Pattern

Identified customers who placed more than one order using cleaned customer names.

### 18. Outlet Revenue Ranking

Ranked outlets by yearly revenue using:

`RANK() OVER (PARTITION BY year ORDER BY revenue DESC)`

### 19. Month-over-Month Growth

Calculated Month-over-Month (MOM) revenue growth using the `LAG()` window function.

### 20. Outlets Below Average Revenue

Used nested subqueries to identify outlets whose total revenue was below the average outlet revenue.

### 21. Repeat Customers Using EXISTS

Used the `EXISTS` operator to identify customers who had more than one order.

### 22. Monthly Outlet Report Using Stored Procedure

Created a reusable stored procedure that generates a monthly report for any selected outlet, year and month.

The report includes:

- Total orders
- Total quantity
- Total revenue
- Average Order Value

---

# Advanced SQL Concepts Used

The project demonstrates the following SQL concepts:

- `CREATE DATABASE`
- `CREATE TABLE`
- `LOAD DATA INFILE`
- `UPDATE`
- `ALTER TABLE`
- `CASE`
- `REGEXP_REPLACE`
- `TRIM`
- `SUBSTRING_INDEX`
- `STR_TO_DATE`
- Aggregate Functions
- `GROUP BY`
- `HAVING`
- Subqueries
- `EXISTS`
- `ROW_NUMBER()`
- `RANK()`
- `LAG()`
- Window Functions
- Data Type Conversion
- Duplicate Detection
- Duplicate Removal
- Stored Procedures

---

# Dataset Loading

The original dataset was loaded locally into MySQL using `LOAD DATA INFILE`.

The dataset-loading section in the SQL file has been commented out because the original file path was specific to the local MySQL environment used for this project.

Before running the project on another computer, update the file path according to the local MySQL setup.

Example:

```sql
LOAD DATA INFILE 'your_local_file_path/ajeys_cafe_franchise_unclean_dataset.csv'
INTO TABLE cafe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
