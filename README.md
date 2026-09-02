# 🛒 Brazilian E-Commerce Sales Analysis

## Introduction
This project analyzes the Olist Brazilian E-Commerce dataset using SQL, exploring revenue, customer behavior, delivery performance, and customer satisfaction to understand what drives sales and where the business could improve.

The data comes from the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle, and includes orders, customers, products, sellers, payments, and reviews from 2016-2018.

The queries I wrote can be found in the [`project_sql/`](./project_sql/) folder.

## Questions I wanted to answer
1. Which product categories generate the most revenue?
2. How many customers are repeat buyers vs. one-time buyers?
3. How does delivery time and late-delivery rate vary by region?
4. Does late delivery correlate with lower customer satisfaction (review scores)?
5. Which sellers and payment methods drive the most revenue?

## Tools I used
- **SQL** — for querying and analyzing the data
- **PostgreSQL** — database management system
- **VS Code** — for writing queries and version control
- **Git & GitHub** — for version control and sharing the project

## The Analysis

### 1. Top Revenue Categories
To identify which product categories generate the most sales, I joined order items with the products and category translation tables, summing revenue (price) and freight separately for each category.

**Key finding:** Health & Beauty was the top-earning category with $1,258,681 in revenue, followed closely by Watches & Gifts ($1,205,006) and Bed, Bath & Table ($1,036,989). Interestingly, the top 3 categories span very different product types — personal care, luxury/gift items, and home goods — suggesting Olist's revenue isn't concentrated in a single niche, but spread across several strong, unrelated categories.

*Note: "Revenue" in this analysis refers to product price only (excluding freight/shipping charges), consistent with treating shipping as a pass-through cost rather than earned revenue.*

### 2. Repeat vs. One-Time Customers

To measure customer retention, I counted the number of orders per unique customer (using `customer_unique_id`, since `customer_id` is generated per-order rather than per-person in this dataset), then classified each customer as "one-time" or "repeat" based on that count.

**Key finding:** Only 2,997 customers (about 3%) made more than one purchase, while 93,099 (97%) were one-time buyers. This is a striking retention problem — Olist's revenue relies almost entirely on constantly acquiring new customers rather than repeat business, which is typically far more expensive and less sustainable than retaining existing ones.

### 3. Delivery Performance by Region
*(fill in)*

### 4. Delivery Delays vs. Customer Satisfaction
*(fill in)*

### 5. Top Sellers and Payment Methods
*(fill in)*

## What I Learned
*(fill in at the end)*

## Conclusions
*(fill in at the end)*
