const db = require("../db/dbOrder");
const { v4: uuidv4 } = require("uuid");

function validateOrderData(data) {
  if (!data.firstName || !data.phone || !data.fkIdService) {
    throw new Error("Недостаточно данных для создания заявки");
  }
}

async function getAllOrders() {
  const result = await db.readOrder();
  return result.orders;
}

async function getOrdersByStatus(status) {
  const result = await db.readOrder();
  const filteredOrders = result.orders.filter(
    (order) => order.status === status
  );
  return filteredOrders;
}

async function updateOrderStatus(pkIdOrder, status) {
  const updatedOrder = await db.updateOrderStatus(pkIdOrder, status);
  return updatedOrder;
};


async function getOrderById(pkIdOrder) {
  const result = await db.readOrder();
  return result.orders.find((order) => order.pkIdOrder === pkIdOrder);
}

async function createOrder(data) {
  validateOrderData(data);
  const orderContent = await db.readOrder();
  const orderExists = orderContent.orders.some(
    (order) => order.phone === data.phone
  );
  if (orderExists) {
    throw new Error("Клиент с таким номером телефона уже существует");
  }
  const newOrder = {
    pkIdOrder: uuidv4(),
    ...data,
  };
  await db.addOrder(newOrder);
  return newOrder;
}

async function updateOrder(pkIdOrder, newData) {
  if (Object.keys(newData).length === 0) {
    throw new Error("Нет данных для обновления");
  }
  const updatedOrder = await db.updateOrder(pkIdOrder, newData);
  return updatedOrder;
}

async function deleteOrder(pkIdOrder) {
  const orderContent = await db.readOrder();
  const orderIndex = orderContent.orders.findIndex(
    (order) => order.pkIdOrder === pkIdOrder
  );
  if (orderIndex === -1) {
    throw new Error("Заявка не найдена");
  }
  await db.deleteOrder(pkIdOrder);
}

module.exports = {
  getAllOrders,
  getOrderById,
  createOrder,
  updateOrder,
  deleteOrder,
  getOrdersByStatus,
  updateOrderStatus,
};
