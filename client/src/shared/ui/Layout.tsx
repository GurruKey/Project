import { Link, Outlet } from 'react-router-dom';

export default function Layout() {
  return (
    <div>
      <nav style={{display:'flex',gap:16,padding:'12px 16px'}}>
        <Link to="/">Slots</Link>
        <Link to="/profile">Profile</Link>
        <Link to="/auth">Auth</Link>
      </nav>
      <main style={{padding:'16px'}}>
        <Outlet />
      </main>
    </div>
  );
}
