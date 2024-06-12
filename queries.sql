-- CREATE DATABASE IF NOT EXISTS sampledb;
CREATE DATABASE IF NOT EXISTS sampledb;
USE sampledb;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Country VARCHAR(50)
);
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- Customers
INSERT INTO Customers (CustomerID, CustomerName, Country) VALUES
(1, 'Kamran', 'Azerbaijan'),
(2, 'Novruz', 'Canada'),
(3, 'Ruslan', 'UK');
(4, 'Ilqar', 'Turkey');
-- Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES
(1, 1, '2024-01-15'),
(2, 1, '2024-02-20'),
(3, 2, '2024-03-10'),
(4, 3, '2024-04-05');
-- Products
INSERT INTO Products (ProductID, ProductName, Category, Price) VALUES
(1, 'Laptop', 'Electronics', 1000.00),
(2, 'Smartphone', 'Electronics', 500.00),
(3, 'Book', 'Books', 20.00),
(4, 'Headphones', 'Electronics', 100.00);
-- OrderDetails
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 3, 3),
(4, 3, 1, 1),
(5, 4, 4, 1);


CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(100)
);
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100)
);
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    Grade DECIMAL(5, 2),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);


-- Students
INSERT INTO Students (StudentID, StudentName) VALUES
(1, 'Kamran Khalilov'),
(2, 'Ruslan Hamidov'),
(3, 'Novruz Shafiyev');
(3, 'Ilqar Asgerov');
-- Courses
INSERT INTO Courses (CourseID, CourseName) VALUES
(1, 'Math'),
(2, 'History'),
(3, 'Science');
-- Enrollments
INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, Grade) VALUES
(1, 1, 1, 80.00),
(2, 1, 2, 90.00),
(3, 2, 1, 70.00),
(4, 2, 3, 75.00),
(5, 3, 2, 85.00),
(6, 3, 3, 95.00);


CREATE TABLE Articles (
    ArticleID INT PRIMARY KEY,
    Title VARCHAR(200),
    AuthorID INT,
    PublishedDate DATE
);
CREATE TABLE Comments (
    CommentID INT PRIMARY KEY,
    ArticleID INT,
    CommentText TEXT,
    CommentDate DATE,
    FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID)
);


-- Articles
INSERT INTO Articles (ArticleID, Title, AuthorID, PublishedDate) VALUES
(1, 'First Article', 1, '2024-05-01'),
(2, 'Second Article', 2, '2024-05-05'),
(3, 'Third Article', 1, '2024-05-10'),
(4, 'Fourth Article', 3, '2024-05-15'),
(5, 'Fifth Article', 2, '2024-05-20');
-- Comments
INSERT INTO Comments (CommentID, ArticleID, CommentText, CommentDate) VALUES
(1, 1, 'Great article!', '2024-05-02'),
(2, 2, 'Very informative.', '2024-05-06'),
(3, 3, 'Thanks for sharing.', '2024-05-11'),
(4, 3, 'Nice post.', '2024-05-12'),
(5, 4, 'Good read.', '2024-05-16'),
(6, 5, 'Interesting.', '2024-05-21');



CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(100),
    Balance DECIMAL(10, 2)
);
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    FromAccountID INT,
    ToAccountID INT,
    Amount DECIMAL(10, 2),
    TransactionDate DATE,
    FOREIGN KEY (FromAccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ToAccountID) REFERENCES Accounts(AccountID)
);

-- Accounts
INSERT INTO Accounts (AccountID, AccountHolder, Balance) VALUES
(1, 'Kamran', 1000.00),
(2, 'Novruz', 500.00),
(3, 'Ruslan', 300.00);
(3, 'Ilqar', 300.00);


--------------------------------------------------------------------------------------

-- TASK 1
SELECT
    c.CustomerName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(od.Quantity * p.Price) AS TotalAmountSpent,
    p.Category AS FavoriteProductCategory
FROM
    Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    LEFT JOIN Products p ON od.ProductID = p.ProductID
GROUP BY
    c.CustomerID, c.CustomerName, p.Category
ORDER BY
    c.CustomerName;

-- TASK 2
WITH StudentAverageGrades AS (
    SELECT
        e.StudentID,
        s.StudentName,
        AVG(e.Grade) AS AverageGrade
    FROM
        Enrollments e
        JOIN Students s ON e.StudentID = s.StudentID
    GROUP BY
        e.StudentID, s.StudentName
    HAVING
        AVG(e.Grade) > 75
)
SELECT
    sag.StudentName,
    c.CourseName,
    MAX(e.Grade) AS HighestGrade,
    sag.AverageGrade
FROM
    Enrollments e
    JOIN Courses c ON e.CourseID = c.CourseID
    JOIN StudentAverageGrades sag ON e.StudentID = sag.StudentID
GROUP BY
    sag.StudentName, c.CourseName, sag.AverageGrade;

-- TASK 3
SELECT
    a.ArticleID,
    a.Title,
    COUNT(c.CommentID) AS CommentCount
FROM
    Articles a
    LEFT JOIN Comments c ON a.ArticleID = c.ArticleID
GROUP BY
    a.ArticleID, a.Title
ORDER BY
    a.PublishedDate DESC
LIMIT 10;

-- TASK 4
CREATE INDEX idx_articles_publisheddate ON Articles (PublishedDate);
CREATE INDEX idx_comments_articleid ON Comments (ArticleID);

-- TASK 5
DELIMITER //
CREATE PROCEDURE TransferFunds(
    IN p_FromAccountID INT,
    IN p_ToAccountID INT,
    IN p_Amount DECIMAL(10, 2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback any changes in case of error
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error occurred during fund transfer.';
    END;
    -- Start the transaction
    START TRANSACTION;
    -- Check if from account has enough balance
    IF (SELECT Balance FROM Accounts WHERE AccountID = p_FromAccountID) < p_Amount THEN
        -- If not enough balance, rollback and throw an error
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient balance in the source account.';
    END IF;
    -- Deduct the amount from the source account
    UPDATE Accounts
    SET Balance = Balance - p_Amount
    WHERE AccountID = p_FromAccountID;
    -- Add the amount to the destination account
    UPDATE Accounts
    SET Balance = Balance + p_Amount
    WHERE AccountID = p_ToAccountID;
    -- Insert a record into the Transactions table
    INSERT INTO Transactions (FromAccountID, ToAccountID, Amount, TransactionDate)
    VALUES (p_FromAccountID, p_ToAccountID, p_Amount, NOW());
    -- Commit the transaction
    COMMIT;
END//
DELIMITER ;