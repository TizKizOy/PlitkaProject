import style from "./FilterSection.module.css";

const FilterSection = () => {
  return (
    <div className={style.filterBar}>
      <select className={style.filterBar__select}>
        <option>Текущая неделя</option>
        <option>Текуий месяц</option>
      </select>
      <input
        className={style.filterBar__input}
        type="text"
        placeholder="Поиск"
      />
      <button className={style.filterBar__button}>Найти</button>
    </div>
  );
};

export default FilterSection;
