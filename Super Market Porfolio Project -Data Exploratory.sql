---- Skills used: CTE'S, Subquery, Aggregate Function, Windown Function, CASE WHEN, GROUP BY, ORDER BY

---Which branch has the most invoice and earn the most money?
WITH comparision AS(
	SELECT
		Branch,
		SUM(total) as Total_revenue,
		COUNT(invoice_id) as Number_invoice
	FROM P1..supermarket
	GROUP BY Branch
)
SELECT 
	Branch,
	ROUND((Total_revenue/(SELECT sum(total_revenue) FROM comparision))*100,0) as Per_revenue,
	(CAST(Number_invoice AS float)/CAST((SELECT sum(number_invoice) FROM comparision) AS float)*100) as Per_Invoice
FROM comparision
ORDER BY Branch
--->> ABOUT REVENUE, BRANCH C IS THE HIGHEST ONE BUT BRANCH C HAS THE LOWEST NUMBER OF INVOICE 



--- Percentage of total sale value by gender
WITH Gender_segment as(
	SELECT
		Gender,
		SUM(total) as Total_gender
	FROM P1..supermarket
	GROUP BY Gender
)
SELECT Gender,
		ROUND((Total_gender/(SELECT SUM(Total_gender) FROM Gender_segment))*100,0) As per_by_gender
FROM Gender_segment ---/=> We get results with almost the same ratio of value between male and female


--- Check whether if the sale value from member is higher than normal
WITH Customer_type as(
	SELECT
		Customer_type,
		SUM(total) as Total_customer_type
	FROM P1..supermarket
	GROUP BY Customer_type
)
SELECT Customer_type,
		ROUND((Total_customer_type/(SELECT SUM(Total_customer_type) FROM Customer_type))*100,0) As per_by_customer 
FROM Customer_type ---=>> Value Contribution of the Member type is more than the normal one



---- How many values does each product_line contribute to the total?
WITH Product as(
	SELECT
		Product_line,
		SUM(total) as Total_product
	FROM P1..supermarket
	GROUP BY Product_line
)
SELECT Product_line,
		ROUND((Total_product/(SELECT SUM(Total_product) FROM Product))*100,0) As per_by_product
FROM Product ---=> Health and beauty has the lowest contribution rate while the other 4 categories are equally distributed



----What day of the week does the supermarket have the most customers?
SELECT 
	Dayofweek,
	AVG(Total) as AVG_Value
FROM (SELECT 
		CAST (Payment_date AS datetime) as P_date,
		DATENAME (Weekday,payment_date) as Dayofweek,
		Total
	FROM P1..supermarket) as by_day
GROUP BY Dayofweek
ORDER BY Avg_Value DESC
----> Customers tend to go to the supermarket on weekends the most.Monday and Wednesday have the lowest number of visitors of the week


----- Distribution of visitors by timeframe in a day
SELECT
	Start_time, End_time,
	count(*) as numberofcustomer
FROM (SELECT 
	time,
	CAST(CONVERT(VARCHAR(2), time, 120) AS INT) as Start_time,
	CAST(CONVERT(VARCHAR(2), time, 120) AS INT) + 1 as End_time
	FROM P1..supermarket) As A
GROUP BY Start_time, End_time
ORDER BY Start_time ----=> 19:00 to 20:00 is the time when the most customers come to the supermarket

--- CACULATE NPS SCORE FOR EACH BRANCH
WITH NPS_SCORE AS(
		SELECT 
			Branch,
			NPS,
			Count(NPS) as Votes
		FROM(SELECT
				Branch,
				CASE WHEN Rating >= 0 and Rating < 7 THEN 'Detractors'
					WHEN Rating >= 7 and Rating < 9 THEN 'Passives'
					ELSE 'Promoters' END AS NPS
			FROM P1..supermarket) AS N
		GROUP BY Branch, NPS)
, NPS_TABLE as(
		SELECT 
				Branch,
				NPS,
				ROUND((Votes/CAST(total_vote AS FLOAT))*100,1) as NPS_Per
		FROM (
				SELECT 
				Branch,
				NPS,
				Votes,
				SUM(Votes) OVER (PARTITION BY BRANCH) as Total_vote
				FROM NPS_SCORE ) AS NPS_PER
)
	SELECT
	a.Branch, a.NPS, a.NPS_Per, b.NPS, b.NPS_Per,
	a.NPS_Per - b.NPS_Per as Sub
	FROM
	(SELECT * FROM NPS_TABLE
	WHERE NPS = 'Promoters') a
	JOIN
	(SELECT * FROM NPS_TABLE
	WHERE NPS = 'Detractors') b ON a.Branch = b.Branch
	ORDER BY a.Branch

	----> Branch B has the lowest NPS Score in the group 