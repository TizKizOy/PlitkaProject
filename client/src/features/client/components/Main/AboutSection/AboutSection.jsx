import style from "./AboutSection.module.css";

import AboutUsLeft from "../../../../../assets/image/AboutUsLeft.jpg";
import AboutUsCenter from "../../../../../assets/image/AboutUsCenter.jpg";
import AboutUsRight from "../../../../../assets/image/AboutUsRight.jpg";

const AboutSection = () => {
  return (
    <div id="aboutSection" className={style.container}>
      <div className={style.textContainer}>
        <h3 className={style.title}>о нас</h3>
        <h2 className={style.subtitle}>СОЗДАЁМ УЮТНЫЕ УЧАСТКИ ДЛЯ ОТДЫХА</h2>
        <p className={style.description}>
          За годы работы компания реализовала множество проектов, завоевала
          доверие клиентов
        </p>
      </div>
      <div className={style.imagesContainer}>
        <img
          className={style.image}
          src={AboutUsLeft}
          alt="Уютный дом слеваа"
        />
        <img
          className={style.image}
          src={AboutUsCenter}
          alt="Уютный дом по центру"
        />
        <img
          className={style.image}
          src={AboutUsRight}
          alt="Уютный дом справа"
        />
      </div>
    </div>
  );
};

export default AboutSection;
