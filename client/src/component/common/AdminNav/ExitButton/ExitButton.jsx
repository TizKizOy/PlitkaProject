import style from "./ExitButton.module.css";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const api_url = "http://localhost:2020";

const ExitButton = () => {
  const navigate = useNavigate();

  const handlerExit = async (e) => {
    e.preventDefault();
    try {
      await axios.post(
        `${api_url}/admin/logout`,
        {},
        { withCredentials: true }
      );
      document.cookie =
        "connect.sid=; Max-Age=0; Path=/; Secure; SameSite=Strict";
      navigate("/admin/login");
    } catch (error) {
      setError("Не удалось выйти. Попробуйте позже.");
    }
  };

  return (
    <button onClick={handlerExit} className={style.exit}>
      Выйти
    </button>
  );
};

export default ExitButton;
