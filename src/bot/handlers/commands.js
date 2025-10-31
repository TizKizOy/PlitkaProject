const { sendMainMenu } = require("./menu");
const { getAllOrders, getLastOrder } = require("../services/order");

function setupCommands(bot) {
  bot.onText(/\/start/, async (msg) => {
    const chatId = msg.chat.id;
    await sendMainMenu(bot, chatId);
  });

  bot.onText(/\/help/, async (msg) => {
    const chatId = msg.chat.id;
    const helpMessage = `
      🤖 Список доступных команд:
      /start - Запустить бота
      /help - Показать помощь
      /all_orders - Показать все заявки
      /last_order - Показать последнюю заявку
    `;
    await bot.sendMessage(chatId, helpMessage);
  });

  bot.onText(/\/all_orders/, async (msg) => {
    const chatId = msg.chat.id;
    const orders = await getAllOrders();
    let message = "📋 Список всех заявок:\n\n";
    if (!orders || orders.length === 0) {
      message = "Нет заявок.";
    } else {
      orders.forEach((order, index) => {
        message += `
          ${index + 1}. Заявка #${order.pkIdOrder}
          Имя: ${order.firstName}
          Услуга: ${order.serviceName}
          Телефон: ${order.phone}
          Местонахождение: ${order.location}
        `;
      });
    }
    await bot.sendMessage(chatId, message);
  });

  bot.onText(/\/last_order/, async (msg) => {
    const chatId = msg.chat.id;
    const lastOrder = await getLastOrder();
    if (!lastOrder) {
      await bot.sendMessage(chatId, "Нет заявок.");
    } else {
      const message = `
        📄 Последняя заявка:
        Имя: ${lastOrder.firstName}
        Услуга: ${lastOrder.serviceName}
        Телефон: ${lastOrder.phone}
        Местонахождение: ${lastOrder.location}
      `;
      await bot.sendMessage(chatId, message);
    }
  });
}

module.exports = { setupCommands };
