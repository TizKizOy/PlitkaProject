const adminService = require('../../services/adminService');

exports.login = async (req, res) => {
  try {
    const { login, password } = req.body;
    const admin = await adminService.authenticateAdmin(login, password);
    req.session.admin = admin;
    res.json({ message: 'Авторизация успешна!' });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};

exports.logout = (req, res) => {
  req.session.destroy();
  res.json({ message: 'Выход выполнен!' });
};
