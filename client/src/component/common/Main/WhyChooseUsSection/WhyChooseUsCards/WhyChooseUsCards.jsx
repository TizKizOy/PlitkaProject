import style from "./WhyChooseUsCards.module.css";
import whyChooseUsData from "../../../../../data/whyChooseUsData";
import WhyChooseUsCard from "../WhyChooseUsCard/WhyChooseUsCard";

const WhyChooseUsCards = () => {
  return (
    <div className={style.cardsContainer}>
      {whyChooseUsData.map((el) => (
        <WhyChooseUsCard key={el.id} id={el.id} text={el.text} />
      ))}
    </div>
  );
};

export default WhyChooseUsCards;
