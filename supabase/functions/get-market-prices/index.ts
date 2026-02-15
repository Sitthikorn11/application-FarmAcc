// ไฟล์: supabase/functions/get-market-prices/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// กำหนด Header เพื่ออนุญาตให้ใครก็ได้เรียกใช้ (CORS)
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // 2. ข้อมูลสินค้า
  const marketData = [
    {
      name: "ปุ๋ยยูเรีย 46-0-0 (ตรากระต่าย)",
      category: "fertilizer",
      price: 890,
      unit: "กระสอบ",
      image_url: "https://global.cpcdn.com/recipes/24d9c490906a5679/680x482cq70.jpg"
    },
    {
      name: "ปุ๋ยสูตร 15-15-15 (ตราเรือใบ)",
      category: "fertilizer",
      price: 1150,
      unit: "กระสอบ",
      image_url: "https://promotions.co.th/wp-content/uploads/2022/05/fertilizer-15-15-15-price.jpg"
    },
    {
      name: "เมล็ดพันธุ์ข้าวหอมมะลิ 105",
      category: "seed",
      price: 28,
      unit: "กก.",
      image_url: "https://cdn.shopify.com/s/files/1/0288/2420/7437/products/Jasmine_Rice_Seeds.jpg"
    },
    {
      name: "ไกลโฟเซต 48% (ยาฆ่าหญ้า)",
      category: "chemical",
      price: 680,
      unit: "แกลลอน",
      image_url: "https://sv1.picz.in.th/images/2021/09/24/CPrlqv.jpg"
    },
    {
      name: "ทุเรียนหมอนทอง (ราคารับซื้อ)",
      category: "other",
      price: 145,
      unit: "กก.",
      image_url: "https://www.sgethai.com/wp-content/uploads/2022/05/durian-monthong.jpg"
    }
  ]

  return new Response(
    JSON.stringify(marketData),
    { 
      headers: { ...corsHeaders, "Content-Type": "application/json" } 
    },
  )
})