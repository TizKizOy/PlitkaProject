import Nav from "./Nav/Nav";
import TopSection from "./TopSection/TopSection";
import style from "./Header.module.css";
import StatsSection from "./StatsSection/StatsSection";
import BackgroundLayout from "./BackgroundLayout/BackgroundLayout";

const Header = ({ onClick }) => {
  return (
    <BackgroundLayout>
      <div className={style.content}>
        <Nav />
        <TopSection onClick={onClick} />
        <StatsSection />
      </div>
    </BackgroundLayout>
  );
};

export default Header;
