import style from "./PortfolioCards.module.css";
import PortfolioData from "../../../../data/portfolioData";
import PortfolioCard from "../PortfolioCard/PortfolioCard";

const PortfolioCards = () => {
  return (
    <div className={style.cardsContainer}>
      {PortfolioData.map((el) => (
        <PortfolioCard
          key={el.id}
          img={el.image}
          title={el.title}
          text={el.text}
        />
      ))}
    </div>
  );
};

export default PortfolioCards;
