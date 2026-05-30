-- 1. Average price by region for the latest year
SELECT Region_Name, ROUND(AVG(Average_Price), 0) AS avg_price
FROM prices
WHERE Year = (SELECT MAX(Year) FROM prices)
GROUP BY Region_Name
ORDER BY avg_price DESC;
 
-- 2. UK national average price by year
SELECT Year, ROUND(AVG(Average_Price), 0) AS uk_avg_price
FROM prices
WHERE Region_Name = 'United Kingdom'
GROUP BY Year
ORDER BY Year;
 
-- 3. Price gap between London and the UK average over time
SELECT a.Year,
       ROUND(AVG(a.Average_Price), 0) AS london_avg,
       ROUND(AVG(b.Average_Price), 0) AS uk_avg,
       ROUND(AVG(a.Average_Price) - AVG(b.Average_Price), 0) AS gap
FROM prices a
JOIN prices b ON a.Year = b.Year
WHERE a.Region_Name = 'London' AND b.Region_Name = 'United Kingdom'
GROUP BY a.Year
ORDER BY a.Year;
 
-- 4. Top 5 regions by price growth (2000 to latest year)
WITH price_2000 AS (
  SELECT Region_Name, AVG(Average_Price) AS p2000
  FROM prices WHERE Year = 2000 GROUP BY Region_Name
),
price_latest AS (
  SELECT Region_Name, AVG(Average_Price) AS p_latest
  FROM prices WHERE Year = (SELECT MAX(Year) FROM prices) GROUP BY Region_Name
)
SELECT a.Region_Name,
       ROUND(((b.p_latest - a.p2000) / a.p2000) * 100, 1) AS growth_pct
FROM price_2000 a
JOIN price_latest b ON a.Region_Name = b.Region_Name
WHERE a.p2000 > 0
ORDER BY growth_pct DESC
LIMIT 5;
 
-- 5. Years where UK average price fell year-on-year
WITH yearly AS (
  SELECT Year, AVG(Average_Price) AS price
  FROM prices
  WHERE Region_Name = 'United Kingdom'
  GROUP BY Year
)
SELECT a.Year, ROUND(a.price, 0) AS this_year, ROUND(b.price, 0) AS last_year
FROM yearly a
JOIN yearly b ON a.Year = b.Year + 1
WHERE a.price < b.price
ORDER BY a.Year;
