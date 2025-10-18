const { getPool, sql } = require("./dbConfig");

exports.readOrder = async ({ status, startDate, endDate, searchText } = {}) => {
  try {
    const pool = await getPool();
    const request = pool.request();

    if (status !== undefined) request.input("status", sql.NVarChar, status);
    if (startDate !== undefined)
      request.input("startDate", sql.Date, startDate);
    if (endDate !== undefined) request.input("endDate", sql.Date, endDate);
    if (searchText !== undefined)
      request.input("searchText", sql.NVarChar, searchText);

    const result = await request.execute("pr_FilterOrders");
    return { orders: result.recordset };
  } catch (err) {
    console.error("Ошибка при чтении заказов:", err);
    throw err;
  }
};

exports.addOrder = async (order) => {
  console.log(order);
  try {
    const pool = await getPool();
    const request = pool.request();
    request
      .input("pkIdOrder", sql.NVarChar, order.pkIdOrder)
      .input("firstName", sql.NVarChar, order.firstName)
      .input("phone", sql.NVarChar, order.phone)
      .input("location", sql.NVarChar, order.location)
      .input("fkIdService", sql.Int, order.fkIdService);
    await request.execute(`pr_InsertOrder`);
    return order;
  } catch (err) {
    console.error("Ошибка при добавлении заказа:", err);
    throw err;
  }
};

exports.updateOrder = async (pkIdOrder, newData) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    request.input("pkIdOrder", sql.NVarChar, pkIdOrder);
    
    if (newData.firstName !== undefined) {
      request.input("newFirstName", sql.NVarChar, newData.firstName);
    }
    if (newData.phone !== undefined) {
      request.input("newPhone", sql.NVarChar, newData.phone);
    }
    if (newData.location !== undefined) {
      request.input("newLocation", sql.NVarChar, newData.location);
    }
    if (newData.comment !== undefined) {
      request.input("newComment", sql.NVarChar, newData.comment);
    }
    if (newData.fkIdService !== undefined) {
      request.input("newFkIdService", sql.Int, newData.fkIdService);
    }
    if (newData.fkIdStatus !== undefined) {
      request.input("newFkIdStatus", sql.Int, newData.fkIdStatus);
    }

    await request.execute("pr_UpdateOrder");
    const result = await pool
      .request()
      .input("pkIdOrder", sql.NVarChar, pkIdOrder)
      .execute("pr_GetOrderById");

    if (!result.recordset[0]) {
      throw new Error("Заявка не найдена");
    }

    return result.recordset[0];
  } catch (err) {
    console.error("Ошибка при обновлении заказа:", err);
    throw err;
  }
};

exports.deleteOrder = async (pkIdOrder) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    request.input("pkIdOrder", sql.NVarChar, pkIdOrder);
    await request.execute("pr_DeleteOrder");
  } catch (err) {
    console.error("Ошибка при удалении заказа:", err);
    throw err;
  }
};
