import axios from "axios";
import EditForm from "../../forms/EditForm/EditForm";
import style from "./AdminMain.module.css";
import FilterSection from "./FilterSection/FilterSection";
import OrdersSection from "./OrdersSection/OrdersSection";
import SelectedOrdersToolbar from "./SelectedOrdersToolbar/SelectedOrdersToolbar";
import { useState } from "react";

const api_url = "http://localhost:2020";

const AdminMain = ({ orders, setOrders }) => {
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [isEditFormVisible, setIsEditFormVisible] = useState(false);
  const [selectedOrders, setSelectedOrders] = useState([]);

  const handleRowClick = (order) => {
    setIsEditFormVisible(false);
    setSelectedOrder(order);
    setIsEditFormVisible(true);
  };

  const handleCloseEditForm = () => {
    setIsEditFormVisible(false);
  };

  const handleCheckboxChange = (e, orderId) => {
    e.stopPropagation();
    setSelectedOrders((prev) =>
      prev.includes(orderId)
        ? prev.filter((id) => id !== orderId)
        : [...prev, orderId]
    );
  };

  const onSetStatusClosed = async () => {
    try {
      await Promise.all(
        selectedOrders.map((orderId) =>
          axios.put(
            `${api_url}/v1/order/${orderId}`,
            { fkIdStatus: 1 },
            { withCredentials: true }
          )
        )
      );

      setOrders((el) =>
        el.map((order) =>
          selectedOrders.includes(order.pkIdOrder)
            ? { ...order, status: "активно" }
            : order
        )
      );
    } catch (error) {
      console.error("Ошибка при блокировке:", error);
    }
  };
  const onSetStatusActive = async () => {
    try {
      await Promise.all(
        selectedOrders.map((orderId) =>
          axios.put(
            `${api_url}/v1/order/${orderId}`,
            { fkIdStatus: 2 },
            { withCredentials: true }
          )
        )
      );

      setOrders((el) =>
        el.map((order) =>
          selectedOrders.includes(order.pkIdOrder)
            ? { ...order, status: "закрыто" }
            : order
        )
      );
    } catch (error) {
      console.error("Ошибка при активации:", error);
    }
  };
  const onDeleteOrder = async () => {
    try {
      await Promise.all(
        selectedOrders.map((orderId) =>
          axios.delete(`${api_url}/v1/order/${orderId}`, {
            withCredentials: true,
          })
        )
      );
      setOrders((prev) =>
        prev.filter((order) => !selectedOrders.includes(order.pkIdOrder))
      );
      setSelectedOrders([]);
    } catch (error) {
      console.error("Ошибка при удалении:", error);
    }
  };

  const handleCloseToolbar = () => {
    setSelectedOrders([]);
  };

  return (
    <>
      <div
        className={`${style.content} ${
          isEditFormVisible ? style.content_shifted : ""
        }`}
      >
        <FilterSection />
        {selectedOrders.length > 0 && (
          <SelectedOrdersToolbar
            selectedOrdersCount={selectedOrders.length}
            onSetStatusClosed={onSetStatusClosed}
            onSetStatusActive={onSetStatusActive}
            onDeleteOrder={onDeleteOrder}
            onClose={handleCloseToolbar}
          />
        )}
        <OrdersSection
          orders={orders}
          onRowClick={handleRowClick}
          selectedOrders={selectedOrders}
          onCheckboxChange={handleCheckboxChange}
        />
      </div>
      {isEditFormVisible && (
        <EditForm
          key={selectedOrder?.pkIdOrder}
          order={selectedOrder}
          setOrders={setOrders}
          onClose={handleCloseEditForm}
          isVisible={isEditFormVisible}
        />
      )}
    </>
  );
};

export default AdminMain;
