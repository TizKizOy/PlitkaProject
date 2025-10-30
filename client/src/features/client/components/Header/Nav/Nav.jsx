import style from "./Nav.module.css";
import Hamburger from "../Hamburger/Hamburger";
import NavSidebar from "../NavSidebar/NavSidebar";
import NavList from "../../../../../shared/components/NavList/NavList";
import { navItems } from "../../../data/navItems";
import { useState } from "react";

const Nav = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  return (
    <>
      <nav className={`${style.nav} ${isSidebarOpen ? style.navHidden : ""}`}>
        <div>
          <p className={style.logoText}>TileHaus</p>
        </div>
        <NavList
          items={navItems}
          listStyle={style.navList}
          itemStyle={style.navItem}
          linkStyle={style.navLink}
        />
        <div className={style.phoneNumber}>
          <a className={style.navLink}>+375447778899</a>
        </div>
      </nav>
      <Hamburger toggleSidebar={toggleSidebar} isActive={isSidebarOpen} />
      <NavSidebar isOpen={isSidebarOpen} setIsOpen={toggleSidebar} />
    </>
  );
};

export default Nav;
