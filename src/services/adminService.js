const dbAdmin = require('../db/dbAdmin');
const bcrypt = require('bcrypt');

exports.authenticateAdmin = async (login, password) => {
  const admin = await dbAdmin.getAdminByLogin(login);
  if (!admin) {
    throw new Error('Админ не найден');
  }
  const isPasswordValid = await bcrypt.compare(password, admin.passwordHash);
  if (!isPasswordValid) {
    throw new Error('Неверный пароль');
  }
  return admin;
};
