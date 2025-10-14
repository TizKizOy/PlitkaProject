import style from "./Hamburger.module.css";

const Hamburger = ({ toggleSidebar, isActive }) => {
  return (
    <button
      className={`${style.hamburger} ${isActive ? style.active : ""}`}
      onClick={toggleSidebar}
    >
      <span></span>
      <span></span>
      <span></span>
    </button>
  );
};

export default Hamburger;
