import style from "./FilterSection.module.css";

const FilterSection = ({
  filters,
  onStatusChange,
  onDateRangeChange,
  onSearchChange,
}) => {
  return (
    <div className={style.filterBar}>
      <select
        className={style.filterBar__select}
        onChange={onStatusChange}
        value={
          filters.status === "активно"
            ? "Активные заявки"
            : filters.status === "закрыто"
            ? "Закрытые заявки"
            : "Все"
        }
      >
        <option value="Активные заявки">Активные заявки</option>
        <option value="Закрытые заявки">Закрытые заявки</option>
        <option value="Все">Все</option>
      </select>
      <select
        className={style.filterBar__select}
        onChange={onDateRangeChange}
        value={filters.dateRange}
      >
        <option value="Текущая неделя">Текущая неделя</option>
        <option value="Текущий месяц">Текущий месяц</option>
        <option value="Все">Все</option>
      </select>
      <input
        className={style.filterBar__input}
        type="text"
        placeholder="Поиск"
        value={filters.searchText}
        onChange={onSearchChange}
      />
    </div>
  );
};

export default FilterSection;
