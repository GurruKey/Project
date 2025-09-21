import { useEffect, useState } from 'react';
import { supabase } from '../../shared/api/supabaseClient';

type Game = { id: number; slug: string; title: string };

export default function Home() {
  const [games, setGames] = useState<Game[]>([]);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const { data, error } = await supabase
        .from('games')
        .select('id, slug, title')
        .order('id', { ascending: true })
        .limit(24);
      if (error) setErr(error.message);
      else setGames(data ?? []);
    })();
  }, []);

  if (err) return <div style={{maxWidth:960, margin:'24px auto'}}>Ошибка: {err}</div>;

  return (
    <div style={{maxWidth:960, margin:'24px auto'}}>
      <h2>Slots</h2>
      <ul>
        {games.map(g => (
          <li key={g.id}>{g.slug} — {g.title}</li>
        ))}
      </ul>
    </div>
  );
}
