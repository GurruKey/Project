import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL as string
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string

// Не хранить секреты тут! Только VITE_* переменные.
export const supabase = createClient(url, anonKey)

// Пример (позже):
// const { data, error } = await supabase.from('games').select('*')
// debug only
// @ts-ignore
window.sb = supabase;