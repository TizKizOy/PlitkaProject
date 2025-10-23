import { useState, useEffect } from "react";
import axios from "axios";
import style from "./AdminPanel.module.css";
import AdminNav from "../../components/AdminNav/AdminNav";
import AdminMain from "../../components/AdminMain/AdminMain";

const api_url = "http://localhost:2020";

export const AdminPanel = () => {
  const [orders, setOrders] = useState([]);

  const getOrders = async () => {
    try {
      const now = new Date();
      const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
      const url = `${api_url}/v1/order?status=активно&startDate=${
        startDate.toISOString().split("T")[0]
      }&endDate=${endDate.toISOString().split("T")[0]}`;

      const response = await axios.get(url, { withCredentials: true });
      setOrders(response.data);
    } catch (error) {
      console.error("Ошибка при получении данных:", error.message);
    }
  };

  useEffect(() => {
    getOrders();
  }, []);

  return (
    <>
      <AdminNav />
      <div className={style.content}>
        <AdminMain orders={orders} setOrders={setOrders} />
      </div>
    </>
  );
};

export default AdminPanel;
