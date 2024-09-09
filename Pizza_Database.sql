CREATE DATABASE pizza_db;

USE pizza_db;

CREATE TABLE Pizza_type (
    Pizza_type_id INT PRIMARY KEY,
    Name VARCHAR(50),
    Category VARCHAR(20),
    Description TEXT
);

CREATE TABLE Pizzas (
    Pizza_id INT PRIMARY KEY,
    Pizza_type_id INT,
    Size VARCHAR(20),
    Price INT,
    FOREIGN KEY (Pizza_type_id)	
		REFERENCES Pizza_type (Pizza_type_id)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    DATE DATE,
    TIME TIME
);

CREATE TABLE Order_details (
    Orderdetails_id INT PRIMARY KEY,
    Order_id INT,
    Pizza_id INT,
    Quantity INT,
    FOREIGN KEY (Order_id)
        REFERENCES Orders (Order_id),
    FOREIGN KEY (Pizza_id)
        REFERENCES Pizzas (Pizza_id)
);




