import NavList from "../Nav/NavList/NavList";
import style from "./NavSidebar.module.css";
import { navItems } from "../../../data/navItems";

const NavSidebar = ({ isOpen }) => {
  return (
    <div className={`${style.navWrapper} ${isOpen ? style.open : ""}`}>
      <NavList
        items={navItems}
        listStyle={style.navList}
        itemStyle={style.navItem}
        linkStyle={style.navLink}
      />
    </div>
  );
};

export default NavSidebar;
