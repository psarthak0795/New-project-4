import { BrowserRouter, Routes, Route, NavLink, Navigate } from "react-router-dom";
import Login from "./pages/Login.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import EmployeeDetail from "./pages/EmployeeDetail.jsx";
import Timesheets from "./pages/Timesheets.jsx";
import Screenshots from "./pages/Screenshots.jsx";
import { logout } from "./api";

function isAuthenticated() {
  return !!localStorage.getItem("token");
}

function RequireAuth({ children }) {
  return isAuthenticated() ? children : <Navigate to="/login" replace />;
}

function Shell({ children }) {
  return (
    <div className="app-shell">
      <div className="sidebar">
        <h3 style={{ padding: "0 20px" }}>Org Tracker</h3>
        <NavLink to="/">Dashboard</NavLink>
        <NavLink to="/timesheets">Timesheets</NavLink>
        <NavLink to="/screenshots">Screenshots</NavLink>
        <a href="#" onClick={() => { logout(); window.location.href = "/login"; }}>
          Log out
        </a>
      </div>
      <div className="content">{children}</div>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <RequireAuth>
              <Shell><Dashboard /></Shell>
            </RequireAuth>
          }
        />
        <Route
          path="/employee/:id"
          element={
            <RequireAuth>
              <Shell><EmployeeDetail /></Shell>
            </RequireAuth>
          }
        />
        <Route
          path="/timesheets"
          element={
            <RequireAuth>
              <Shell><Timesheets /></Shell>
            </RequireAuth>
          }
        />
        <Route
          path="/screenshots"
          element={
            <RequireAuth>
              <Shell><Screenshots /></Shell>
            </RequireAuth>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}