USE Training_13Aug19_Pune
GO

--Creating a Schema for the Project

CREATE SCHEMA HBMS
GO

--Creating Table for Storing User Details

CREATE TABLE HBMS.Users
(
UserID INT IDENTITY(1000,1) PRIMARY KEY,
UserName VARCHAR(40) UNIQUE NOT NULL,
Email VARCHAR(40) UNIQUE NOT NULL,
PhoneNo VARCHAR(10) UNIQUE NOT NULL,
Name VARCHAR(50) NOT NULL,
PasswordHash VARBINARY(max) NOT NULL,
UserType VARCHAR(15) NOT NULL CHECK (UserType in ('Customer','Employee','Admin'))
)

--Procedure to Check If Any User Credential Already Exists

CREATE PROCEDURE HBMS.UserAlreadyExist
@username VARCHAR(40),
@email VARCHAR(40),
@phoneno VARCHAR(10)
AS
DECLARE @ret INT
	BEGIN
		SET @ret=0
		IF (SELECT COUNT(UserID) FROM HBMS.Users WHERE UserName=@username)>0
			BEGIN
				SET @ret=@ret+1
			END
		IF (SELECT COUNT(UserID) FROM HBMS.Users WHERE Email=@email)>0
			BEGIN
				SET @ret=@ret+10
			END
		IF (SELECT COUNT(UserID) FROM HBMS.Users WHERE PhoneNo=@phoneno)>0
			BEGIN
				SET @ret=@ret+100
			END
		SELECT @ret
	END
GO

--Procedure for Registering the User

CREATE PROCEDURE HBMS.RegisterUser
@username VARCHAR(40),
@email VARCHAR(40),
@phoneno VARCHAR(10),
@name VARCHAR(50),
@password VARCHAR(20),
@usertype VARCHAR(15)
AS
	BEGIN
		INSERT INTO HBMS.Users VALUES(@username,@email,@phoneno,@name,EncryptByPassPhrase('2b|!2biet?',@password),@usertype)
	END
GO

--Procedure for Verifying Login Credentials

CREATE PROCEDURE HBMS.VerifyLogin
@loginid VARCHAR(40),
@password VARCHAR(20)
AS
	BEGIN
		SELECT * FROM HBMS.Users WHERE (UserName=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password) OR (Email=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password) OR (PhoneNo=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password)
	END
GO


--For Changing Password
CREATE PROCEDURE HBMS.ChangePassword
@loginid VARCHAR(40),
@password VARCHAR(20),
@passwordnew VARCHAR(20)
AS
	BEGIN
		UPDATE HBMS.Users SET PasswordHash=EncryptByPassPhrase('2b|!2biet?',@passwordnew) WHERE (UserName=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password)
	END
GO

--For Changing Details
CREATE PROCEDURE HBMS.ChangeDetails
@username VARCHAR(40),
@email VARCHAR(40),
@phoneno VARCHAR(10),
@name VARCHAR(50)
AS
	BEGIN
		UPDATE HBMS.Users SET Name=@name,Email=@email,PhoneNo=@phoneno WHERE UserName=@username
	END
GO


EXEC HBMS.UserAlreadyExist @username='dfg',@email='ag@c.com',@phoneno='9836894970'

EXEC HBMS.RegisterUser @username='deg',@email='a@c.com',@phoneno='9836894070',@name='Anyone',@password='password',@usertype='Employee'

EXEC HBMS.VerifyLogin @loginid='a@c.com', @password='password'

SELECT username,name,convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash)) FROM HBMS.Users 
SELECT * FROM HBMS.Users 

EXEC HBMS.ChangePassword @loginid='satish08', @password='123', @passwordnew='123456'

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Hotel Details

CREATE TABLE HBMS.Hotels
(
HotelID INT IDENTITY(1000,1) PRIMARY KEY,
HotelName VARCHAR(40) UNIQUE NOT NULL,
Location VARCHAR(30) NOT NULL,
HotelType VARCHAR(10) NOT NULL CHECK (HotelType IN ('*','**','***','****','*****')),
Rating FLOAT CHECK (Rating >= 1 AND Rating <= 5),
WiFi VARCHAR (5) NOT NULL CHECK (WiFi IN ('Yes','No')),
Geyser VARCHAR (5) NOT NULL CHECK (Geyser IN ('Yes','No')),
StartingAt FLOAT NOT NULL,
Discount FLOAT
)

--Procedure for Adding a new Hotel

CREATE PROCEDURE HBMS.AddHotel
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(10),
@rating FLOAT,
@wifi VARCHAR (5),
@geyser VARCHAR (5),
@startingat FLOAT,
@discount FLOAT
AS
    BEGIN
        INSERT INTO HBMS.Hotels VALUES (@hotelname,@location,@hoteltype,@rating,@wifi,@geyser,@startingAt,@discount)
    END
GO

--Procedure for Showing details of All Hotels 

CREATE PROCEDURE HBMS.ShowHotels
AS
	BEGIN
		SELECT * FROM HBMS.Hotels
	END
GO

--Procedure for Deleting a Hotel by HotelID

CREATE PROCEDURE HBMS.DeleteHotelByID
@hotelid INT
AS
	BEGIN
		DELETE FROM HBMS.Hotels WHERE HotelID = @hotelid
	END
GO

--Procedure for Deleting a Hotel by HotelName

CREATE PROCEDURE HBMS.DeleteHotelByName
@hotelname VARCHAR(40)
AS
	BEGIN
		DELETE FROM HBMS.Hotels WHERE HotelName = @hotelname
	END
GO

--Procedure for Search for a Hotel by HotelID

CREATE PROCEDURE HBMS.SearchHotelByID
@hotelid INT
AS
	BEGIN
		SELECT * FROM HBMS.Hotels WHERE HotelID = @hotelid
	END
GO

--Procedure for Search for a Hotel by HotelName

CREATE PROCEDURE HBMS.SearchHotelByName
@hotelname VARCHAR(40)
AS
	BEGIN
		SELECT * FROM HBMS.Hotels WHERE HotelName LIKE ('%'+@hotelname+'%') AND @hotelname <> '' 
	END
GO


--Procedure for Modifying a Hotel by HotelID

CREATE PROCEDURE HBMS.ModifyHotelByID
@hotelid INT,
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(10),
@rating FLOAT,
@wifi VARCHAR (5),
@geyser VARCHAR (5),
@startingat FLOAT,
@discount FLOAT
AS
    BEGIN
        UPDATE HBMS.Hotels SET HotelName=@hotelname,Location=@location,HotelType=@hoteltype,Rating=@rating,WiFi=@wifi,Geyser=@geyser,StartingAt=@startingat,Discount=@discount WHERE HotelID = @hotelid
    END
GO

--Procedure for Modifying a Hotel by HotelName

CREATE PROCEDURE HBMS.ModifyHotelByName
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(10),
@rating FLOAT,
@wifi VARCHAR (5),
@geyser VARCHAR (5),
@startingat FLOAT,
@discount FLOAT
AS
    BEGIN
        UPDATE HBMS.Hotels SET Location=@location,HotelType=@hoteltype,Rating=@rating,WiFi=@wifi,Geyser=@geyser,StartingAt=@startingat,Discount=@discount WHERE HotelName = @hotelname
    END
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Room Details

CREATE TABLE HBMS.RoomDetails
(
RoomID INT IDENTITY(1000,1) PRIMARY KEY,
RoomNo INT NOT NULL,
HotelID INT NOT NULL FOREIGN KEY (HotelID) REFERENCES HBMS.Hotels(HotelID) ON DELETE CASCADE,
Price FLOAT NOT NULL,
Beds VARCHAR(10) NOT NULL CHECK(Beds IN ('Single(1X)','Classic(2X)','Suite(3X)')),
RoomType VARCHAR(10) NOT NULL CHECK (RoomType IN ('Deluxe','Standard'))
--BookingID INT NOT NULL FOREIGN KEY (BookingID) REFERENCES HBMS.BookingDetails(BookingID)
)

--Procedure for Adding a new Room

CREATE PROCEDURE HBMS.AddRooms
@roomno INT,
@hotelid INT,
@price FLOAT,
@beds VARCHAR(10),
@roomtype VARCHAR(10)
AS
    BEGIN
        INSERT INTO HBMS.RoomDetails VALUES (@roomno,@hotelid,@price,@beds,@roomtype)
    END
GO

--Procedure for Showing details of All Rooms 

CREATE PROCEDURE HBMS.ShowRooms
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails
	END
GO

--Procedure for Deleting a Room by RoomID

CREATE PROCEDURE HBMS.DeleteRoomByID
@roomid INT
AS
	BEGIN
		DELETE FROM HBMS.RoomDetails WHERE RoomID = @roomid
	END
GO

--Procedure for Modifying a Room by RoomID

CREATE PROCEDURE HBMS.ModifyRoomByID
@roomid INT,
@roomno INT,
@hotelid INT,
@price FLOAT,
@beds VARCHAR(10),
@roomtype VARCHAR(10)
AS
    BEGIN
        UPDATE HBMS.RoomDetails SET RoomNo=@roomno,HotelID=@hotelid,Price=@price,Beds=@beds,RoomType=@roomtype WHERE RoomID = @roomid
    END
GO

--Procedure for Searching a Room by RoomID

CREATE PROCEDURE HBMS.SearchRoomByID
@roomid INT
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails WHERE RoomID=@roomid
	END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Booking Details

CREATE TABLE HBMS.BookingDetails
(
BookingID INT IDENTITY(1000,1) PRIMARY KEY,
UserID INT NOT NULL FOREIGN KEY (UserID) REFERENCES HBMS.Users(UserID) ON DELETE CASCADE,
GuestName VARCHAR(40) NOT NULL,
RoomID INT NOT NULL FOREIGN KEY (RoomID) REFERENCES HBMS.RoomDetails(RoomID) ON DELETE CASCADE,
BookingFrom DATETIME NOT NULL,
BookingTo DATETIME NOT NULL,
GuestNum INT NOT NULL CHECK (GuestNum IN (1,2,3)),
BreakfastIncluded VARCHAR (5) NOT NULL CHECK (BreakfastIncluded IN ('Yes','No')),
TotalAmount FLOAT NOT NULL,
BookingStatus VARCHAR(10) NOT NULL CHECK(BookingStatus IN ('Confirmed','Cancelled')),
Rating FLOAT CHECK (Rating >= 1 AND Rating <= 5)
)

--Procedure for Booking a new Room

CREATE PROCEDURE HBMS.BookRooms
@userid INT,
@guestname VARCHAR(40),
@roomtype VARCHAR(10),
@hotelid INT,
@bookingfrom DATETIME,
@bookingto DATETIME,
@beds VARCHAR(10),
@guestnum INT,
@breakfastincluded VARCHAR (5),
@totalamount FLOAT,
@rating FLOAT
AS
	BEGIN
		DECLARE @roomid INT
		SET @roomid=(SELECT TOP 1 RoomID FROM HBMS.RoomDetails WHERE RoomID NOT IN(SELECT RoomID FROM HBMS.BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto) AND BookingStatus='Confirmed') AND RoomType=@roomtype AND Beds=@beds AND HotelID=@hotelid)
        INSERT INTO HBMS.BookingDetails VALUES (@userid,@guestname,@roomid,@bookingfrom,@bookingto,@guestnum,@breakfastincluded,@totalamount,'Confirmed',@rating)
    END
GO

--Procedure to List all Booking Details

CREATE PROCEDURE HBMS.ShowBookings
AS
	BEGIN
		SELECT * FROM HBMS.BookingDetails
    END
GO

--Procedure to Search a Booking by ID

CREATE PROCEDURE HBMS.SearchBookingByID
@bookingid INT
AS
	BEGIN
		SELECT * FROM HBMS.BookingDetails WHERE BookingID=@bookingid
    END
GO


--Procedure to Delete a Booking by BookingID


CREATE PROCEDURE HBMS.DeleteBookingByID
@bookingid INT
AS
	BEGIN
		DELETE FROM HBMS.BookingDetails WHERE BookingID=@bookingid
    END
GO


--Procedure to Cancel Booking

CREATE PROCEDURE HBMS.CancelBooking
@bookingid INT
AS
	BEGIN
		UPDATE HBMS.BookingDetails SET BookingStatus='Cancelled' WHERE BookingID=@bookingid
    END
GO

--Procedure to Change number of guests

CREATE PROCEDURE HBMS.ChangeGuestNumber
@bookingid INT,
@guestnum INT
AS
	BEGIN
		UPDATE HBMS.BookingDetails SET GuestNum=@guestnum WHERE @BookingID=@bookingid
    END
GO

--Procedure to Change Room

CREATE PROCEDURE HBMS.ViewAvailableRooms
@hotelid INT,
@beds VARCHAR(10),
@location VARCHAR(30),
@roomtype VARCHAR(10),
@bookingfrom DATETIME,
@bookingto DATETIME
AS
	BEGIN
		SELECT RoomID FROM HBMS.RoomDetails WHERE RoomType=@roomtype AND Beds=@beds AND RoomID NOT IN(SELECT RoomID FROM BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto)  AND BookingStatus='Confirmed') AND RoomID IN (SELECT RoomID FROM HBMS.RoomDetails WHERE HotelID = (SELECT HotelID FROM HBMS.Hotels WHERE Location=@location))
	END
GO


CREATE PROCEDURE HBMS.ChangeRoom
@bookingid INT,
@roomid INT
AS
	BEGIN
		UPDATE HBMS.BookingDetails SET RoomID=@roomid WHERE BookingID=@bookingid
    END
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Rating
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Procedure for Searching a Room by RoomType

CREATE PROCEDURE HBMS.SearchRoomByType
@location VARCHAR(30),
@roomtype VARCHAR(10),
@bookingfrom DATETIME,
@bookingto DATETIME
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails WHERE RoomType=@roomtype AND RoomID NOT IN(SELECT RoomID FROM BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto)  AND BookingStatus='Confirmed') AND RoomID IN (SELECT RoomID FROM HBMS.RoomDetails WHERE HotelID = (SELECT HotelID FROM HBMS.Hotels WHERE Location=@location))
	END
GO

--Procedure for Searching a Room by Beds

CREATE PROCEDURE HBMS.SearchRoomByBeds
@location VARCHAR(30),
@beds VARCHAR(10),
@bookingfrom DATETIME,
@bookingto DATETIME
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails WHERE Beds=@beds AND RoomID NOT IN(SELECT RoomID FROM BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto)  AND BookingStatus='Confirmed')  AND RoomID IN (SELECT RoomID FROM HBMS.RoomDetails WHERE HotelID = (SELECT HotelID FROM HBMS.Hotels WHERE Location=@location))
	END
GO

--Procedure for Searching a Room by RoomType and Beds

CREATE PROCEDURE HBMS.SearchRoomByTypeAndBeds
@location VARCHAR(30),
@roomtype VARCHAR(10),
@beds VARCHAR(10),
@bookingfrom DATETIME,
@bookingto DATETIME
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails WHERE RoomType=@roomtype AND Beds=@beds AND RoomID NOT IN(SELECT RoomID FROM BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto)  AND BookingStatus='Confirmed')  AND RoomID IN (SELECT RoomID FROM HBMS.RoomDetails WHERE HotelID = (SELECT HotelID FROM HBMS.Hotels WHERE Location=@location))
	END
GO

--Procedure to check if Rooms are available by location

CREATE PROCEDURE HBMS.SearchRoomByLocationAndDates
@location VARCHAR(30),
@bookingfrom DATETIME,
@bookingto DATETIME
AS
	BEGIN
		SELECT * FROM HBMS.RoomDetails WHERE RoomID NOT IN(SELECT RoomID FROM HBMS.BookingDetails WHERE (BookingFrom BETWEEN @bookingfrom AND @bookingto) OR (BookingTo BETWEEN @bookingfrom AND @bookingto)  AND BookingStatus='Confirmed') AND RoomID IN (SELECT RoomID FROM HBMS.RoomDetails WHERE HotelID = (SELECT HotelID FROM HBMS.Hotels WHERE Location=@location))
    END
GO

CREATE PROCEDURE HBMS.RateHotels
@userrating FLOAT,
@bookingid INT,
@hotelid INT
AS
	BEGIN
		Declare @avg FLOAT
		SET @avg=((SELECT Count(BookingID) FROM HBMS.BookingDetails WHERE Rating IS NOT NULL)*(SELECT Rating FROM HBMS.Hotels WHERE HotelID=@hotelID)+@userrating)/((SELECT Count(BookingID) FROM HBMS.BookingDetails WHERE Rating IS NOT NULL)+1)
		UPDATE HBMS.BookingDetails SET Rating=@userrating WHERE BookingID=@bookingid
		UPDATE HBMS.Hotels SET Rating=@avg WHERE HotelID=@hotelid
	END
GO


EXEC HBMS.RateHotels @userrating=5,@bookingid=1000,@hotelid=1000

SELECT * FROM HBMS.Users

SELECT * FROM HBMS.Hotels

INSERT INTO HBMS.Hotels VALUES ('Sonar Bangla','Kolkata','*****',4.5,'Yes','Yes',40000,0.2)

SELECT * FROM HBMS.RoomDetails

INSERT INTO HBMS.RoomDetails VALUES ('101',1000,50000,'Single(1X)','Deluxe')

SELECT * FROM HBMS.BookingDetails

INSERT INTO HBMS.BookingDetails VALUES (1000,'Soumyadip',1000,'11/04/2019','12/04/2019',2,'Yes',50000,'Confirmed',null)
