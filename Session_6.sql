# Week 6 :)

# Question 1: The first thing Mike is interested in is the total number of flights, and total number of passengers that flew to New York. Can you provide this?

SELECT  COUNT(Flights.to) AS total_flights,
        SUM(Flights.passengers) AS total_passengers

FROM fraud.Flights

WHERE Flights.to = 'New York'

# Question 2:
# Mike has used his immaculate dress sense, style and recently trimmed beard to convince a woman that has access to baggage data for all airlines. 
# This information is captured in the baggage table. Can you show the average weight per baggage type per airline? 

SELECT  AVG(Baggage.weight) AS average_weight,
        Baggage.type,
        Flights.airline,

FROM fraud.Baggage
    LEFT JOIN fraud.Flights ON Flights.flight_number = Baggage.flight_number

GROUP BY Baggage.type, Flights.airline

# Question 3:
# Top cyclists are increasingly training in a polarized way, with time spent either at extremely low heartrate zones (z2 and below), or deep in the rest (z6 and up). Sweet spot training, essentially straddling the middle ground, has become unpopular at the very top.

# However, Mike loves averages. Can you give him the following averages:

# i) Average number of passengers for flights from Seattle;

SELECT AVG(Flights.passengers) AS avg_passengers,

FROM fraud.Flights

WHERE Flights.from = 'Seattle'

# ii) Average number of passengers for flights to New York; 

SELECT AVG(Flights.passengers) AS avg_passengers,

FROM fraud.Flights

WHERE Flights.to = 'New York'

# iii) Average number of passengers for flights from Seattle to New York;

SELECT AVG(Flights.passengers) AS avg_passengers,

FROM fraud.Flights

WHERE Flights.from = 'Seattle' AND Flights.to = 'New York'

# iv) Average number of bike bags checked in across all flights in February (answer should be 3.05?)

#Ties’ pro tips: You may want to use EXTRACT (link to documentation) here :)
#
#Ties’ metric definition dictionary: Average number of bike bags = Number of bike bags included in all flights / Number of flight

SELECT (COUNT(DISTINCT Baggage.baggage_id) / COUNT(DISTINCT Flights.flight_number)) AS avg_nr_bike_bags,
    Baggage.type,

FROM fraud.Flights
    INNER JOIN fraud.Baggage ON Baggage.flight_number = Flights.flight_number

WHERE type = 'Bikebag' 
    AND EXTRACT(MONTH FROM Flights.timestamp) = 2

GROUP BY Baggage.type

# v) Average number of bike bags checked in for CA flight numbers that have at least one bike bag on board 
# (Note: you can count one flight number (e.g. CA100) as a single flight) 

SELECT  (COUNT(DISTINCT Baggage.baggage_id) / COUNT(DISTINCT Flights.flight_number)) AS avg_nr_bike_bags,

FROM fraud.Flights
    INNER JOIN fraud.Baggage ON Baggage.flight_number = Flights.flight_number

WHERE Baggage.type = 'Bikebag'

    AND SUBSTRING(Flights.flight_number, 0, 2) = 'CA'

# Question from me: What if you wanted to know the answer to this question but only for flight numbers that had at least 2 bike bags on board? 
# Use a subquery in the WHERE statement

SELECT  (COUNT(DISTINCT Baggage.baggage_id) / COUNT(DISTINCT Baggage.flight_number)) AS avg_nr_bike_bags,

FROM fraud.Baggage

WHERE Baggage.flight_number LIKE "CA%"

        AND Baggage.type = "Bikebag"

        AND Baggage.flight_number IN  

            (SELECT flight_number
        
                FROM (SELECT Baggage.flight_number, COUNT(Baggage.type)
            
                        FROM fraud.Baggage
                        
                        WHERE Baggage.type = 'Bikebag'

                        AND SUBSTRING(Baggage.flight_number, 0, 2) = 'CA'
                        
                        GROUP BY Baggage.flight_number

                        HAVING COUNT(Baggage.type) > 1)
            )
            
### Ties solution with alternative syntax for SUBSTRING:

SELECT
  COUNT(DISTINCT Baggage.baggage_id) / COUNT(DISTINCT Baggage.flight_number) AS avg_bikebags

FROM fraud.Baggage

WHERE Baggage.flight_number LIKE "CA%"

AND Baggage.type = "Bikebag";

# Question 4
# In 2019, on average across all airlines there were 40 pieces of check-in luggage per flight. 
# This year, Mike has a hunch that the average number of luggage check-in per flight is lower. Can you validate this claim? 
#   Ties’ pro tips: working with dates, you often want to use EXTRACT (link to documentation).

SELECT (COUNT(DISTINCT Baggage.baggage_id) / COUNT(DISTINCT Flights.flight_number)) AS avg_luggage_per_flight,
         --  Flights.airline,
            EXTRACT(YEAR FROM Flights.timestamp) AS year

FROM fraud.Baggage
    LEFT JOIN fraud.Flights ON Baggage.flight_number = Flights.flight_number

GROUP BY 
--Flights.airline,
 year

# Question 5a
# From previous analysis, Mike knows that the baggage is overweight 20% of the time. Let’s validate this theory.

# Ties’ wisdom: sometimes, writing it in one query is hard. Doing it in two queries is much easier. 
# Feel free to use a scrappy method here :)

SELECT COUNT(baggage_overweight) AS count_baggage, baggage_overweight

FROM
    (SELECT DISTINCT(Baggage.baggage_id), 
                CASE WHEN Baggage.weight > Allowance.max_weight_allowance THEN "overweight"
                        ELSE "not overweight"

                END AS baggage_overweight

          FROM fraud.Baggage
            INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type
    )

GROUP BY baggage_overweight

SELECT (235/(235+631)) AS percentage_overweight

# Answer code .. much more clever way of doing it.. but would that INNER JOIN work if different airlines had different weight allowance for different item types ?

SELECT
  (
      SELECT COUNT(DISTINCT Baggage.baggage_id)
  FROM fraud.Baggage
  INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type
  WHERE Baggage.weight > Allowance.max_weight_allowance
  )
   / COUNT(DISTINCT Baggage.baggage_id) AS perc_overweight
  FROM fraud.Baggage;

# Question 5b
# How about the % of overweight bags on flights from Austin & Seattle?
# Ties’ metric definition dictionary: Overweight bags = Number of bags overweight / Number of all bags

SELECT
  (SELECT COUNT(DISTINCT Baggage.baggage_id)
    FROM fraud.Baggage
    INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type
    INNER JOIN fraud.Flights ON Baggage.flight_number = Flights.flight_number

  WHERE Baggage.weight > Allowance.max_weight_allowance
  AND Flights.from IN ('Austin', 'Seattle')
  )
   / 
    (SELECT COUNT(DISTINCT Baggage.baggage_id) 
        FROM fraud.Baggage
        WHERE Baggage.flight_number IN (SELECT Flights.flight_number
                                        FROM fraud.Flights 
                                        WHERE Flights.from IN ('Austin', 'Seattle'))
    )    

AS percentage_overweight_bags;

# Question 6
# Mike goes for weekend group rides with the COO at one of the competing airlines. 
# They agree to a race, where the COO claims to have a “dirty secret” about his airline's approach to overweight baggage.
# Naturally, Mike with these massive thighs crushes his competitor in a thrilling final sprint. 
# The COO of KL claims that they changed policy after February 1, which has made them more lenient with overweight baggage. 
# Can you validate whether the COO of KL is telling the truth?

SELECT AVG(Baggage.paid_amount),
    CASE WHEN Flights.timestamp > "2020-02-01" THEN "After Feb 1"
    ELSE "Before Feb 1"
    END AS timing

FROM fraud.Baggage
    LEFT JOIN fraud.Flights ON Baggage.flight_number = FLights.flight_number
    INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type

WHERE Baggage.flight_number LIKE "KL%"
AND Baggage.weight > Allowance.max_weight_allowance

GROUP BY timing

# Question 7

# Since Cognitas Airways is based on the noble #mission of leveraging the fact that owners of Italian superbikes will do almost everything to protect them,
# even if it means crazy overweight baggage fees, we need to know how much revenue this has generated.
# Can you pull how much revenue Cognitas has generated with overweight baggage penalties?
# Ties’ pro tips: This might be a question that’s easier to do in multiple queries. 
# If you want to do it the cool way instead, you can use the SUBSTR function (link to documentation) to join Baggage.flight_number on Allowance.airline
# Ties’ metric definition dictionary: Revenue from overweight baggage = Paid amount for baggage - price of baggage type (summed for all bags)

SELECT SUM(Allowance.fine_overweight)

FROM fraud.Baggage
    LEFT JOIN fraud.Flights ON Baggage.flight_number = Flights.flight_number
    INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type

WHERE Baggage.flight_number LIKE "CA%" AND Flights.flight_number LIKE "CA%" AND Allowance.airline = "CA"
        AND (Baggage.paid_amount > Allowance.fine_overweight) AND (Baggage.weight > Allowance.max_weight_allowance)

# Answer from Ties and Max

SELECT
   SUM(Baggage.paid_amount - Allowance.price) AS paid_overweight
FROM fraud.Baggage
   INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type AND SUBSTR(Baggage.flight_number, 0, 2) = Allowance.airline
   WHERE Baggage.weight > Allowance.max_weight_allowance
   AND Baggage.flight_number LIKE "CA%"

# Question 8
#  Mike is surprised by the results, and is starting to sweat a little. With the current numbers,
#  his latest bike upgrade seems financially irresponsible. Maybe asymmetrical crank based power medals in the pedals were a bit much.
# Based on the baggage allowance price list, how much would you have expected to see in revenue from the fine listed in the price list? 
# How much do you actually see (your answer to question 7)?
#   Ties’ pro tips: This might be a question that’s easier to do in multiple queries. 
# If you want to do it the cool way instead, you can use the SUBSTR function (link to documentation) to join Baggage.flight_number on Allowance.airline.

SELECT 
(SELECT 
   COUNT(DISTINCT Baggage.baggage_id)
FROM fraud.Baggage
   INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type AND SUBSTR(Baggage.flight_number, 0, 2) = Allowance.airline
   WHERE Baggage.weight > Allowance.max_weight_allowance
   AND Baggage.flight_number LIKE "CA%"
   AND Baggage.type IN ("Roller", "Suitcase"))
   
* (175/2) AS estimated_revenue

# Question 9 
# Mike is furious, and says that he has not seen fraud of this magnitude since the post Tour de France win Floyd Landis doping scandal.
#  Do you think this is fraud? What else might be an explanation for the discrepancy?

Employees not actually charging for overweight luggage. Perhaps they are confused by the rules.

# Question 10
# Desperate to save face and blame the industry dynamics like a true leader, Mike has asked you to benchmark CA to the other two airlines.
# What is the total dollar value lost to “fraud” on overweight baggage claims, per airline? 
# How does CA compare, and what insights do you see here that would be interesting to present to the C-level?
# Ties’ metric definition dictionary: Lost revenue = Fine overweight baggage - Paid amount for overweight baggage by passengers (summed for all bags)

SELECT 
   SUM(Allowance.fine_overweight) AS missed_revenue,
   Allowance.airline,

FROM fraud.Baggage
   INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type AND SUBSTR(Baggage.flight_number, 0, 2) = Allowance.airline
   WHERE Baggage.weight > Allowance.max_weight_allowance
   AND Baggage.paid_amount = Allowance.price

GROUP BY Allowance.airline

# Max and Ties answer

SELECT
   SUBSTR(Baggage.flight_number, 0, 2) AS airline,
   SUM(Allowance.fine_overweight) - SUM(Baggage.paid_amount - Allowance.price) AS lost_revenue
FROM fraud.Baggage
INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type AND SUBSTR(Baggage.flight_number, 0, 2) = Allowance.airline
   WHERE Baggage.weight > Allowance.max_weight_allowance
GROUP BY airline;

# HARD: Finally, Mike is keen to see the % of overweight suitcases that did not get a fine per airline, broken out per luggage type.
# Can you pull this? Any interesting trends?
# % overweight without fine  = without fine overweight / total nr overweight
# COUNT (baggage_id) / COUNT(baggage_id)

# Max and Ties answer, couldn't figure this out.

SELECT
 SUBSTR(Baggage.flight_number, 0, 2) AS airline,
 Baggage.type,
 SUM
 (
  CASE WHEN Baggage.weight > Allowance.max_weight_allowance
  AND Baggage.paid_amount = (Allowance.price + Allowance.fine_overweight)
 THEN 0 ELSE 1 END) -- nr of unpaid fines
 / COUNT(DISTINCT Baggage.baggage_id) AS overweight_not_paid
FROM fraud.Baggage
INNER JOIN fraud.Allowance ON Baggage.type = Allowance.type
AND SUBSTR(Baggage.flight_number, 0, 2) = Allowance.airline
GROUP BY airline, Baggage.type;
