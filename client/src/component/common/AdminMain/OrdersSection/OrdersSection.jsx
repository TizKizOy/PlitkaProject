import axios from "axios";
import style from "./OrdersSection.module.css";
import services from "../../../../data/servicesForm";

const api_url = "http://localhost:2020";

const OrdersSection = ({
  orders,
  onRowClick,
  selectedOrders,
  onCheckboxChange,
}) => {
  return (
    <div className={style.table}>
      <div className={style.table__header}>
        <div className={style.table__checkbox}>
          <input type="checkbox" />
        </div>
        <div>Имя</div>
        <div>Услуга</div>
        <div>Локация, км</div>
        <div>Телефон</div>
        <div>Комментарий</div>
        <div>Статус</div>
      </div>
      <div className={style.table__list}>
        {orders.map((order) => (
          <div
            key={order.pkIdOrder}
            className={style.table__row}
            onClick={() => onRowClick(order)}
          >
            <div className={style.table__checkbox}>
              <input
                type="checkbox"
                checked={selectedOrders.includes(order.pkIdOrder)}
                onChange={(e) => onCheckboxChange(e, order.pkIdOrder)}
                onClick={(e) => e.stopPropagation()}
              />
            </div>
            <div>{order.firstName}</div>
            <div>
              {services.find((s) => s.value === order.serviceName)?.label ||
                order.serviceName}
            </div>
            <div>{order.location}</div>
            <div>{order.phone}</div>
            <div className={style.table__comment}>{order.comment || ""}</div>
            <div>{order.status || "активно"}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrdersSection;
