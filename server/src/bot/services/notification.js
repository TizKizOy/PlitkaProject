const bot = require("../index").bot;
const chatId = "631228432";

async function sendNotification(order) {
  let serviceName = "";
  
  switch (order.fkIdService) {
    case "1":
      serviceName = "Укладка плитки";
      break;
    case "2":
      serviceName = "Рулонный/посевной газон";
      break;
    case "3":
      serviceName = "Грунтовая дорога";
      break;
    case "4":
      serviceName = "Забор";
      break;
    case "5":
      serviceName = "Фундамент";
      break;
    case "6":
      serviceName = "Водоотвод";
      break;
    case "7":
      serviceName = "Комплексные работы";
  }

  const message = `
    📝 Новая заявка!
    Дата: ${new Date().toLocaleString()}
    Данные:
      Имя: ${order.firstName}
      Услуга: ${serviceName}
      Номер телефона: ${order.phone}
      Местонахождение: ${order.location}
  `;
  try {
    await bot.sendMessage(chatId, message);
    console.log("Уведомление отправлено в Telegram");
  } catch (error) {
    console.error("Ошибка отправки уведомления:", error);
  }
}

module.exports = { sendNotification };
