import { useState } from 'react';
import { supabase } from '../../shared/api/supabaseClient';

export default function Auth() {
  const [mode, setMode] = useState<'in'|'up'>('in');
  const [email, setEmail] = useState('');
  const [pass, setPass] = useState('');
  const [msg, setMsg]   = useState('');

  async function submit(e: React.FormEvent) {
    e.preventDefault(); setMsg('');
    const fn = mode === 'in'
      ? supabase.auth.signInWithPassword({ email, password: pass })
      : supabase.auth.signUp({ email, password: pass });
    const { error } = await fn;
    setMsg(error ? error.message : (mode === 'in' ? 'Вход выполнен' : 'Аккаунт создан — войдите'));
    if (!error && mode === 'up') setMode('in');
  }

  async function signOut() {
    await supabase.auth.signOut();
    setMsg('Вы вышли.');
  }

  return (
    <div style={{maxWidth:420, margin:'40px auto', padding:20, border:'1px solid #3333', borderRadius:12}}>
      <h2 style={{marginBottom:12}}>Авторизация</h2>
      <form onSubmit={submit} style={{display:'grid', gap:10}}>
        <input placeholder="Email" type="email" value={email} onChange={e=>setEmail(e.target.value)} required />
        <input placeholder="Пароль" type="password" value={pass} onChange={e=>setPass(e.target.value)} required />
        <button type="submit">{mode==='in' ? 'Войти' : 'Создать аккаунт'}</button>
      </form>

      <div style={{marginTop:10, fontSize:12, opacity:.8}}>
        {mode==='in' ? 'Нет аккаунта?' : 'Уже есть аккаунт?'}{' '}
        <button onClick={()=>setMode(mode==='in'?'up':'in')}
                style={{border:'none', background:'transparent', textDecoration:'underline', cursor:'pointer'}}>
          {mode==='in' ? 'Создать' : 'Войти'}
        </button>
      </div>

      <div style={{marginTop:12}}>
        <button onClick={signOut}>Выйти</button>
      </div>

      {msg && <div style={{marginTop:12}}>{msg}</div>}
    </div>
  );
}
