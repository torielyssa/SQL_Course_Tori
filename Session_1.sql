
#Exercise A
#Select all the flight numbers that depart from Chicago

SELECT  
    flno, d_from

FROM 
    flights.Flights

WHERE
   d_from = ('Chicago')

#Exercise B
#Select all the flight numbers that leave from Madison that cost under $140

SELECT  
   flno AS flight_number, 
   price AS price_dollars, 
   distance

FROM 
    flights.Flights

WHERE
    d_from = ('Madison')
    AND price < 140

# Exercise C
# Select the flight numbers for all flights to Dallas

SELECT  
    flno, d_to

FROM 
    flights.Flights

WHERE
    d_to = ('Dallas')

# Exercise D
# Select all flight numbers, distance & price for flights that fly to Honolulu, Washington or Sydney

SELECT  
    flno, distance, price, d_to

FROM 
    flights.Flights

WHERE
    d_to IN ('Honolulu', 'Washington', 'Sydney')

# Exercise E
# Select all columns for the flight with flight number 2223.

SELECT * 

FROM flights.Flights

WHERE flno = 2223

# Exercise F
# From what cities can you fly to New York for less than 200 dollars?

SELECT d_from AS departure_city,
        d_to AS arrival_city,
        price AS price_in_dollars

FROM flights.Flights

WHERE 
        d_to = ('New York')
        AND price < 200

# Exercise G
# What is the average price for every city of destination?

SELECT d_to AS destination_city,
        AVG(price) AS average_price

FROM flights.Flights

GROUP BY d_to

# Exercise H
# What is the price of the most expensive flight departing from Los Angeles?

SELECT  
        d_from AS departure_city,
        MAX(price) as most_expensive_flight

FROM 
        flights.Flights

WHERE 
        d_from = ('Los Angeles')

GROUP BY 
        d_from

# Exercise I 
# What are the flight numbers, departing cities, destinations, and prices from the flights that fly more than 500 in distance and cost less than 200 or flight more 1000 in distance and cost more than 200?

SELECT  flno AS flight_numbers,
        d_from AS departure_city,
        d_to AS destination_city,
        price AS price_in_dollars,

FROM    flights.Flights

WHERE   (distance > 500 AND price < 200)
        OR 
        (distance > 1000 AND price > 200)

GROUP BY flno,d_from, d_to, price

# Exercise J 
# What is the total price and total distance of all flights departing from Los Angeles? Rename your columns to easier to understand names as well!

SELECT 
        SUM(price) AS total_price, 
        SUM(distance) AS total_distance,

FROM flights.Flights

WHERE d_from = ('Los Angeles')

# Pivot Tables

SELECT d_from, d_to

FROM flights.Flights

GROUP BY d_from, d_to

