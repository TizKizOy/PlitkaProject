import style from "./StatsSection.module.css";

const StatsSection = () => {
  return (
    <div className={style.statsContainer}>
      <div className={style.statItem}>
        <h2 className={style.statNumber}>10 ЛЕТ </h2>
        <h2 className={style.statDescription}>НА РЫНКЕ</h2>
      </div>
      <div className={style.statItem}>
        <h2 className={style.statNumber}>1000+ </h2>
        <h2 className={style.statDescription}>ДОВОЛЬНЫХ КЛИЕНТОВ</h2>
      </div>
    </div>
  );
};

export default StatsSection;
