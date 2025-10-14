import PortfolioCards from "./PortfolioCards/PortfolioCards";
import style from "./PortfolioSection.module.css";

const PortfolioSection = () => {
  return (
    <div className={style.container}>
      <div className={style.textContainer}>
        <h3 className={style.title}>качество и мастерство</h3>
        <h2 className={style.subtitle}>ПРИМЕРЫ НАШИХ РАБОТ</h2>
      </div>
      <div>
        <PortfolioCards />
      </div>
    </div>
  );
};

export default PortfolioSection;
