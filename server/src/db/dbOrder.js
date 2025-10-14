const sqlite3 = require("sqlite3").verbose();
const path = require("path");
const dbPath = path.resolve(__dirname, "dbTileHaus.db");
const db = new sqlite3.Database(dbPath);

exports.readOrder = () => {
  return new Promise((resolve, reject) => {
    const sql = `
            SELECT
                o.pkIdOrder,
                o.firstName,
                o.phone,
                o.location,
                s.name AS serviceName,
                os.status as status
            FROM
                tbOrder o
            JOIN
                tbService s ON o.fkIdService = s.pkIdService
            JOIN
                tbOrderStatus os ON o.fkIdOrderStatus = os.pkIdOrderStatus
        `;
    db.all(sql, (err, rows) => {
      if (err) {
        reject(err);
      } else {
        resolve({ orders: rows });
      }
    });
  });
};

exports.updateOrderStatus = (pkIdOrder, status) => {
  return new Promise((resolve, reject) => {
    db.run(
      `UPDATE tbOrder SET fkIdOrderStatus = (SELECT pkIdOrderStatus FROM tbOrderStatus WHERE status = ?) WHERE pkIdOrder = ?`,
      [status, pkIdOrder],
      function (err) {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      }
    );
  });
};


exports.writeOrder = (data) => {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      db.run("DELETE FROM tbOrder", (err) => {
        if (err) {
          reject(err);
        } else {
          const stmt = db.prepare(`
                        INSERT INTO tbOrder (pkIdOrder, firstName, phone, location, fkIdService, fkIdOrderStatus)
                        VALUES (?, ?, ?, ?, ?, ?)
                    `);
          data.orders.forEach((order) => {
            stmt.run([
              order.pkIdOrder,
              order.firstName,
              order.phone,
              order.location,
              order.fkIdService,
              order.fkIdOrderStatus,
            ]);
          });
          stmt.finalize();
          resolve();
        }
      });
    });
  });
};

exports.addOrder = (order) => {
  return new Promise((resolve, reject) => {
    db.run(
      `INSERT INTO tbOrder (pkIdOrder, firstName, phone, location, fkIdService, fkIdOrderStatus)
             VALUES (?, ?, ?, ?, ?, ?)`,
      [
        order.pkIdOrder,
        order.firstName,
        order.phone,
        order.location,
        order.fkIdService,
        order.fkIdOrderStatus,
      ],
      function (err) {
        if (err) {
          reject(err);
        } else {
          resolve(order);
        }
      }
    );
  });
};

exports.updateOrder = (pkIdOrder, newData) => {
  return new Promise((resolve, reject) => {
    db.get(
      "SELECT * FROM tbOrder WHERE pkIdOrder = ?",
      [pkIdOrder],
      (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        if (!row) {
          reject(new Error("Заявка не найдена"));
          return;
        }
        const updatedOrder = { ...row, ...newData };
        const fieldsToUpdate = [];
        const values = [];
        for (const [key, value] of Object.entries(updatedOrder)) {
          if (key !== "pkIdOrder") {
            fieldsToUpdate.push(`${key} = ?`);
            values.push(value);
          }
        }
        values.push(pkIdOrder);
        const sql = `UPDATE tbOrder SET ${fieldsToUpdate.join(
          ", "
        )} WHERE pkIdOrder = ?`;
        db.run(sql, values, function (err) {
          if (err) {
            reject(err);
          } else {
            resolve(updatedOrder);
          }
        });
      }
    );
  });
};

exports.deleteOrder = (pkIdOrder) => {
  return new Promise((resolve, reject) => {
    db.run(
      "DELETE FROM tbOrder WHERE pkIdOrder = ?",
      [pkIdOrder],
      function (err) {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      }
    );
  });
};

exports.close = () => {
  return new Promise((resolve, reject) => {
    db.close((err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};
