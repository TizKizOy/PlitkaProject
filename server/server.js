const createApp = require('./src/app/createApp');
const orderRoutes = require('./src/routes/v1/orderRoutes');
const adminRoutes = require('./src/routes/v1/adminRoutes');
const logger = require('./src/middlewares/logger');
const session = require('express-session');
const dotenv = require('dotenv');
const cors = require("cors");

dotenv.config();

const app = createApp();

app.use(
  cors({
    origin: "http://localhost:5173",
    credentials: true,
  })
);


app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: false,
      httpOnly: true, 
      sameSite: "strict",
      maxAge: 1000 * 60 * 60 * 24,
    },
  })
); 

app.use(logger);

app.get('/', (req, res) => {
  res.json({ message: 'Добро пожаловать в API заказов! Используйте /v1/order для работы с заявками. ' });
});

app.use('/v1', orderRoutes);
app.use('/admin', adminRoutes);


const port = process.env.PORT || 3000;
const server = app.listen(port, () => {
  const host = server.address().address;
  const actualPort = server.address().port;
  console.log(`Сервер запущен по адресу: http://${host === '::' ? 'localhost' : host}:${actualPort}`);
});