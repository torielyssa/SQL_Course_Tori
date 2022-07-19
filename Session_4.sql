# Week 4! :)

# Exercise A: What is the total opportunity amount that has been lost (use OpenClosedWonLost) by Reps with the Role Name "Sales EMEA" for each product? 

SELECT  
        SUM(opps.Amount) AS total_amount_lost,
        prod.Product_Name,
        Reps.RoleNames,
        opps.OpenClosedWonLost

FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID
    LEFT JOIN crm.Reps ON opps.Owner_ID = Reps.User_ID
       
GROUP BY prod.Product_Name, Reps.RoleNames, opps.OpenClosedWonLost

HAVING Reps.RoleNames = 'Sales EMEA' AND opps.OpenClosedWonLost = 'Lost'

# Second solution which uses WHERE so this is better than using HAVING! :)

SELECT
    sum(Opportunities.Amount) AS Total,
    Opportunities.Stage,
    Reps.RoleNames,
    Products.Product_Name
    
FROM
    crm.Opportunities
    LEFT JOIN 
        crm.Reps ON Opportunities.Owner_ID = Reps.USER_ID
    LEFT JOIN
        crm.Products ON Opportunities.Product_ID = Products.Product_ID

WHERE
   Opportunities.Stage = "Closed Lost" AND Reps.RoleNames = "Sales EMEA"
   
GROUP BY
    Reps.RoleNames,
    Opportunities.Stage,
    Product_Name

# Question B: Which country (use Country from crm.Reps) has the highest total opp amount won by Reps with the role name Sales EMEA and the products Courses or Cables?

SELECT  
        SUM(opps.Amount) AS total_amount_won,
        prod.Product_Name,
        Reps.RoleNames,
        opps.OpenClosedWonLost,
        Reps.Country

FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID
    LEFT JOIN crm.Reps ON opps.Owner_ID = Reps.User_ID

WHERE Reps.RoleNames = 'Sales EMEA' AND opps.OpenClosedWonLost = 'Closed Won' AND (prod.Product_Name = 'Courses' OR prod.Product_Name = 'Cables')

GROUP BY prod.Product_Name, Reps.RoleNames, opps.OpenClosedWonLost, Reps.Country

ORDER BY total_amount_won DESC

LIMIT 1

# Shorter Syntax!

SELECT  
        SUM(opps.Amount) AS total_amount_won,
        prod.Product_Name,
        Reps.RoleNames,
        opps.OpenClosedWonLost,
        Reps.Country

FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID
    LEFT JOIN crm.Reps ON opps.Owner_ID = Reps.User_ID

WHERE Reps.RoleNames = 'Sales EMEA' AND opps.OpenClosedWonLost = 'Closed Won' AND prod.Product_Name IN ('Courses', 'Cables')

GROUP BY 2,3,4,5

ORDER BY total_amount_won DESC

LIMIT 1

# Question C: Which country (use Country from crm.Reps) has the lowest total opp amount lost by Reps with the role name "Sales APAC" and the prod name is Cables: NB: we don't want the billing country.

SELECT  
        SUM(opps.Amount) AS total_amount_lost,
        prod.Product_Name,
        Reps.RoleNames,
        opps.OpenClosedWonLost,
        Reps.Country

FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID
    LEFT JOIN crm.Reps ON opps.Owner_ID = Reps.User_ID

WHERE Reps.RoleNames = 'Sales APAC' AND opps.OpenClosedWonLost = 'Lost' AND prod.Product_Name = 'Cables'

GROUP BY prod.Product_Name, Reps.RoleNames, opps.OpenClosedWonLost, Reps.Country

ORDER BY total_amount_lost ASC

LIMIT 1

# Question D: What is the total opp amount grouped by account owner name and account? 
# Only show reps that own accounts, only show acounts that are attached to opportunities.

SELECT  SUM(Opportunities.Amount) AS total_opp_amount,
            Reps.Full_Name AS account_owner,
            Accounts.Account_Name AS account_name,
        
FROM    crm.Accounts
        INNER JOIN crm.Reps ON Accounts.Owner_ID = Reps.User_ID
        INNER JOIN crm.Opportunities ON Accounts.Account_ID = Opportunities.Account_ID

GROUP BY account_owner, account_name

ORDER BY total_opp_amount DESC

# Simple solution without using multiple joins

SELECT  SUM(opps.Amount) AS total_opp_amount,
        opps.Account_Name,
        opps.Account_Owner

FROM crm.Opportunities opps

GROUP BY 2, 3

ORDER BY total_opp_amount DESC

# SUBQUERY EXERCISES

# Question A: What is the total opps amount for each Segment (use opps.Segment) where the opp has a product from the Product Family 'Laptops' attached to it? 

SELECT  SUM(opps.Amount) AS total_opps_amount,
        opps.Segment,
      
FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID

WHERE prod.Product_Family = 'Laptops'

GROUP BY opps.Segment 

# Let's try now with a subquery.

SELECT SUM(Amount) AS total_opps_amount,
        Segment,
      
FROM crm.Opportunities

WHERE Product_ID IN (SELECT Product_ID
                        FROM crm.Products 
                        WHERE Product_Family = 'Laptops')

GROUP BY Segment 

# Question B: Select the Account Name, Account Owner Name, and RoleName using a join and subquery combined.

SELECT Accounts.Account_Name,
        Accounts.Owner_Name,
        Reps.RoleNames

FROM crm.Accounts
    LEFT JOIN (SELECT   RoleNames,
                        User_ID
                FROM crm.Reps) AS Reps
    
     ON Accounts.Owner_ID = Reps.User_ID

# Without subquery, but this is slower because it involves selecting the whole table rather than just a few columns.

SELECT Accounts.Account_Name,
        Accounts.Owner_Name,
        Reps.RoleNames

FROM crm.Accounts
    LEFT JOIN crm.Reps ON Accounts.Owner_ID = Reps.User_ID

# Question C: Select the opportunity name, opportunity owner, and opportunity age of the opportunity, 
# from the opportunity with the highest Opportunity Age.

SELECT  Opportunity_Age,
        Opportunity_Name,
        Opportunity_Owner,

FROM   crm.Opportunities

WHERE Opportunity_Age = (SELECT MAX(Opportunity_Age)    
                            FROM crm.Opportunities)

# Without subclause:

SELECT  MAX(Opportunity_Age),
        Opportunity_Name,
        Opportunity_Owner,

FROM   crm.Opportunities

GROUP BY 2, 3

ORDER BY MAX(Opportunity_Age) DESC

LIMIT 1
