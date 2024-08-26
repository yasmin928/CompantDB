-- Orders
DECLARE @i INT = 1
WHILE @i <= 200
BEGIN
    INSERT INTO Orders (OrderID, CustomerID, EmployeeID, OrderDate, ShipperID) VALUES (
        @i,
        ((@i - 1) % 100) + 1,  -- CustomerID between 1 and 100
        ((@i - 1) % 50) + 1,   -- EmployeeID between 1 and 50
        DATEADD(DAY, @i, '2023-01-01'),  -- OrderDate increasing from 2023-01-01
        ((@i - 1) % 5) + 1    -- ShipperID between 1 and 5
    )
    SET @i = @i + 1
END

/*
IMPORTANT: modulo of a number 𝑛 with a larger number 𝑚(where n<m), the result will always be 𝑛.
*/

-- OrderDetails
--DECLARE @i INT = 1 -- ALready declared. Make sure to use this line if you commented the previous declared variable.
SET @i = 1
WHILE @i <= 400
BEGIN
    INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES (
        @i,
        ((@i - 1) % 200) + 1,  -- OrderID between 1 and 200
        ((@i - 1) % 30) + 1,   -- ProductID between 1 and 30
        ((@i - 1) % 100) + 1   -- Quantity between 1 and 100
    )
    SET @i = @i + 1
END

-- Select data to verify
SELECT * FROM Suppliers;
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Employees;
SELECT * FROM Shippers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- Select data with different column names
SELECT ShipperName AS Shipping_company_name
FROM Shippers;

--------------------------------------------------------------------------------------
------------------------- Arithmetic Operators ---------------------------------------
--------------------------------------------------------------------------------------

-- Retrieve all the employees that there last name is not starting with letter 'F'
SELECT * FROM Employees WHERE LastName NOT LIKE 'F%';

-- Retrieve Employee Name as one name
SELECT FirstName+LastName AS Employee_Name
from Employees

--------------------------------------------------------------------------------------
------------------------- Comparison Operators ---------------------------------------
--------------------------------------------------------------------------------------

-- Retrieve all the orders that there shipper has id = 3
SELECT * FROM Orders WHERE ShipperID=3;

-- Retrieve OrderID & ProductID if its quantity is bigger than 50
SELECT OrderID, ProductID FROM OrderDetails WHERE Quantity >50;

-- Retrieve OrderID & ProductID if its quantity is not equal to 30
SELECT OrderID, ProductID FROM OrderDetails WHERE Quantity <>30;

--------------------------------------------------------------------------------------
------------------------- Logical Operators ------------------------------------------
--------------------------------------------------------------------------------------

-- Retrieve OrderID & ProductID if ProductID = 5 and Quantity = 20
SELECT OrderID, ProductID 
FROM OrderDetails 
WHERE ProductID = 5 AND Quantity = 20;

-- Retrieve all the employees that there last name is not starting with letter 'F' or its first name starts with letter 'W'
SELECT * 
FROM Employees 
WHERE LastName NOT LIKE 'F%' OR FirstName NOT LIKE 'W%';

--------------------------------------------------------------------------------------
------------------------- Special Operators ------------------------------------------
--------------------------------------------------------------------------------------

-- selects customers whose CustomerID is between 5 and 10, inclusive
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID BETWEEN 5 AND 10;

-- selects customers whose last names are either 'Frost', 'Rivers', or 'Vale'.  "IN: compare a value to a list" Less efficient
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE LastName IN ('Frost', 'Rivers', 'Vale');

--------------------------------------------------------------------------------------
------------------------- Aggregate Functions ----------------------------------------
--------------------------------------------------------------------------------------

-- Retrieve average quantity
SELECT AVG(Quantity) AS AvgQuantity
FROM OrderDetails;

-- retrieve the total number of rows
SELECT COUNT(*) AS TotalRows
FROM OrderDetails;

-- retrieve the first product ID appears in the table 
SELECT TOP 1 ProductID AS First_Product_ID
FROM OrderDetails;

-- Retrieve max quantity
SELECT MAX(Quantity) AS max_quantity
FROM OrderDetails;

-- retrieve all data from products and order by its price (desc, asc)
SELECT ProductName, Price
FROM Products
ORDER BY Price DESC; -- ASC

--------------------------------------------------------------------------------------
------------------------- Scalar Functions -------------------------------------------
--------------------------------------------------------------------------------------

-- Converting names to upper CASE
SELECT UPPER(FirstName) AS first_name
FROM Customers;

-- Fetching first 3 characters
SELECT SUBSTRING(FirstName, 1, 3) AS char_name
FROM Customers;

-- Fetching Customers names and current system time. 
select (FirstName+LastName), GETDATE()
from Customers;

--------------------------------------------------------------------------------------
------------------------- JOIN -------------------------------------------------------
--------------------------------------------------------------------------------------

-- For each category, list category_id, number of products, max price, lowest price, avgerage price
SELECT 
    CategoryID,
    COUNT(ProductID) AS NumberOfProducts,
    MAX(Price) AS MaxPrice,
    MIN(Price) AS LowestPrice,
    AVG(Price) AS AveragePrice
FROM 
    Products
GROUP BY CategoryID;

-- For each category, list category_id, category_name, number of products, max price, lowest price, avgerage price
SELECT 
    c.CategoryID,
    c.CategoryName,
    COUNT(p.ProductID) AS NumberOfProducts,
    MAX(p.Price) AS MaxPrice,
    MIN(p.Price) AS LowestPrice,
    AVG(p.Price) AS AveragePrice
FROM 
    Products p
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName;

-- OR
-- ORDER BY NumberOfProducts desc;
-- OR
-- HAVING COUNT(p.ProductID) > 4
-- ORDER BY NumberOfProducts desc;

--------------------------------------------------------------------------------------
------------------------- SubQueries -------------------------------------------------
--------------------------------------------------------------------------------------

-- selects customers whose CustomerID is greater than all CustomerID values in the Orders table.
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID > ALL (SELECT CustomerID FROM Orders);

-- selects customers whose CustomerID matches any CustomerID values in the Orders table.
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID = ANY (SELECT CustomerID FROM Orders);

-- Find orders shipped by FedEx
SELECT OrderID, CustomerID, OrderDate
FROM Orders
WHERE ShipperID = (SELECT ShipperID FROM Shippers WHERE ShipperName = 'FedEx');

-- Find orders placed by customers with more than or equal 2 orders
SELECT OrderID, CustomerID, OrderDate
FROM Orders
WHERE CustomerID IN (SELECT CustomerID
                     FROM Orders
                     GROUP BY CustomerID
                     HAVING COUNT(*) >= 2);

-- Find orders with more than or equal 2 different products ordered
SELECT OrderID, COUNT(DISTINCT ProductID) AS NumProducts
FROM OrderDetails
GROUP BY OrderID
HAVING COUNT(DISTINCT ProductID) >= 2;

-- Find customers who have ordered more than 100 units in total
SELECT CustomerID
FROM Orders
WHERE OrderID IN (SELECT OrderID
                  FROM OrderDetails
                  GROUP BY OrderID
                  HAVING SUM(Quantity) > 100);
				  
-- Using both where and having
-- Find orders where the total quantity of products ordered exceeds 100 units after a specific date
SELECT od.OrderID, COUNT(*) AS NumProducts, SUM(od.Quantity) AS TotalQuantity
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate > '2023-06-01'  -- Filtering orders placed after June 1st, 2023
GROUP BY od.OrderID
HAVING SUM(Quantity) > 100;  -- Filtering orders where total quantity exceeds 100 units

-- selects customers for whom there exists an order in the Orders table.  "EXISTS: compare a value to a subquery or a list" More efficient.
SELECT CustomerID, FirstName, LastName  
FROM Customers
WHERE EXISTS (SELECT 1 FROM Orders WHERE Orders.CustomerID = Customers.CustomerID);

-- selects customers for whom there IN an order in the Orders table.  "IN: compare a value to a list" Less efficient.
SELECT CustomerID, FirstName, LastName  
FROM Customers
WHERE CustomerID IN (SELECT 1 FROM Orders WHERE Orders.CustomerID = Customers.CustomerID);

--------------------------------------------------------------------------------------
------------------------- user defined functions -------------------------------------
--------------------------------------------------------------------------------------

-- Calculate Total Quantity for an Order
CREATE FUNCTION dbo.GetTotalQuantityForOrder (@orderId INT)
RETURNS INT
AS
BEGIN
    DECLARE @totalQuantity INT;

    SELECT @totalQuantity = SUM(Quantity)
    FROM OrderDetails
    WHERE OrderID = @orderId;

    RETURN ISNULL(@totalQuantity, 0);
END;

-- Usage
DECLARE @orderId INT = 1;
SELECT dbo.GetTotalQuantityForOrder(@orderId) AS TotalQuantity;

-- Get the total number of orders for a given customer
CREATE FUNCTION GetTotalOrdersByCustomer
(
    @CustomerID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalOrders INT;
    SELECT @TotalOrders = COUNT(*)
    FROM Orders
    WHERE CustomerID = @CustomerID;
    RETURN @TotalOrders;
END;

-- Calculate the total cost of an order
CREATE FUNCTION GetTotalOrderCost
(
    @OrderID INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(18, 2);
    SELECT @TotalCost = SUM(od.Quantity * p.Price)
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = @OrderID;
    RETURN @TotalCost;
END;

-- Retrieve the name of a product based on its ID
CREATE FUNCTION GetProductName
(
    @ProductID INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @ProductName NVARCHAR(50);
    SELECT @ProductName = ProductName
    FROM Products
    WHERE ProductID = @ProductID;
    RETURN @ProductName;
END;

-- Get the full name of an employee based on their ID
CREATE FUNCTION GetEmployeeFullName
(
    @EmployeeID INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FullName NVARCHAR(100);
    SELECT @FullName = FirstName + ' ' + LastName
    FROM Employees
    WHERE EmployeeID = @EmployeeID;
    RETURN @FullName;
END;


-- Check if a product belongs to a specific category
CREATE FUNCTION IsProductInCategory
(
    @ProductID INT,
    @CategoryID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsInCategory BIT;
    IF EXISTS (
        SELECT 1
        FROM Products
        WHERE ProductID = @ProductID
        AND CategoryID = @CategoryID
    )
    BEGIN
        SET @IsInCategory = 1;
    END
    ELSE
    BEGIN
        SET @IsInCategory = 0;
    END
    RETURN @IsInCategory;
END;

--------------------------------------------------------------------------------------
------------------------- Stored Procedures ------------------------------------------
--------------------------------------------------------------------------------------

-- Retrieves orders placed by a specific customer ID
CREATE PROCEDURE GetOrdersByCustomerID
    @customerId INT
AS
BEGIN
    SELECT OrderID, OrderDate, ShipperID
    FROM Orders
    WHERE CustomerID = @customerId;
END;

-- ALTER PROCEDURE to select only OrderID and OrderDate
ALTER PROCEDURE GetOrdersByCustomerID
    @customerId INT
AS
BEGIN
    SELECT OrderID, OrderDate
    FROM Orders
    WHERE CustomerID = @customerId;
END;

-- Usage
DECLARE @customerId INT = 1;  -- Example CustomerID
EXEC GetOrdersByCustomerID @customerId;

-- List all orders for a given customer
CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT o.OrderID, o.OrderDate, o.ShipperID
    FROM Orders o
    WHERE o.CustomerID = @CustomerID;
END;

-- Find all products supplied by a specific supplier
CREATE PROCEDURE GetProductsBySupplier
    @SupplierID INT
AS
BEGIN
    SELECT p.ProductID, p.ProductName, p.Price
    FROM Products p
    WHERE p.SupplierID = @SupplierID;
END;

-- Get the total quantity of each product ordered
CREATE PROCEDURE GetTotalProductQuantity
AS
BEGIN
    SELECT od.ProductID, SUM(od.Quantity) AS TotalQuantity
    FROM OrderDetails od
    GROUP BY od.ProductID;
END;

-- Retrieve all orders handled by a specific employee within a date range
CREATE PROCEDURE GetEmployeeOrders
    @EmployeeID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT o.OrderID, o.CustomerID, o.OrderDate, o.ShipperID
    FROM Orders o
    WHERE o.EmployeeID = @EmployeeID
      AND o.OrderDate BETWEEN @StartDate AND @EndDate;
END;

-- Calculate the total sales for each product category
CREATE PROCEDURE GetTotalSalesByCategory
AS
BEGIN
    SELECT c.CategoryID, c.CategoryName, SUM(od.Quantity * p.Price) AS TotalSales
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
    GROUP BY c.CategoryID, c.CategoryName;
END;

--------------------------------------------------------------------------------------
------------------------- Control of Flow --------------------------------------------
--------------------------------------------------------------------------------------
-- Retrieve ProductID & ProductName with price greater than 500 and print a message if no records are retrieved
BEGIN
	SELECT ProductID, ProductName
	FROM Products
	WHERE Price > 500;
	
	IF @@ROWCOUNT = 0  -- Global Variable automatically identified by sql server.
		PRINT 'No product with price greater than 500 found';
END

-- Retrieve the product name appears in the first row after ordering by price in descending order
-- IF there is a value retrieved print a message show that this is the most expensive product
-- otherwise print no product found
BEGIN
	DECLARE @name VARCHAR(MAX);

	SELECT TOP 1 
		@name = ProductName
	FROM Products
	ORDER BY Price DESC;

	IF @@ROWCOUNT <> 0
	BEGIN  -- Specify to identify all of the statements at this block in case of if
		PRINT 'The most expensive product is ' + @name
	END
	ELSE
	BEGIN
		PRINT 'No Product found';
	END;
END

-- WE need to know if the sales in 2023 is greater than 1,000,000 or not
-- Print a Congratulations message if yes otherwise print enthusiastic message

-- Exploratory query "What years we have"
Select DISTINCT(LEFT(OrderDate, 4))
From Orders
-- OR
SELECT YEAR(OrderDate) from Orders
--------
BEGIN
	DECLARE @TotalSales INT;

	SELECT
		@TotalSales = SUM(od.Quantity * p.Price)
	from OrderDetails od
	JOIN Products p ON od.ProductID = p.ProductID
	JOIN Orders o ON o.OrderID = od.OrderID
	WHERE YEAR(o.OrderDate) = 2023;

	IF @TotalSales > 1000000
	BEGIN
		PRINT 'You got total sales of'+str(@TotalSales)+CHAR(10)+'Congratulations! Sales in 2023 exceeded $1,000,000!';
	END
	ELSE
	BEGIN
		PRINT 'Keep pushing! Let''s strive to exceed $1,000,000 in sales next year!';
	END
END
-- what is ASCII()
SELECT ASCII('A'), ASCII('a') -- >>65, 97
/*
65/2=32.5 >> 1
32/2=16   >> 0
16/2=8	  >> 0
8/2=4	  >> 0
4/2=2	  >> 0
2/2=1	  >> 0
1/2=0.5	  >> 1
*/

-- WHILE
DECLARE @counter INT = 0

WHILE @counter <= 50
BEGIN
	SET @counter = @counter + 1
	IF @counter = 10
		BREAK;
	if @counter = 5
		CONTINUE
	PRINT @Counter
	
END

--------------------------------------------------------------------------------------
------------------------- Cursors ----------------------------------------------------
--------------------------------------------------------------------------------------
-- Example 1
SELECT ProductName, Price
FROM Products

-- USING Cursors
DECLARE @product_name VARCHAR(MAX), @list_price DECIMAL;

DECLARE cursor_product CURSOR
FOR SELECT productName, Price
FROM Products;

-- OPEN
OPEN cursor_product;

-- FETCH
FETCH NEXT FROM cursor_product INTO @product_name, @list_price;

-- Loop overall rows
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @product_name + ' ' + CAST(@list_price AS varchar);
	FETCH NEXT FROM cursor_product INTO
	@product_name,
	@list_price;
END;

-- CLOSE
CLOSE cursor_product;

-- Deallocate
DEALLOCATE cursor_product;

-- Example 2
SELECT c.CategoryName, p.ProductName, p.Price
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
Order by c.CategoryName

-- USING Cursors
DECLARE @category_name VARCHAR(MAX), @product_name VARCHAR(MAX), @list_price DECIMAL;

DECLARE curosr_product_by_category CURSOR
FOR SELECT c.CategoryName, p.ProductName, p.Price
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
Order by c.CategoryName

-- OPEN
OPEN curosr_product_by_category;

-- FETCH
FETCH NEXT FROM curosr_product_by_category INTO @category_name, @product_name, @list_price;

-- Loop overall rows
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @category_name + ' ' + @product_name + ' ' + CAST(@list_price AS varchar);
	FETCH NEXT FROM curosr_product_by_category INTO
	@category_name,
	@product_name,
	@list_price;
END;

-- CLOSE
CLOSE curosr_product_by_category;

-- Deallocate
DEALLOCATE curosr_product_by_category;

--------------------------------------------------------------------------------------
------------------------- Exception Handling -----------------------------------------
--------------------------------------------------------------------------------------
-- ERROR
SELECT 10 / 0

-- Without procedure
BEGIN TRY
	SELECT 10 / 0
END TRY
BEGIN CATCH
	SELECT
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_LINE() AS ErrorLine,
		ERROR_PROCEDURE() AS ErrorProcedure;
END CATCH

-- with stored procedure (Alter PROC)
CREATE PROC divide_numbers(@numerator DECIMAL, @denominator DECIMAL, @RESULT DECIMAL OUTPUT) AS
BEGIN
    BEGIN TRY
        SET @RESULT = @numerator / @denominator
        PRINT 'Inside Try result = ' + CAST(@RESULT AS VARCHAR)
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_STATE() AS ErrorState,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END;

-- Execution
DECLARE @z DECIMAL
EXEC divide_numbers 10, 2, @z OUTPUT -- USE (10, 0)
PRINT @z

-------------------------- Solving the problem -------------------
CREATE PROC divide_numbers_solve(@numerator DECIMAL, @denominator DECIMAL, @RESULT DECIMAL OUTPUT) AS
BEGIN
	BEGIN TRY
		SET @RESULT = @numerator / @denominator
		PRINT 'Inside Try result = ' + CAST(@RESULT AS VARCHAR)
	END TRY
	BEGIN CATCH
		if ERROR_NUMBER() = 8134
			PRINT 'Enter Non Zero value for the @denominator'
			SET @RESULT = NULL
	END CATCH
END;

-- Execution
DECLARE @z DECIMAL
EXEC divide_numbers 10, 5, @z OUTPUT
PRINT @z
-------------------------- Raise your own Error ------------------
CREATE PROCEDURE DivideNumber_custom_error (@Numerator INT, @Denominator INT, @Result INT OUTPUT)
AS
BEGIN
    BEGIN TRY
        IF @Denominator = 0
        BEGIN
			-- RAiSEERROR(Message, Sverity Level, State_Number)
            RAISERROR('Divide by zero error: @Denominator cannot be zero.', 16, 1);
            RETURN;
        END
        SET @Result = @Numerator / @Denominator;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_STATE() AS ErrorState,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END;

DECLARE @result_output INT;
EXEC DivideNumber_custom_error 10, 0, @result_output OUTPUT;
PRINT @result_output

--------------------------------------------------------------------------------------
----------------------------- Triggers -----------------------------------------------
--------------------------------------------------------------------------------------

-- audits table
CREATE TABLE product_audits(
	change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
	--FOREIGN KEY (product_id) REFERENCES Products(ProductID),
    CHECK(operation = 'INS' or operation='DEL') --Constraint CHECK
)

-- CREATE Trigger
CREATE TRIGGER trg_product_audits ON Products
AFTER INSERT, DELETE 
AS
BEGIN
	SET NOCOUNT ON; -- Ignore the message of how many rows affected

	INSERT INTO product_audits (product_id, product_name, category_id, list_price, updated_at, operation)

	SELECT i.ProductID, ProductName, CategoryID, i.Price, GETDATE(), 'INS'
	FROM inserted AS i

	UNION ALL

	SELECT d.ProductID, ProductName, CategoryID, d.Price, GETDATE(), 'DEL'
	FROM deleted AS d

END

-- Insert in products
INSERT INTO Products VALUES (32, 'Mouse', 7, 5, 56.5)
-- Delete from products
DELETE FROM Products WHERE PRODUCTID = 31 -- >> ERROE

DROP TABLE product_audits
CREATE TABLE product_audits(
	change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
	--FOREIGN KEY (product_id) REFERENCES Products(ProductID),
    CHECK(operation = 'INS' or operation='DEL') --Constraint CHECK
)
-- CHECK the trigger calls
SELECt * FROM product_audits

