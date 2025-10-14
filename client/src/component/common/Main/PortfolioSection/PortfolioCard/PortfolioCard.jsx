import style from "./PortfolioCard.module.css";

const PortfolioCard = ({ img, title, text }) => {
  return (
    <div className={style.card}>
      <img src={img} alt={title} className={style.image} />
      <div className={style.textContainer}>
        <h3 className={style.title}>{title}</h3>
        <p className={style.subtitle}>{text}</p>
      </div>
    </div>
  );
};

export default PortfolioCard;
