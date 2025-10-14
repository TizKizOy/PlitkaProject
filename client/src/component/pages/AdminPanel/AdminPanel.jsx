import { useState, useEffect } from "react";
import axios from "axios";
import style from "./AdminPanel.module.css";
import AdminNav from "../../common/AdminNav/AdminNav";
import AdminMain from "../../common/AdminMain/AdminMain";

const api_url = "http://localhost:2020";

export const AdminPanel = () => {
  const [activeTab, setActiveTab] = useState("active");
  const [orders, setOrders] = useState([]);

  const getOrders = async () => {
    try {
      const url = `${api_url}/v1/order?status=${activeTab}`;
      const response = await axios.get(url, { withCredentials: true });
      setOrders(response.data);
    } catch (error) {
      console.error("Ошибка при получении данных:", error.message);
    }
  };

  useEffect(() => {
    getOrders();
  }, [activeTab]);

  return (
    <>
      <AdminNav activeTab={activeTab} setActiveTab={setActiveTab} />
      <div className={style.content}>
        <AdminMain
          activeTab={activeTab}
          orders={orders}
          setOrders={setOrders}
        />
      </div>
    </>
  );
};

export default AdminPanel;
