import ExitButton from "./ExitButton/ExitButton";
import style from "./AdminNav.module.css";

const AdminNav = () => {
  return (
    <>
      <div className={style.nav}>
        <p className={style.nav__title}>TILEHAUS|ЗАЯВКИ</p>
        <ExitButton />
      </div>
    </>
  );
};

export default AdminNav;
