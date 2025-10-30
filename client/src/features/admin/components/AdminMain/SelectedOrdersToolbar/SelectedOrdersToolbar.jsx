import style from "./SelectedOrdersToolbar.module.css";
import { CiLock, CiUnlock, CiTrash } from "react-icons/ci";
import { FiX } from "react-icons/fi";

const SelectedOrdersToolbar = ({
  selectedOrdersCount,
  onSetStatusClosed,
  onSetStatusActive,
  onDeleteOrder,
  onClose,
  isVisible,
}) => {
  return (
    <div
      className={`${style.toolbar} ${isVisible ? style.toolbar_visible : ""}`}
    >
      <div className={style.selectedCount}>
        <FiX className={style.closeIcon} onClick={onClose} />
        <span>
          {selectedOrdersCount} заявк{selectedOrdersCount === 1 ? "а" : "и"}
        </span>
      </div>
      <div className={style.buttons}>
        <button className={style.button} onClick={onSetStatusClosed}>
          <CiUnlock />
        </button>
        <button className={style.button} onClick={onSetStatusActive}>
          <CiLock />
        </button>
        <button className={style.button} onClick={onDeleteOrder}>
          <CiTrash />
        </button>
      </div>
    </div>
  );
};

export default SelectedOrdersToolbar;
