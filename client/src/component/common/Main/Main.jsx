import AboutSection from "./AboutSection/AboutSection";
import style from "./Main.module.css";
import ServicesSection from "./ServicesSection/ServicesSection";
import WhyChooseUsSection from "./WhyChooseUsSection/WhyChooseUsSection";
import PortfolioSection from "./PortfolioSection/PortfolioSection";

const Main = () => {
  return (
    <div className={style.content}>
      <AboutSection />
      <ServicesSection />
      <WhyChooseUsSection />
      <PortfolioSection />
    </div>
  );
};

export default Main;
