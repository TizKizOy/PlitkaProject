import style from "./OrdersSection.module.css";
import services from "../../../../../shared/data/servicesForm";

const OrdersSection = ({
  orders,
  onRowClick,
  selectedOrders,
  onCheckboxChange,
  isVisibleToolBar,
}) => {
  return (
    <div
      className={`${style.table} ${isVisibleToolBar ? style.table_down : ""}`}
    >
      <div className={style.table__header}>
        <div className={style.table__checkbox}>
          <input type="checkbox" />
        </div>
        <div>Имя</div>
        <div>Услуга</div>
        <div>Локация, км</div>
        <div>Телефон</div>
        <div>Статус</div>
        <div>Комментарий</div>
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
            <div className={style.table__customer}>
              <span>Заказчик</span>
              <p>{order.firstName}</p>
            </div>
            <div className={style.table__service}>
              <span>Услуга</span>
              <p>
                {services.find((s) => s.value === order.serviceName)?.label ||
                  order.serviceName}
              </p>
            </div>
            <div className={style.table__location}>
              <span>Локация, км</span>
              <p>{order.location}</p>
            </div>
            <div className={style.table__phone}>
              <span>Номер телефона</span>
              <p>{order.phone}</p>
            </div>
            <div className={style.table__status}>
              <span>Статус</span>
              <p>{order.status || "активно"}</p>
            </div>
            <div className={style.table__comment}>
              <span>Комментарий</span>
              <p>{order.comment || "Отсутствует"}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrdersSection;
