import { useEffect, useState } from 'react'
import { supabase } from '../../shared/api/supabaseClient'
type Game = { id:number; slug:string; title:string }
export default function Home(){
  const [games,setGames] = useState<Game[]>([])
  const [err,setErr] = useState<string|null>(null)
  useEffect(()=>{(async()=>{
    const { data, error } = await supabase.from('games').select('id,slug,title').eq('is_active', true).order('id',{ascending:true})
    if(error) setErr(error.message); else setGames(data ?? [])
  })()},[])
  return (
    <div style={{padding:24}}>
      <h1>Slots</h1>
      {err && <p style={{color:'#EF4444'}}>Error: {err}</p>}
      <ul>{games.map(g => <li key={g.id}>{g.slug} — {g.title}</li>)}</ul>
      {!err && games.length===0 && <p>Нет данных.</p>}
    </div>
  )
}
