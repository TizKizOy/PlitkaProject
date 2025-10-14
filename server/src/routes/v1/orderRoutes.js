const express = require("express");
const router = express.Router();
const orderController = require("../../controllers/v1/orderController");
const isAuthenticated =
  require("../../middlewares/isAuthenticated").isAuthenticated;

router.get("/order", isAuthenticated, orderController.getOrder);
router.get("/order/:id", isAuthenticated, orderController.getOrderById);
router.post("/order", orderController.postOrder);
router.put("/order/:id", isAuthenticated, orderController.putAndPatchOrderById);
router.patch(
  "/order/:pkIdOrder",
  isAuthenticated,
  orderController.updateOrderStatus
);
router.delete("/order/:id", isAuthenticated, orderController.deleteOrderById);
module.exports = router;
