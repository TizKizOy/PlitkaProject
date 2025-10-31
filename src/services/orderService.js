const db = require("../db/dbOrder");
const { v4: uuidv4 } = require("uuid");

function validateOrderData(data) {
  if (!data.firstName || !data.phone || !data.fkIdService) {
    throw new Error("Недостаточно данных для создания заявки");
  }
}

exports.getAllOrders = async({ status, startDate, endDate, searchText }) => {
  const result = await db.readOrder({ status, startDate, endDate, searchText });
  return result.orders;
}

exports.getOrderById = async(pkIdOrder) => {
  const result = await db.readOrder();
  return result.orders.find((order) => order.pkIdOrder === pkIdOrder);
}

exports.createOrder = async(data) => {
  validateOrderData(data);
  const orderContent = await db.readOrder();
  const samePhoneOrders = orderContent.orders.filter(
    (order) => order.phone === data.phone
  );
  if (samePhoneOrders.length > 3) {
    throw new Error(
      "Клиент с таким номером телефона уже имеет 3 или более заказов"
    );
  }
  const newOrder = {
    pkIdOrder: uuidv4(),
    ...data,
  };
  await db.addOrder(newOrder);
  return newOrder;
}


exports.updateOrder = async(pkIdOrder, newData) => {
  if (Object.keys(newData).length === 0) {
    throw new Error("Нет данных для обновления");
  }
  const updatedOrder = await db.updateOrder(pkIdOrder, newData);
  return updatedOrder;
}

exports.deleteOrder = async(pkIdOrder) => {
  const orderContent = await db.readOrder();
  const orderIndex = orderContent.orders.findIndex(
    (order) => order.pkIdOrder === pkIdOrder
  );
  if (orderIndex === -1) {
    throw new Error("Заявка не найдена");
  }
  await db.deleteOrder(pkIdOrder);
}
