import style from "./FooterButton.module.css";

const FooterButton = ({ children }) => {
  return (
    <a href="#" className={style.footButton}>
      {children}
    </a>
  );
};

export default FooterButton;
