# Question A: Select the opportunity name of all opportunities and the attached product name from the Opportunity and Product table where the products are Certifications, Courses.

SELECT  Opportunities.Opportunity_Name,
        Products.Product_Name

FROM crm.Opportunities
    LEFT JOIN crm.Products ON Opportunities.Product_ID = Products.Product_ID

WHERE Products.Product_Name IN ("Certifications", "Courses")

# Question B: How many opportunities have been won for each product (Product_Name)? Order the products from largest to smallest.

SELECT prod.Product_Name,
        COUNT(DISTINCT opps.Opportunity_ID) AS won_opps

FROM crm.Opportunities opps
    LEFT JOIN crm.Products prod ON opps.Product_ID = prod.Product_ID

WHERE opps.Stage = "Closed Won"

GROUP BY prod.Product_Name

ORDER BY won_opps DESC

# Question C: Select only the reps that own accounts, include the the name of the rep, the role, and the account name

# In accounts table we have Owner_ID, and in reps we have User_ID which are the same.
# role = Reps.RoleNames
# rep name = Reps.Full_Name
# account name = Accounts.Account_Name
# We want all account owners in the table, but not all reps --> Left join with left table being Accounts and right table being Reps.

SELECT  Reps.RoleNames AS role,
        Reps.Full_Name AS name_of_rep,
        Accounts.Account_Name AS name_of_account

FROM crm.Accounts
    LEFT JOIN crm.Reps ON Accounts.Owner_ID = Reps.User_ID

GROUP BY Accounts.Account_Name, Reps.RoleNames, Reps.Full_Name

# Question D: Select only the reps that own accounts and the number of accounts they own. Only show the reps that own more than 5 accounts.

SELECT  Reps.Full_Name AS name_of_rep,
        COUNT(DISTINCT Accounts.Account_Name) AS number_of_accounts

FROM crm.Accounts
    LEFT JOIN crm.Reps ON Accounts.Owner_ID = Reps.User_ID

GROUP BY Reps.Full_Name

HAVING number_of_accounts > 5

# Question 1: Make it look like there are 300 accounts. (i.e duplicate them)

SELECT Accounts.*

FROM crm.Accounts 

UNION ALL 

SELECT Accounts.*

FROM crm.Accounts 

UNION ALL 

SELECT Accounts.*

FROM crm.Accounts 

# Question 2: What Accounts currently have no opportunities assigned to them?
# The tables Accounts and Opportunities share column Account_Name

SELECT Accounts.Account_Name

FROM crm.Accounts

EXCEPT DISTINCT

SELECT Opportunities.Account_Name

FROM crm.Opportunities 

# Question 3: Who are the sales reps that have accounts assigned?
# Reps table has Full_Name / Accounts table has Owner_Name -> they are the same.

SELECT Reps.Full_Name

FROM crm.Reps

INTERSECT DISTINCT

SELECT Accounts.Owner_Name

FROM crm.Accounts

# Question 4: Which accounts have not had a new opportunity since end of Q3? 
# Q3 dates are: 01-07-2019 until 30-09-2019
# I am assuming end of Q3 in this question means Q3 in 2019.
# Problem = there might be accounts with more than one opportunity in their name so how do we make sure these don't show up in the list?
# Also I am a bit confused because a lot of the accounts in the Opportunities table actually do not exist in the Accounts table.

SELECT opps.Account_Name, opps.CreatedDate,
    
FROM crm.Opportunities opps

WHERE opps.CreatedDate >= '2019-09-30' 

# This is how I found the duplicates in the Account_Name column in Opportunities.

SELECT opps.Account_Name, COUNT(*)

FROM crm.Opportunities opps

GROUP BY opps.Account_Name

HAVING COUNT(*) > 1

# Question 5.1: Run the following query SELECT 'Diederik' as WINNER, 9999999 as AMOUNT (feel free to add yourself to it in a similar way)  Think about the output before you continue what is it?

SELECT 'Diederik' as WINNER, 9999999 as AMOUNT

# Question 5.2: Show all sales reps with their opportunities amount but add Diederik's name with 9999999 so he feels like a winner (and your own?)

SELECT  Reps.Full_Name, 
        Opportunities.Amount,

CASE WHEN Amount >= 9999999 THEN "Winner"
    ELSE "Loser"
END AS Status

FROM crm.Reps 
    LEFT JOIN  crm.Opportunities ON Opportunities.Owner_ID = Reps.User_ID

UNION ALL

SELECT 'Diederik' AS Full_Name, 9999999 AS Amount, 'Winner' AS Status

UNION ALL

SELECT 'Tori' AS Full_Name, 9999999 AS Amount, 'Winner' AS Status

# Question 5.3: Put brackets () around your query Put FROM in front of the opening bracket - (act like the code you created is just a table name). Find the 5 sales people with the biggest opportunities

SELECT *

FROM

    (SELECT 'Diederik' AS Full_Name, 9999999 AS Amount

    UNION ALL

    SELECT 'Tori' AS Full_Name, 9999999 AS Amount

    UNION ALL 

    SELECT  Reps.Full_Name, 
        Opportunities.Amount,

    FROM crm.Reps 
        LEFT JOIN  crm.Opportunities ON Opportunities.Owner_ID = Reps.User_ID)

GROUP BY Full_Name, Amount

ORDER BY Amount DESC

LIMIT 5


