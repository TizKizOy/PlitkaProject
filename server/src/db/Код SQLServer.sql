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
values('active'),
	  ('closed')
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
values ('7181f5cf-e3e9-42e2-8532-aeb643b69730', 'Захар', '+375447281124', 'СТ Птичь-2', 2, 1),
	   ('423b4399-5228-49b5-9ac2-d54fabd21e2a', 'Евлампий', '+375449281144', 'СТ Птичь-1', 3, 2);
					
delete from tbOrder where pkIdOrder = '7181f5cf-e3e9-42e2-8532-aeb643b69730'


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



UPDATE tbOrder
    SET fkIdStatus = (SELECT pkIdStatus FROM tbStatus WHERE [name] = 'active')
    WHERE pkIdOrder = '769bb14a-f85b-41eb-a15e-5852c2d47e06'



select * from tbOrder