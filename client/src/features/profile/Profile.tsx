import { useEffect, useState } from 'react';
import { supabase } from '../../shared/api/supabaseClient';

export default function Profile() {
  const [email, setEmail] = useState<string | null>(null);
  const [uid, setUid]     = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.auth.getUser();
      setUid(data.user?.id ?? null);
      setEmail(data.user?.email ?? null);
    })();
  }, []);

  async function signOut() {
    await supabase.auth.signOut();
    location.href = '/auth';
  }

  return (
    <div style={{maxWidth:640, margin:'40px auto', padding:20, border:'1px solid #3333', borderRadius:12}}>
      <h2>Профиль</h2>
      <div style={{marginTop:8}}>UID: {uid ?? '—'}</div>
      <div>Email: {email ?? '—'}</div>
      <div style={{marginTop:12}}>
        <button onClick={signOut}>Выйти</button>
      </div>
    </div>
  );
}
