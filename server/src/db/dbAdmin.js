const { getPool, sql } = require('./dbConfig')
const bcrypt = require("bcrypt");

exports.getAdminByLogin = async (login) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    request.input("login", sql.NVarChar, login);
    const result = await request.execute("pr_GetAdmilByLogin");
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
      .execute("pr_CreateAdmin");
    return result.recordset[0];
  } catch (err) {
    console.error("Ошибка при создании админа:", err);
    throw err;
  }
};


