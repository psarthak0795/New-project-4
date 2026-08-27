import { useEffect, useState } from "react";
import { listUsers, listTimeEntries } from "../api";

export default function Dashboard() {
  const [users, setUsers] = useState([]);
  const [activeByUser, setActiveByUser] = useState({});

  useEffect(() => {
    listUsers().then(async (u) => {
      setUsers(u);
      const entries = await listTimeEntries();
      const active = {};
      entries.forEach((e) => {
        if (e.status === "active") active[e.user_id] = e;
      });
      setActiveByUser(active);
    });
  }, []);

  return (
    <div>
      <h1>Team Overview</h1>
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Status</th>
              <th>Current session IP</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => {
              const active = activeByUser[u.id];
              return (
                <tr key={u.id}>
                  <td>{u.name}</td>
                  <td>{u.email}</td>
                  <td>{active ? "🟢 Tracking" : "⚪ Idle"}</td>
                  <td>{active ? active.start_ip_address : "-"}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
