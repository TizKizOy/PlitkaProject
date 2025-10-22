import { useState } from "react";
import axios from "axios";
import style from "./EditForm.module.css";
import services from "../../../../shared/data/servicesForm";

const api_url = import.meta.env.VITE_API_URL;

const EditForm = ({
  order,
  onClose,
  setOrders,
  isVisible,
  initialServiceName,
  fetchOrders,
}) => {
  const [formData, setFormData] = useState(() => {
    const initialServiceLabel = services.find(
      (s) => s.value === order.serviceName
    )?.label;
    return {
      ...order,
      serviceName: initialServiceName || order.serviceName,
    };
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async () => {
    try {
      const selectedService = services.find(
        (s) => s.label === formData.serviceName
      );
      const fkIdService = selectedService ? selectedService.value : "";

      const reqData = {
        pkIdOrder: formData.pkIdOrder,
        firstName: formData.firstName,
        phone: formData.phone,
        location: formData.location,
        comment: formData.comment,
        fkIdService: fkIdService,
        fkIdStatus: formData.status === "активно" ? "1" : "2",
      };

      const response = await axios.put(
        `${api_url}/v1/order/${order.pkIdOrder}`,
        reqData,
        { withCredentials: true }
      );

      setOrders((prev) =>
        prev.map((o) =>
          o.pkIdOrder === order.pkIdOrder ? { ...o, ...formData } : o
        )
      );

      await fetchOrders();

      onClose();
    } catch (error) {
      console.error("Ошибка при сохранении:", error);
    }
  };

  return (
    <div
      className={`${style.editForm} ${isVisible ? style.editForm_visible : ""}`}
    >
      <div className={style.editForm__header}>
        <h3>Редактирование</h3>
      </div>
      <div className={style.editForm__row}>
        <div className={style.editForm__rowItem}>
          <label>Заказчик</label>
          <input
            type="text"
            name="firstName"
            value={formData.firstName}
            onChange={handleChange}
          />
        </div>
        <div className={style.editForm__rowItem}>
          <label>Номер телефона</label>
          <input
            type="text"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
          />
        </div>
      </div>
      <div className={style.editForm__row}>
        <div className={style.editForm__rowItem}>
          <label>Услуга</label>
          <select
            className={style.editForm__rowItemSelect}
            name="serviceName"
            value={formData.serviceName || ""}
            onChange={handleChange}
          >
            {services.map((e) => (
              <option key={e.value} value={e.label}>
                {e.label}
              </option>
            ))}
          </select>
        </div>
        <div className={style.editForm__rowItem}>
          <label>Локация, км</label>
          <input
            type="text"
            name="location"
            value={formData.location}
            onChange={handleChange}
          />
        </div>
      </div>
      <div className={style.editForm__comment}>
        <label className={style.editForm__commentLabel}>Комментарий</label>
        <textarea
          name="comment"
          value={formData.comment || ""}
          onChange={handleChange}
        />
      </div>
      <div className={style.editForm__status}>
        <label className={style.editForm__statusLabel}>Статус</label>
        <div className={style.editForm__statusOptions}>
          <label className={style.editForm__statusOptionsLabel}>
            <input
              type="radio"
              name="status"
              value="активно"
              checked={formData.status === "активно"}
              onChange={handleChange}
            />
            Активно
          </label>
          <label>
            <input
              type="radio"
              name="status"
              value="закрыто"
              checked={formData.status === "закрыто"}
              onChange={handleChange}
            />
            Закрыто
          </label>
        </div>
      </div>
      <div className={style.editForm__buttons}>
        <button onClick={handleSubmit}>Сохранить</button>
        <button onClick={onClose}>Отмена</button>
      </div>
    </div>
  );
};

export default EditForm;
