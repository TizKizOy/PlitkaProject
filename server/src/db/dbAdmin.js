const { getPool, sql } = require('./dbConfig')

exports.getAdminByLogin = async (login) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    const result = await request
      .input("login", sql.NVarChar, login)
      .query("SELECT * FROM tbAdmin WHERE login = @login");
    return result.recordset[0] || null;
  } catch (err) {
    console.error("Ошибка при получении админа:", err);
    throw err;
  }
};

exports.createAdmin = async (login, password) => {
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const pool = await getPool();
    const request = pool.request();
    const result = await request
      .input("login", sql.NVarChar, login)
      .input("passwordHash", sql.NVarChar, hashedPassword)
      .query(
        "INSERT INTO tbAdmin (login, passwordHash) OUTPUT INSERTED.pkIdAdmin, INSERTED.login, INSERTED.passwordHash VALUES (@login, @passwordHash)"
      );
    return result.recordset[0];
  } catch (err) {
    console.error("Ошибка при создании админа:", err);
    throw err;
  }
};

