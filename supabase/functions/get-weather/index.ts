// ไฟล์: supabase/functions/get-weather/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. จัดการ CORS (เพื่อให้ Browser/มือถือ ดึงข้อมูลได้ไม่ติดแดง)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. รับค่าพิกัดจากแอป (ถ้าไม่ส่งมา ให้ใช้พิกัด 'อนุสาวรีย์ชัยฯ' เป็นค่าเริ่มต้น)
    // ใช้ try-catch ดักกรณี body ว่าง
    let body = {}
    try { body = await req.json() } catch {}
    
    let { lat, long } = body as { lat?: number, long?: number }
    
    // Default: Bangkok
    if (!lat) lat = 13.7563
    if (!long) long = 100.5018

    // 3. ดึงข้อมูลจริงจาก Open-Meteo (ขอ: อุณหภูมิ, ความชื้น, ฝน, รหัสอากาศ)
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${long}&current=temperature_2m,relative_humidity_2m,precipitation,weather_code&timezone=auto`
    
    const weatherRes = await fetch(url)
    const weatherData = await weatherRes.json()
    const current = weatherData.current

    // 4. แปลรหัสสภาพอากาศ (WMO Code) เป็นภาษาไทย
    const condition = decodeWeatherCode(current.weather_code)

    // 5. ส่ง JSON กลับไปให้แอป
    const result = {
      location: { lat, long },
      temperature: current.temperature_2m, // องศา C
      humidity: current.relative_humidity_2m, // %
      rain: current.precipitation, // มม.
      condition_text: condition.text, // ข้อความไทย
      icon: condition.icon, // ชื่อไอคอน (เอาไป map กับ Icon ใน Flutter ได้)
      updated_at: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    )
  }
})

function decodeWeatherCode(code: number) {

  if (code === 0) return { text: "ฟ้าโปร่ง แดดจัด", icon: "sunny" }
  if (code >= 1 && code <= 3) return { text: "มีเมฆบางส่วน", icon: "cloudy" }
  if (code === 45 || code === 48) return { text: "มีหมอกลง", icon: "fog" }
  if (code >= 51 && code <= 67) return { text: "ฝนตกปรอยๆ", icon: "rainy_light" }
  if (code >= 80 && code <= 99) return { text: "ฝนตกหนัก ระวังน้ำท่วม", icon: "thunderstorm" }
  return { text: "ฝนตก", icon: "rainy" } 
}