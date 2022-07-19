# Question A: What is the departing city, destination, and average price of the top 5 longest distance flights?

SELECT  d_from AS departing_city,
        d_to AS destination,
        distance,
        AVG(price) as average_price

FROM flights.Flights

GROUP BY d_from, d_to, distance

ORDER BY distance DESC 

LIMIT 5


# Question B: How many unique destinations does each departing city have? Sort the table from largest to smallest.

SELECT 
        d_from AS departing_city,
        
        COUNT(DISTINCT d_to) AS destination

FROM    flights.Flights 

GROUP BY d_from

ORDER BY COUNT(DISTINCT d_to) DESC

# Question C: There is a data quality issue in the flights.Flights table... 
# The data in the ‘departs’ and ‘arrives’ column indicate that some flights are flying back in time. 
# Create a new column that checks what rows of data are valid saying “Valid” if the ‘departs’ column is smaller than the ‘arrives’ column and 
# ... “Invalid” when the ‘arrives’ column is smaller than the ‘departs’ column.

SELECT  departs AS departure_time,
        arrives AS arrival_time,

        CASE    
            WHEN departs < arrives THEN "Valid"
            WHEN arrives < departs THEN "Invalid"

            ELSE "Error"
        
        END AS  flying_time_quality

FROM    flights.Flights 

# Question D
# Select the flight number, departing city, destination, departing date, and arriving date. Also, filter out all rows that are flagged as “Invalid”

SELECT  flno AS flights_number,
        d_from AS departing_city,   
        d_to AS destination,
        departs AS departing_date,
        arrives AS arrival_date,
        
        CASE    
            WHEN departs < arrives THEN "Valid"
            WHEN arrives < departs THEN "Invalid"

            ELSE "Error"
        
        END AS  flying_time_quality
    
FROM flights.Flights    

GROUP BY flno, d_from, d_to, departs, arrives

HAVING flying_time_quality = 'Valid'
