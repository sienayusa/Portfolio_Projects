
-- Change column name

Alter Table portfolio.apocolypse_sales
Rename column `Product ID` to Product_ID,
Rename column `Order ID` to Order_ID,
Rename column `Units Sold` to Units_Sold,
Rename column `Date Purchased` to Date_Purchased;


Alter Table portfolio.apocolypse_store
Rename column `Product ID` to Product_ID,
Rename column `Product Name` to Product_Name,
Rename column `Production Cost` to Production_Cost;







-- Join the Sales table with the Store table

Select 
	a.Product_ID,
    a.Customer, 
	a.Units_Sold, 
    a.Date_Purchased, 
    o.Product_Name, 
    o.Price,
    O.Production_Cost
From portfolio.apocolypse_sales a
Join portfolio.apocolypse_store o
	On a.Product_ID = O.Product_ID
Order by 1,2;








-- Create a new table with the result of the joined query

Create Table apocolypse_sales_staging AS 
Select 
	a.Product_ID,
    a.Customer, 
	a.Units_Sold, 
    a.Date_Purchased,
    o.Product_Name, 
    o.Price,
    o.Production_Cost,
    o.Price - o.Production_Cost AS 'Profit'
From portfolio.apocolypse_sales a
Join portfolio.apocolypse_store o
	On a.Product_ID = O.Product_ID
Order by Profit DESC;
    
    






-- TEMP TABLE
-- Delete the temp table when it is no longer needed.

Create Table apocolypse_sales_staging1
Like apocolypse_sales_staging;

Insert Into apocolypse_sales_staging1
Select * From apocolypse_sales_staging;

Select * From portfolio.apocolypse_sales_staging1;

Drop Table portfolio.apocolypse_sales_staging1;








-- Shows the total profit from each customer

Select 
	Customer, 
    Sum(Profit) AS 'Total_Profit'
From portfolio.apocolypse_sales_staging
Group by Customer
Order by Customer;








-- Looking at profit margin

Select 
	Customer, 
    Product_Name, 
    Price, 
    Production_Cost, 
    Profit, 
    (Profit/Price)*100 AS 'Profit_Margin'
From(
	Select 
		a.Product_ID,
		a.Customer, 
		a.Units_Sold, 
		a.Date_Purchased,
		o.Product_Name, 
		o.Price,
		o.Production_Cost,
		o.Price - o.Production_Cost AS 'Profit'
	From portfolio.apocolypse_sales a
	Join portfolio.apocolypse_store o
		On a.Product_ID = O.Product_ID
) AS Subquery
Order by Profit_Margin DESC;









-- Looking at the most sold product

Select 
	Product_Name, 
    UnitS_Sold
From(
	Select 
		a.Product_ID,
		a.Customer, 
		a.Units_Sold, 
		a.Date_Purchased,
		o.Product_Name, 
		o.Price,
		o.Production_Cost,
		o.Price - o.Production_Cost as 'Profit'
	From portfolio.apocolypse_sales a
	Join portfolio.apocolypse_store o
		On a.Product_ID = O.Product_ID
) AS Subquery
Order by Units_Sold DESC;








-- Looking at customer's selling capabilities
-- Select customer, product name, units sold, and assign a status based on units sold

Select 
	Customer, 
    Product_Name, 
    Units_Sold, 
Case
	When Units_Sold >= 60 Then 'Gold'
	When Units_Sold between 40 and 60 Then 'Silver'
	When Units_Sold between 20 and 40 Then 'Not Bad'
	Else 'Bad'
End AS 'Status'
From(
	Select 
		a.Product_ID,
		a.Customer, 
		a.Units_Sold, 
		a.Date_Purchased,
		o.Product_Name, 
		o.Price,
		o.Production_Cost,
		o.Price - o.Production_Cost AS 'Profit'
	From portfolio.apocolypse_sales a
	Join portfolio.apocolypse_store o
		On a.Product_ID = O.Product_ID
) AS Subquery
Where Units_Sold IS NOT NULL
Order by Customer;







-- Looking at the rolling sum of units sold for each customer

Select 
	a.Customer, 
    a.Date_Purchased,
    SUM(Cast(a.Units_Sold AS signed)) OVER (
		Partition by a.Customer
        Order by a.Date_Purchased 
		Rows between unbounded preceding and current row
	) AS Rolling_Units_Sold
From portfolio.apocolypse_sales a
Order by a.Customer, a.Date_Purchased;







-- USE CTE

With CustomervsSales (Customer, Product_Name, Date_Purchased, Units_Sold, Rolling_Units_Sold)
AS
(
Select 
	a.Customer, 
    o.Product_Name,
    a.Date_Purchased,
    a.Units_Sold,
    SUM(Cast(a.Units_Sold AS signed)) OVER (
		Partition by a.Customer
        Order by a.Date_Purchased 
		Rows between unbounded preceding and current row
	) AS Rolling_Units_Sold
From portfolio.apocolypse_sales a
Join portfolio.apocolypse_store o
	On a.Product_ID = o.Product_ID
)
Select * From CustomervsSales
Order by CustomervsSales.Customer, CustomervsSales.Date_Purchased;







-- Creating view to store data for later visulations

Create View apocolypse_sales_staging_View AS
Select 
	a.Product_ID,
    a.Customer, 
	a.Units_Sold, 
    a.Date_Purchased,
    o.Product_Name, 
    o.Price,
    o.Production_Cost,
    o.Price - o.Production_Cost AS 'Profit'
From portfolio.apocolypse_sales a
Join portfolio.apocolypse_store o
	On a.Product_ID = O.Product_ID
Order by Profit DESC;
