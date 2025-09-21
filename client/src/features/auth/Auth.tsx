import { useState } from 'react'
import { supabase } from '../../shared/api/supabaseClient'

export default function Auth() {
  const [mode, setMode] = useState<'signin'|'signup'>('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [msg, setMsg] = useState<string|null>(null)
  const [err, setErr] = useState<string|null>(null)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setMsg(null); setErr(null)
    try {
      if (mode === 'signin') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
        setMsg('Signed in')
      } else {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        setMsg('Check your email to confirm (если включено подтверждение)')
      }
    } catch (e:any) { setErr(e.message) }
  }

  return (
    <div style={{padding:24, maxWidth:420}}>
      <h1>Auth</h1>
      <div style={{display:'flex', gap:8, margin:'12px 0'}}>
        <button onClick={()=>setMode('signin')} disabled={mode==='signin'}>Sign in</button>
        <button onClick={()=>setMode('signup')} disabled={mode==='signup'}>Sign up</button>
      </div>
      <form onSubmit={handleSubmit} style={{display:'grid', gap:8}}>
        <input type="email" placeholder="email" value={email} onChange={e=>setEmail(e.target.value)} required />
        <input type="password" placeholder="password" value={password} onChange={e=>setPassword(e.target.value)} required />
        <button type="submit">{mode==='signin'?'Sign in':'Sign up'}</button>
      </form>
      {msg && <p style={{color:'#22c55e'}}>{msg}</p>}
      {err && <p style={{color:'#ef4444'}}>Error: {err}</p>}
    </div>
  )
}
