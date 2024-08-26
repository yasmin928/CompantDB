--5)Retrieve all the employees that there last name is not starting with letter 'F'
SELECT *
FROM Employees
WHERE LastName NOT LIKE 'F%';

--6)Retrieve column called “Employee Name” hold the first name and the last name.
SELECT CONCAT(FirstName, ' ', LastName) AS EmployeeName
FROM Employees;

--7)Retrieve all the orders that there shipper has id = 3
SELECT *
FROM Orders
WHERE ShipperID = 3;

--8)Retrieve OrderID & ProductID if its quantity is not equal to 30
SELECT OrderID , ProductID ,Quantity
FROM OrderDetails
WHERE Quantity != 30 ;

--9)Retrieve OrderID & ProductID if ProductID = 5 and Quantity = 20
SELECT OrderID, ProductID
FROM OrderDetails
WHERE ProductID = 5 AND Quantity = 20;

--10)Retrieve all the employees that there last name is not starting with letter 'F' or its first name starts with letter 'W'
SELECT *
FROM Employees
WHERE LastName NOT LIKE 'F%' OR FirstName like '%w';

--11)Retrieve customers whose CustomerID is between 5 and 10, inclusive
SELECT *
FROM Customers
WHERE CustomerID BETWEEN 5 AND 10;

--12)Retrieve customers whose last names are either 'Frost', 'Rivers', or 'Vale'.
SELECT *
FROM Customers
WHERE LastName IN ('Frost', 'Rivers', 'Vale');

/*13)From OrderDetails table retrieve the following:
a.average quantity
b.total number of OrderDetails
c.first product ID appears in the table */
SELECT
    AVG(Quantity) AS AverageQuantity,
    COUNT(*) AS TotalOrderDetails,
    MIN(ProductID) AS FirstProductID
FROM OrderDetails;

--14)Retrieve all data from products and order by its price starts with the expensive
SELECT *
FROM Products
ORDER BY Price DESC;

--15)Retrieve just the first three characters of the customers first names and make sure to get those characters to be in upper case
SELECT FirstName, UPPER(LEFT(FirstName, 3)) AS FirstNameInitials
FROM Customers;

--16)For each category, list category_id, number of products, max price, lowest price, avgerage price
SELECT 
    c.CategoryID,
    COUNT(*) AS NumberOfProducts,
    MAX(p.Price) AS MaxPrice,
    MIN(p.Price) AS LowestPrice,
    AVG(p.Price) AS AveragePrice
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID;

--17)For each category, list category_id, category_name, number of products, max price, lowest price, avgerage price
SELECT 
    c.CategoryID,
	c.CategoryName,
    COUNT(*) AS NumberOfProducts,
    MAX(p.Price) AS MaxPrice,
    MIN(p.Price) AS LowestPrice,
    AVG(p.Price) AS AveragePrice
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID , c.CategoryName;

--18)Find orders where the total quantity of products ordered exceeds 100 units after a specific date ('2023-06-01')
SELECT o.OrderID, SUM(od.Quantity) AS TotalQuantity
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.OrderDate > '2023-06-01'
GROUP BY o.OrderID
HAVING SUM(od.Quantity) > 100;

--19)Find orders with more than 3 different products ordered
SELECT o.OrderID
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
HAVING COUNT(DISTINCT od.ProductID) > 3;

SELECT o.OrderID, p.ProducrName
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY o.OrderID, p.ProducrName
HAVING COUNT(DISTINCT p.ProducrName) > 3;

--20)Find customers who have ordered more than 100 units in total
SELECT c.CustomerID, SUM(od.Quantity) AS TotalUnitsOrdered
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
HAVING SUM(od.Quantity) > 100;

--21)Create a SQL Function to Calculate Total Quantity for an Order
CREATE FUNCTION GetOrderTotalQuantity (@OrderID INT)
RETURNS INT
AS
BEGIN
  DECLARE @TotalQuantity INT;

  SELECT @TotalQuantity = SUM(Quantity)
  FROM OrderDetails
  WHERE OrderID = @OrderID;

  RETURN @TotalQuantity;
END;

SELECT OrderID, GetOrderTotalQuantity(OrderID) AS TotalQuantity
FROM Orders;

--22)Create a stored procedure to Retrieve orders placed by a specific customer ID customerIDs (15, 10, 6, 50)

CREATE PROCEDURE GetOrdersByCustomerIDs
    @CustomerIDs VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQLQuery NVARCHAR(MAX);

    -- Build dynamic SQL query to retrieve orders for the given customer IDs
    SET @SQLQuery = '
        SELECT o.OrderID, o.OrderDate, c.CustomerID
        FROM Orders o
        INNER JOIN Customers c ON o.CustomerID = c.CustomerID
        WHERE o.CustomerID IN (' + @CustomerIDs + ')
        ORDER BY o.OrderDate DESC;
    ';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @SQLQuery;
END;

EXEC GetOrdersByCustomerIDs '15, 10, 6, 50';
