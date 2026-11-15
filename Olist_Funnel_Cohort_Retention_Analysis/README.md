# Olist E-commerce: Funnel, Cohort & Retention Analysis

SQL (SQLite) analysis of about 100K orders from Olist, a Brazilian marketplace, from 2016 to 2018. A Power BI dashboard is the next step (see the end).

The business question I wanted to answer: where does Olist lose orders and customers, and how well does it keep them?

Short answer: orders mostly make it, customers mostly don't come back. 97% of orders get delivered, but only 3.04% of customers ever order twice (2.15% if I don't count a second order placed within 24 hours of the first). I tested satisfaction, late delivery, product category and location as explanations, and none of them explains it well. The data doesn't show the cause, so what I recommend at the end is a test, not a fix.

## The data

Brazilian E-Commerce Public Dataset by Olist on Kaggle (CC BY-NC-SA 4.0). It has 9 tables: orders, customers, order items, payments, reviews, products, sellers, geolocation and category names. I loaded the CSVs into SQLite with DB Browser and checked the row counts after loading. That caught the reviews table coming in as 211,874 rows instead of 99,224, because the comments contain line breaks. I re-imported it and the count matched.

## Things I had to deal with first

`customer_id` isn't a customer. The dataset page says each order gets its own `customer_id`, and `customer_unique_id` is the actual person. I checked it in the data: 99,441 orders, 99,441 distinct `customer_id`s, and only 96,096 distinct people. If you measure repeat buyers with `customer_id` you get 0.00%. With `customer_unique_id` you get 3.04%.

I left canceled and unavailable orders out of every customer analysis, because they aren't completed purchases. That leaves 94,990 customers.

One order can have several items (and several sellers), so joining orders to items multiplies rows. I count distinct orders, take revenue from item price only, and average reviews per order because some orders have more than one.

| Check | Result | What I did |
|---|---|---|
| Duplicate order IDs | 0 | Nothing |
| Delivered before purchase | 0 | Nothing |
| Marked delivered but no delivery date | 8 | Kept them, too few to matter |
| Orders with no items | 775 (767 are canceled or unavailable) | Those two statuses are excluded anyway; kept the other 8 |
| Products with no category | 610, all of them sold (1.42% of items, 1.32% of revenue) | Labeled "unknown" |
| Categories with no English translation | 2 | Used the Portuguese name |
| Orders with more than one category | 0.8% | Used the category of the most expensive item |

## Funnel

| Step | Orders | From previous step |
|---|---|---|
| Purchased | 99,441 | |
| Approved | 99,281 | 99.84% |
| Shipped (handed to carrier) | 97,658 | 98.37% |
| Delivered | 96,476 | 98.79% |
| Delivered and reviewed | 95,830 | 99.33% |

The biggest drop is between approved and shipped (1,623 orders). This is the order lifecycle, not a browsing funnel, so losing under 2% at each step is small.

## The orders that never shipped

2,965 orders never got a delivery date. By status: shipped 1,107, canceled 619, unavailable 609, invoiced 314, processing 301, and a handful of others.

The unavailable ones bothered me. Why would Olist approve an order and take payment, and only then find out it's unavailable? The dataset page says sellers are told to fulfil an order after the customer buys it, so approval and payment can happen before anyone confirms stock. The data can't confirm that's what happens here.

What I could check: all 609 unavailable orders were approved and have a payment record, none has a carrier date, and only 6 have items. They all stop at the same place. Canceled orders are different: 141 of 625 were never approved and 75 got as far as a carrier. So I report the two separately instead of lumping them together as one kind of failure.

I tried three explanations for the unavailable orders and none worked:

- I expected more of them in busy months. November 2017 was the busiest month and had the most (84), but its rate (1.11%) was about average for 2017 (1.01%). The rate then fell to 0.27% in Jan to Aug 2018 while volume kept growing.
- I checked whether they were just being labeled canceled in 2018 instead. Canceled stayed flat (0.59% to 0.58%) and the two combined fell from 1.60% to 0.85%, so no.
- I compared payment types. Unavailable orders use boleto a bit more (24.7% vs 19.9% for delivered), but 73% paid by credit card, so it doesn't explain them.

The data doesn't say why orders become unavailable: there's no stock data, and these orders have no items, so they can't be linked to a seller either. One thing worth following up: 12.2% of canceled orders used a voucher, against 1.6% of delivered ones.

## Retention

94,990 customers, 2,888 with two or more orders: 3.04%.

I looked at when the second order happens. 896 of the 2,888 (31%) came within 24 hours of the first. I wondered if those were items from the same order, but the dataset page says one order can already hold items from several sellers, so a split cart wasn't an obvious reason. So I checked how far apart the two orders were: 749 of the 896 were within 5 minutes, 87 were 5 to 60 minutes apart, and 60 were 1 to 24 hours apart. In 704 of the 749, the two orders had different products. That points to one shopping session placed as two orders. I can't see Olist's checkout, so I treat that as likely, not certain.

Because of that I report two numbers: 3.04% (every second order) and 2.15% (second order at least 24 hours after the first, 2,040 customers). Together they give the range: 2.15% to 3.04%.

For the 1,992 customers whose second order came 24 hours or more later: 28.7% came back within 30 days, 25.3% in 31 to 90 days, 21.0% in 91 to 180 days and 25.0% after 180 days. The return rate per day is highest in the first month, but 71% of these customers come back after it. The later groups are understated, because recent customers had less time to return.

## Cohorts

I grouped customers by the month of their first order and checked what share of each group ordered again in each later month.

New customers per month went from 752 in January 2017 to 7,190 in November 2017, then settled at roughly 5,900 to 7,000 a month in 2018. The share of each group that ordered again the next month stayed between about 0.2% and 0.7% the whole time, with no clear decay curve. So Olist grew by bringing in more new customers, and retention didn't improve as it grew.

Two cautions. The 2016 groups are tiny (2, 290 and 1 customers), so I ignore them. And a monthly cohort table doesn't count a repeat order placed in the same month as the first, so it makes retention look lower than the 3.04% and 2.15% above.

## What I tested to explain low retention

**Satisfaction.** Do unhappy customers come back less? I looked at the review score of the first order. 1-star first orders repeat at 2.82% and 5-star at 3.16% (using the 3.04% definition). That's a gap of about 0.3 points, and it isn't a steady slope: 4-star is 2.81%. I also read a sample of 15 one-star comments (in Portuguese): late or missing deliveries, items missing from an order, wrong or faulty products, and refund requests nobody answered. That's a sample, not a count.

**Delivery.** Late delivery kept coming up in the comments, so I compared the delivery date to the promised date. I didn't pick the bands up front. I looked at every single day first, then cut the bands where the average review started to move. 91.9% of orders arrive before the promised date, 1.3% on the day and 6.8% late.

| Delivered vs promised date | Orders | Avg review | 1-star share |
|---|---|---|---|
| 7+ days early | 76,140 | 4.31 | 6.5% |
| 1 to 6 days early | 12,504 | 4.18 | 7.2% |
| On the promised day | 1,292 | 4.04 | 8.4% |
| 1 to 2 days late | 1,370 | 3.51 | 18.7% |
| 3 to 5 days late | 1,400 | 2.47 | 48.4% |
| 6+ days late | 3,764 | 1.74 | 68.6% |

Reviews stay around 4.3 while orders are early, then fall fast once they pass the promised date. Late orders are about 7% of deliveries but roughly a third of the one-star reviews on delivered orders (estimated from the table above), so most one-star reviews come from orders that arrived on time or early.

Does it affect retention? Customers whose first order was late repeat at 1.62% (103 of 6,350), against 2.27% for 7+ days early. Inside the late groups there's no pattern (1.35%, 1.76%, 1.67%, with only 18 to 61 repeat customers each). If lateness caused the whole gap, it would be about 41 customers out of 94,990.

I also looked at the seller side. Each item has a `shipping_limit_date`, the deadline for the seller to hand the package to the carrier. For delivered orders with one seller (95,194 orders), the later the seller was past that deadline, the more often the order arrived late.

| Seller handoff | Orders | Delivered late | Avg review |
|---|---|---|---|
| On time | 86,535 | 5.4% | 4.22 |
| Up to 1 day late | 4,327 | 11.4% | 3.96 |
| 1 to 3 days late | 1,848 | 17.6% | 3.78 |
| 3+ days late | 2,484 | 39.9% | 3.21 |

That is a real signal, but a weak one on its own. Even when the seller was 3+ days past the deadline, about 60% of those orders still arrived on or before the promised date, and about 72% of all late deliveries came from orders that were handed over on time (both approximate, worked out from the rounded percentages). This only covers delivered orders with one seller, so orders that never arrived aren't in it.

**Category.** I guessed beauty would repeat the most and furniture the least. It was the opposite: furniture_decor was near the top (2.84%) and health_beauty was below average (1.95%). The highest is fashion_bags_accessories at 3.82% (1,727 customers) and the lowest is electronics at 1.41%. With 22 groups compared, only fashion_bags_accessories clearly stands out. The rest could be chance.

**Location.** SP, RJ, MG, RS, PR and SC all sit between 1.99% and 2.41%. The one that stands out is CE at 1.08% (14 of 1,300 customers). The reason isn't in this data.

None of these gives a convincing reason for the low retention.

## What I'd recommend

These come from the findings above. The data doesn't identify a cause of low retention, so the first one is a test.

**Test what brings customers back.** Randomly split new customers into a control group and a group that gets a re-engagement message with an incentive, roughly 30, 90 and 180 days after the first order. Measure the share who order again at least 24 hours after the first within 180 days, so split orders don't count. A standard sample-size calculation (about 2% baseline, 5% significance, 80% power) gives roughly 3,800 customers per group to detect a lift from 2% to 3%. The data has no margin or incentive cost figures, so break-even would be set before launch. Afterwards I'd check whether the effect differs by category or location, but only as a follow-up question.

**Tell customers when an order is going to be late, and flag likely late orders earlier.** Once an order passes its promised date without being delivered, send the customer a notice, and test a small incentive as a second variant. The case is the review table: scores drop from about 4.3 to 1.7 once orders pass the promised date. Separately, when a seller misses the carrier handoff deadline, flag it internally so the seller or support can step in. I wouldn't message the customer at that point. Even at 3+ days past the deadline about 60% of orders still arrive on time, and most late deliveries come from orders that were handed over on time, so a handoff alert would miss them. Whether a notice improves the review is what the test would show. The retention gap for late first orders amounts to only about 41 customers out of 94,990, so I'd justify this on reviews and customer experience, not on retention. It could be tested by randomly sending the notice to some late orders and not others.

**Record why orders fail.** Store a reason, and who canceled, for every canceled or unavailable order. 1,234 orders (1.2%) ended that way, and nothing in the data says why the unavailable ones failed. It would let this analysis be redone with the reason attached.

I'm not recommending a delivery overhaul to raise retention, or spending targeted at specific categories. The data doesn't support either.

## Limits of this data

- This is observational data from 2016 to 2018, with no marketing, pricing, stock or competitor information, so it can show patterns but not prove causes.
- Customers who first bought in mid-2018 had little time to return, so every repeat rate is a bit low.
- A payment record doesn't prove the money was collected.
- Orders that were never delivered aren't in the delivery analysis.
- Left for follow-up: CE's low rate, the voucher share among canceled orders, and the spikes in canceled orders in Feb and Aug 2018.

## Next steps

- Power BI dashboard (funnel, cohort heatmap, delivery vs reviews). In progress, screenshots will be added here.

## Repository and how to reproduce

```
sql/    numbered query files, one per question
README.md
```

1. Download the dataset from Kaggle and import each CSV into one SQLite database (DB Browser: File, Import, Table from CSV file). Check the row counts: orders 99,441, order items 112,650, reviews 99,224.
2. Run the files in `sql/` in numeric order. The queries only read data, so they don't change the database.

Data: Brazilian E-Commerce Public Dataset by Olist (Kaggle), CC BY-NC-SA 4.0. Used here for non-commercial, educational purposes.
