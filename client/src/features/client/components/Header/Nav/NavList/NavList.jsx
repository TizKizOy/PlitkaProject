import style from "./NavList.module.css";

const NavList = ({ items, navStyle, listStyle, itemStyle, linkStyle }) => {
  return (
    <ul className={listStyle}>
      {items.map((item, index) => (
        <li key={index} className={itemStyle}>
          <a href="#" className={linkStyle}>
            {item}
          </a>
        </li>
      ))}
    </ul>
  );
};

export default NavList;
