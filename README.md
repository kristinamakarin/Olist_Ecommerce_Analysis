# 🛒 Brazilian E-Commerce Sales Analysis

## Introduction

This project analyzes the Olist Brazilian E-Commerce dataset in two parts. First, **SQL** (PostgreSQL) explores revenue, customer behavior, delivery performance and customer satisfaction. Then **Python** (pandas, matplotlib, seaborn) answers questions the SQL part could not: how delivery delays affect reviews, how revenue grew over time, which categories sell a lot but disappoint customers, and how late deliveries combine region and season.
 
The data comes from the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle and includes orders, customers, products, sellers, payments and reviews from 2016-2018.
 
- SQL queries: [`project_sql/`](./project_sql/)
- Python notebooks: [`project_python/`](./project_python/)

## Key Findings

- **Retention is the weakest point:** 97% of customers bought only once, so growth relies on constantly acquiring new customers.
- **Late deliveries are the biggest drag on satisfaction:** the 6.7% of orders that arrive late average 2.27 stars vs. 4.29 on time, and 62.4% of them get 1 or 2 stars vs. 9.2% of on-time orders.
- **Delivery problems come in waves, not evenly through the year:** March 2018 had 19.0% late orders vs. 1.2% in June 2018. The state-by-month heatmap shows two episodes: November-December 2017 (worst in Rio de Janeiro and Espírito Santo) and February-March 2018, when almost every large state was affected, while São Paulo stayed below about 10%. Rio de Janeiro alone accounts for about 23% of all late orders with only 13% of the orders. Delivery speed also differs by region: orders to Ceará take 21.2 days on average vs. 8.7 in São Paulo.
- **Revenue grew about eightfold during 2017** to R$1.0M in November 2017, then flattened in 2018.
- **Furniture and home categories** (`bed_bath_table`, `furniture_decor`, `office_furniture`) combine high sales with below-average ratings.

## Questions I wanted to answer
 
**SQL**
1. Which product categories generate the most revenue?
2. How many customers are repeat buyers vs. one-time buyers?
3. What is the average order value by customer state?
4. Which states have the most customers?
5. How does average delivery time vary by state?
6. What percentage of orders are delivered late, and does it vary by state?
7. Which month has the highest rate of late deliveries?
8. How does customer satisfaction (review score) vary by product category?

**Python**
1. What does the dataset look like overall (volume, quality, customers, payments, geography)?
2. Do late deliveries lead to lower review scores, and does the score keep dropping as the delay grows?
3. How did revenue and order volume change month by month?
4. Which categories sell a lot but disappoint customers?
5. Are late deliveries a regional problem, a seasonal problem, or both?

## Tools I used
 
- **SQL & PostgreSQL**: querying, joins, CTEs, aggregation
- **Python** (pandas): data cleaning, merging, aggregation
- **Matplotlib & Seaborn**: visualizations
- **VS Code & Git/GitHub**: development and version control

## Dataset and setup
 
Download the CSV files from Kaggle and place them in `csv_files/` (ignored by Git). The notebooks read them from `../csv_files/`. Create the environment with:
 
```bash
conda create -n olist python=3.11 pandas matplotlib seaborn jupyter ipykernel adjusttext
conda activate olist
```
 
Currency is the Brazilian real (R$). "Revenue" means item price only, excluding freight.

## Definitions

- **Late order:** delivered at least one full day after the estimated delivery date (same rule in SQL and Python).
- **Customer:** identified by `customer_unique_id`, because `customer_id` changes with every order.
- **Revenue:** item price only, freight excluded. The SQL queries count all orders; the Python revenue analysis excludes canceled and unavailable ones.
- **Review score per order:** averaged when an order has more than one review.
 
## The Analysis (SQL)

<details>
<summary><b>Click to expand SQL Analysis</b></summary>

### 1. Top Revenue Categories
To identify which product categories generate the most sales, I joined order items with the products and category translation tables, summing revenue (price) and freight separately for each category.

> **Key finding:** Health & Beauty was the top-earning category with R$1,258,681 in revenue, followed closely by Watches & Gifts (R$1,205,006) and Bed, Bath & Table (R$1,036,989). Interestingly, the top 3 categories span very different product types — personal care, luxury/gift items, and home goods — suggesting Olist's revenue isn't concentrated in a single niche, but spread across several strong, unrelated categories.

*Note: "Revenue" in this analysis refers to product price only (excluding freight/shipping charges), consistent with treating shipping as a pass-through cost rather than earned revenue.*

### 2. Repeat vs. One-Time Customers

To measure customer retention, I counted the number of orders per unique customer (using `customer_unique_id`, since `customer_id` is generated per-order rather than per-person in this dataset), then classified each customer as "one-time" or "repeat" based on that count.

> **Key finding:** Only 2,997 customers (about 3%) made more than one purchase, while 93,099 (97%) were one-time buyers. This is a striking retention problem — Olist's revenue relies almost entirely on constantly acquiring new customers rather than repeat business, which is typically far more expensive and less sustainable than retaining existing ones.

### 3. Average Order Value by State

To measure spending patterns by region, I first summed order item prices per order (to get each order's total value), then averaged those order totals grouped by customer state.

> **Key finding:** Average order value varies notably by state, ranging from R$216.67 in Paraíba (PB) down to around R$143 in Rio de Janeiro (RJ) — despite RJ being one of Brazil's largest, most economically developed states. This suggests that order value isn't simply driven by regional wealth or market size; smaller or less-saturated markets may see fewer but higher-value purchases.

### 4. Top States by Number of Customers
To see where Olist's customer base is concentrated, I counted distinct customers per state directly from the customers table.

> **Key finding:** São Paulo (SP) dominates with 40,302 customers — over 3x more than the second-place state, Rio de Janeiro (12,384). The top 2 states alone (SP and RJ) account for a substantial share of the customer base, while the remaining top 10 states each contribute a few thousand customers, showing a heavily concentrated, São Paulo-centric market rather than an evenly distributed national presence.

### 5. Average Delivery Time by State

To measure delivery speed by region, I calculated the number of days between purchase and actual delivery for each delivered order, then averaged by customer state. I also counted the orders per state to see how reliable each average is.

> **Key finding:** Delivery time varies strongly by state. São Paulo (SP) is the fastest at 8.7 days and also has by far the most orders (40,494), followed by Paraná (PR) and Minas Gerais (MG) at 11.9 days. At the other end, Roraima (RR) takes 29.3 days (only 41 delivered orders, so this average is less reliable), about 3.4 times slower than SP. The slower states are in the North and Northeast of Brazil (for example CE at 21.2 days, AC at 21.0 and PB at 20.4, with RR at the very bottom), likely reflecting the greater logistical distance from the Southeast.

*Note: Small states have few delivered orders (for example AC has only 80), so their averages are less reliable than those of large states like SP.*

### 6. Percentage of Late Deliveries by State

Extending the delivery time analysis, I used a CASE statement to flag each order as "late" (delivered after the estimated delivery date) or "on time", then calculated the percentage of late orders per state.

> **Key finding:** Late delivery rates vary widely, from 21.4% in Alagoas (AL), 17.4% in Maranhão (MA) and 15.2% in Sergipe (SE) down to under 3% in Amazonas (AM) and Rondônia (RO). The three biggest states differ strongly: São Paulo (4.5%) and Minas Gerais (4.6%) are reliable, but Rio de Janeiro has 12.1%. Because RJ is so large, it accounts for about 23% of all late orders (1,495 of 6,535) while having only 13% of the orders, whereas São Paulo has 42% of the orders but 28% of the late ones. The ranking also doesn't match the average delivery days from the previous query: remote northern states with long delivery times, such as Acre (21.0 days on average) and Rondônia (19.3 days), have some of the lowest late rates (3.8% and 2.9%). This suggests that Olist sets longer estimated delivery dates for distant states instead of consistently underestimating them, although these states are small, so the conclusion is tentative.

### 7. Late Delivery Rate by Month
Extending the late-delivery analysis from Query 6, I flagged each order as "late" or "on time" and grouped by the year and month in which the order was purchased. Months with fewer than 100 delivered orders are left out, because their percentages are not reliable. An earlier version grouped by month number only, which mixed March 2017 with March 2018 and hid how different the two years were.

> **Key finding:** Late deliveries were concentrated in a few months rather than in a calendar season. **March 2018 had the highest late-delivery rate at 19.0%** (1,328 of 7,003 orders), followed by February 2018 (14.1%) and November 2017 (12.4%), the month of Black Friday. March 2017, by comparison, had only 4.6%. The best large month was June 2018 with just 1.2% late (71 of 6,096 orders), about 16 times better than March 2018. Order volume alone does not explain the spikes: January 2018 had a similar number of orders to March 2018 but only 5.7% were late, so the February-March 2018 problem was probably something specific to that period, which this data cannot explain.

### 8. Customer Satisfaction by Product Category
To see how customer satisfaction varies by product type, I joined reviews with order items and products, calculating the average review score per category (using the English category names for readability).

> **Key finding:** CDs/DVDs/Musicals had the highest average rating (4.64), followed by Fashion Children's Clothes (4.50) and Books - General Interest (4.45) — suggesting media and books tend to meet expectations reliably, likely because they're low-risk, standardized purchases. At the other end, Security & Services scored lowest by far (2.50, though with only 2 reviews), while Diapers & Hygiene (3.26) and Portable Kitchen & Food Preparers (3.27) were the lowest categories with meaningful review volume — both product types where quality/functionality issues would directly and noticeably affect the buyer's experience.

*Note: A small number of reviews (1,598) belong to products with no assigned category (NULL), likely a data quality gap in the original product listings.*

</details>

## The Analysis (Python)
 
<details>
<summary><b>Click to expand Python Analysis</b></summary>

### 1. Exploratory Data Analysis

Before answering specific questions, I explored the Olist dataset to understand its size, quality and shape: order volume over time, review scores, payment methods, repeat customers, the biggest states, the best-selling categories and the price distribution.

See notebook: [`1_EDA_intro.ipynb`](./project_python/1_EDA_intro.ipynb)

#### Orders over time

![Number of Orders per Month](./project_python/images/orders_per_month.png)

> **Key insight:** Olist grew quickly through 2017, from about 800 orders in January to about 4,600 in October. Orders peaked in **November 2017 at about 7,500**, most likely because of Black Friday, then dropped to about 5,700 in December and settled at roughly 6,200 to 7,300 per month during 2018. The first months of 2016 and the last two months of 2018 have almost no orders, because the data collection started and ended mid-period, so those months should be left out of any trend analysis. November 2017, the busiest month, also had one of the highest late-delivery rates in the SQL analysis (12.4%), although March 2018 was worse.

#### Customers

![One-Time vs. Repeat Customers](./project_python/images/one_time_vs_repeat_customers.png)

> **Key insight:** Only **3.1%** of customers ordered more than once, while **96.9%** bought a single time. This confirms the SQL result (2,997 repeat vs. 93,099 one-time customers) and shows that Olist depends almost entirely on acquiring new customers.

![Top 10 States by Number of Customers](./project_python/images/top_10_states.png)

> **Key insight:** The customer base is heavily concentrated: **São Paulo (SP)** has more than three times as many customers as Rio de Janeiro (RJ), and SP, RJ and Minas Gerais (MG) together account for about two thirds of all customers. The remaining states in the top 10 (RS, PR, SC, BA, DF, ES, GO) each have only a few thousand.

#### Reviews and payments

![Review Scores](./project_python/images/review_scores.png)

> **Key insight:** Customers are mostly satisfied: about **58%** of reviews are 5 stars and about 77% are 4 or 5 stars. The distribution is not smooth, though. 1-star reviews (about 11%) are more common than 2-star or 3-star reviews, which means that unhappy customers tend to be very unhappy. This is what the later notebook on late deliveries investigates.

![Number of Payments per Payment Type](./project_python/images/payments_per_payment_type.png)

> **Key insight:** **Credit card** is by far the most used payment method (roughly three quarters of payments), followed by **boleto**, a Brazilian bank-slip payment (about 19%). Vouchers and debit cards together make up only a small share, and `not_defined` is practically empty.

#### Products

![Top 10 Product Categories by Items Sold](./project_python/images/top_categories.png)

> **Key insight:** `bed_bath_table` sells the most items (about 11,100), followed by `health_beauty` (about 9,700) and `sports_leisure` (about 8,600). The ranking by items differs from the SQL ranking by revenue: `watches_gifts` is only 7th by items sold (about 6,000) but 2nd by revenue, and `bed_bath_table` is first by items but only 3rd by revenue. This suggests that watches and gifts have a much higher price per item, while bed and bath products sell in volume at lower prices.

![Product Price Distribution](./project_python/images/product_price_distribution.png)

> **Key insight:** Prices are strongly right-skewed. Roughly three quarters of the items cost less than about R$135, and a long tail of expensive items reaches R$1,400 and above. Because of this tail, the median describes a typical price better than the mean.

#### Delivery Time 

![Distribution of Delivery Time](./project_python/images/delivery_time.png)

> **Key insight:** Most orders arrive quickly: the median delivery time is **10 days**, and delivery times peak at around 6 to 9 days. Roughly 85% of orders arrive within three weeks. The distribution is right-skewed: a long tail of slow deliveries pulls the mean (**12 days**) above the median, so the median describes a typical delivery better. The chart is cut at the 99th percentile (about 46 days), so around 1% of orders took even longer. This national picture complements the SQL analysis by state, where averages hide how much individual orders vary.

### 2. Do Late Deliveries Hurt Customer Satisfaction?

The SQL part measured late deliveries and review scores separately. Here I connect them: I marked each delivered order as on time or late (delivered at least one day after the estimated date), measured how many days late it was, and compared the review scores.

See notebook: [`2_delivery_vs_reviews.ipynb`](./project_python/2_delivery_vs_reviews.ipynb)

```python
df_delivered['days_late'] = (delivered_day - estimated_day).dt.days
df_delivered['is_late'] = df_delivered['days_late'] > 0

review_per_order = reviews.groupby('order_id')['review_score'].mean().reset_index()
df = df_delivered.merge(review_per_order, on='order_id', how='inner')
```

![Average Review Score: On Time vs. Late Deliveries](./project_python/images/delivery_vs_reviews_overview.png)

> **Key insight:** Late deliveries are strongly linked to lower ratings. Orders delivered on time average **4.29** stars, while late orders average **2.27**, a gap of about two stars. Late orders are only **6.7%** of delivered orders, yet **62.4%** of them received 1 or 2 stars, compared with only **9.2%** of on-time orders, about 6.8 times more often. As a result, late deliveries account for roughly a third (about **33%**) of all 1-2 star reviews, despite being a small share of orders.

![Average Review Score by Delivery Delay](./project_python/images/delivery_vs_reviews_by_delay.png)

> **Key insight:** Even a short delay hurts: orders that arrive only 1 to 3 days late already lose a full star (**3.29** vs. 4.29). The score keeps falling to **2.11** for 4 to 7 days and **1.67** for 8 to 14 days, then levels off at about **1.7** for delays above two weeks, since customers who wait that long almost always give the lowest rating. The estimated delivery date works like a promise: breaking it matters more than how long the delay lasts.

**Limitations:** This shows an association, not proof of cause. Late orders may also differ in other ways (distance, product type), and I averaged the score for orders with more than one review. Orders are counted as late only when they arrive at least one full day after the estimated date.

### 3. Revenue Over Time

The SQL part looked at categories, states and delivery performance, but had no time trend. Here I summed the item price by purchase month and counted distinct orders, using only full months (January 2017 to August 2018). Canceled and unavailable orders are excluded, and orders still in progress are included, so the most recent months are not artificially low.

See notebook: [`3_revenue_over_time.ipynb`](./project_python/3_revenue_over_time.ipynb)

```python
monthly = sales.groupby('year_month').agg(
    revenue=('price', 'sum'),
    orders=('order_id', 'nunique')
)
monthly['avg_order_value'] = monthly['revenue'] / monthly['orders']
```

![Monthly Revenue and Orders](./project_python/images/revenue_over_time.png)

> **Key insight:**
> * **Fast growth through 2017:** monthly revenue grew from about R$120K in January 2017 to **R$1.0M in November 2017** (roughly eight times more), while monthly orders grew from about 800 to about 7,400 (orders here exclude canceled and unavailable ones, so counts are slightly lower than in the EDA).
> * **November 2017 was the peak:** revenue was 52% higher than in October, most likely because of Black Friday, and then fell by 26% in December, which suggests that part of the demand was pulled forward into the sale month.
> * **Growth stalled in 2018:** revenue stayed in a range of about R$830K to R$1.0M, and orders between about 6,100 and 7,200 per month, until a drop in June, after which revenue remained around R$850K to R$880K.
> * **Growth came from more orders, not bigger orders:** the average order value stayed around R$135.

**Limitations:** The data covers only about two years, so there is a single Black Friday and I cannot separate a seasonal effect from the general growth trend. Revenue means item price only (freight excluded).

### 4. Category Sales vs. Customer Satisfaction

The SQL part ranked categories by revenue and, separately, by review score. Here I put both on one chart to see which popular categories disappoint customers. For every category with at least 100 orders I compared the number of orders, revenue and the average review score. The chart shows the 15 categories with the highest revenue; bubble size shows revenue and the dashed line is the overall average score (4.04).

See notebook: [`4_category_sales_vs_satisfaction.ipynb`](./project_python/4_category_sales_vs_satisfaction.ipynb)

```python
df_category = items.groupby('product_category_name_english').agg(
    orders=('order_id', 'nunique'),
    revenue=('price', 'sum'),
    avg_review=('review_score', 'mean')
)
priority = df_category[(df_category['orders'] > df_category['orders'].median()) & (df_category['avg_review'] < overall_review)]
```

![Category Sales vs. Customer Satisfaction](./project_python/images/category_sales_vs_satisfaction.png)

> **Key insight:**
> * **The biggest category is also one of the happiest:** `health_beauty` has the highest revenue and an average score of about 4.14, above the overall average. `sports_leisure` (about 4.11) is similar.
> * **Several large categories fall below average:** `bed_bath_table` sells the most orders (9,313) but scores only 3.90, and `computers_accessories` (3.93), `furniture_decor` (3.91) and `telephony` (3.95) are also below the 4.04 average. `watches_gifts`, the second category by revenue, is right at the average (4.02).
> * **The weakest category is `office_furniture`** with 3.49, about half a star below the average, although it is much smaller (1,263 orders).
> * **A pattern, not a proof:** furniture and home categories dominate the list of below-average categories. A possible reason is that bulky products are harder to deliver and more likely to arrive damaged, but this analysis does not test it.

**Categories with orders above the median threshold of 508 and an average review score below the overall average** (the most valuable ones to improve are at the top, sorted by revenue):

| Category | Orders | Revenue (R$) | Avg. review |
|---|---|---|---|
| watches_gifts | 5,576 | 1,196,496 | 4.02 |
| bed_bath_table | 9,313 | 1,026,192 | 3.90 |
| computers_accessories | 6,649 | 906,893 | 3.93 |
| furniture_decor | 6,398 | 723,344 | 3.91 |
| baby | 2,861 | 408,364 | 4.01 |
| telephony | 4,168 | 319,939 | 3.95 |
| office_furniture | 1,263 | 271,076 | 3.49 |
| consoles_games | 1,052 | 155,371 | 4.02 |

**Limitations:** The differences from the average are small (mostly 0.1 to 0.15 stars), so they show where to look, not what is broken. Review scores are averaged per order and counted once for every item, so orders with several items weigh more. Items without a category are excluded, and the sample for small categories is limited.

### 5. Late Deliveries by State and Month

The SQL part measured late deliveries by state (query 6) and by month (query 7) separately. Here I combined both in a heatmap for the 10 states with the most orders, to see whether late deliveries are a regional problem, a seasonal one, or both. Cells with fewer than 30 orders are hidden because their percentages are not reliable.

See notebook: [`5_late_delivery_heatmap.ipynb`](./project_python/5_late_delivery_heatmap.ipynb)

```python
late_rate = df_top.pivot_table(index='customer_state', columns='year_month', values='is_late', aggfunc='mean') * 100
late_rate = late_rate.where(order_count >= 30)
sns.heatmap(late_rate, cmap='Reds', cbar_kws={'label': '% of orders delivered late'})
```

![Late Delivery Rate by State and Purchase Month](./project_python/images/late_delivery_heatmap.png)

> **Key insight:**
> * **Late deliveries came in two waves, not evenly through the year.** Outside November 2017 to March 2018, most large states stayed at roughly 2% to 8% late orders.
> * **Wave 1, November-December 2017 (Black Friday season):** Rio de Janeiro (about 25-27%) and Espírito Santo (about 23% in November) were hit hardest, while São Paulo and Minas Gerais stayed much lower.
> * **Wave 2, February-March 2018, was network-wide:** in March 2018 almost every state turned dark red, with Espírito Santo (41.4%), Rio de Janeiro (about 35%) and Bahia (about 30%) the worst. Only São Paulo stayed below 10%.
> * **Rio de Janeiro was not a chronic problem:** it was at normal levels (about 4-8%) until October 2017, then ran between about 13% and 35% for five months. Bahia and Espírito Santo were slower to recover and stayed elevated (about 15-18%) in April and May 2018, when most other states were back to normal.
> * **Rio de Janeiro matters most in absolute terms:** it has about 13% of all orders but about 23% of all late ones(all months), while São Paulo has 42% of the orders and 28% of the late ones.
> * **São Paulo and Paraná were the most reliable states**, rarely above about 10% in any month.

![Share of Late Deliveries by Purchase Month](./project_python/images/late_delivery_monthly.png)

> **Key insight:** Across all states, the late rate stayed around 3% for most of 2017, then jumped to 12.4% in November 2017 and peaked at 19.0% in March 2018 (14.1% in February), before falling back to 4.5% in April and 1.2% in June 2018. These values match SQL query 7, which confirms that both analyses use the same definition of a late order. The heatmap adds the missing detail: the March 2018 peak was a country-wide event, while the November 2017 peak was concentrated in a few states.

**Limitations:** The heatmap covers the 10 states with the most orders and the months from February 2017 to July 2018. January 2017 has too few orders, and the last month is left out because orders not yet delivered by then are missing, which would understate its late rate. Cells with fewer than 30 orders are hidden. Because of this window, the numbers differ slightly from SQL query 6, which covers all months; reproducing query 6 in pandas with the same rule gave identical results (for example AL 21.4% and RJ 12.1%). The heatmap shows where and when deliveries were late, not why: the cause of the February-March 2018 episode is not in this dataset.

</details>

## Conclusions

This analysis paints a picture of a marketplace with real growth alongside clear operational weaknesses:

- **Revenue is healthy and diversified, but retention is the biggest weakness.** Revenue grew about eightfold during 2017 and is spread across very different categories (Health & Beauty, Watches & Gifts, Bed, Bath & Table), yet 97% of customers never came back.
- **Delivery is the main driver of customer satisfaction.** Late orders are only 6.7% of deliveries, but they average 2.27 stars vs. 4.29 for on-time orders and account for about a third of all 1-2 star reviews. Even a delay of 1 to 3 days costs about a full star.
- **Delivery problems come in waves, in specific places.** Late deliveries peaked during Black Friday season in November 2017 (12.4%, worst in Rio de Janeiro and Espírito Santo) and again in February-March 2018 (14.1% and 19.0%), when nearly every large state was affected. Outside these periods the late rate was only about 3-5%, and São Paulo stayed reliable throughout. Remote states also wait much longer in general (for example 21.2 days in Ceará vs. 8.7 in São Paulo).
- **Satisfaction differs by category, and several large categories are below average.** Health & Beauty scores above the average (about 4.14), while `bed_bath_table` (3.90), `computers_accessories` (3.93) and `furniture_decor` (3.91) sell in large volumes but score lower.

Overall, the data points to two connected opportunities: **delivery reliability**, which most directly affects ratings, and **customer retention**, which would reduce the dependence on constant new-customer acquisition. It is plausible that better delivery would also improve repeat purchases, but this dataset cannot show that, so it remains a hypothesis to test.

**Limitations:** The data covers only about two years, so seasonal effects cannot be separated from growth. Most findings are associations, not proof of cause, and the differences between categories are small.

## Recommendations

These come from the data, but they are suggestions, not tested interventions.

1. **Protect the delivery promise.** Even a delay of 1 to 3 days costs about a full star (4.29 vs. 3.29), so reliable estimated dates matter more than fast ones, especially in peak periods.
2. **Plan capacity for peaks, region by region.** Black Friday 2017 hit Rio de Janeiro and Espírito Santo hardest, and February-March 2018 affected almost every state, while São Paulo coped well. Monitoring late rates per state in near real time would show these episodes as they start.
3. **Review the weakest large categories** (`bed_bath_table`, `computers_accessories`, `furniture_decor`) for quality, packaging and delivery problems.
4. **Invest in retention.** With 97% one-time buyers, even a small increase in repeat purchases would reduce the dependence on new customers, and good delivery experiences are the most obvious place to start.

## What I Learned
Working through this project deepened my SQL and Python skills in several ways beyond the fundamentals from my first project:

- **Two-step aggregation:** Recognizing when raw data is "too granular" for the question being asked — such as averaging order value, where I first had to sum item-level prices into order-level totals (via a CTE) before averaging across orders, to avoid distorting results.
- **CASE for classification, not just display:** Using `CASE` to flag individual rows (e.g. "late" vs. "on time") *before* aggregating, rather than applying it to an already-averaged result — an important distinction that changes what the analysis actually measures.
- **The `SUM(CASE...)` counting pattern:** Using `SUM()` on 0/1 flags as a way to count how many rows meet a condition within each group, alongside `COUNT(*)` for the total, to calculate percentages.
- **Working with real-world data quality issues:** Encountering and resolving foreign key violations caused by missing category translations, and NULL categories in the review data — realistic problems that don't show up in cleaner tutorial datasets.
- **Choosing the right grain for `customer_id`:** Learning to distinguish between `customer_id` (unique per order) and `customer_unique_id` (unique per person) — a dataset-specific quirk that would have silently produced wrong retention numbers if missed.
- **Checking the grain of a grouping:** My first version of the late-delivery-by-month query grouped by month number only, which mixed March 2017 with March 2018 and gave a misleading result. Grouping by year and month showed that the real problem was concentrated in February and March 2018.
- **Keeping definitions consistent across tools:** The SQL and Python analyses only agreed once both used the same rule for a "late" order (comparing dates, not timestamps).
- **Merging and reshaping data in pandas:** joining several tables with `merge`, averaging duplicate reviews per order before joining, and using `groupby` with named aggregations and `pivot_table`.
- **Telling a distinct count from a row count:** using `nunique()` to count orders when the data has one row per item.
- **Visualizing two dimensions at once:** scatter and bubble charts, and heatmaps (state by month) instead of separate tables.
- **Not trusting small samples:** hiding months and categories with too few orders, and checking whether an association could be explained by something else.
- **Hiding unreliable results:** using `.where()` to blank out state-month combinations with fewer than 30 orders, so a single late order in a tiny cell does not look like a 50% problem.