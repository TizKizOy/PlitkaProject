import style from "./ServicesCards.module.css";
import serviceCardsData from "../../../../data/servicesCardsData";
import ServicesCard from "../ServicesCard/ServicesCard";

const ServicesCards = () => {
  return (
    <div className={style.cardsContainer}>
      {serviceCardsData.map((el) => (
        <ServicesCard
          key={el.id}
          icon={el.icon}
          title={el.title}
          text={el.text}
        />
      ))}
    </div>
  );
};

export default ServicesCards;
