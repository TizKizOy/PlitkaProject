import style from "./MessageAfterAppForm.module.css";

const MessageAfterAppForm = ({ onClick }) => {
  return (
    <div>
      <div className={style.overlay} onClick={() => onClick(false)} />
      <div className={style.formContainer}>
        <div style={{ position: "relative" }}>
          <button className={style.closeButton} onClick={() => onClick(false)}>
            &times;
          </button>
          <div className={style.formCard}>
            <h2>Спасибо, что выбрали нас!</h2>
            <p>
              Если у вас есть дополнительные вопросы или пожелания, пожалуйста,
              свяжитесь с нами по телефону +375447771122 или напишите на
              TileHaus@yandex.by
            </p>
            <h4>С уважением, TileHaus</h4>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MessageAfterAppForm;
