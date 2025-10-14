function sendMainMenu(bot, chatId) {
  const options = {
    reply_markup: {
      inline_keyboard: [
        [
          { text: "📋 Все заявки", callback_data: "all_orders" },
          { text: "📄 Последняя заявка", callback_data: "last_order" },
        ],
        [{ text: "❓ Помощь", callback_data: "help" }],
      ],
    },
  };
  bot.sendMessage(chatId, "Выберите действие:", options);
}

module.exports = { sendMainMenu };
