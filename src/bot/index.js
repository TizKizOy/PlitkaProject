const TelegramBot = require("node-telegram-bot-api");
const dotenv = require('dotenv');
dotenv.config();
const token = process.env.TOKEN_BOT;
const bot = new TelegramBot(token, { polling: true });

const { setupCommands } = require("./handlers/commands");
const { setupCallbacks } = require("./handlers/callbacks");

setupCommands(bot);
setupCallbacks(bot);

module.exports = { bot };
