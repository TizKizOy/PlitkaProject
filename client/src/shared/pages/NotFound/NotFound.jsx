import { Link } from "react-router-dom";
import style from "./NotFound.module.css";

export const NotFound = () => {
  return (
    <div className={style.wrap}>
      <h1 className={style.text}>Not Found</h1>
      <Link to="/">На главную</Link>
    </div>
  );
};
