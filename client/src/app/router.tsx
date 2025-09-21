import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import Home from '../features/slots/Home'
import Profile from '../features/profile/Profile'
import Admin from '../features/admin/Admin'

function NotFound(){ return <div style={{padding:24}}>Page not found</div> }

export default function AppRouter(){
  return (
    <BrowserRouter>
      <nav style={{display:'flex',gap:16,padding:16}}>
        <Link to="/">Slots</Link>
        <Link to="/profile">Profile</Link>
        <Link to="/admin">Admin</Link>
      </nav>
      <Routes>
        <Route path="/" element={<Home/>} />
        <Route path="/profile" element={<Profile/>} />
        <Route path="/admin" element={<Admin/>} />
        <Route path="*" element={<NotFound/>} />
      </Routes>
    </BrowserRouter>
  )
}
