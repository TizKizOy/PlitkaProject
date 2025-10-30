import ServicesCards from "./ServicesCards/ServicesCards";
import style from "./ServicesSection.module.css";

const ServicesSection = () => {
  return (
    <>
      <div id="servicesSection" className={style.container}>
        <h3 className={style.title}>наши услуги</h3>
        <h2 className={style.subtitle}>МЫ ПРЕДЛАГАЕМ ЛУЧШИЕ РЕШЕНИЯ</h2>
      </div>
      <div>
        <ServicesCards />
      </div>
    </>
  );
};

export default ServicesSection;
