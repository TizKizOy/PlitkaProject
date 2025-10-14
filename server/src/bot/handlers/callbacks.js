const { getAllOrders, getLastOrder } = require("../services/order");

function setupCallbacks(bot) {
  bot.on("callback_query", async (callbackQuery) => {
    const chatId = callbackQuery.message.chat.id;
    const data = callbackQuery.data;

    if (data === "all_orders") {
      const orders = await getAllOrders();
      let message = "📋 Список всех заявок:\n\n";
      if (!orders || orders.length === 0) {
        message = "Нет заявок.";
      } else {
        orders.forEach((order, index) => {
          message += `
            Заявка № ${index + 1}
            Имя: ${order.firstName}
            Услуга: ${order.serviceName}
            Телефон: ${order.phone}
            Местонахождение: ${order.location}
          `;
        });
      }
      await bot.sendMessage(chatId, message);
    } else if (data === "last_order") {
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
    } else if (data === "help") {
      const helpMessage = `
        🤖 Список доступных команд:
        /start - Запустить бота
        /help - Показать помощь
        /all_orders - Показать все заявки
        /last_order - Показать последнюю заявку
      `;
      await bot.sendMessage(chatId, helpMessage);
    }
  });
}

module.exports = { setupCallbacks };
