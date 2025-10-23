import axios from "axios";
import EditForm from "../../forms/EditForm/EditForm";
import style from "./AdminMain.module.css";
import FilterSection from "./FilterSection/FilterSection";
import OrdersSection from "./OrdersSection/OrdersSection";
import SelectedOrdersToolbar from "./SelectedOrdersToolbar/SelectedOrdersToolbar";
import { useEffect, useState } from "react";

const api_url = "http://localhost:2020";

const AdminMain = ({ orders: initialOrders, setOrders }) => {
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [isEditFormVisible, setIsEditFormVisible] = useState(false);
  const [selectedOrders, setSelectedOrders] = useState([]);
  const [filters, setFilters] = useState({
    status: "активно",
    dateRange: "Текущий месяц",
    searchText: "",
  });

  const fetchOrders = async () => {
    try {
      const params = {};
      if (filters.status) params.status = filters.status;
      if (filters.dateRange) {
        const now = new Date();
        let startDate, endDate;

        switch (filters.dateRange) {
          case "Текущий день":
            startDate = new Date(now.setHours(0, 0, 0, 0));
            endDate = new Date(now.setHours(23, 59, 59, 999));
            break;
          case "Текущая неделя":
            const currentDay = now.getDay();
            const diffToMonday = currentDay === 0 ? -6 : 1 - currentDay;
            startDate = new Date(now);
            startDate.setDate(now.getDate() + diffToMonday);
            startDate.setHours(0, 0, 0, 0);
            endDate = new Date(startDate);
            endDate.setDate(startDate.getDate() + 6);
            endDate.setHours(23, 59, 59, 999);
            break;
          case "Текущий месяц":
            startDate = new Date(now.getFullYear(), now.getMonth(), 1);
            endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            break;
          case "Ранее":
            endDate = new Date(now.getFullYear(), now.getMonth(), 0);
            startDate = null;
            break;
          case "Все":
            startDate = null;
            endDate = null;
            break;
          default:
            startDate = null;
            endDate = null;
        }

        if (startDate) params.startDate = startDate.toISOString().split("T")[0];
        if (endDate) params.endDate = endDate.toISOString().split("T")[0];
      }
      if (filters.searchText) params.searchText = filters.searchText;

      const response = await axios.get(`${api_url}/v1/order`, {
        params,
        withCredentials: true,
      });
      setOrders(response.data);
    } catch (error) {
      console.error("Ошибка при фильтрации заказов:", error);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [filters]);

  const handleStatusChange = (e) => {
    const selectedStatus = e.target.value;
    let status;
    if (selectedStatus === "Все") {
      status = null;
    } else {
      status = selectedStatus === "Активные заявки" ? "активно" : "закрыто";
    }
    setFilters((prev) => ({ ...prev, status }));
  };

  const handleDateRangeChange = (e) => {
    setFilters((prev) => ({ ...prev, dateRange: e.target.value }));
  };

  const handleSearchChange = (e) => {
    setFilters((prev) => ({ ...prev, searchText: e.target.value }));
  };

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
      setSelectedOrders([]);
      await fetchOrders();
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
      setSelectedOrders([]);
      await fetchOrders();
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
      await fetchOrders();
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
        <FilterSection
          filters={filters}
          onStatusChange={handleStatusChange}
          onDateRangeChange={handleDateRangeChange}
          onSearchChange={handleSearchChange}
        />
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
          orders={initialOrders}
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
          fetchOrders={fetchOrders}
        />
      )}
    </>
  );
};

export default AdminMain;
