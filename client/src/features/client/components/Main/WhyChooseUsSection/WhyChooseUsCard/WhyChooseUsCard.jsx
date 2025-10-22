import style from "./WhyChooseUsCard.module.css";

const WhyChooseUsCard = ({ text, id }) => {
  return (
    <div className={style.card}>
      <h4 className={style.title}>{`0${id}`}</h4>
      <p className={style.subtitle}>{text}</p>
    </div>
  );
};

export default WhyChooseUsCard;
