# Week 5 Case Study

# Question 1: The first thing the CMO wants to know a sense of how much website traffic she’s gotten so far. How many (unique) visitors has ECCC gotten in total?

SELECT COUNT(DISTINCT user_id) as unique_visitors

FROM cmo.Activity

# Question 2: She needs to know how much they’ve spent (marketing spend), broken out (grouped) by channel.

SELECT  SUM(Marketing_spend) AS marketing_total_spend, 
        Channel

FROM cmo.Activity

GROUP BY Channel

# Question 3: How much revenue have you generated per channel? (We will have to join Activity and Product)

SELECT  Activity.Channel,
        SUM(Product.price) AS total_revenue

FROM cmo.Activity 
    LEFT JOIN cmo.Product ON Activity.Product_bought = Product.Product_ID

GROUP BY Activity.Channel

# Question 4: She wants to see the total numbers of users per week. Can you provide this? 

SELECT  COUNT(DISTINCT user_id) AS number_of_users, 
        EXTRACT (WEEK FROM datetime_weeks) AS week_number 

FROM cmo.Activity

GROUP BY week_number

ORDER BY week_number ASC

# Question 5: Analyzing the numbers around website behavior (time on site & conversion rates), 
# you spot something weird happening after Jan 15. The website design team is saying that this is just because of some awesome work they have been doing that went live on Jan 15th. 
# Your boss wants to know if they are right. Did something material change, if so what? Which numbers show this?

# Hint: Ties’ metric definition dictionary: Conversion rate = Number of conversions / number of visitors:  ( SUM(Conversion) / COUNT(DISTINCT user_id))

SELECT  (SUM(Conversion) / COUNT(DISTINCT user_id)) AS conversion_rate,
        AVG(session_time_seconds) AS avg_time_on_site,

    CASE WHEN datetime_weeks < '2020-01-15' THEN 'Before Jan 15'
    ELSE 'After Jan 15'

    END AS new_time_stamp

FROM cmo.Activity

GROUP BY new_time_stamp

# Question 6: You decide to see if Facebook traffic requires more marketing spend than Google traffic, 
# and also look at the average cost per conversion for Google traffic vs Facebook. What do you find?

# Cost per conversion = Marketing spend / Number of conversions
# Traffic = number of unique users ?

SELECT (total_marketing_spend / traffic) AS spend_per_hit,
        (total_marketing_spend / nr_of_conversions) AS cost_per_conversion,
        Channel,
        
FROM (SELECT COUNT(DISTINCT user_id) AS traffic,
        SUM(Marketing_spend) AS total_marketing_spend,
        Channel,
        SUM(Conversion) AS nr_of_conversions
        
        FROM cmo.Activity

        WHERE Channel IN ('Facebook', 'Google')

        GROUP BY Channel)

# Question 7: At a higher level, if you look at the revenue per $ of marketing spend (ROI), 
# what has been the most profitable marketing channel (excl. referrals)? 
# What might be a reason to still invest in the other channels?

# Revenue per $ of marketing spend (ROI) = Revenue / Marketing spend

SELECT SAFE_DIVIDE(total_revenue, total_marketing_spend) AS ROI,
        Channel

FROM
    (SELECT Channel,
        SUM(price) AS total_revenue,
        SUM(Marketing_spend) AS total_marketing_spend,

    FROM cmo.Activity
         RIGHT JOIN cmo.Product ON Activity.Product_Bought = Product.product_id

    GROUP BY Channel)

# Question 8: The people that are doing the Cognitas SQL course bragged that they were going to be coding geniuses very soon, and mentioned the super awesome power of SQL to their co-workers.
# Naturally, some of these co-workers felt overwhelmed by FOMO and also signed up. 
# Can you give the CMO a sense of which company generated the most converted referrals? How many conversions did each company generate per referral on average?

# Referral conversion rate = Number of conversions / Number of referrals

SELECT company_referee,
        SUM(number_conversions) AS total_conversions,
        SUM(number_referrals) AS total_referrals,
        (SUM(number_conversions)/SUM(number_referrals)) AS referral_conversion_rate,

FROM cmo.Referral

GROUP BY company_referee

ORDER BY total_conversions DESC

# Question 9: Given that you know SQL, you are much smarter than other people (and better looking). Hence, the entire referral program was your idea. 
# You are writing your Performance Review self-reflection, and want to quantify how much money you’ve made ECCC. 
# To make this case study realistic, you are doubling your best estimate (this is your own performance review after all).
# Based on your estimates, how much money have you made ECCC roughly through the referral program?

SELECT (SUM(Referral.number_conversions) * AVG(Product.price) * 2) AS revenue

FROM cmo.Referral
    LEFT JOIN cmo.Activity ON Referral.user_id = Activity.user_id
    LEFT JOIN cmo.Product ON Activity.Product_bought = Product.product_id

# Question 10

SELECT (SUM(revenue) / 4378) AS nr_of_jetskis 

FROM

    (SELECT Activity.Channel, 
   
        SUM(Product.price) AS revenue

    FROM cmo.Activity
        LEFT JOIN cmo.Product ON Activity.Product_bought = Product.product_id

    WHERE Channel = 'Organic' 

    GROUP BY Channel # Gives you the total revenue for all organic conversions

    UNION ALL 

    SELECT  'Referrals' AS Channel, # Create value "referrals" in Channel column to make UNION ALL possible (now it is aligned with the outcome of organic revenue)

            (SUM(Referral.number_conversions) * AVG(Product.price) * 2) AS revenue

    FROM cmo.Referral
        LEFT JOIN cmo.Activity ON Referral.user_id = Activity.user_id
        LEFT JOIN cmo.Product ON Activity.Product_bought = Product.product_id) # Gives you the total revenue for all referrals

