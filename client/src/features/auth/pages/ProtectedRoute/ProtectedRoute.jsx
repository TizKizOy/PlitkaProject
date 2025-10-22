import axios from "axios";
import { Navigate } from "react-router-dom";
import { useState, useEffect } from "react";

const isAuthenticated = async () => {
  try {
    const response = await axios.get("http://localhost:2020/admin/protected", {
      withCredentials: true,
    });
    return !!response.data.admin;
  } catch (error) {
    return false;
  }
};

export const ProtectedRoute = ({ children }) => {
  const [isAuth, setIsAuth] = useState(null);

  useEffect(() => {
    const checkAuth = async () => {
      const authenticated = await isAuthenticated();
      setIsAuth(authenticated);
    };
    checkAuth();
  }, []);

  if (isAuth === null) {
    return <h1>Проверка авторизации...</h1>;
  }

  return isAuth ? children : <Navigate to="/admin/login" replace />;
};
