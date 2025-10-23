import BackgroundLayout from "../../../../shared/components/BackgroundLayout/BackgroundLayout";
import LoginForm from "../../forms/LoginForm/LoginForm";
import style from "./AdminLogin.module.css";

export const AdminLogin = () => {
  return (
    <div className={style.wrap}>
      <BackgroundLayout>
        <div className={style.content}>
          <LoginForm />
        </div>
      </BackgroundLayout>
    </div>
  );
};
