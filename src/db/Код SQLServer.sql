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
	firstName nvarchar(128)not null,
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

select * from tbDeletedOrders
go

create or alter trigger trg_DeleteOrder_SaveOrderInTbDeletedOrders
on tbOrder
after delete
as
begin 
	insert into tbDeletedOrders(pkIdOrder, firstName, phone, [location], comment, fkIdService, fkIdStatus, reason)
	select d.pkIdOrder, d.firstName, d.phone, d.[location], d.comment, d.fkIdService, d.fkIdStatus, 'Заявка обработана/устарела'
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
begin tran
	begin try
		if exists (select 1 from tbOrder where pkIdOrder = @pkIdOrder)
			delete from tbOrder where pkIdOrder = @pkIdOrder
		commit tran
	end try
begin catch
	rollback tran
end catch

--exec pr_DeleteOrder @pkIdOrder = 'b8c7d16b-4810-4241-9778-d03275ac4ce7'



--EXEC pr_InsertOrder @PkIdOrder = '5c711f3d-fb2b-4f8c-9d7f-ed7cb50cbb2a', @firstName = 'Артур', @phone='+375253378844', @location='деревушка, 20', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8', @firstName = 'Иван', @phone='+375291234567', @location='Минск, ул. Ленина, 10', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'b2c3d4e5-f6g7-8901-h2i3-j4k5l6m7n8o9', @firstName = 'Пётр', @phone='+375339876543', @location='СТ Птичь-2, дом 45', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'c3d4e5f6-g7h8-9012-i3j4-k5l6m7n8o9p0', @firstName = 'Александр', @phone='+375441112233', @location='д. Колодищи, 5', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd4e5f6g7-h8i9-0123-j4k5-l6m7n8o9p0q1', @firstName = 'Дмитрий', @phone='+375257778899', @location='пос. Лесной, 18', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e5f6g7h8-i9j0-1234-k5l6-m7n8o9p0q1r2', @firstName = 'Алексей', @phone='+375296667788', @location='Минск, пр-т Независимости, 50', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f6g7h8i9-j0k1-2345-l6m7-n8o9p0q1r2s3', @firstName = 'Сергей', @phone='+375442233445', @location='Гомель, ул. Советская, 15', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g7h8i9j0-k1l2-3456-m7n8-o9p0q1r2s3t4', @firstName = 'Андрей', @phone='+375335556677', @location='Брест, ул. Московская, 30', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'h8i9j0k1-l2m3-4567-n8o9-p0q1r2s3t4u5', @firstName = 'Михаил', @phone='+375254445566', @location='Гродно, ул. Горького, 7', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'i9j0k1l2-m3n4-5678-o9p0-q1r2s3t4u5v6', @firstName = 'Николай', @phone='+375443334455', @location='Витебск, ул. Кирова, 12', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'j0k1l2m3-n4o5-6789-p0q1-r2s3t4u5v6w7', @firstName = 'Евгений', @phone='+375298889900', @location='Могилёв, ул. Первомайская, 8', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'k1l2m3n4-o5p6-7890-q1r2-s3t4u5v6w7x8', @firstName = 'Владимир', @phone='+375337778899', @location='СТ Птичь-1, дом 20', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'l2m3n4o5-p6q7-8901-r2s3-t4u5v6w7x8y9', @firstName = 'Олег', @phone='+375251112233', @location='д. Саковичи, 12', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'm3n4o5p6-q7r8-9012-s3t4-u5v6w7x8y9z0', @firstName = 'Максим', @phone='+375449998877', @location='д. Колодищи, 5', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'n4o5p6q7-r8s9-0123-t4u5-v6w7x8y9z0a1', @firstName = 'Артём', @phone='+375293334455', @location='пос. Лесной, 18', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'o5p6q7r8-s9t0-1234-u5v6-w7x8y9z0a1b2', @firstName = 'Кирилл', @phone='+375332233445', @location='Минск, ул. Сурганова, 3', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'p6q7r8s9-t0u1-2345-v6w7-x8y9z0a1b2c3', @firstName = 'Захар', @phone='+375256667788', @location='Минск, ул. Тимирязева, 60', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'q7r8s9t0-u1v2-3456-w7x8-y9z0a1b2c3d4', @firstName = 'Евлампий', @phone='+375447778899', @location='Минск, ул. Богдановича, 75', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'r8s9t0u1-v2w3-4567-x8y9-z0a1b2c3d4e5', @firstName = 'Артур', @phone='+375291234567', @location='Гомель, ул. Барыкина, 10', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 's9t0u1v2-w3x4-5678-y9z0-a1b2c3d4e5f6', @firstName = 'Борис', @phone='+375339876543', @location='Брест, ул. Орловская, 22', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 't0u1v2w3-x4y5-6789-z0a1-b2c3d4e5f6g7', @firstName = 'Глеб', @phone='+375254445566', @location='Гродно, ул. Ожешковского, 14', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'u1v2w3x4-y5z6-7890-a1b2-c3d4e5f6g7h8', @firstName = 'Давид', @phone='+375443334455', @location='Витебск, ул. Толстого, 9', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'v2w3x4y5-z6a7-8901-b2c3-d4e5f6g7h8i9', @firstName = 'Антон', @phone='+375298889900', @location='Могилёв, ул. Лазаряна, 33', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'w3x4y5z6-a7b8-9012-c3d4-e5f6g7h8i9j0', @firstName = 'Илья', @phone='+375337778899', @location='д. Новосёлки, 7', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'x4y5z6a7-b8c9-0123-d4e5-f6g7h8i9j0k1', @firstName = 'Роман', @phone='+375251112233', @location='пос. Ратомка, 11', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'y5z6a7b8-c9d0-1234-e5f6-g7h8i9j0k1l2', @firstName = 'Егор', @phone='+375449998877', @location='д. Озерище, 15', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'z6a7b8c9-d0e1-2345-f6g7-h8i9j0k1l2m3', @firstName = 'Константин', @phone='+375293334455', @location='д. Большие Некрасовичи, 8', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'a7b8c9d0-e1f2-3456-g7h8-i9j0k1l2m3n4', @firstName = 'Юрий', @phone='+375332233445', @location='пос. Ждановичи, 22', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'b8c9d0e1-f2g3-4567-h8i9-j0k1l2m3n4o5', @firstName = 'Виктор', @phone='+375256667788', @location='д. Малые Некрасовичи, 19', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'c9d0e1f2-g3h4-5678-i9j0-k1l2m3n4o5p6', @firstName = 'Павел', @phone='+375447778899', @location='д. Лошаны, 34', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd0e1f2g3-h4i5-6789-j0k1-l2m3n4o5p6q7', @firstName = 'Станислав', @phone='+375291234567', @location='пос. Острошицкий Городок, 12', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e1f2g3h4-i5j6-7890-k1l2-m3n4o5p6q7r8', @firstName = 'Денис', @phone='+375339876543', @location='д. Большой Тростенец, 5', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f2g3h4i5-j6k7-8901-l2m3-n4o5p6q7r8s9', @firstName = 'Иван', @phone='+375254445566', @location='д. Малый Тростенец, 17', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g3h4i5j6-k7l8-9012-m3n4-o5p6q7r8s9t0', @firstName = 'Пётр', @phone='+375443334455', @location='д. Сенница, 25', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'h4i5j6k7-l8m9-0123-n4o5-p6q7r8s9t0u1', @firstName = 'Александр', @phone='+375298889900', @location='д. Большие Новосёлки, 30', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'i5j6k7l8-m9n0-1234-o5p6-q7r8s9t0u1v2', @firstName = 'Дмитрий', @phone='+375337778899', @location='д. Малые Новосёлки, 14', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'j6k7l8m9-n0o1-2345-p6q7-r8s9t0u1v2w3', @firstName = 'Алексей', @phone='+375251112233', @location='Минск, ул. Ленина, 10', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'k7l8m9n0-o1p2-3456-q7r8-s9t0u1v2w3x4', @firstName = 'Сергей', @phone='+375449998877', @location='Минск, пр-т Независимости, 50', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'l8m9n0o1-p2q3-4567-r8s9-t0u1v2w3x4y5', @firstName = 'Андрей', @phone='+375293334455', @location='Гомель, ул. Советская, 15', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'm9n0o1p2-q3r4-5678-s9t0-u1v2w3x4y5z6', @firstName = 'Михаил', @phone='+375332233445', @location='Брест, ул. Московская, 30', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'n0o1p2q3-r4s5-6789-t0u1-v2w3x4y5z6a7', @firstName = 'Николай', @phone='+375256667788', @location='Гродно, ул. Горького, 7', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'o1p2q3r4-s5t6-7890-u1v2-w3x4y5z6a7b8', @firstName = 'Евгений', @phone='+375447778899', @location='Витебск, ул. Кирова, 12', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'p2q3r4s5-t6u7-8901-v2w3-x4y5z6a7b8c9', @firstName = 'Владимир', @phone='+375291234567', @location='Могилёв, ул. Первомайская, 8', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'q3r4s5t6-u7v8-9012-w3x4-y5z6a7b8c9d0', @firstName = 'Олег', @phone='+375339876543', @location='СТ Птичь-1, дом 20', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'r4s5t6u7-v8w9-0123-x4y5-z6a7b8c9d0e1', @firstName = 'Максим', @phone='+375254445566', @location='д. Саковичи, 12', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 's5t6u7v8-w9x0-1234-y5z6-a7b8c9d0e1f2', @firstName = 'Артём', @phone='+375443334455', @location='д. Колодищи, 5', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 't6u7v8w9-x0y1-2345-z6a7-b8c9d0e1f2g3', @firstName = 'Кирилл', @phone='+375298889900', @location='пос. Лесной, 18', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'u7v8w9x0-y1z2-3456-a7b8-c9d0e1f2g3h4', @firstName = 'Захар', @phone='+375337778899', @location='Минск, ул. Сурганова, 3', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'v8w9x0y1-z2a3-4567-b8c9-d0e1f2g3h4i5', @firstName = 'Евлампий', @phone='+375251112233', @location='Минск, ул. Тимирязева, 60', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'w9x0y1z2-a3b4-5678-c9d0-e1f2g3h4i5j6', @firstName = 'Артур', @phone='+375449998877', @location='Минск, ул. Богдановича, 75', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'x0y1z2a3-b4c5-6789-d0e1-f2g3h4i5j6k7', @firstName = 'Борис', @phone='+375293334455', @location='Гомель, ул. Барыкина, 10', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'y1z2a3b4-c5d6-7890-e1f2-g3h4i5j6k7l8', @firstName = 'Глеб', @phone='+375332233445', @location='Брест, ул. Орловская, 22', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'z2a3b4c5-d6e7-8901-f2g3-h4i5j6k7l8m9', @firstName = 'Давид', @phone='+375256667788', @location='Гродно, ул. Ожешковского, 14', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'a3b4c5d6-e7f8-9012-g3h4-i5j6k7l8m9n0', @firstName = 'Антон', @phone='+375447778899', @location='Витебск, ул. Толстого, 9', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'b4c5d6e7-f8g9-0123-h4i5-j6k7l8m9n0o1', @firstName = 'Илья', @phone='+375291234567', @location='Могилёв, ул. Лазаряна, 33', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'c5d6e7f8-g9h0-1234-i5j6-k7l8m9n0o1p2', @firstName = 'Роман', @phone='+375339876543', @location='д. Новосёлки, 7', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd6e7f8g9-h0i1-2345-j6k7-l8m9n0o1p2q3', @firstName = 'Егор', @phone='+375254445566', @location='пос. Ратомка, 11', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e7f8g9h0-i1j2-3456-k7l8-m9n0o1p2q3r4', @firstName = 'Константин', @phone='+375443334455', @location='д. Озерище, 15', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f8g9h0i1-j2k3-4567-l8m9-n0o1p2q3r4s5', @firstName = 'Юрий', @phone='+375298889900', @location='д. Большие Некрасовичи, 8', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g9h0i1j2-k3l4-5678-m9n0-o1p2q3r4s5t6', @firstName = 'Виктор', @phone='+375337778899', @location='пос. Ждановичи, 22', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'h0i1j2k3-l4m5-6789-n0o1-p2q3r4s5t6u7', @firstName = 'Павел', @phone='+375251112233', @location='д. Малые Некрасовичи, 19', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'i1j2k3l4-m5n6-7890-o1p2-q3r4s5t6u7v8', @firstName = 'Станислав', @phone='+375449998877', @location='д. Лошаны, 34', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'j2k3l4m5-n6o7-8901-p2q3-r4s5t6u7v8w9', @firstName = 'Денис', @phone='+375293334455', @location='пос. Острошицкий Городок, 12', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'k3l4m5n6-o7p8-9012-q3r4-s5t6u7v8w9x0', @firstName = 'Иван', @phone='+375332233445', @location='д. Большой Тростенец, 5', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'l4m5n6o7-p8q9-0123-r4s5-t6u7v8w9x0y1', @firstName = 'Пётр', @phone='+375256667788', @location='д. Малый Тростенец, 17', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'm5n6o7p8-q9r0-1234-s5t6-u7v8w9x0y1z2', @firstName = 'Александр', @phone='+375447778899', @location='д. Сенница, 25', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'n6o7p8q9-r0s1-2345-t6u7-v8w9x0y1z2a3', @firstName = 'Дмитрий', @phone='+375291234567', @location='д. Большие Новосёлки, 30', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'o7p8q9r0-s1t2-3456-u7v8-w9x0y1z2a3b4', @firstName = 'Алексей', @phone='+375339876543', @location='д. Малые Новосёлки, 14', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'p8q9r0s1-t2u3-4567-v8w9-x0y1z2a3b4c5', @firstName = 'Сергей', @phone='+375254445566', @location='Минск, ул. Ленина, 10', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'q9r0s1t2-u3v4-5678-w9x0-y1z2a3b4c5d6', @firstName = 'Андрей', @phone='+375443334455', @location='Минск, пр-т Независимости, 50', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'r0s1t2u3-v4w5-6789-x0y1-z2a3b4c5d6e7', @firstName = 'Михаил', @phone='+375298889900', @location='Гомель, ул. Советская, 15', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 's1t2u3v4-w5x6-7890-y1z2-a3b4c5d6e7f8', @firstName = 'Николай', @phone='+375337778899', @location='Брест, ул. Московская, 30', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 't2u3v4w5-x6y7-8901-z2a3-b4c5d6e7f8g9', @firstName = 'Евгений', @phone='+375251112233', @location='Гродно, ул. Горького, 7', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'u3v4w5x6-y7z8-9012-a3b4-c5d6e7f8g9h0', @firstName = 'Владимир', @phone='+375449998877', @location='Витебск, ул. Кирова, 12', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'v4w5x6y7-z8a9-0123-b4c5-d6e7f8g9h0i1', @firstName = 'Олег', @phone='+375293334455', @location='Могилёв, ул. Первомайская, 8', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'w5x6y7z8-a9b0-1234-c5d6-e7f8g9h0i1j2', @firstName = 'Максим', @phone='+375332233445', @location='СТ Птичь-1, дом 20', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'x6y7z8a9-b0c1-2345-d6e7-f8g9h0i1j2k3', @firstName = 'Артём', @phone='+375256667788', @location='д. Саковичи, 12', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'y7z8a9b0-c1d2-3456-e7f8-g9h0i1j2k3l4', @firstName = 'Кирилл', @phone='+375447778899', @location='д. Колодищи, 5', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'z8a9b0c1-d2e3-4567-f8g9-h0i1j2k3l4m5', @firstName = 'Захар', @phone='+375291234567', @location='пос. Лесной, 18', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'a9b0c1d2-e3f4-5678-g9h0-i1j2k3l4m5n6', @firstName = 'Евлампий', @phone='+375339876543', @location='Минск, ул. Сурганова, 3', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'b0c1d2e3-f4g5-6789-h0i1-j2k3l4m5n6o7', @firstName = 'Артур', @phone='+375443334455', @location='Минск, ул. Тимирязева, 60', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'c1d2e3f4-g5h6-7890-i1j2-k3l4m5n6o7p8', @firstName = 'Борис', @phone='+375254445566', @location='Минск, ул. Богдановича, 75', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd2e3f4g5-h6i7-8901-j2k3-l4m5n6o7p8q9', @firstName = 'Глеб', @phone='+375337778899', @location='Гомель, ул. Барыкина, 10', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e3f4g5h6-i7j8-9012-k3l4-m5n6o7p8q9r0', @firstName = 'Давид', @phone='+375298889900', @location='Брест, ул. Орловская, 22', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f4g5h6i7-j8k9-0123-l4m5-n6o7p8q9r0s1', @firstName = 'Антон', @phone='+375447778899', @location='Гродно, ул. Ожешковского, 14', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g5h6i7j8-k9l0-1234-m5n6-o7p8q9r0s1t2', @firstName = 'Илья', @phone='+375251112233', @location='Витебск, ул. Толстого, 9', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'h6i7j8k9-l0m1-2345-n6o7-p8q9r0s1t2u3', @firstName = 'Роман', @phone='+375339876543', @location='Могилёв, ул. Лазаряна, 33', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'i7j8k9l0-m1n2-3456-o7p8-q9r0s1t2u3v4', @firstName = 'Егор', @phone='+375443334455', @location='д. Новосёлки, 7', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'j8k9l0m1-n2o3-4567-p8q9-r0s1t2u3v4w5', @firstName = 'Константин', @phone='+375291234567', @location='пос. Ратомка, 11', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'k9l0m1n2-o3p4-5678-q9r0-s1t2u3v4w5x6', @firstName = 'Юрий', @phone='+375337778899', @location='д. Озерище, 15', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'l0m1n2o3-p4q5-6789-r0s1-t2u3v4w5x6y7', @firstName = 'Виктор', @phone='+375254445566', @location='д. Большие Некрасовичи, 8', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'm1n2o3p4-q5r6-7890-s1t2-u3v4w5x6y7z8', @firstName = 'Павел', @phone='+375449998877', @location='пос. Ждановичи, 22', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'n2o3p4q5-r6s7-8901-t2u3-v4w5x6y7z8a9', @firstName = 'Станислав', @phone='+375293334455', @location='д. Малые Некрасовичи, 19', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'o3p4q5r6-s7t8-9012-u3v4-w5x6y7z8a9b0', @firstName = 'Денис', @phone='+375332233445', @location='д. Лошаны, 34', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'p4q5r6s7-t8u9-0123-v4w5-x6y7z8a9b0c1', @firstName = 'Иван', @phone='+375256667788', @location='пос. Острошицкий Городок, 12', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'q5r6s7t8-u9v0-1234-w5x6-y7z8a9b0c1d2', @firstName = 'Пётр', @phone='+375447778899', @location='д. Большой Тростенец, 5', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'r6s7t8u9-v0w1-2345-x6y7-z8a9b0c1d2e3', @firstName = 'Александр', @phone='+375291234567', @location='д. Малый Тростенец, 17', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 's7t8u9v0-w1x2-3456-y7z8-a9b0c1d2e3f4', @firstName = 'Дмитрий', @phone='+375339876543', @location='д. Сенница, 25', @fkIdService=6, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 't8u9v0w1-x2y3-4567-z8a9-b0c1d2e3f4g5', @firstName = 'Алексей', @phone='+375254445566', @location='д. Большие Новосёлки, 30', @fkIdService=5, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'u9v0w1x2-y3z4-5678-a9b0-c1d2e3f4g5h6', @firstName = 'Сергей', @phone='+375443334455', @location='д. Малые Новосёлки, 14', @fkIdService=2, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'v0w1x2y3-z4a5-6789-b0c1-d2e3f4g5h6i7', @firstName = 'Андрей', @phone='+375298889900', @location='Минск, ул. Ленина, 10', @fkIdService=1, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'w1x2y3z4-a5b6-7890-c1d2-e3f4g5h6i7j8', @firstName = 'Михаил', @phone='+375337778899', @location='Минск, пр-т Независимости, 50', @fkIdService=7, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'x2y3z4a5-b6c7-8901-d2e3-f4g5h6i7j8k9', @firstName = 'Николай', @phone='+375251112233', @location='Гомель, ул. Советская, 15', @fkIdService=4, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'y3z4a5b6-c7d8-9012-e3f4-g5h6i7j8k9l0', @firstName = 'Евгений', @phone='+375449998877', @location='Брест, ул. Московская, 30', @fkIdService=3, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'z4a5b6c7-d8e9-0123-f4g5-h6i7j8k9l0m1', @firstName = 'Владимир', @phone='+375293334455', @location='Гродно, ул. Горького, 7', @fkIdService=6, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'a5b6c7d8-e9f0-1234-g5h6-i7j8k9l0m1n2', @firstName = 'Олег', @phone='+375332233445', @location='Витебск, ул. Кирова, 12', @fkIdService=5, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'b6c7d8e9-f0g1-2345-h6i7-j8k9l0m1n2o3', @firstName = 'Максим', @phone='+375256667788', @location='Могилёв, ул. Первомайская, 8', @fkIdService=2, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'c7d8e9f0-g1h2-3456-i7j8-k9l0m1n2o3p4', @firstName = 'Артём', @phone='+375447778899', @location='СТ Птичь-1, дом 20', @fkIdService=1, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd8e9f0g1-h2i3-4567-j8k9-l0m1n2o3p4q5', @firstName = 'Кирилл', @phone='+375291234567', @location='д. Саковичи, 12', @fkIdService=7, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e9f0g1h2-i3j4-5678-k9l0-m1n2o3p4q5r6', @firstName = 'Захар', @phone='+375339876543', @location='д. Колодищи, 5', @fkIdService=4, @fkIdStatus=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f0g1h2i3-j4k5-6789-l0m1-n2o3p4q5r6s7', @firstName = 'Евлампий', @phone='+375254445566', @location='пос. Лесной, 18', @fkIdService=3, @fkIdStatus=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g1h2i3j4-k5l6-7890-m1n2-o3p4q5r6s7t8', @firstName = 'Артур', @phone='+375443334455', @location='Минск, ул. Сурганова, 3', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'h2i3j4k5-l6m7-8901-n2o3-p4q5r6s7t8u9', @firstName = 'Борис', @phone='+375298889900', @location='Минск, ул. Тимирязева, 60', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'i3j4k5l6-m7n8-9012-o3p4-q5r6s7t8u9v0', @firstName = 'Глеб', @phone='+375337778899', @location='Минск, ул. Богдановича, 75', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'j4k5l6m7-n8o9-0123-p4q5-r6s7t8u9v0w1', @firstName = 'Давид', @phone='+375251112233', @location='Гомель, ул. Барыкина, 10', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'k5l6m7n8-o9p0-1234-q5r6-s7t8u9v0w1x2', @firstName = 'Антон', @phone='+375449998877', @location='Брест, ул. Орловская, 22', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'l6m7n8o9-p0q1-2345-r6s7-t8u9v0w1x2y3', @firstName = 'Илья', @phone='+375293334455', @location='Гродно, ул. Ожешковского, 14', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'm7n8o9p0-q1r2-3456-s7t8-u9v0w1x2y3z4', @firstName = 'Роман', @phone='+375332233445', @location='Витебск, ул. Толстого, 9', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'n8o9p0q1-r2s3-4567-t8u9-v0w1x2y3z4a5', @firstName = 'Егор', @phone='+375256667788', @location='Могилёв, ул. Лазаряна, 33', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'o9p0q1r2-s3t4-5678-u9v0-w1x2y3z4a5b6', @firstName = 'Константин', @phone='+375447778899', @location='д. Новосёлки, 7', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'p0q1r2s3-t4u5-6789-v0w1-x2y3z4a5b6c7', @firstName = 'Юрий', @phone='+375291234567', @location='пос. Ратомка, 11', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'q1r2s3t4-u5v6-7890-w1x2-y3z4a5b6c7d8', @firstName = 'Виктор', @phone='+375339876543', @location='д. Озерище, 15', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'r2s3t4u5-v6w7-8901-x2y3-z4a5b6c7d8e9', @firstName = 'Павел', @phone='+375254445566', @location='д. Большие Некрасовичи, 8', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 's3t4u5v6-w7x8-9012-y3z4-a5b6c7d8e9f0', @firstName = 'Станислав', @phone='+375443334455', @location='пос. Ждановичи, 22', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 't4u5v6w7-x8y9-0123-z4a5-b6c7d8e9f0g1', @firstName = 'Денис', @phone='+375298889900', @location='д. Малые Некрасовичи, 19', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'u5v6w7x8-y9z0-1234-a5b6-c7d8e9f0g1h2', @firstName = 'Иван', @phone='+375337778899', @location='д. Лошаны, 34', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'v6w7x8y9-z0a1-2345-b6c7-d8e9f0g1h2i3', @firstName = 'Пётр', @phone='+375251112233', @location='пос. Острошицкий Городок, 12', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'w7x8y9z0-a1b2-3456-c7d8-e9f0g1h2i3j4', @firstName = 'Александр', @phone='+375449998877', @location='д. Большой Тростенец, 5', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'x8y9z0a1-b2c3-4567-d8e9-f0g1h2i3j4k5', @firstName = 'Дмитрий', @phone='+375293334455', @location='д. Малый Тростенец, 17', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'y9z0a1b2-c3d4-5678-e9f0-g1h2i3j4k5l6', @firstName = 'Алексей', @phone='+375332233445', @location='д. Сенница, 25', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'z0a1b2c3-d4e5-6789-f0g1-h2i3j4k5l6m7', @firstName = 'Сергей', @phone='+375256667788', @location='д. Большие Новосёлки, 30', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8', @firstName = 'Андрей', @phone='+375447778899', @location='д. Малые Новосёлки, 14', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'b2c3d4e5-f6g7-8901-h2i3-j4k5l6m7n8o9', @firstName = 'Михаил', @phone='+375291234567', @location='Минск, ул. Ленина, 10', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'c3d4e5f6-g7h8-9012-i3j4-k5l6m7n8o9p0', @firstName = 'Николай', @phone='+375339876543', @location='Минск, пр-т Независимости, 50', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'd4e5f6g7-h8i9-0123-j4k5-l6m7n8o9p0q1', @firstName = 'Евгений', @phone='+375254445566', @location='Гомель, ул. Советская, 15', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'e5f6g7h8-i9j0-1234-k5l6-m7n8o9p0q1r2', @firstName = 'Владимир', @phone='+375443334455', @location='Брест, ул. Московская, 30', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'f6g7h8i9-j0k1-2345-l6m7-n8o9p0q1r2s3', @firstName = 'Олег', @phone='+375298889900', @location='Гродно, ул. Горького, 7', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'g7h8i9j0-k1l2-3456-m7n8-o9p0q1r2s3t4', @firstName = 'Максим', @phone='+375337778899', @location='Витебск, ул. Кирова, 12', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'h8i9j0k1-l2m3-4567-n8o9-p0q1r2s3t4u5', @firstName = 'Артём', @phone='+375251112233', @location='Могилёв, ул. Первомайская, 8', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'i9j0k1l2-m3n4-5678-o9p0-q1r2s3t4u5v6', @firstName = 'Кирилл', @phone='+375449998877', @location='СТ Птичь-1, дом 20', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'j0k1l2m3-n4o5-6789-p0q1-r2s3t4u5v6w7', @firstName = 'Захар', @phone='+375293334455', @location='д. Саковичи, 12', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'k1l2m3n4-o5p6-7890-q1r2-s3t4u5v6w7x8', @firstName = 'Евлампий', @phone='+375332233445', @location='д. Колодищи, 5', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'l2m3n4o5-p6q7-8901-r2s3-t4u5v6w7x8y9', @firstName = 'Артур', @phone='+375256667788', @location='пос. Лесной, 18', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'm3n4o5p6-q7r8-9012-s3t4-u5v6w7x8y9z0', @firstName = 'Борис', @phone='+375447778899', @location='Минск, ул. Сурганова, 3', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'n4o5p6q7-r8s9-0123-t4u5-v6w7x8y9z0a1', @firstName = 'Глеб', @phone='+375291234567', @location='Минск, ул. Тимирязева, 60', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'o5p6q7r8-s9t0-1234-u5v6-w7x8y9z0a1b2', @firstName = 'Давид', @phone='+375339876543', @location='Минск, ул. Богдановича, 75', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'p6q7r8s9-t0u1-2345-v6w7-x8y9z0a1b2c3', @firstName = 'Антон', @phone='+375254445566', @location='Гомель, ул. Барыкина, 10', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'q7r8s9t0-u1v2-3456-w7x8-y9z0a1b2c3d4', @firstName = 'Илья', @phone='+375443334455', @location='Брест, ул. Орловская, 22', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'r8s9t0u1-v2w3-4567-x8y9-z0a1b2c3d4e5', @firstName = 'Роман', @phone='+375298889900', @location='Гродно, ул. Ожешковского, 14', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 's9t0u1v2-w3x4-5678-y9z0-a1b2c3d4e5f6', @firstName = 'Егор', @phone='+375337778899', @location='Витебск, ул. Толстого, 9', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 't0u1v2w3-x4y5-6789-z0a1-b2c3d4e5f6g7', @firstName = 'Константин', @phone='+375251112233', @location='Могилёв, ул. Лазаряна, 33', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'u1v2w3x4-y5z6-7890-a1b2-c3d4e5f6g7h8', @firstName = 'Юрий', @phone='+375449998877', @location='д. Новосёлки, 7', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'v2w3x4y5-z6a7-8901-b2c3-d4e5f6g7h8i9', @firstName = 'Виктор', @phone='+375293334455', @location='пос. Ратомка, 11', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'w3x4y5z6-a7b8-9012-c3d4-e5f6g7h8i9j0', @firstName = 'Павел', @phone='+375332233445', @location='д. Озерище, 15', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'x4y5z6a7-b8c9-0123-d4e5-f6g7h8i9j0k1', @firstName = 'Станислав', @phone='+375256667788', @location='д. Большие Некрасовичи, 8', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'y5z6a7b8-c9d0-1234-e5f6-g7h8i9j0k1l2', @firstName = 'Денис', @phone='+375447778899', @location='пос. Ждановичи, 22', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'z6a7b8c9-d0e1-2345-f6g7-h8i9j0k1l2m3', @firstName = 'Иван', @phone='+375291234567', @location='д. Малые Некрасовичи, 19', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'a7b8c9d0-e1f2-3456-g7h8-i9j0k1l2m3n4', @firstName = 'Пётр', @phone='+375339876543', @location='д. Лошаны, 34', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'b8c9d0e1-f2g3-4567-h8i9-j0k1l2m3n4o5', @firstName = 'Александр', @phone='+375254445566', @location='пос. Острошицкий Городок, 12', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'c9d0e1f2-g3h4-5678-i9j0-k1l2m3n4o5p6', @firstName = 'Дмитрий', @phone='+375443334455', @location='д. Большой Тростенец, 5', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'd0e1f2g3-h4i5-6789-j0k1-l2m3n4o5p6q7', @firstName = 'Алексей', @phone='+375298889900', @location='д. Малый Тростенец, 17', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'e1f2g3h4-i5j6-7890-k1l2-m3n4o5p6q7r8', @firstName = 'Сергей', @phone='+375337778899', @location='д. Сенница, 25', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'f2g3h4i5-j6k7-8901-l2m3-n4o5p6q7r8s9', @firstName = 'Андрей', @phone='+375251112233', @location='д. Большие Новосёлки, 30', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'g3h4i5j6-k7l8-9012-m3n4-o5p6q7r8s9t0', @firstName = 'Михаил', @phone='+375449998877', @location='д. Малые Новосёлки, 14', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'h4i5j6k7-l8m9-0123-n4o5-p6q7r8s9t0u1', @firstName = 'Николай', @phone='+375293334455', @location='Минск, ул. Ленина, 10', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'i5j6k7l8-m9n0-1234-o5p6-q7r8s9t0u1v2', @firstName = 'Евгений', @phone='+375332233445', @location='Минск, пр-т Независимости, 50', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'j6k7l8m9-n0o1-2345-p6q7-r8s9t0u1v2w3', @firstName = 'Владимир', @phone='+375256667788', @location='Гомель, ул. Советская, 15', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'k7l8m9n0-o1p2-3456-q7r8-s9t0u1v2w3x4', @firstName = 'Олег', @phone='+375447778899', @location='Брест, ул. Московская, 30', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'l8m9n0o1-p2q3-4567-r8s9-t0u1v2w3x4y5', @firstName = 'Максим', @phone='+375291234567', @location='Гродно, ул. Горького, 7', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'm9n0o1p2-q3r4-5678-s9t0-u1v2w3x4y5z6', @firstName = 'Артём', @phone='+375339876543', @location='Витебск, ул. Кирова, 12', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'n0o1p2q3-r4s5-6789-t0u1-v2w3x4y5z6a7', @firstName = 'Кирилл', @phone='+375254445566', @location='Могилёв, ул. Первомайская, 8', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'o1p2q3r4-s5t6-7890-u1v2-w3x4y5z6a7b8', @firstName = 'Захар', @phone='+375443334455', @location='СТ Птичь-1, дом 20', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'p2q3r4s5-t6u7-8901-v2w3-x4y5z6a7b8c9', @firstName = 'Евлампий', @phone='+375298889900', @location='д. Саковичи, 12', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'q3r4s5t6-u7v8-9012-w3x4-y5z6a7b8c9d0', @firstName = 'Артур', @phone='+375337778899', @location='д. Колодищи, 5', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'r4s5t6u7-v8w9-0123-x4y5-z6a7b8c9d0e1', @firstName = 'Борис', @phone='+375251112233', @location='пос. Лесной, 18', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 's5t6u7v8-w9x0-1234-y5z6-a7b8c9d0e1f2', @firstName = 'Глеб', @phone='+375449998877', @location='Минск, ул. Сурганова, 3', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 't6u7v8w9-x0y1-2345-z6a7-b8c9d0e1f2g3', @firstName = 'Давид', @phone='+375293334455', @location='Минск, ул. Тимирязева, 60', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'u7v8w9x0-y1z2-3456-a7b8-c9d0e1f2g3h4', @firstName = 'Антон', @phone='+375332233445', @location='Минск, ул. Богдановича, 75', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'v8w9x0y1-z2a3-4567-b8c9-d0e1f2g3h4i5', @firstName = 'Илья', @phone='+375256667788', @location='Гомель, ул. Барыкина, 10', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'w9x0y1z2-a3b4-5678-c9d0-e1f2g3h4i5j6', @firstName = 'Роман', @phone='+375447778899', @location='Брест, ул. Орловская, 22', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'x0y1z2a3-b4c5-6789-d0e1-f2g3h4i5j6k7', @firstName = 'Егор', @phone='+375291234567', @location='Гродно, ул. Ожешковского, 14', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'y1z2a3b4-c5d6-7890-e1f2-g3h4i5j6k7l8', @firstName = 'Константин', @phone='+375339876543', @location='Витебск, ул. Толстого, 9', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'z2a3b4c5-d6e7-8901-f2g3-h4i5j6k7l8m9', @firstName = 'Юрий', @phone='+375254445566', @location='Могилёв, ул. Лазаряна, 33', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'a3b4c5d6-e7f8-9012-g3h4-i5j6k7l8m9n0', @firstName = 'Виктор', @phone='+375443334455', @location='д. Новосёлки, 7', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'b4c5d6e7-f8g9-0123-h4i5-j6k7l8m9n0o1', @firstName = 'Павел', @phone='+375298889900', @location='пос. Ратомка, 11', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'c5d6e7f8-g9h0-1234-i5j6-k7l8m9n0o1p2', @firstName = 'Станислав', @phone='+375337778899', @location='д. Озерище, 15', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'd6e7f8g9-h0i1-2345-j6k7-l8m9n0o1p2q3', @firstName = 'Денис', @phone='+375251112233', @location='д. Большие Некрасовичи, 8', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'e7f8g9h0-i1j2-3456-k7l8-m9n0o1p2q3r4', @firstName = 'Иван', @phone='+375449998877', @location='пос. Ждановичи, 22', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'f8g9h0i1-j2k3-4567-l8m9-n0o1p2q3r4s5', @firstName = 'Пётр', @phone='+375293334455', @location='д. Малые Некрасовичи, 19', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'g9h0i1j2-k3l4-5678-m9n0-o1p2q3r4s5t6', @firstName = 'Александр', @phone='+375332233445', @location='д. Лошаны, 34', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'h0i1j2k3-l4m5-6789-n0o1-p2q3r4s5t6u7', @firstName = 'Дмитрий', @phone='+375256667788', @location='пос. Острошицкий Городок, 12', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'i1j2k3l4-m5n6-7890-o1p2-q3r4s5t6u7v8', @firstName = 'Алексей', @phone='+375447778899', @location='д. Большой Тростенец, 5', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'j2k3l4m5-n6o7-8901-p2q3-r4s5t6u7v8w9', @firstName = 'Сергей', @phone='+375291234567', @location='д. Малый Тростенец, 17', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'k3l4m5n6-o7p8-9012-q3r4-s5t6u7v8w9x0', @firstName = 'Андрей', @phone='+375339876543', @location='д. Сенница, 25', @fkIdStatus=2, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 'l4m5n6o7-p8q9-0123-r4s5-t6u7v8w9x0y1', @firstName = 'Михаил', @phone='+375254445566', @location='д. Большие Новосёлки, 30', @fkIdStatus=1, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 'm5n6o7p8-q9r0-1234-s5t6-u7v8w9x0y1z2', @firstName = 'Николай', @phone='+375443334455', @location='д. Малые Новосёлки, 14', @fkIdStatus=2, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'n6o7p8q9-r0s1-2345-t6u7-v8w9x0y1z2a3', @firstName = 'Евгений', @phone='+375298889900', @location='Минск, ул. Ленина, 10', @fkIdStatus=1, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'o7p8q9r0-s1t2-3456-u7v8-w9x0y1z2a3b4', @firstName = 'Владимир', @phone='+375337778899', @location='Минск, пр-т Независимости, 50', @fkIdStatus=2, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'p8q9r0s1-t2u3-4567-v8w9-x0y1z2a3b4c5', @firstName = 'Олег', @phone='+375251112233', @location='Гомель, ул. Советская, 15', @fkIdStatus=1, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'q9r0s1t2-u3v4-5678-w9x0-y1z2a3b4c5d6', @firstName = 'Максим', @phone='+375449998877', @location='Брест, ул. Московская, 30', @fkIdStatus=2, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'r0s1t2u3-v4w5-6789-x0y1-z2a3b4c5d6e7', @firstName = 'Артём', @phone='+375293334455', @location='Гродно, ул. Горького, 7', @fkIdStatus=1, @fkIdService=3;
--EXEC pr_InsertOrder @PkIdOrder = 's1t2u3v4-w5x6-7890-y1z2-a3b4c5d6e7f8', @firstName = 'Кирилл', @phone='+375332233445', @location='Витебск, ул. Кирова, 12', @fkIdStatus=2, @fkIdService=6;
--EXEC pr_InsertOrder @PkIdOrder = 't2u3v4w5-x6y7-8901-z2a3-b4c5d6e7f8g9', @firstName = 'Захар', @phone='+375256667788', @location='Могилёв, ул. Первомайская, 8', @fkIdStatus=1, @fkIdService=5;
--EXEC pr_InsertOrder @PkIdOrder = 'u3v4w5x6-y7z8-9012-a3b4-c5d6e7f8g9h0', @firstName = 'Евлампий', @phone='+375447778899', @location='СТ Птичь-1, дом 20', @fkIdStatus=2, @fkIdService=2;
--EXEC pr_InsertOrder @PkIdOrder = 'v4w5x6y7-z8a9-0123-b4c5-d6e7f8g9h0i1', @firstName = 'Артур', @phone='+375291234567', @location='д. Саковичи, 12', @fkIdStatus=1, @fkIdService=1;
--EXEC pr_InsertOrder @PkIdOrder = 'w5x6y7z8-a9b0-1234-c5d6-e7f8g9h0i1j2', @firstName = 'Борис', @phone='+375339876543', @location='д. Колодищи, 5', @fkIdStatus=2, @fkIdService=7;
--EXEC pr_InsertOrder @PkIdOrder = 'x6y7z8a9-b0c1-2345-d6e7-f8g9h0i1j2k3', @firstName = 'Глеб', @phone='+375254445566', @location='пос. Лесной, 18', @fkIdStatus=1, @fkIdService=4;
--EXEC pr_InsertOrder @PkIdOrder = 'y7z8a9b0-c1d2-3456-e7f8-g9h0i1j2k3l4', @firstName = 'Давид', @phone='+375443334455', @location='Минск, ул. Сурганова, 3', @fkIdStatus=2, @fkIdService=3;
