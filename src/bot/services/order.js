const db = require("../../db/dbOrder");

async function getAllOrders() {
  const orders = await db.readOrder();
  return orders.orders || [];
}

async function getLastOrder() {
  const orders = await db.readOrder();
  if (!orders || !orders.orders || orders.orders.length === 0) {
    return null;
  }
  return orders.orders[orders.orders.length - 1];
}

module.exports = { getAllOrders, getLastOrder };
