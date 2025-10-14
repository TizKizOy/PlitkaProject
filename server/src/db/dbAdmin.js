const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');
const dbPath = path.resolve(__dirname, 'dbTileHaus.db');
const db = new sqlite3.Database(dbPath);

exports.getAdminByLogin = (login) => {
  return new Promise((resolve, reject) => {
    db.get('SELECT * FROM tbAdmin WHERE login = ?', [login], (err, admin) => {
      if (err) {
        reject(err);
      } else {
        resolve(admin);
      }
    });
  });
};

exports.createAdmin = async (login, password) => {
  const hashedPassword = await bcrypt.hash(password, 10);
  return new Promise((resolve, reject) => {
    db.run(
      'INSERT INTO tbAdmin (login, passwordHash) VALUES (?, ?)',
      [login, hashedPassword],
      function (err) {
        if (err) {
          reject(err);
        } else {
          resolve({ pkIdAdmin: this.lastID, login, passwordHash: hashedPassword });
        }
      }
    );
  });
};

