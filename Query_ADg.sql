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
@name VARCHAR(20),
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
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Hotel Details

CREATE TABLE HBMS.Hotels
(
HotelID INT IDENTITY(1000,1) PRIMARY KEY,
HotelName VARCHAR(40) UNIQUE NOT NULL,
Location VARCHAR(30) NOT NULL,
HotelType VARCHAR(3) NOT NULL CHECK (HotelType IN ('***','****','*****')),
Rating INT NOT NULL CHECK (Rating IN (1,2,3,4,5)),
StartingAt INT NOT NULL,
Discount FLOAT
)

--Procedure for Adding a new Hotel

CREATE PROCEDURE HBMS.AddHotel
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(3),
@rating INT,
@startingat INT,
@discount FLOAT
AS
    BEGIN
        INSERT INTO HBMS.Hotels VALUES (@hotelname,@location,@hoteltype,@rating,@startingAt,@discount)
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


--Procedure for Modifying a Hotel by HotelID

CREATE PROCEDURE HBMS.ModifyHotelByID
@hotelid INT,
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(3),
@rating INT,
@startingat INT,
@discount FLOAT
AS
    BEGIN
        UPDATE HBMS.Hotels SET HotelName=@hotelname,Location=@location,HotelType=hoteltype,Rating=rating,StartingAt=@startingat,Discount=@discount WHERE HotelID = @hotelid
    END
GO

--Procedure for Modifying a Hotel by HotelName

CREATE PROCEDURE HBMS.ModifyHotelByID
@hotelname VARCHAR(40),
@location VARCHAR(30),
@hoteltype VARCHAR(3),
@rating INT,
@startingat INT,
@discount FLOAT
AS
    BEGIN
        UPDATE HBMS.Hotels SET HotelName=@hotelname,Location=@location,HotelType=hoteltype,Rating=rating,StartingAt=@startingat,Discount=@discount WHERE HotelName = @hotelname
    END
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Room Details

CREATE TABLE HBMS.RoomDetails
(
RoomID INT IDENTITY(1000,1) PRIMARY KEY,
RoomNo INT UNIQUE NOT NULL,
HotelID INT NOT NULL FOREIGN KEY (HotelID) REFERENCES HBMS.Hotels(HotelID),
Price FLOAT NOT NULL,
Beds VARCHAR(10) NOT NULL CHECK(Beds IN ('Single(1X)','Classic(2X)','Suite(3X)')),
GuestNum INT NOT NULL CHECK (GuestNum IN (1,2,3)),
RoomType VARCHAR(10) NOT NULL CHECK (RoomType IN ('Deluxe','Standard')),
WiFi VARCHAR (5) NOT NULL CHECK (WiFi IN ('Yes','No')),
Geyser VARCHAR (5) NOT NULL CHECK (Geyser IN ('Yes','No')),
BreakfastIncluded VARCHAR (5) NOT NULL CHECK (BreakfastIncluded IN ('Yes','No')),
BookingFrom DATE NOT NULL,
BookingTo DATE NOT NULL
--BookingID INT NOT NULL FOREIGN KEY (BookingID) REFERENCES HBMS.BookingDetails(BookingID)
)

--Procedure for Adding a new Room

CREATE PROCEDURE HBMS.AddRooms
@roomno INT,
@hotelid INT,
@price FLOAT,
@beds VARCHAR(10),
@guestnum INT,
@roomtype VARCHAR(10),
@wifi VARCHAR (5),
@geyser VARCHAR (5),
@breakfastincluded VARCHAR (5),
@bookingfrom DATE,
@bookingto DATE
AS
    BEGIN
        INSERT INTO HBMS.RoomDetails VALUES (@roomno,@hotelid,@price,@beds,@guestnum,@roomtype,@wifi,@geyser,@breakfastincluded,@bookingfrom,@bookingto)
    END
GO

--Procedure for Showing details of All Rooms 

CREATE PROCEDURE HBMS.ShowRooms
AS
	BEGIN
		SELECT * FROM HBMS.Rooms
	END
GO

--Procedure for Deleting a Room by RoomID

CREATE PROCEDURE HBMS.DeleteRoomByID
@roomid INT
AS
	BEGIN
		DELETE FROM HBMS.Rooms WHERE RoomID = @roomid
	END
GO

--Procedure for Modifying a Room by RoomID

CREATE PROCEDURE HBMS.ModifyRoomByID
@roomid INT,
@roomno INT,
@hotelid INT,
@price FLOAT,
@beds VARCHAR(10),
@guestnum INT,
@roomtype VARCHAR(10),
@wifi VARCHAR (5),
@geyser VARCHAR (5),
@breakfastincluded VARCHAR (5),
@bookingfrom DATE,
@bookingto DATE
AS
    BEGIN
        UPDATE HBMS.Rooms SET RoomNo=@roomno,HotelID=@hotelid,Price=@price,Beds=@beds,GuestNum=@guestnum,RoomType=@roomtype,WiFi=@wifi,Geyser=@geyser,BreakFastIncluded=@breakfastincluded,BookingFrom=@bookingfrom,BookingTo=@bookingto WHERE RoomID = @roomid
    END
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Creating Table for Storing Booking Details

CREATE TABLE HBMS.BookingDetails
(
BookingID INT IDENTITY(1000,1) PRIMARY KEY,
UserID INT NOT NULL FOREIGN KEY (UserID) REFERENCES HBMS.Users(UserID),
GuestName VARCHAR(40) NOT NULL,
RoomID INT NOT NULL FOREIGN KEY (RoomID) REFERENCES HBMS.RoomDetails(RoomID),
BookingFrom DATE NOT NULL,
BookingTo DATE NOT NULL,
Location VARCHAR(30) NOT NULL,
TotalAmount FLOAT NOT NULL,
BookingStatus VARCHAR(10) NOT NULL CHECK(BookingStatus IN ('Booked','Cancelled'))
)

--Procedure for Booking a new Room

CREATE PROCEDURE HBMS.BookRooms
@userid INT,
@guestname VARCHAR(40),
@roomid INT,
@bookingfrom DATE,
@bookingto DATE,
@location VARCHAR(30),
@totalamount FLOAT
AS
	BEGIN
		DECLARE @bookingstatus VARCHAR(10)
		IF	(@bookingfrom>)
			
		END
        INSERT INTO HBMS.RoomDetails VALUES (@userid,@guestname,@roomid,@bookingfrom,@bookingto,@location,@totalamount,@)
    END
GO