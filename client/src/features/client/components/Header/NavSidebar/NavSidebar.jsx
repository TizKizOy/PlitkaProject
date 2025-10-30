import NavList from "../../../../../shared/components/NavList/NavList";
import style from "./NavSidebar.module.css";
import { navItems } from "../../../data/navItems";

const NavSidebar = ({ isOpen, setIsOpen }) => {
  return (
    <div className={`${style.navWrapper} ${isOpen ? style.open : ""}`}>
      <NavList
        items={navItems}
        listStyle={style.navList}
        itemStyle={style.navItem}
        linkStyle={style.navLink}
        setIsOpenSideBar={setIsOpen}
      />
    </div>
  );
};

export default NavSidebar;
