import React from "react";
import { useEffect, useState } from "react";
import "./ClientPage.module.css";
import ApplicationForm from "../../forms/ApplicationForm/ApplicationForm";
import Footer from "../../common/Footer/Footer";
import Header from "../../common/Header/Header";
import Main from "../../common/Main/Main";
import MessageAfterAppForm from "../../forms/MessageAfterAppForm/MessageAfterAppForm";
import { validateForm } from "../../../utils/validation";
import axios from "axios";

export const ClientPage = () => {
  const [appFormIsVisible, setAppFormIsVisible] = useState(false);
  const [messageIsVisible, setMessageIsVisible] = useState(false);
  const [data, setData] = useState({
    firstName: "",
    phone: "",
    location: "",
    fkIdService: "",
    fkIdStatus: "1",
  });
  const [errors, setErrors] = useState({
    firstName: "",
    phone: "",
    location: "",
    fkIdService: "",
    fkIdStatus: "1",
  });

  useEffect(() => {
    if (appFormIsVisible || messageIsVisible) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [appFormIsVisible, messageIsVisible]);

  const handleInputChange = (e, name) => {
    setData({ ...data, [name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const { isValid, errors: newErrors } = validateForm(data);
    setErrors(newErrors);
    if (isValid) {
      setAppFormIsVisible(false);
      console.log(JSON.stringify(data, null, 2));

      axios
        .post("http://localhost:2020/v1/order", data, {
          headers: {
            "Content-Type": "application/json",
          },
        })
        .then((response) => {
          console.log("Ответ сервера:", response.data);
          setData({
            firstName: "",
            phone: "",
            location: "",
            fkIdService: "",
          });
          setMessageIsVisible(true);
        })
        .catch((error) => {
          console.error("Ошибка:", error);
          alert("Произошла ошибка при отправке формы. Попробуйте позже.");
        });
    }
  };
  return (
    <>
      {appFormIsVisible && (
        <ApplicationForm
          handleInputChange={handleInputChange}
          data={data}
          errors={errors}
          handleSubmit={handleSubmit}
          onClick={setAppFormIsVisible}
        />
      )}
      {messageIsVisible && (
        <MessageAfterAppForm onClick={setMessageIsVisible} />
      )}
      <Header onClick={setAppFormIsVisible} />
      <Main />
      <Footer />
    </>
  );
};
