import style from "./Input.module.css";

const Input = ({
  type = "text",
  placeholder,
  options,
  handleInputChange,
  data,
  name,
  error,
}) => {
  return (
    <div
      className={`${style.inputGroup} ${
        type === "select" ? style.selectGroup : ""
      }`}
    >
      {type === "select" ? (
        <select
          className={style.input}
          value={data[name] || ""}
          onChange={(e) => handleInputChange(e, name)}
          required
        >
          <option value="" disabled hidden>
            {placeholder}
          </option>
          {options.map((option, index) => (
            <option key={index} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      ) : (
        <input
          className={style.input}
          type={type}
          value={data[name] || ""}
          onChange={(e) => handleInputChange(e, name)}
          placeholder={placeholder}
        />
      )}
      {error && <span className={style.error}>{error}</span>}
    </div>
  );
};

export default Input;
