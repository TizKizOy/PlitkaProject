import WhyChooseUsCards from "./WhyChooseUsCards/WhyChooseUsCards";
import style from "./WhyChooseUsSection.module.css";

const WhyChooseUsSection = () => {
  return (
    <div className={style.container}>
      <div className={style.textContainer}>
        <h3 className={style.title}>качество и мастерство</h3>
        <h2 className={style.subtitle}>ПОЧЕМУ НАС ВЫБИРАЮТ</h2>
      </div>
      <div>
        <WhyChooseUsCards />
      </div>
    </div>
  );
};

export default WhyChooseUsSection;
