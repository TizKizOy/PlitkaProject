import style from "./ApplicationForm.module.css";
import Input from "./Input/Input";
import services from "../../../data/servicesForm";

const ApplicationForm = ({
  onClick,
  handleSubmit,
  handleInputChange,
  data,
  errors,
}) => {
  return (
    <>
      <div className={style.overlay} onClick={() => onClick(false)} />
      <div className={style.formContainer}>
        <div style={{ position: "relative" }}>
          <button className={style.closeButton} onClick={() => onClick(false)}>
            &times;
          </button>
          <div className={style.formCard}>
            <h2>Оставить заявку</h2>
            <p>Обработаем Вашу заявку в самое ближайшее время</p>
            <form className={style.form} onSubmit={handleSubmit}>
              <Input
                name="firstName"
                placeholder="Имя"
                data={data}
                handleInputChange={handleInputChange}
                error={errors.firstName}
              />
              <Input
                name="fkIdService"
                placeholder="Выберите услугу"
                type="select"
                options={services}
                data={data}
                handleInputChange={handleInputChange}
                error={errors.fkIdService}
              />
              <Input
                name="location"
                placeholder="Местонахождение объекта"
                data={data}
                handleInputChange={handleInputChange}
                error={errors.location}
              />
              <Input
                name="phone"
                placeholder="Номер телефона"
                data={data}
                handleInputChange={handleInputChange}
                error={errors.phone}
              />
              <button className={style.submitButton} type="submit">
                Отправить
              </button>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default ApplicationForm;
