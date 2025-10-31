const express = require("express");
const router = express.Router();
const orderController = require("../../controllers/v1/orderController");
const isAuthenticated =
  require("../../middlewares/isAuthenticated").isAuthenticated;

router.get("/order", orderController.getOrder);
router.get("/order/:id", isAuthenticated, orderController.getOrderById);
router.post("/order", orderController.postOrder);
router.put("/order/:id", isAuthenticated, orderController.putOrderById);
router.patch("/order/:id", isAuthenticated, orderController.putOrderById);
router.delete("/order/:id", isAuthenticated, orderController.deleteOrderById);

module.exports = router;
