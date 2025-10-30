import style from "./Footer.module.css";
import FooterButton from "./FooterButton/FooterButton";
import footerButtons from "../../data/footerButtons";
import NavList from "../../../../shared/components/NavList/NavList";
import { navItems } from "../../data/navItems";

const Footer = () => {
  return (
    <div id="footer" className={style.footerContainer}>
      <h3 className={style.title}>TILEHAUS</h3>
      <NavList
        items={navItems}
        listStyle={style.list}
        itemStyle={style.listItem}
        linkStyle={style.listLink}
      />
      <div className={style.footerButtons}>
        {footerButtons.map((button, index) => (
          <FooterButton key={index} href={button.href}>
            {button.icon}
          </FooterButton>
        ))}
      </div>
      <p className={style.copyright}>
        © 2025 ShabunevichProduction Все права защищены
      </p>
    </div>
  );
};
export default Footer;
