import style from "./AdminMain.module.css";
import FilterSection from "./FilterSection/FilterSection";
import OrdersSection from "./OrdersSection/OrdersSection";

const AdminMain = ({ activeTab, orders, setOrders }) => {
  return (
    <>
      <h2 className={style.title}>
        {activeTab === "active" ? "Активные заявки" : "Закрытые заявки"}
      </h2>
      <FilterSection />
      <OrdersSection
        orders={orders}
        setOrders={setOrders}
        activeTab={activeTab}
      />
    </>
  );
};

export default AdminMain;
