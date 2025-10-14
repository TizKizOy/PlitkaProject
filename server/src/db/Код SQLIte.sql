-- Таблица tbService
DROP TABLE IF EXISTS tbService;
CREATE TABLE tbService (
    pkIdService INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Таблица tbOrder
DROP TABLE IF EXISTS tbOrder;
CREATE TABLE tbOrder (
    pkIdOrder TEXT NOT NULL PRIMARY KEY,
    firstName TEXT NOT NULL,
    phone TEXT NOT NULL,
    location TEXT NOT NULL,
	comment TEXT NULL,
    fkIdService INTEGER NOT NULL,
    FOREIGN KEY (fkIdService) REFERENCES tbService(pkIdService)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Таблица tbAdmin
DROP TABLE IF EXISTS tbAdmin;
CREATE TABLE tbAdmin (
    pkIdAdmin INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL,
    passwordHash TEXT NOT NULL
);

-- Индексы для tbOrder
CREATE INDEX ind_tbOrder_firstName ON tbOrder(firstName);
CREATE INDEX ind_tbOrder_fkIdService ON tbOrder(fkIdService);
