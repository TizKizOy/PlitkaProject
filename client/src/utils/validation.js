export const validateForm = (data) => {
  let isValid = true;
  const newErrors = {
    firstName: "",
    phone: "",
    location: "",
    fkIdService: "",
  };

  if (!data.firstName.trim()) {
    newErrors.firstName = "Имя обязательно для заполнения";
    isValid = false;
  }

  if (!data.phone.trim()) {
    newErrors.phone = "Телефон обязателен для заполнения";
    isValid = false;
  } else if (!/^\+?\d{10,15}$/.test(data.phone)) {
    newErrors.phone = "Некорректный формат телефона";
    isValid = false;
  }

  if (!data.location.trim()) {
    newErrors.location = "Месторасположение обязательно для заполнения";
    isValid = false;
  } 

  if (!data.fkIdService) {
    newErrors.fkIdService = "Услуга обязательна для выбора";
    isValid = false;
  }

  return { isValid, errors: newErrors };
};
