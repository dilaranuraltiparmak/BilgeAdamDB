Lesson01.sql
--DML

select * from Categories

select CategoryName, [Description]
from Categories

select Cat.CategoryName as [Kategori Ismi], 
Cat.[Description] Açýklama 
from Categories as Cat

select p.ProductName,p.UnitPrice,p.UnitsInStock
from Products p
where p.UnitsInStock<=10 and p.UnitsInStock>5

--join subquery

select p.ProductName as [Ürün Adý],
(select c.CategoryName from Categories c where c.CategoryID=p.CategoryID) 
as [Kategori Adý] ,
(select CompanyName from Suppliers where SupplierID=p.SupplierID) as [Tedarikci]
from Products p

--join(s) 

--inner 
--outher => left,right
--full
--cross

select kategori.CategoryName,urun.ProductName,tedarikci.CompanyName from Categories kategori
inner join Products urun  on  kategori.CategoryID =urun.CategoryID
join Suppliers tedarikci on tedarikci.SupplierID=urun.SupplierID


select COUNT(ProductName),SUM(UnitPrice) from Products

--10248 nolu order da toplam kaç para kargo ucreti odenmiþtir  ve hangi kargo ile sipariþ gönderilmiþtir.
--Shipper ,ORders

Select Freight,Shippers.CompanyName from Orders 
join Shippers on Shippers.ShipperID = Orders.ShipVia
where OrderID=10248

select *
from [Order Details] 
join Orders on Orders.OrderID=[Order Details].OrderID
where Orders.OrderID=10250

select Orders.OrderID,SUM(Quantity) [Toplam Sipari UrunADeti] ,Orders.ShippedDate
from [Order Details]
join Orders on Orders.OrderID=[Order Details].OrderID
where Orders.OrderID=10250
group by Orders.ShippedDate,Orders.OrderID

select * from Employees

--insert
Select * from Categories

--inserted table
insert into Categories(CategoryName,[Description])
values('meyve','asdasdadasdasdas')

update Categories set [Description]='elma armut amanda açslmça'
where CategoryID=9

--deleted 
delete Categories where CategoryID=1


--Transaction (iþlem bütünlüðü)
--DML
--=>Ado Commit Rollback => SqlTransaction  
--=>Entity Commit => TranactionScope
--ya hep ya hiç

--ACID
	
begin try
	begin tran SiparisKontrol
			insert into Orders(CustomerID,EmployeeID,ShipVia,OrderDate)
			values('ALFKI',1,1,getdate())

			insert into [Order Details](OrderID,ProductID,Quantity)
			values(10248,10,1)

	Commit Tran SiparisKontrol
end try
begin catch
	rollback tran SiparisKontrol
end catch

--Isolation Level 
--ReadCommited
--read unCommited -- dirty read
--repeatable read
--snapshot
--seriazable


select * from Categories

--soru 

--insert into Categories(CategoryName) values('Yemek01')

begin try
		begin tran trn
				if exists( select * from Categories where CategoryName='Yemek01')
					begin
					--cat ID  al product a ekle .
					declare @catID int

					select @catID=CategoryID from Categories where CategoryName='Yemek01'

					--pro ýd al
						insert into Products(ProductName,UnitPrice,UnitsInStock,CategoryID) 
						values('Kadýn Budu Köfte 01',50,60,@catID)

						--raiserror('melike hatasý',16,1)

						insert into [Order Details](OrderID,ProductID,UnitPrice,Quantity,Discount)
						values(10248,SCOPE_IDENTITY(),50,1,0)
					end 
				else
					begin 
						print 'yemek kategorisi bulunamamýþtýr.'
					end 
		commit tran trn
end try
begin catch
		rollback tran trn
		select ERROR_MESSAGE() as 'Hata Mesajý', ERROR_LINE() as 'Hata Satiri', ERROR_NUMBER() as 'Hata Kodu'
end catch


select * from Categories where CategoryName='Yemek01'
select * from Products where ProductName='Kadýn Budu Köfte 01'
select * from [Order Details] where OrderID=10248


-- function, stored proc ,trigger,views


--SP 
use Northwind 
GO
alter  procedure SP_KategoriyeGoreUrunCek(@kategorid int)
as
begin 
	select p.ProductName, c.CategoryName from Products p 
	join Categories c on c.CategoryID =p.CategoryID
	where p.CategoryID=@kategorid
end

--SP adýný ve soyadýný bildiðimiz çalýþanlarý listele ?


--sp içinden SP çaðýrmak?
alter procedure SP_InsertProduct @proName nvarchar(40),
@categoryName nvarchar(15),
@unitPrice money
as
begin 
		declare @CatID int
		
		exec SP_InsertCategory @categoryName,@CatID out --diðer SP çaðýrýldý..

		insert into Products(ProductName,UnitPrice,CategoryID)
		values(@proName,@unitPrice,@CatID)
end
----
exec SP_InsertProduct 'kalem','Bevegares',50
---- saðlama
select * from Categories order by CategoryID desc
Select * from Products order by ProductID desc
-----
create proc SP_InsertCategory @catname nvarchar(15),
 @CatID int out
as
begin 
 if  not exists(select * from Categories where CategoryName=@catname)
	begin
	--yeni ekleyip catID deðerni kullanýcýya ver 
		insert into Categories(CategoryName) values(@catname)

		set @CatID=@@IDENTITY		
	end
else
	begin
	-- catIDdeðerini kullanýcýya ver
	select @CatID= CategoryID from Categories where CategoryName=@catname
	end
end

--Kullanýcýdan alýnan deðerlere göre  1 tane urunden 1 adet satmaya yarayan SP geliþtiriniz. 



--TRIGGER
--DML  after / instead of 
-- FOR trigger
--inserted-deleted 

alter trigger  TRG_Eklendi
on Shippers
after insert
as
begin 
	declare  @kargoAdi nvarchar(40)
	select @kargoAdi =CompanyName from inserted
	print	@kargoAdi +' kayýt eklendi..'
end 



insert into Shippers(CompanyName,Phone)
values('hede kargo1234','22121212')
--order detail de veri eklendiðinde stoðu düþüren TRG yazýnýz ..
create trigger  TRG_StokDusur
on [Order Details]
after insert
as
begin 
 declare @dusurulecekADet smallint
 declare @proID int
 select @dusurulecekADet=Quantity,@proID=ProductID from inserted
update Products set UnitsInStock=UnitsInStock-@dusurulecekADet
 where  ProductID=@proID
end

select * from [Order Details]
select * from Products

insert into [Order Details](OrderID,ProductID,UnitPrice,Quantity,Discount)
values(10249,1,18,5,0)

--order detail tablosundan veri silindiðinde urunun stoðu artýran TRG yazýnýz ..















