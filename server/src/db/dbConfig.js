const sql = require("mssql");
const dotenv = require('dotenv');
dotenv.config();

const config = {
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    trustedConnection: false,
    trustServerCertificate: true,
    enableArithAbort: true,
    instancename: process.env.DB_OPTIONS_INSTANCENAME,
  },
  port: parseInt(process.env.DB_PORT, 10),
};

let pool;

async function getPool() {
  if (!pool) {
    try {
      pool = await sql.connect(config);
      console.log("Подключение к базе данных установлено");
    } catch (err) {
      console.error("Ошибка подключения к базе:", err);
      throw err;
    }
  }
  return pool;
}

module.exports = { getPool, sql };
