import style from "./NavList.module.css";

const NavList = ({
  items,
  listStyle,
  itemStyle,
  linkStyle,
  setIsOpenSideBar,
}) => {
  return (
    <ul className={listStyle}>
      {items.map((item, index) => (
        <li key={index} className={itemStyle}>
          <a href={item.href} onClick={setIsOpenSideBar} className={linkStyle}>
            {item.text}
          </a>
        </li>
      ))}
    </ul>
  );
};

export default NavList;
