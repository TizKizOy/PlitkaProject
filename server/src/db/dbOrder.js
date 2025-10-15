const { getPool, sql } = require("./dbConfig");

exports.readOrder = async () => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        o.pkIdOrder,
        o.firstName,
        o.phone,
        o.location,
        s.name AS 'serviceName',
        os.name as 'status'
      FROM tbOrder o
      JOIN tbService s ON o.fkIdService = s.pkIdService
      JOIN tbStatus os ON o.fkIdStatus = os.pkIdStatus
    `);
    return { orders: result.recordset };
  } catch (err) {
    console.error("Ошибка при чтении заказов:", err);
    throw err;
  }
};

exports.updateOrderStatus = async (pkIdOrder, status) => {
  try {
    const pool = await getPool();
    await pool
      .request()
      .input("status", sql.NVarChar, status)
      .input("pkIdOrder", sql.NVarChar, pkIdOrder).query(`
        UPDATE tbOrder
        SET fkIdStatus = (SELECT pkIdStatus FROM tbStatus WHERE name = @status)
        WHERE pkIdOrder = @pkIdOrder
      `);
  } catch (err) {
    console.error("Ошибка при обновлении статуса заказа:", err);
    throw err;
  }
};

exports.writeOrder = async (data) => {
  try {
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    await transaction.begin();
    try {
      await transaction.request().query("DELETE FROM tbOrder");
      const request = new sql.Request(transaction);
      for (const order of data.orders) {
        await request
          .input("pkIdOrder", sql.Int, order.pkIdOrder)
          .input("firstName", sql.NVarChar, order.firstName)
          .input("phone", sql.NVarChar, order.phone)
          .input("location", sql.NVarChar, order.location)
          .input("fkIdService", sql.Int, order.fkIdService)
          .input("fkIdOrderStatus", sql.Int, order.fkIdOrderStatus).query(`
            INSERT INTO tbOrder (pkIdOrder, firstName, phone, location, fkIdService, fkIdOrderStatus)
            VALUES (@pkIdOrder, @firstName, @phone, @location, @fkIdService, @fkIdOrderStatus)
          `);
      }
      await transaction.commit();
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  } catch (err) {
    console.error("Ошибка при записи заказов:", err);
    throw err;
  }
};

exports.addOrder = async (order) => {
  console.log(order)
  try {
    const pool = await getPool();
    await pool
      .request()
      .input("pkIdOrder", sql.NVarChar, order.pkIdOrder)
      .input("firstName", sql.NVarChar, order.firstName)
      .input("phone", sql.NVarChar, order.phone)
      .input("location", sql.NVarChar, order.location)
      .input("fkIdService", sql.Int, order.fkIdService)
      .input("fkIdStatus", sql.Int, order.fkIdStatus).query(`
        INSERT INTO tbOrder (pkIdOrder, firstName, phone, location, fkIdService, fkIdStatus)
        VALUES (@pkIdOrder, @firstName, @phone, @location, @fkIdService, @fkIdStatus)
      `);
    return order;
  } catch (err) {
    console.error("Ошибка при добавлении заказа:", err);
    throw err;
  }
};

exports.updateOrder = async (pkIdOrder, newData) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("pkIdOrder", sql.NVarChar, pkIdOrder)
      .query("SELECT * FROM tbOrder WHERE pkIdOrder = @pkIdOrder");
    if (!result.recordset[0]) {
      throw new Error("Заявка не найдена");
    }
    const updatedOrder = { ...result.recordset[0], ...newData };
    const fieldsToUpdate = [];
    const updateRequest = pool.request();
    updateRequest.input("pkIdOrder", sql.NVarChar, pkIdOrder);

    for (const [key, value] of Object.entries(updatedOrder)) {
      if (key !== "pkIdOrder") {
        fieldsToUpdate.push(`${key} = @${key}`);
        if (key === "fkIdService" || key === "fkIdStatus") {
          updateRequest.input(key, sql.Int, value);
        } else {
          updateRequest.input(key, sql.NVarChar, value);
        }
      }
    }

    await updateRequest.query(`
      UPDATE tbOrder
      SET ${fieldsToUpdate.join(", ")}
      WHERE pkIdOrder = @pkIdOrder
    `);
    return updatedOrder;
  } catch (err) {
    console.error("Ошибка при обновлении заказа:", err);
    throw err;
  }
};


exports.deleteOrder = async (pkIdOrder) => {
  try {
    const pool = await getPool();
    await pool
      .request()
      .input("pkIdOrder", sql.NVarChar, pkIdOrder)
      .query("DELETE FROM tbOrder WHERE pkIdOrder = @pkIdOrder");
  } catch (err) {
    console.error("Ошибка при удалении заказа:", err);
    throw err;
  }
};

exports.close = async () => {
  try {
    await sql.close();
    pool = null;
  } catch (err) {
    console.error("Ошибка при закрытии подключения:", err);
    throw err;
  }
};
