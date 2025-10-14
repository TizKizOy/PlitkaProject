import axios from "axios";
import style from "./OrdersSection.module.css";

const api_url = "http://localhost:2020";

const OrdersSection = ({ orders, setOrders, activeTab }) => {
  const handleStatusChange = async (order) => {
    try {
      const newStatus = order.status === "active" ? "closed" : "active";
      const response = await axios.patch(
        `${api_url}/v1/order/${order.pkIdOrder}`,
        { status: newStatus },
        { withCredentials: true }
      );

      setOrders(
        orders.map((o) =>
          o.pkIdOrder === order.pkIdOrder ? { ...o, status: newStatus } : o
        )
      );
    } catch (error) {
      console.error("Ошибка при изменении статуса:", error);
    }
  };

  return (
    <div className={style.table}>
      <div className={style.table__header}>
        <div>Статус</div>
        <div>Имя</div>
        <div>Услуга</div>
        <div>Локация, км</div>
        <div>Телефон</div>
        <div>Комментарий</div>
      </div>
      <div className={style.table__list}>
        {orders.map((order) => (
          <div key={order.pkIdOrder} className={style.table__row}>
            <div className={style.table__checkbox}>
              <input
                type="checkbox"
                checked={order.status === "closed"}
                onChange={() => handleStatusChange(order)}
              />
            </div>
            <div>{order.firstName}</div>
            <div>{order.serviceName}</div>
            <div>{order.location}</div>
            <div>{order.phone}</div>
            <div>{order.comment || ""}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrdersSection;
