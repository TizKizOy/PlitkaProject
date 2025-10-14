const orderService = require("../../services/orderService");
const { sendNotification } = require("../../bot/services/notification");

exports.getOrder = async (req, res, next) => {
  try {
    const { status } = req.query;
    let orders;
    if (status) {
      orders = await orderService.getOrdersByStatus(status);
    } else {
      orders = await orderService.getAllOrders();
    }
    res.json(orders);
  } catch (error) {
    next(error);
  }
};

exports.getOrderById = async (req, res, next) => {
  try {
    const order = await orderService.getOrderById(req.params.id);
    if (order) {
      res.json(order);
    } else {
      res.status(404).json({ error: "Order is not found" });
    }
  } catch (error) {
    next(error);
  }
};

exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { pkIdOrder } = req.params;
    const { status } = req.body;

    const updatedOrder = await orderService.updateOrderStatus(
      pkIdOrder,
      status
    );
    res.json(updatedOrder);
  } catch (error) {
    next(error);
  }
};

exports.postOrder = async (req, res, next) => {
  try {
    if (!req.body) {
      return res
        .status(400)
        .json({
          error: "Bad Request",
          message: "Тело запроса не может быть пустым",
        });
    }
    const newOrder = await orderService.createOrder(req.body);
    sendNotification(newOrder);
    res
      .status(201)
      .json({ message: "Заявка создана успешно", order: newOrder });
  } catch (error) {
    if (error.message === "Клиент с таким номером телефона уже существует") {
      res.status(400).json({ error: "Bad Request", message: error.message });
    } else if (error.message === "Недостаточно данных для создания заявки") {
      res.status(400).json({ error: "Bad Request", message: error.message });
    } else {
      next(error);
    }
  }
};

exports.putAndPatchOrderById = async (req, res, next) => {
  try {
    if (!req.body || Object.keys(req.body).length === 0) {
      return res
        .status(400)
        .json({
          error: "Bad Request",
          message: "Тело запроса не может быть пустым",
        });
    }

    const updatedOrder = await orderService.updateOrder(
      req.params.id,
      req.body
    );
    res
      .status(200)
      .json({ message: "Заявка успешно изменена", order: updatedOrder });
  } catch (error) {
    if (error.message === "Заявка не найдена") {
      res.status(404).json({ error: "Not Found", message: error.message });
    } else {
      next(error);
    }
  }
};

exports.deleteOrderById = (req, res, next) => {
  try {
    orderService.deleteOrder(req.params.id);
    res.status(204).json({ message: "Заявка удалена" });
  } catch (error) {
    if (error.message === "Заявка не найдена") {
      res.status(404).json({ error: "Not Found", message: error.message });
    } else {
      next(error);
    }
  }
};
