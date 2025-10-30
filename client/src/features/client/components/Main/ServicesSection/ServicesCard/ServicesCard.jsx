import style from "./ServicesCard.module.css";

const ServicesCard = ({ icon, title, text }) => {
  return (
    <div className={style.card}>
      <div className={style.icon}>{icon}</div>
      <h4 className={style.title}>{title}</h4>
      <ul className={style.list}>
        {text.map((item, index) => (
          <li key={index}>{item}</li>
        ))}
      </ul>
    </div>
  );
};

export default ServicesCard;
