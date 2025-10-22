import style from "./BackgroundLayout.module.css";

const BackgroundLayout = ({ children }) => {
  return (
    <div className={style.backImage}>
      <div className={style.overlay}></div>
      {children}
    </div>
  );
};

export default BackgroundLayout;
