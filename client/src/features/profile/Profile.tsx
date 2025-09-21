import { useEffect, useState } from 'react'
import { supabase } from '../../shared/api/supabaseClient'

export default function Profile(){
  const [email, setEmail] = useState<string | null>(null)

  useEffect(() => {
    let mounted = true
    supabase.auth.getUser().then(({ data }) => {
      if (!mounted) return
      setEmail(data.user?.email ?? null)
    })
    const { data: sub } = supabase.auth.onAuthStateChange(async () => {
      const { data } = await supabase.auth.getUser()
      setEmail(data.user?.email ?? null)
    })
    return () => { mounted = false; sub.subscription.unsubscribe() }
  }, [])

  async function signOut(){ await supabase.auth.signOut() }

  return (
    <div style={{padding:24}}>
      <h1>Profile</h1>
      {email ? (
        <>
          <p>Signed in as <b>{email}</b></p>
          <button onClick={signOut}>Sign out</button>
        </>
      ) : (
        <p>Not signed in. Перейди на вкладку <code>Auth</code>.</p>
      )}
    </div>
  )
}
