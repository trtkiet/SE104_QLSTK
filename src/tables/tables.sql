create database SOTIETKIEM
use SOTIETKIEM




/*======================================================================
KHACHHANG
======================================================================*/

-- CREATE CUSTOMERS TABLE
-- Creat Customer table
CREATE TABLE Customers
(
	CustomerID 	INT IDENTITY(10,1),
	CustomerName	VARCHAR(40) NOT NULL,
	PhoneNumber	VARCHAR(20) NOT NULL,
	CitizenID	VARCHAR(20) NOT NULL,
	CustomerAddress	VARCHAR(100) NOT NULL,
)
-- Add primary key
ALTER TABLE Customers ADD CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)

-- STORED PROCEDURE: INSERT INTO Customers TABLE
-- Create trigger
GO
CREATE TRIGGER dbo.trgInsertCustomer
ON Customers
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @CustomerID INT,
			@CitizenID VARCHAR(20),
			@PhoneNumber VARCHAR(20)
	SELECT @CustomerID = CustomerID, 
		   @CitizenID = CitizenID,
		   @PhoneNumber = PhoneNumber
		FROM inserted
	-- sdt va cccd phai la so
	IF (ISNUMERIC(@PhoneNumber) = 0 OR ISNUMERIC(@CitizenID) = 0)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50020, -1,-1)
			RETURN
		END
	IF (EXISTS (SELECT * FROM Customers 
				WHERE CustomerID != @CustomerID
						AND CitizenID = @CitizenID))
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50012, -1, -1)
			RETURN;
		END
END
GO

-- Define Procedure
CREATE PROCEDURE dbo.addCustomer 
					@CustomerName	VARCHAR(40),
					@PhoneNumber	VARCHAR(20),
					@CitizenID	VARCHAR(20),
					@CustomerAddress	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO Customers (CustomerName, PhoneNumber, CitizenID, CustomerAddress)
	VALUES (@CustomerName, @PhoneNumber, @CitizenID, @CustomerAddress)
	SET NOCOUNT ON;
	SELECT CustomerID FROM Customers 
		WHERE CitizenID = @CitizenID
END
GO


-- STORED PROCEDURE: UPDATE Customers TABLE
GO
CREATE PROCEDURE dbo.updateCustomer 
				@CustomerID	   INT,
				@CustomerName	VARCHAR(40) = NULL,
				@PhoneNumber	VARCHAR(20) = NULL,
				@CitizenID	VARCHAR(20) = NULL,
				@CustomerAddress	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON
	IF (NOT EXISTS (SELECT * FROM Customers WHERE CustomerID = @CustomerID))
		SELECT 1 AS err -- ko co khach hang
	IF (@CitizenID IS NOT NULL)
		BEGIN
			UPDATE Customers
			SET CitizenID = @CitizenID
			WHERE @CustomerID = CustomerID
		END
	IF (@CustomerName IS NOT NULL)
		BEGIN
			UPDATE Customers
			SET CustomerName = @CustomerName
			WHERE @CustomerID = CustomerID
		END
	IF (@PhoneNumber IS NOT NULL)
		BEGIN
			UPDATE Customers
			SET Phonenumber = @PhoneNumber
			WHERE @CustomerID = CustomerID
		END
	IF (@CustomerAddress IS NOT NULL)
		BEGIN
			UPDATE Customers
			SET CustomerAddress = @CustomerAddress
			WHERE @CustomerID = CustomerID
		END
END
GO


-- STORED PROCEDURE: GET DATA IN customers TABLE 
GO
CREATE PROCEDURE dbo.getCustomerDetailWithCitizenID 
			@CitizenID VARCHAR(20) = NULL
AS 
BEGIN
	SET NOCOUNT ON;
	IF (@CitizenID IS NULL)
		SELECT CustomerID, CustomerName, CustomerAddress, PhoneNumber FROM Customers
	ELSE
		SELECT CustomerID, CustomerName, CustomerAddress, PhoneNumber FROM Customers
		WHERE CitizenID = @CitizenID
END
GO

/*====================================================================
LOAITK
======================================================================*/

-- CREATE INTEREST_TYPES TABLE (LoaiTK)
-- Create InterestTypes table
CREATE TABLE InterestTypes( 
	InterestTypeID INT IDENTITY(10,1),		-- Ma loai tiet kiem
	InterestRate DECIMAL(17,2) NOT NULL,		-- Lai suat (%)
	Term INT NOT NULL,						-- So thang trong ky han
	MinimumTimeToWithdrawal INT NOT NULL,	-- Thoi gian toi thieu de duoc rut, mac dinh la 0
);  
-- Add primary key
ALTER TABLE InterestTypes ADD CONSTRAINT PK_InterestType PRIMARY KEY (InterestTypeID);
-- Add new column
ALTER TABLE InterestTypes
ADD Status BIT; -- NULL: opened, 1: blocked
ALTER TABLE InterestTypes
ADD InterestTypeName TEXT;


-- TRIGGER: check duplicate
GO
CREATE TRIGGER dbo.trgCheckDuplicate
ON InterestTypes
AFTER INSERT
AS
BEGIN	
	DECLARE @InterestTypeID INT = NULL
	SELECT @InterestTypeID = InterestTypeID
	FROM InterestTypes IT
	WHERE EXISTS (SELECT * FROM inserted i 
					WHERE i.InterestRate = IT.InterestRate AND i.Term = IT.Term
					AND i.InterestTypeID != IT.InterestTypeID)

	IF (@InterestTypeID IS NOT NULL)  -- have duplicate
		BEGIN
			ROLLBACK TRANSACTION
		END
END
GO


-- STORED PROCEDURE: Add New Interest Type
-- Define procedure
GO
CREATE PROCEDURE dbo.addInterestType
			@InterestRate DECIMAL(17,2), 
			@Term INT,
			@MinimumTimeToWithdrawal INT = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @TypeName VARCHAR(11)
	SELECT @TypeName = 'LS' + CONVERT(VARCHAR, @InterestRate) + '_KH' + CONVERT(VARCHAR, @Term)
	INSERT INTO InterestTypes (InterestRate, Term, MinimumTimeToWithdrawal, InterestTypeName)
	VALUES (@InterestRate, @Term, @MinimumTimeToWithdrawal, @TypeName)
		-- return 0 thanh cong
END
GO



-- STORED PROCEDURE: Hide/Block Interest Type
-- Define procedure
GO
CREATE PROCEDURE dbo.blockInterestType 
			@InterestTypeID INT
AS
BEGIN
	SET NOCOUNT ON
	UPDATE InterestTypes
	SET Status = 1 -- blocked
	WHERE InterestTypeID = @InterestTypeID
	IF (EXISTS (SELECT * FROM InterestTypes 
		WHERE InterestTypeID = @InterestTypeID))
			RETURN  -- them thanh cong
	ELSE 
		BEGIN 
			RAISERROR(50008, -1, -1) -- khong co LoaiTK trong CSDL
		END
END
GO


-- STORED PROCEDURE: Unblock Interest Type
-- Define procedure
GO
CREATE PROCEDURE dbo.unblockInterestType 
			@InterestTypeID INT
AS
BEGIN
	SET NOCOUNT ON
	UPDATE InterestTypes
	SET Status = NULL -- unblocked
	WHERE InterestTypeID = @InterestTypeID
	IF (EXISTS (SELECT * FROM InterestTypes 
		WHERE InterestTypeID = @InterestTypeID))
			RETURN -- thanh cong
	ELSE RAISERROR(50008, -1, -1) -- khong co MaLTK trong CSDL
END
GO


-- STORED PROCEDURE: UPDATE Interest Type
GO
CREATE TRIGGER dbo.trgUpdateInterestType
ON InterestTypes
AFTER UPDATE
AS
BEGIN
	DECLARE @InsTerm INT,
			@DelTerm INT,
			@InsInterestRate DECIMAL(17,2),
			@DelInterestRate DECIMAL(17,2)
	SELECT @InsTerm = Term, @InsInterestRate = InterestRate FROM Inserted
	SELECT @DelTerm = Term, @DelInterestRate = InterestRate FROM Deleted
	IF (@InsTerm != @DelTerm OR @InsInterestRate != @DelInterestRate)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50013, -1, -1) -- loi trung voi record co san
			RETURN;
		END
END
GO

GO
CREATE PROCEDURE dbo.updateInterestType 
			@InterestTypeID INT, 
			@NewMinimumTimeToWithdrawal INT = NULL
AS
BEGIN
	SET NOCOUNT ON
	IF (@NewMinimumTimeToWithdrawal IS NOT NULL)
		BEGIN
			UPDATE InterestTypes
			SET MinimumTimeToWithdrawal = @NewMinimumTimeToWithdrawal
			WHERE InterestTypeID = @InterestTypeID
			IF (EXISTS (SELECT * FROM InterestTypes 
				WHERE InterestTypeID = @InterestTypeID))
					RETURN -- thanh cong
		END
	ELSE
		RAISERROR(50008, -1, -1) -- loi khong co LoaiTK
END
GO



-- STORED PROCEDURE: GET Interest Type 
GO
CREATE PROCEDURE dbo.getInterestType
			@Term INT = NULL,
			@InterestRate DECIMAL(17,2) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF (@Term IS NULL AND @InterestRate IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
		END
	ELSE IF (@Term IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @InterestRate = InterestRate
		END
	ELSE IF (@InterestRate IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @Term = Term
		END
	ELSE
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @Term = Term AND @InterestRate = InterestRate
		END
END
GO



/*====================================================================
PHIEUGUI
======================================================================*/

-- CREATE DEPOSITS TABLE (PhieuGT)
-- Create table
CREATE TABLE Deposits(
	DepositID INT IDENTITY(10,1),      -- Ma phieu gui tien
	CustomerID INT NOT NULL,	  -- Ma khach hang
	InterestTypeID INT NOT NULL, -- Loai tiet kiem
	OpenedDate SMALLDATETIME,		  -- Ngay tao (tu dong)
	Fund MONEY NOT NULL,			  -- So tien gui
	Withdrawer VARCHAR(40)				-- Ten nguoi rut
);
-- Add primary key
ALTER TABLE Deposits ADD CONSTRAINT PK_Deposit PRIMARY KEY (DepositID);

-- Add foreign key on CustomerID
ALTER TABLE Deposits 
ADD CONSTRAINT FK_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

-- Add foreign key on InterestTypeID
ALTER TABLE Deposits
ADD CONSTRAINT FK_InterestTypeID
FOREIGN KEY (InterestTypeID) REFERENCES InterestTypes(InterestTypeID);



-- STORED PROCEDURE: INSERT INTO Deposits table
-- Create trigger
GO
CREATE TRIGGER dbo.trgInsertDeposit
ON Deposits
AFTER INSERT
AS
BEGIN
	-- Check if Withdrawer is null
	DECLARE @Withdrawer VARCHAR(40)
	SELECT @Withdrawer = Withdrawer FROM inserted
	IF (@Withdrawer IS NOT NULL) 
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50014, -1, -1)
			RETURN
		END
	-- Check if Status of InterestTypeID is null
	DECLARE @Status BIT
	SELECT @Status = Status FROM inserted i, InterestTypes IT
							WHERE i.InterestTypeID = IT.InterestTypeID
	IF (@Status IS NOT NULL) 
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50003, -1, -1)
			RETURN
		END
	-- Check if the amount of fund satisfies 
	DECLARE @MinFund MONEY, 
			@Fund MONEY
	SELECT @MinFund = MinimumDeposit FROM Params
	SELECT @Fund=inserted.Fund FROM inserted
	IF (@Fund < @MinFund)
		BEGIN
			ROLLBACK TRANSACTION
			DECLARE @LatestIdentityValue INT
			SELECT @LatestIdentityValue = DepositID - 1 FROM inserted;
			RAISERROR(50002, -1, -1)
			RETURN;
		END
	-- if added successfully
END
GO

-- Define Procedure
GO
CREATE PROCEDURE dbo.addDeposit 
					@CustomerID INT, 
					@InterestTypeID INT, 
					@Fund MONEY
AS
BEGIN
	SET NOCOUNT ON
	-- Check if the customer or the given interest type is in the database 
	IF (NOT EXISTS (SELECT * FROM InterestTypes WHERE @InterestTypeID = InterestTypeID) -- invalid Type
		OR NOT EXISTS (SELECT * FROM Customers WHERE @CustomerID = CustomerID)) -- invalid customer
		BEGIN
			SELECT 1 AS err -- khong co KhachHang hoac LoaiTK
			RETURN 
		END
	-- insert new record
	DECLARE @OutputRecord TABLE (ID INT)
	INSERT INTO Deposits 
	OUTPUT inserted.DepositID INTO @OutputRecord(ID)
	VALUES (@CustomerID, @InterestTypeID, GETDATE(), @Fund, NULL);
	-- return record set 
	SELECT DepositID, OpenedDate, Term, InterestRate 
		FROM Deposits D JOIN InterestTypes IT ON IT.InterestTypeID = D.InterestTypeID
		WHERE EXISTS (SELECT * FROM @OutputRecord WHERE ID = DepositID)
END
GO


-- STORED PROCEDURE: Delete a deposit 
-- Define the procedure
GO
CREATE PROCEDURE dbo.deleteDeposit @DepositID INT 
AS
BEGIN
	SET NOCOUNT ON
	IF (NOT EXISTS (SELECT * FROM Deposits WHERE DepositID = @DepositID))
		BEGIN
			SELECT 1 AS err -- khong co phieu trong DB
		END
	DECLARE @OpenedDate SMALLDATETIME
	SELECT @OpenedDate = OpenedDate FROM Deposits
		WHERE DepositID = @DepositID
	-- cannot delete after 30 minutes 
	IF (DATEDIFF(minute, @OpenedDate, GETDATE()) > 30) 
		BEGIN
			RAISERROR(50005, -1, -1)
			RETURN
		END 

	DELETE FROM Deposits
	WHERE DepositID = @DepositID
	-- SELECT 0
END
GO

-- STORED PROCEDURE: GET DATA IN THIS TABLE 
GO
CREATE PROCEDURE dbo.getDepositDetailWithDate 
			@OpenedDate SMALLDATETIME 
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT TOP 1 WITH TIES D.DepositID, D.CustomerID, 
		   CustomerName, ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate
	FROM Deposits D LEFT JOIN Transactions T
		ON T.DepositID = D.DepositID
		JOIN Customers C 
		ON D.CustomerID = C.CustomerID
		JOIN InterestTypes IT
		ON D.InterestTypeID = IT.InterestTypeID
	WHERE @OpenedDate = CAST(CONVERT(VARCHAR(10), D.OpenedDate, 101) AS DATE)
	ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
END
GO


GO
CREATE PROCEDURE dbo.getDepositDetailWithID 
			@DepositID INT 
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT TOP 1 WITH TIES D.DepositID, D.CustomerID, 
		   CustomerName, ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate
	FROM Deposits D LEFT JOIN Transactions T
		ON T.DepositID = D.DepositID
		JOIN Customers C 
		ON D.CustomerID = C.CustomerID
		JOIN InterestTypes IT
		ON D.InterestTypeID = IT.InterestTypeID
	WHERE @DepositID = D.DepositID
	ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
END
GO


GO
CREATE PROCEDURE dbo.getDepositDetailWithDateAndID 
			@DepositID INT = NULL,
			@OpenedDate SMALLDATETIME = NULL
AS 
BEGIN
	SET NOCOUNT ON;
	IF (@DepositID IS NOT NULL)
		BEGIN
			EXEC dbo.getDepositDetailWithID @DepositID
		END
	ELSE 
		BEGIN
			EXEC dbo.getDepositDetailWithDate @OpenedDate
		END
END
GO



GO
CREATE PROCEDURE dbo.getDepositDetailWithCitizenID
			@CitizenID VARCHAR(20)
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT TOP 1 WITH TIES D.DepositID, D.CustomerID, 
			CustomerName, ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate
	FROM Deposits D LEFT JOIN Transactions T
		ON T.DepositID = D.DepositID 
		JOIN Customers C 
		ON D.CustomerID = C.CustomerID
		JOIN InterestTypes IT
		ON D.InterestTypeID = IT.InterestTypeID
	WHERE @CitizenID = C.CitizenID
	ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
END
GO


GO
CREATE PROCEDURE dbo.searchDeposit
			@DepositID INT = NULL, 
			@CitizenID VARCHAR(20) = NULL,
			@OpenedDate SMALLDATETIME = NULL
AS 
BEGIN
	SET NOCOUNT ON;
	IF (@DepositID IS NOT NULL)
		BEGIN
			EXEC dbo.getDepositDetailWithID @DepositID
		END
	ELSE IF (@CitizenID IS NOT NULL AND @OpenedDate IS NULL)
		BEGIN
			EXEC dbo.getDepositDetailWithCitizenID @CitizenID
		END
	ELSE IF (@CitizenID IS NOT NULL AND @OpenedDate IS NOT NULL)
		BEGIN
			SELECT TOP 1 WITH TIES D.DepositID, D.CustomerID, 
						CustomerName, ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate
				FROM Deposits D LEFT JOIN Transactions T
					ON T.DepositID = D.DepositID
					JOIN Customers C 
					ON D.CustomerID = C.CustomerID
			 		JOIN InterestTypes IT
					ON D.InterestTypeID = IT.InterestTypeID
				WHERE @CitizenID = C.CitizenID 
					AND @OpenedDate = CAST(CONVERT(VARCHAR(10), D.OpenedDate, 101) AS DATE)
				ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
	ELSE IF(@OpenedDate IS NOT NULL)
		BEGIN
			EXEC dbo.getDepositDetailWithDate @OpenedDate
		END
	ELSE
		BEGIN
			SELECT TOP 1 WITH TIES D.DepositID, D.CustomerID, 
						CustomerName, ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate
				FROM Deposits D LEFT JOIN Transactions T
					ON T.DepositID = D.DepositID
					JOIN Customers C 
					ON D.CustomerID = C.CustomerID
			 		JOIN InterestTypes IT
					ON D.InterestTypeID = IT.InterestTypeID
				ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
END
GO


GO
CREATE PROCEDURE dbo.getDeposit
					@DepositID INT
AS
BEGIN
	SET NOCOUNT ON;
	-- neu phieu da rut 
	IF (EXISTS (SELECT * FROM Deposits WHERE @DepositID = DepositID AND Withdrawer IS NOT NULL))
		BEGIN
			SELECT TOP 1 WITH TIES D.CustomerID, 
					CustomerName, CitizenID, PhoneNumber, 
					CustomerAddress,
					D.DepositID, Fund,
					Term, InterestRate, 
					ISNULL(-Changes - Fund, 0) AS TotalChanges, -- tinh tong tien lai
					ISNULL(Balance, Fund) AS CurrentBalance,  -- so du hien tai
					OpenedDate, -- ngay gui
					Withdrawer, TransactionDate AS WithdrawalDate, -- ngay rut
					DATEDIFF(minute, OpenedDate, TransactionDate) - 1 AS NoDaysDeposited -- so ngay gui -- minute for testing
			FROM Deposits D LEFT JOIN Transactions T
				ON T.DepositID = D.DepositID
				JOIN Customers C 
				ON D.CustomerID = C.CustomerID
				JOIN InterestTypes IT
				ON D.InterestTypeID = IT.InterestTypeID
			WHERE @DepositID = D.DepositID
			ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
	ELSE -- neu phieu chua rut
		BEGIN
			SELECT TOP 1 WITH TIES D.CustomerID, 
					CustomerName, CitizenID, PhoneNumber, 
					CustomerAddress,
					D.DepositID, Fund,
					Term, InterestRate, 
					ISNULL(Balance - Fund, 0) AS TotalChanges,
					ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate,
					Withdrawer, NULL AS WithdrawalDate,
					DATEDIFF(minute, OpenedDate, GETDATE()) - 1 AS NoDaysDeposited -- so ngay gui -- minute for testing
			FROM Deposits D LEFT JOIN Transactions T
				ON T.DepositID = D.DepositID
				JOIN Customers C 
				ON D.CustomerID = C.CustomerID
				JOIN InterestTypes IT
				ON D.InterestTypeID = IT.InterestTypeID
			WHERE @DepositID = D.DepositID
			ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
END
GO



-- Create trigger after update on Deposits
GO
CREATE TRIGGER trgInsertandDeleteWithdrawal
ON dbo.Deposits
AFTER UPDATE
AS
BEGIN	
	DECLARE @InsWithdrawer VARCHAR(40),
			@DelWithdrawer VARCHAR(40),
			@DepositID INT
	SELECT @DepositID = DepositID FROM inserted
	SELECT @InsWithdrawer = Withdrawer FROM inserted
	SELECT @DelWithdrawer = Withdrawer FROM deleted
	-- Khong cap nhat phieu rut khi da co Ten nguoi rut !! 
	IF (@DelWithdrawer IS NOT NULL AND @InsWithdrawer IS NOT NULL AND @DelWithdrawer != @InsWithdrawer)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50016, -1, -1)
			RETURN
		END
	-- Khi Insert Phieu RT vao Transaction
	IF (@DelWithdrawer IS NULL AND @InsWithdrawer IS NOT NULL)
		BEGIN
			--------
			-- Tinh so ngay gui
			DECLARE @NumOfDaysDeposited INT
			SELECT @NumOfDaysDeposited = DATEDIFF(minute, OpenedDate, GETDATE()) - 1 FROM deleted -- minutes for testing
			-- Kiem tra dieu kien so ngay gui
			DECLARE @MinimumTimeToWithdrawal INT
			SELECT @MinimumTimeToWithdrawal = MinimumTimeToWithdrawal FROM InterestTypes
				WHERE InterestTypeID = (SELECT InterestTypeID FROM deleted)

			--IF (@NumOfDaysDeposited != -1)
			--	BEGIN
			IF (@NumOfDaysDeposited < @MinimumTimeToWithdrawal)
				BEGIN
					ROLLBACK TRANSACTION
					RAISERROR(50017, -1, -1)
					RETURN
				END
			--	END
			--ELSE SET @NumOfDaysDeposited = 0 -- neu ngay rut trung ngay gui 

			-- Lay so du trong ngay cap nhat moi nhat
			DECLARE @Balance MONEY,
					@NewBalance MONEY
					--@TransactionID INT
			SELECT TOP 1 @Balance = Balance 
					FROM Transactions 
					WHERE DepositID = @DepositID 
					ORDER BY TransactionDate DESC
			SET @NewBalance = @Balance
			-- Tinh so ky da gui neu la loai TK co ky han
			DECLARE @Term INT
			SELECT @Term = Term FROM InterestTypes
							WHERE InterestTypeID = (SELECT InterestTypeID FROM deleted)
			-- Neu la loai co ky han
			IF (@Term > 0)
				BEGIN
					DECLARE @RemaningNumOfDays INT
					SET @RemaningNumOfDays = @NumOfDaysDeposited % (@Term * 30)
					-- Neu rut giua ky thi cap nhat so du moi nhat
					IF (@RemaningNumOfDays != 0)
						BEGIN
							-- Lay lai suat cua loai khong ky han thap nhat
							DECLARE @InterestRate DECIMAL(17,2)
							SELECT TOP 1 @InterestRate = InterestRate FROM InterestTypes 
													WHERE Term = 0 ORDER BY InterestRate ASC
							-- Cap nhat so du moi
							SET @NewBalance = @Balance * (1 + @InterestRate / 100 * @RemaningNumOfDays / 360)
							INSERT INTO Transactions
							VALUES(@DepositID, @NewBalance - @Balance, @NewBalance, GETDATE())
						END
					END
			-- Insert to Transaction with Balance is 0
			INSERT INTO Transactions(DepositID, Changes, Balance, TransactionDate)
				VALUES(@DepositID, -@NewBalance, 0, GETDATE())
			RETURN
			--------
		END
	-- Khi xoa phieu rut
	IF (@DelWithdrawer IS NOT NULL AND @InsWithdrawer IS NULL)
		BEGIN
			DECLARE @TransactionID INT,
					@CurrentBalance MONEY,
					@WithdrawalDate SMALLDATETIME
			SELECT TOP 1 @TransactionID = TransactionID, 
						@CurrentBalance = Balance, 
						@WithdrawalDate = TransactionDate
				FROM Transactions
				WHERE DepositID = @DepositID
				ORDER BY TransactionID DESC
			IF (@CurrentBalance > 0)
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR(50019, -1, -1)
				RETURN
			END
		-- Xoa phieu rut
			DELETE FROM Transactions
				WHERE TransactionID = @TransactionID	
		-- Xoa Transaction truoc do neu la co ky han va rut truoc ky han
			-- Tinh so ngay gui
			DECLARE @NoDaysDeposited INT
			SELECT @NoDaysDeposited = DATEDIFF(minute, OpenedDate, @WithdrawalDate) - 1  -- minute for testing
				FROM Deposits
				WHERE DepositID = @DepositID
			-- Tim ky han
			DECLARE @TheTerm INT
			SELECT @TheTerm = Term FROM InterestTypes
							WHERE InterestTypeID = (SELECT InterestTypeID FROM Deposits
													WHERE DepositID = @DepositID)
			-- Neu la loai co ky han
			IF (@TheTerm > 0)
				BEGIN
					DECLARE @RemainingNumOfDays INT
					SET @RemainingNumOfDays = @NoDaysDeposited % (@TheTerm * 30)
					-- Neu rut giua ky
					IF (@RemainingNumOfDays != 0)
						BEGIN
							-- Xoa Transaction cu
							SELECT TOP 1 @TransactionID = TransactionID
								FROM Transactions
								WHERE DepositID = @DepositID 
								ORDER BY TransactionID DESC
							DELETE FROM Transactions
								WHERE TransactionID = @TransactionID			
						END
				END
		END
END
GO


-- STORED PROCEDURE: ADD NEW WITHDRAWAL
GO
CREATE PROCEDURE dbo.addWithdrawal
			@DepositID INT,
			@Withdrawer VARCHAR(40)
AS
BEGIN
	SET NOCOUNT ON
	IF (NOT EXISTS (SELECT * FROM Deposits
					WHERE DepositID = @DepositID))
		SELECT 1 AS err -- khong co phieu rut trong CSDL
	IF (@Withdrawer IS NULL)
		RETURN 
	DECLARE @CurrentWithdrawer VARCHAR(40)
	SELECT @CurrentWithdrawer = Withdrawer 
	FROM Deposits WHERE @DepositID = DepositID 
	IF (@CurrentWithdrawer IS NOT NULL)
		BEGIN
			SELECT 2 AS err -- phieu da duoc rut
			RETURN
		END
	UPDATE Deposits
	SET Withdrawer = @Withdrawer
	WHERE DepositID = @DepositID 
	-- noi dung can in ra (cung voi noi dung input)
	SELECT TOP 1 C.CustomerID, CustomerName, -- thong tin khach hang
			ISNULL(-Changes - Fund , 0) AS BankInterest, -- tong tien lai
			Fund,		-- tien gui
			ISNULL(-Changes, Fund) AS Withdrawn,  -- tong tien rut
			TransactionDate		-- thoi gian rut
		FROM Transactions T JOIN Deposits D ON T.DepositID = D.DepositID
			 JOIN Customers C ON C.CustomerID = D.CustomerID
		WHERE T.DepositID = @DepositID
		ORDER BY TransactionID DESC
END
GO


-- STORED PROCEDURE: DELETE WITHDRAWAL 
-- Define the procedure
GO
CREATE PROCEDURE dbo.deleteWithdrawal 
				@DepositID INT
AS
BEGIN
	SET NOCOUNT ON
	IF (NOT EXISTS (SELECT * FROM Transactions WHERE DepositID = @DepositID))
		SELECT 1 AS err --

	-- cannot delete records that were created after 30 minutes
	DECLARE @WithdrawalDate SMALLDATETIME
	SELECT TOP 1 @WithdrawalDate = TransactionDate 
		FROM Transactions 
		WHERE DepositID = @DepositID 
		ORDER BY TransactionID DESC
	IF (DATEDIFF(minute, @WithdrawalDate, GETDATE()) > 30) 
		BEGIN
			RAISERROR(50005, -1, -1) -- cannot delete after 30 minutes
			RETURN
		END
	UPDATE Deposits
	SET Withdrawer = NULL
		WHERE DepositID = @DepositID
END
GO




/*====================================================================
CTPHIEUGUI
======================================================================*/

-- CREATE TRANSACTIONS TABLE
-- Create Transaction table
CREATE TABLE Transactions(
	TransactionID INT IDENTITY(10,1),
	DepositID INT NOT NULL,
	Changes MONEY,
	Balance MONEY,
	TransactionDate SMALLDATETIME,
);
-- Add primary key
ALTER TABLE Transactions ADD CONSTRAINT PK_Transaction PRIMARY KEY (TransactionID);

-- Add foreign key on TransactionID
ALTER TABLE Transactions
ADD CONSTRAINT FK_TransactionID
FOREIGN KEY (DepositID) REFERENCES Deposits(DepositID);


-- Create trigger after insert
GO 
CREATE TRIGGER trgInsertTransaction	
ON Transactions	
AFTER INSERT	
AS	
BEGIN 	
	DECLARE @Count INT	
	SELECT @Count = COUNT(*) - 1 	
		FROM Transactions, inserted 	
		WHERE inserted.DepositID = Transactions.DepositID 	
			AND inserted.TransactionID = Transactions.TransactionID
	-- Check if the deposit slip has any transactions before 	
	IF (@Count > 0) 	
		BEGIN	
			DECLARE @Balance MONEY	
			DECLARE @DepositID INT	
			SELECT @DepositID = DepositID FROM inserted	
			-- select the second latest transaction of the deposit (except the inserted one)	
			SELECT TOP 1 @Balance = Balance	
				FROM (SELECT TOP 2 *	
					FROM Transactions	
					WHERE DepositID = @DepositID 	
					ORDER BY TransactionID DESC) AS Temp
				ORDER BY TransactionID ASC;	
			-- Check if this deposit slip has been withdrawn 	
			IF (@Balance = 0)	
			BEGIN	
				-- if the slip is withdrawn, we cannot make any transactions with this slip	
				ROLLBACK TRANSACTION	
				RAISERROR(50010, -1, -1)	
				RETURN;	
			END	
		END	
END	
GO


-- STORED PROCEDURE: ADD NEW TRANSACTION 
GO
CREATE PROCEDURE dbo.addTransactions
			@DepositID CHAR(10),
			@Changes MONEY 
AS
BEGIN
	SET NOCOUNT ON
	IF (@Changes IS NOT NULL)
		BEGIN
			DECLARE @NewBalance MONEY
			SELECT TOP 1 @NewBalance=(Balance + @Changes)
				FROM Transactions
				WHERE @DepositID = DepositID
				ORDER BY TransactionDate DESC
			INSERT INTO Transactions(DepositID, Changes, Balance, TransactionDate)
				VALUES(@DepositID, @Changes, @NewBalance, GETDATE())
		END
	ELSE 
		BEGIN
			RAISERROR(50011, -1, -1);
		END
END
GO


-- STORED PROCEDURE: Sum of active deposits (tong tien gui cua cac phieu gui chua rut)
GO 
CREATE PROCEDURE dbo.sumActiveDeposit 
AS
BEGIN
	SELECT ISNULL(SUM(Fund), 0) AS Total
	FROM Deposits 
	WHERE Withdrawer IS NULL
END
GO


/*====================================================================
THAMSO
======================================================================*/

-- CREATE PARAMETERS TABLE (THAMSO)
-- Create PARAMS table
CREATE TABLE Params(
	MinimumDeposit MONEY NOT NULL   -- So tien gui toi thieu
);  



GO
CREATE TRIGGER dbo.trgPreventInsertion -- khong cho insert nhieu hon 1 record tham so
ON Params
AFTER INSERT
AS
BEGIN
	DECLARE @NoRows SMALLINT
	SELECT @NoRows=COUNT(*) FROM Params
	IF (@NoRows > 1)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50009, -1, -1)
		END
END
GO



GO
CREATE TRIGGER dbo.trgPreventDeletion -- khong cho delete record tham so da them, chi co the thay doi
ON Params
AFTER DELETE
AS
BEGIN
	DECLARE @NoRows SMALLINT
	SELECT @NoRows=COUNT(*) FROM Params
	IF (@NoRows < 1)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50009, -1, -1)
		END
END
GO


-- STORED PROCEDURE: UPDATE MINIMUM DEPOSIT VALUE
-- Define procedure 
GO
CREATE PROCEDURE dbo.updateMinimumDeposit -- thay doi so tien gui toi thieu 
					@NewMinimumDeposit TEXT
AS
BEGIN
	UPDATE Params 
	SET MinimumDeposit = CAST(@NewMinimumDeposit AS VARCHAR)
END
GO


INSERT INTO Params VALUES (1000000); -- khoi tao so tien gui toi thieu la 1 trieu VND



/*====================================================================
BCDOANHSONGAY
======================================================================*/


CREATE TABLE ProfitReports (
	RecordedDate  DATE NOT NULL, 
	TotalRevenue MONEY,
	TotalCost MONEY,
	TotalProfit MONEY
);

CREATE TABLE ReportDetails (
	RecordedDate DATE NOT NULL,
	InterestTypeID INT NOT NULL,
	Revenue MONEY,
	Cost MONEY,
	Profit MONEY
)

-- Add primary key
ALTER TABLE ProfitReports ADD CONSTRAINT PK_Report PRIMARY KEY (RecordedDate);
ALTER TABLE ReportDetails ADD CONSTRAINT PK_ReportDetail PRIMARY KEY (RecordedDate, InterestTypeID);

-- Add foreign key on InterestTypeID
ALTER TABLE ReportDetails
ADD CONSTRAINT FK_ReportInterestTypeID
FOREIGN KEY (InterestTypeID) REFERENCES InterestTypes(InterestTypeID);

ALTER TABLE ReportDetails
ADD CONSTRAINT FK_RecordedDate
FOREIGN KEY (RecordedDate) REFERENCES ProfitReports(RecordedDate);


GO 
CREATE PROCEDURE dbo.calculateReportByDay
				@Date DATE
AS
BEGIN
	SET NOCOUNT ON
	IF (EXISTS (SELECT * FROM ProfitReports WHERE RecordedDate=@Date))
		BEGIN
			DELETE FROM ReportDetails WHERE RecordedDate=@Date
		END
	-- create a new report
	ELSE
		BEGIN
			-- initialize report
			INSERT INTO ProfitReports(RecordedDate) VALUES (@Date)
		END
	-- calculate details
	INSERT INTO ReportDetails 
	SELECT  Costs.RecordedDate, -- ngay lap phieu
			Costs.InterestTypeID, -- loaitk 
			TotalRevenueEachType, -- tong thu 
			TotalCostEachType, -- tong chi
			TotalRevenueEachType - TotalCostEachType as ProfitEachType -- chenh lech
		FROM (
				SELECT ISNULL(CAST(OpenedDate AS DATE), @Date) AS RecordedDate, 
						 IT.InterestTypeID, 
						 ISNULL(SUM(Fund), 0) AS TotalRevenueEachType
				FROM (SELECT * FROM Deposits WHERE CAST(OpenedDate AS DATE) = @Date) Opens -- bang phu luu cac PhieuGT vao ngay @Date
				RIGHT JOIN InterestTypes IT ON IT.InterestTypeID = Opens.InterestTypeID
				GROUP BY CAST(OpenedDate AS DATE), IT.InterestTypeID
			) AS Revenues -- bang phu luu ngay gui, LoaiTK, tong tien gui cua LoaiTK do
			FULL OUTER JOIN
			(
				SELECT ISNULL(CAST(TransactionDate AS DATE), @Date) AS RecordedDate, 
						InterestTypes.InterestTypeID, 
						ISNULL(-SUM(Changes), 0) AS TotalCostEachType
				FROM (
						SELECT * FROM Transactions
						WHERE Changes < 0 -- is a withdrawal
						AND CAST(TransactionDate AS DATE) = @Date -- at the given date
					) AS MoneyWithdrawn -- luu nhung transactions rut tien vao ngay @Date
				JOIN Deposits D ON D.DepositID = MoneyWithdrawn.DepositID
				RIGHT JOIN InterestTypes ON InterestTypes.InterestTypeID = D.InterestTypeID
				GROUP BY CAST(TransactionDate AS DATE), InterestTypes.InterestTypeID
			) AS Costs -- bang phu luu ngay rut, loaiTK, tong tien rut ra loaiTK do
			ON Costs.InterestTypeID = Revenues.InterestTypeID
	-- summary details
	UPDATE ProfitReports
	SET TotalRevenue = (SELECT ISNULL(SUM(Revenue),0) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalCost = (SELECT ISNULL(SUM(Cost), 0) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalProfit = (SELECT ISNULL(SUM(Profit), 0) FROM ReportDetails WHERE RecordedDate = @Date)
	WHERE RecordedDate = @Date;
END
GO


-- STORED PROCEDURE: MAKE REPORT By Day
GO
CREATE PROCEDURE dbo.makeReportByDay
					@Date DATE -- format 'ydm'
AS 
BEGIN
	SET NOCOUNT ON
	IF (@Date > GETDATE())  -- cannot create reports for the future
		BEGIN
			RAISERROR(50022, -1, -1)
			RETURN
		END
	
	EXEC dbo.calculateReportByDay @Date

	
	-- return reports
	SELECT TotalRevenue, TotalCost, TotalProfit
		 FROM ProfitReports WHERE RecordedDate = @Date
	SELECT IT.InterestTypeID, InterestTypeName, Revenue, Cost, Profit
		FROM ReportDetails RD JOIN InterestTypes IT ON IT.InterestTypeID = RD.InterestTypeID
		WHERE RecordedDate = @Date
		ORDER BY Profit DESC
END
GO



-- STORED PROCEDURE: Summary month report
GO
CREATE PROCEDURE dbo.summaryMonthReport
					@Month INT,
					@Year INT
AS
BEGIN
	SET NOCOUNT ON
	-- cannot summarise if the month is invalid or time in the future
	IF (@Month < 1 OR @Month > 12 OR @Month > MONTH(GETDATE()) OR @Year > YEAR(GETDATE())) -- invalid month 
		BEGIN
			RAISERROR(50022, -1, -1)
			RETURN  -- cannot summarise report
		END
	-- auto create reports for the days in month that was not created
	DECLARE @Day INT, @CurrentDate DATE, @NoDays INT
	
	SET @Day = 1
	SET @CurrentDate = CONCAT(CONVERT(NVARCHAR, @Year),'-', CONVERT(NVARCHAR, @Month), '-', CONVERT(NVARCHAR, @Day))
	IF DATEDIFF(day, GETDATE(), EOMONTH ( @CurrentDate )) >= 0 -- is the current month
		SET @NoDays = DATEDIFF(day, @CurrentDate, GETDATE()) + 1
	ELSE		-- is a month in the past
		SET @NoDays = DATEDIFF(day, @CurrentDate, EOMONTH ( @CurrentDate )) + 1

	WHILE (@Day < @NoDays)
		BEGIN
			EXEC dbo.calculateReportByDay @CurrentDate
			SET @Day = @Day + 1
			SET @CurrentDate = CONCAT(CONVERT(NVARCHAR, @Year),'-', CONVERT(NVARCHAR, @Month), '-', CONVERT(NVARCHAR, @Day))
		END
	-- update latest report for today if required
	IF (DATEDIFF(day, @CurrentDate, GETDATE()) = 0)
		BEGIN
			INSERT INTO ProfitReports
				EXEC dbo.calculateReportByDay @CurrentDate
		END
	SELECT SUM(TotalRevenue) AS MonthRevenue, 
		   SUM(TotalCost) AS MonthCost, 
		   SUM(TotalProfit) AS MonthProfit
	FROM ProfitReports
	WHERE MONTH(RecordedDate) = @Month AND YEAR(RecordedDate) = @Year
END
GO


/*====================================================================
NHOMNGUOIDUNG
======================================================================*/
CREATE TABLE AccountTypes( -- NHOMNGUOIDUNG
	AccountTypeID INT NOT NULL,
	AccountTypeName VARCHAR(20)
);

ALTER TABLE AccountTypes 
ADD CONSTRAINT PK_AccountTypes 
PRIMARY KEY(AccountTypeID);

/*====================================================================
NGUOIDUNG
======================================================================*/
CREATE TABLE Accounts( -- NGUOIDUNG
	AccountID INT NOT NULL,
	Username VARCHAR(20),
	AccountPassword VARCHAR(50),
	AccountTypeID INT,
);

ALTER TABLE Accounts 
ADD CONSTRAINT PK_Accounts 
PRIMARY KEY(AccountID); 

ALTER TABLE Accounts 
ADD CONSTRAINT FK_Accounts_AccountTypes 
FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);
/*====================================================================
CHUCNANG
======================================================================*/
CREATE TABLE UserFunctionality( -- CHUCNANG
	UserFunctionalityID INT NOT NULL,
	UserFunctionalityName VARCHAR(20),
	UFNDescription VARCHAR(100),
);

ALTER TABLE UserFunctionality 
ADD CONSTRAINT PK_UserFunctionality 
PRIMARY KEY(UserFunctionalityID);

/*====================================================================
PHANQUYEN
======================================================================*/
CREATE TABLE UserAuthorization( -- PHANQUYEN
	AccountTypeID INT NOT NULL,
	UserFunctionalityID INT NOT NULL,
);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT PK_AccountTypes_UserFunctionality 
PRIMARY KEY(AccountTypeID, UserFunctionalityID);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT FK_UserAuthorization_AccountTypes 
FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT FK_UserAuthorization_UserFunctionality 
FOREIGN KEY (UserFunctionalityID) REFERENCES UserFunctionality(UserFunctionalityID);