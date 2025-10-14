import style from "./TopSection.module.css";

const TopSection = ({ onClick }) => {
  return (
    <section className={style.topSection}>
      <h1 className={style.title}>
        СОЗДАЙТЕ УЧАСТОК МЕЧТЫ ВМЕСТЕ С{" "}
        <span className={style.highlight}>TILEHAUS</span>
      </h1>
      <p className={style.subtitle}>
        Начните путь к дому вашей мечты уже сегодня
      </p>
      <button className={style.button} onClick={() => onClick(true)}>
        Оставить заявку
      </button>
    </section>
  );
};

export default TopSection;
