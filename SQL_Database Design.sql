create table ContentWriter (
    writerID int primary key not null,
    WriterName varchar(255) NOT NULL,
    DayOfBirth date,
    WriterContact int
)
GO
create table Content (
    ContentID int primary key not null,
    ContentName varchar(255) not null,
    ContentTopic varchar(255) not null,
    ContentSumary varchar(255) not null,
    ContentFull varchar(255) not null,
    WriterID int foreign key references ContentWriter(WriterID)
)
GO
create table Manager (
    ManagerID int primary key not null,
    ManagerName varchar(255) not null,
    ManagerContact int 
)
go
create table ConfirmedContent(
    ContentID int foreign key references Content(ContentID),
    ManagerID int foreign key references Manager(ManagerID),
    ConfirmName varchar(255) not null,
    ConfirmContent varchar(255) not null,
    ConfirmStatus varchar(10) not null,
    primary key (ContentID,ManagerID)
)
go
-- Add value to table
select* from contentwriter
go
delete from ContentWriter
 where writerID=001
go
insert into ContentWriter
values 
(001,'Huynh Thanh Ngan','10-13-2000',097123456),
(002,'Huynh Thanh A','02-23-1984',099999999),
(003,'Huynh Thanh B','03-13-1999',087542900),
(004,'Huynh Thanh C','04-10-1888',575723490),
(005,'Huynh Thanh D','05-23-1679',086234782),
(006,'Huynh Thanh E','06-19-2004',023489274),
(007,'Nguyen Thanh Toan','07-18-1897',020934829),
(008,'Tran Thanh Nam','11-29-1789',023948203),
(009,'Nguyen Van Thanh','08-15-1845',023847924),
(010,'Nguyen Thi Hong Hanh','04-02-1996',023487234)
GO
select * from content
insert into Content VALUES
(1001,'Ngay Tet','Doi song','Ngay Tet o Viet Nam','O Viet Nam, Ngay Tet,...',010),
(1008,'Cau Long','The Thao','The thao trong nuoc','The thao trong nuoc,...',001),
(1023,'Quoc hoi khoa 10','Chinh Tri','Quoc hoi khoa 10 o Viet Nam','O Viet Nam, Quoc hoi khoa 10 o Viet Nam,...',004),
(1054,'Phat giao','Ton Giao','Phat giao trong nuoc','Phat giao trong nuoc,...',001),
(1888,'Ukaina vs Moscow','Tin The gioi','Chien tranh the gioi','Chien tranh the gioi thu 3...',005),
(2593,'Hoang Sa Truong Sa','Tin trong nuoc','Hoang Sa Truong Sa','Hoang Sa Truong Sa la cua...',003),
(2345,'Covic-19','Y te','Tinh hinh covic o Viet Nam','O Viet Nam, Tinh hinh covic ...',005),
(7653,'Cai cach giao duc','Giao duc','Cai cach giao duc 2022','Cai cach giao duc 2022,...',008),
(3324,'Trien lam tranh anh','Nghe Thuat','Trien lam tranh anh chien tranh bien gioi','Ngay ... trein lam tranh anh ...',009),
(8676,'An chan tu thien','Phap luat','An chan tu thien cua cac nghe si','Bo cong an vua ra quyet dinh ...',002)

GO
insert into Manager VALUES
(213333,'Nguyen Phuc Thuy Tien',098764564),
(394857,'Nguyen Tram Bao Duc',029835734),
(938457,'David Silva',034578998),
(283947,'Keisukei Honda',087634532),
(92374,'Nguyen Gia Bao',0923425),
(34873,'Nguyen Thien Thuat',01235643),
(920384,'Ngo Bao Chau',034521),
(73463,'Tran Nga',0398457),
(472389,'Takeo Ajishima',03984753)
GO
select * from ConfirmedContent
insert into ConfirmedContent VALUES
(1001,213333,'Ngay Tet o Viet Nam','Ngay Tet o Viet Nam ..........','OK'),
(1008,73463,'Cau Long','The thao trong nuoc.......','OK'),
(1023,283947,'Quoc hoi khoa 10 o Viet Nam','O Viet Nam, Quoc hoi khoa 10 o Viet Nam,...','OK'),
(1054,472389,'Phat giao trong nuoc','Phat giao trong nuoc,...','NOT OK'),
(1888,938457,'Ukaina vs Moscow','Chien tranh the gioi thu 3...','OK'),
(2593,92374,'Hoang Sa Truong Sa','Hoang Sa Truong Sa la cua...','OK'),
(2345,394857,'Tinh hinh covic o Viet Nam','O Viet Nam, Tinh hinh covic ...','OK'),
(7653,34873,'Cai cach giao duc 2022','Cai cach giao duc 2022,...','OK'),
(3324,34873,'Trien lam tranh anh chien tranh bien gioi','Ngay ... trein lam tranh anh ...','NOT OK'),
(8676,920384,'An chan tu thien cua cac nghe si','Bo cong an vua ra quyet dinh ...','OK')
go

-- 1.  Create Trigger ON Content hiện ra số Content chưa được duyệt

--drop trigger trg_Content
create trigger trg_Content ON Content After Insert 
AS
BEGIN 
    SELECT * FROM Inserted
    select count(ContentID) - (select count(ContentID) from ConfirmedContent) as WaitForCheck
    from Content 
END

--Test
--delete from Content where ContentID=1666
--insert into Content values (1666,'Ve tinh vu tru','Khoa Hoc','Khoa hoc','Khoa hoc .....',6)


GO
-- 2. Stored Procedure SP_CheckContent
Create Procedure SP_Check_Content(@ContentID int)
AS 
Begin 
    IF Exists (Select * from Content WHERE ContentID= @ContentID)
    BEGIN 
        Select * FROM Content LEFT JOIN ConfirmedContent
        ON Content.ContentID=ConfirmedContent.ContentID
        WHERE  Content.ContentID = @ContentID
    END
    ELSE
        PRINT 'Khong co ContentID can tim'
END
--EXEC  SP_Check_Content 1113
--EXEC SP_Check_Content 1054

--3.Function cho biết số Content đã được kiểm duyệt bởi mỗi Manager. Với ManagerID là tham số
--drop function FN_ManageContent
CREATE Function FN_ManageContent(@ManagerID int) 
RETURNS TABLE AS RETURN

    Select * from ConfirmedContent WHERE ManagerID = @ManagerID 

--Query
--select * from FN_ManageContent(34873)

--4.Index 
Create nonclustered index ix_ConfirmedContent on  ConfirmedContent(ContentID,ConfirmName,ManagerID,ConfirmContent)

select ConfirmName from ConfirmedContent order by ConfirmName

--5. Transaction
Begin Transaction 
Select * from ContentWriter
Update ContentWriter 
Set WriterContact=97123456 Where WriterContact = 10000001
Select * from ContentWriter
Commit Transaction


--6. Truy vấn 
select * from Content

select * from Content Where ContentTopic='The thao'

select* from Manager order by ManagerName
select * from Content Where ContentName LIKE '[ABCDE]%' order by ContentName
select* from ContentWriter Where year(DayOfBirth) > = 2000

select top(5) * from ContentWriter T1 INNER JOIN Content T2
ON T1.WriterID = T2.WriterID

select T1.ManagerID,ManagerName,ConfirmName from Manager T1 FULL OUTER JOIN ConfirmedContent T2
ON T1.ManagerID= T2.ManagerID

--Tìm danh sách các bài viết của các nhà báo lớn tuổi hơn năm 2000.
select * from Content
Where WriterID in ( Select WriterID from ContentWriter Where year(DayOfBirth) < 2000)

-- Mệnh đề WITH
WITH TemporaryTable As (select ContentID,WriterID,ContentTopic,ContentSumary from Content WHERE ContentTopic='Khoa Hoc' or ContentTopic='Chinh Tri')
    --Select ContentID From TemporaryTable
    Select * from TemporaryTable,ConfirmedContent  WHERE TemporaryTable.ContentID = ConfirmedContent.ContentID

-- GROUP BY and HAVING
Select ManagerID,COUNT(ContentID) as NumContent from ConfirmedContent 
Group by ManagerID 
HAVING Count(ContentID)>0


-- Truy vấn với Function
Select * from FN_ManageContent(34873)