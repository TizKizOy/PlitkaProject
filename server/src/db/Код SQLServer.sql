use master 

drop database if exists dbTileHaus
--ALTER DATABASE dbTileHaus SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
go

create database dbTileHaus
go

use dbTileHaus
go

if exists
(select * from dbo.sysobjects
where id=OBJECT_ID('tbService')) drop table tbService
go
CREATE TABLE tbService(
    pkIdService int not null identity(1,1),
    [name] nvarchar(128) NOT NULL
);
go
alter table tbService
add constraint se_pk primary key(pkIdService)
go


if exists
(select * from dbo.sysobjects
where id=OBJECT_ID('tbStatus')) drop table tbStatus
go
create table tbStatus(
	pkIdStatus int not null identity(1,1),
	[name] nvarchar(128) not null
)
go
alter table tbStatus
add constraint st_pk primary key(pkIdStatus)
go



if exists
(select * from dbo.sysobjects
where id=OBJECT_ID('tbOrder')) drop table tbOrder
go
CREATE TABLE tbOrder (
    pkIdOrder nvarchar(256) NOT NULL,
    firstName nvarchar(128) NOT NULL,
    phone nvarchar(32) NOT NULL CHECK (LEN(phone) >= 9 AND LEN(phone) <= 32),
    [location] nvarchar(256) NOT NULL,
	dateOfCreation date not null DEFAULT GetDate(),
	comment nvarchar(1024) NULL,
    fkIdService int null DEFAULT 7,
	fkIdStatus int null DEFAULT 1
);
go
create index ind_tbOrder_firstName on tbOrder(firstName);
create index ind_tbOrder_fkIdService on tbOrder(fkIdService);
create index ind_tbOrder_fkIdStatus on tbOrder(fkIdStatus);
go
alter table tbOrder
add constraint or_pk primary key(pkIdOrder),
	constraint se_fk foreign key(fkIdService) 
		references tbService(pkIdService)
		on delete set null on update cascade,
	constraint st_fk foreign key(fkIdStatus)
		references tbStatus(pkIdStatus)
		on delete set null on update cascade
go

if exists
(select * from dbo.sysobjects
where id=OBJECT_ID('tbAdmin')) drop table tbAdmin
go
CREATE TABLE tbAdmin (
    pkIdAdmin int not null identity(1,1),
    [login] nvarchar(256) NOT NULL,
    passwordHash nvarchar(528) NOT NULL
);
alter table tbAdmin
add constraint ad_pk primary key(pkIdAdmin)
go

insert into tbStatus([name])
values('активно'),
	  ('закрыто')
go

insert into tbService([name])
values ('Укладка плитки'),
	   ('Рулонный/посевной газон'),
	   ('Грунтовая дорога'),
       ('Забор'),
	   ('Фундамент'),
	   ('Водоотвод'),
	   ('Комплексные работы')

insert into tbAdmin([login], passwordHash)
values ('admin', '$2b$10$5./Sni1NL3pSSAbqXCGj1O7PTc.Suz6TjBk0A2Vduq7W7.BvfxjE2');

insert into tbOrder(pkIdOrder, firstName, phone, [location], fkIdService, fkIdStatus)
values ('7181f5cf-e3e9-42e2-8532-aeb643b69730', 'Захар', '+375447281124', 'СТ Птичь-2, 20', 2, 1),
	   ('423b4399-5228-49b5-9ac2-d54fabd21e2a', 'Евлампий', '+375449281144', 'СТ Птичь-1, 22', 3, 2);
					



if exists
(select * from dbo.sysobjects
where id=OBJECT_ID('tbDeletedOrders')) drop table tbDeletedOrders
go
CREATE TABLE tbDeletedOrders(
    pkIdDeleteOrder int not null identity(1,1),
	pkIdOrder nvarchar(256) NOT NULL,
    phone nvarchar(64) NOT NULL,
    [location] nvarchar(256) NOT NULL,
	comment nvarchar(1024) NULL,
    fkIdService int null,
	fkIdStatus int null,
	deletedAt DATETIME NOT NULL DEFAULT GETDATE(),
	reason nvarchar(1024) null
);
go
alter table tbDeletedOrders
add constraint do_pk primary key(pkIdDeleteOrder)
go


create trigger trg_DeleteOrder_SaveOrderInTbDeletedOrders
on tbOrder
after delete
as
begin 
	insert into tbDeletedOrders(pkIdOrder, phone, [location], comment, fkIdService, fkIdStatus, reason)
	select d.pkIdOrder, d.phone, d.[location], d.comment, d.fkIdService, d.fkIdStatus, 'Заявка обработана/устарела'
	from deleted d
end
go




create or alter procedure pr_FilterOrders
	@status nvarchar(64) = null,
	@startDate date = null,
	@endDate date = null,
	@searchText nvarchar(128) = null
as
select 
	o.pkIdOrder,
	o.firstName,
	o.phone,
	o.[location],
	o.comment,
	o.dateOfCreation,
	s.[name] as 'serviceName',
	st.[name] as 'status'
from tbOrder o
join tbService s on o.fkIdService = s.pkIdService
join tbStatus st on o.fkIdStatus = st.pkIdStatus
where (@status is null or st.[name] = @status)
	and (@startDate is null or o.dateOfCreation >= @startDate)
	and (@endDate is null or o.dateOfCreation <= @endDate)
	and ( @searchText IS NULL
        OR o.firstName LIKE '%' + @searchText + '%'
        OR o.phone LIKE '%' + @searchText + '%'
        OR o.[location] LIKE '%' + @searchText + '%'
        OR o.comment LIKE '%' + @searchText + '%'
        OR s.[name] LIKE '%' + @searchText + '%'
        OR st.[name] LIKE '%' + @searchText + '%')

exec pr_FilterOrders 
	@searchText = 'закрыто'
go

create or alter procedure pr_GetOrderById
    @pkIdOrder nvarchar(256)
as
select
    o.pkIdOrder,
    o.firstName,
    o.phone,
    o.[location],
    o.comment,
    o.dateOfCreation,
    s.[name] AS 'serviceName',
    st.[name] AS 'status',
    o.fkIdService,
    o.fkIdStatus
from
    tbOrder o
join tbService s ON o.fkIdService = s.pkIdService
join tbStatus st ON o.fkIdStatus = st.pkIdStatus
where o.pkIdOrder = @pkIdOrder;
go

create or alter procedure pr_GetAdmilByLogin
	@login nvarchar(256)
as
select * from tbAdmin where [login] = @login
exec pr_GetAdmilByLogin @login = 'admin'
go

create or alter procedure pr_InsertOrder
	@pkIdOrder nvarchar(256),
	@firstName nvarchar(128),
	@phone nvarchar(32),
	@location nvarchar(256),
	@fkIdService int = 7,
	@fkIdStatus int = 1
as
INSERT INTO tbOrder (pkIdOrder, firstName, phone, [location], fkIdService, fkIdStatus)
	VALUES (@pkIdOrder, @firstName, @phone, @location, @fkIdService, @fkIdStatus)
go
--exec pr_InsertOrder @PkIdOrder = '5c711f3d-fb2b-4f8c-9d7f-ed7cb50cbb2a',
--	@firstName = 'Артур', @phone='+375253378844', @location='деревушка, 20'
--select * from tbOrder
--go

create or alter procedure pr_CreateAdmin
    @login nvarchar(256),
    @passwordHash nvarchar(528)
as
SET NOCOUNT ON;
declare @Inserted table (pkIdAdmin int, [login] nvarchar(255), passwordHash nvarchar(528));

insert into tbAdmin ([login], passwordHash)
output INSERTED.pkIdAdmin, INSERTED.[login], INSERTED.passwordHash into @Inserted
values (@login, @passwordHash);
select * from @Inserted;
go


create or alter procedure pr_UpdateOrder
	@pkIdOrder nvarchar(256),
	@newFirstName nvarchar(128) = null,
	@newPhone nvarchar(32) = null,
	@newLocation nvarchar(256) = null,
	@newComment nvarchar(1024) = null,
	@newFkIdService int = null,
	@newFkIdStatus int = null
as
update tbOrder set
	firstName = ISNULL(@newFirstName, firstName),
	phone = ISNULL(@newPhone, phone),
	[location] = ISNULL(@newLocation, [location]),
	comment = isnull(@newComment, comment),
	fkIdService = isnull(@newFkIdService, fkIdService),
	fkIdStatus = isnull(@newFkIdStatus, fkIdStatus)
where
	pkIdOrder = @pkIdOrder
go

--exec pr_UpdateOrder @pkIdOrder = 'c273fce9-01a7-4f17-8573-cf4245ca0250',
--	@newLocation = 'Уручье, 10', @newComment = 'Добавил киломметры к локации',
--	@newFkIdService = '2', @newFkIdStatus='2'
--go


create or alter procedure pr_DeleteOrder
	@pkIdOrder nvarchar(256)
as
	if exists (select 1 from tbOrder where pkIdOrder = @pkIdOrder)
		delete from tbOrder where pkIdOrder = @pkIdOrder

--exec pr_DeleteOrder @pkIdOrder = 'b8c7d16b-4810-4241-9778-d03275ac4ce7'
