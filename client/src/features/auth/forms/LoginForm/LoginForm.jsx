import { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import style from "./LoginForm.module.css";
import { FiEye, FiEyeOff } from "react-icons/fi";
import { API_URL } from "../../../../shared/utils/apiConfig";

const LoginForm = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [data, setData] = useState({ login: "", password: "" });
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  const handlerInputChange = (e, name) => {
    setData({ ...data, [name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    axios
      .post(`${API_URL}/admin/login`, data, {
        headers: {
          "Content-Type": "application/json",
        },
        withCredentials: true,
      })
      .then(() => {
        navigate("/admin");
      })
      .catch((error) => {
        console.error("Ошибка:", error.response?.data?.error || error.message);
        setError(error.response?.data?.error || "Ошибка авторизации");
      });
  };

  return (
    <form className={style.form} onSubmit={handleSubmit}>
      <h1 className={style.form__title}>
        TileHaus
        <br />
        Системный Вход
      </h1>
      {error && <p className={style.error}>{error}</p>}
      <div className={style.form__group}>
        <input
          className={style.form__input}
          onChange={(e) => handlerInputChange(e, "login")}
          placeholder="Введите логин"
          type="text"
          id="login"
          name="login"
          value={data.login}
        />
      </div>
      <div className={style.form__group}>
        <div className={style.passwordContainer}>
          <input
            className={style.form__input}
            onChange={(e) => handlerInputChange(e, "password")}
            placeholder="Введите пароль"
            type={showPassword ? "text" : "password"}
            id="password"
            name="password"
            value={data.password}
          />
          <span className={style.eyeIcon} onClick={togglePasswordVisibility}>
            {showPassword ? (
              <FiEyeOff color="white" size={20} />
            ) : (
              <FiEye color="white" size={20} />
            )}
          </span>
        </div>
      </div>
      <button className={style.form__button} type="submit">
        Войти
      </button>
    </form>
  );
};

export default LoginForm;
