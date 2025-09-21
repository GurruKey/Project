import { createRoot } from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Layout from './shared/ui/Layout';
import Home from './features/games/Home';
import Auth from './features/auth/Auth';
import Profile from './features/profile/Profile';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      { index: true, element: <Home /> },
      { path: 'auth', element: <Auth /> },
      { path: 'profile', element: <Profile /> },
    ],
  },
]);

createRoot(document.getElementById('root')!).render(<RouterProvider router={router} />);
