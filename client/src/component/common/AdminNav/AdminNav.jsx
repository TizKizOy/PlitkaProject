import ExitButton from "./ExitButton/ExitButton";
import style from "./AdminNav.module.css";

const AdminNav = ({ activeTab, setActiveTab }) => {
  return (
    <>
      <div className={style.nav}>
        <ul className={style.nav__list}>
          <li className={style.nav__item}>
            <button
              className={`${style.nav__button} ${
                activeTab === "active" ? style.active : ""
              }`}
              onClick={() => setActiveTab("active")}
            >
              Активные заявки
            </button>
          </li>
          <li className={style.nav__item}>
            <button
              className={`${style.nav__button} ${
                activeTab === "closed" ? style.active : ""
              }`}
              onClick={() => setActiveTab("closed")}
            >
              Закрытые заявки
            </button>
          </li>
        </ul>
        <ExitButton />
      </div>
    </>
  );
};

export default AdminNav;
