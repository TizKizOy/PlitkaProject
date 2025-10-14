import { ClientPage } from "../component/pages/ClientPage/ClientPage";
import { AdminLogin } from "../component/pages/AdminLogin/AdminLogin";
import { AdminPanel } from "../component/pages/AdminPanel/AdminPanel";
import { ProtectedRoute } from "../component/auth/ProtectedRoute/ProtectedRoute";
import { NotFound } from "../component/pages/NotFound/NotFound";

export const routes = [
  {
    path: "/",
    element: <ClientPage />,
  },
  {
    path: "/admin/login",
    element: <AdminLogin />,
  },
  {
    path: "/admin/*",
    element: (
      <ProtectedRoute>
        <AdminPanel />
      </ProtectedRoute>
    ),
  },
  {
    path: "*",
    element: <NotFound />,
  },
];
