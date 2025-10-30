import style from "./FooterButton.module.css";

const FooterButton = ({ children, href }) => {
  return (
    <a href={href} className={style.footButton}>
      {children}
    </a>
  );
};

export default FooterButton;
