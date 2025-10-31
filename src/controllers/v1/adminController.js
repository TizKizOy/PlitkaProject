const adminService = require('../../services/adminService');

exports.login = async (req, res) => {
  try {
    const { login, password } = req.body;
    if (!login || !password) {
      return res.status(400).json({ error: "Логин и пароль обязательны!" });
    }
    const admin = await adminService.authenticateAdmin(login, password);
    req.session.admin = {
      id: admin.pkIdAdmin,
      login: admin.login,
      role: admin.login
    };
    res.json({ message: 'Авторизация успешна!' });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};

exports.logout = (req, res) => {
  req.session.destroy();
  res.json({ message: 'Выход выполнен!' });
};
