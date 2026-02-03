// Supabase Edge Function: admin_delete_user
// مسیر پیشنهادی: supabase/functions/admin_delete_user/index.ts
//
// این فانکشن باید با Service Role Key اجرا شود (Edge Function env).
// از سمت کلاینت با: supabase.functions.invoke('admin_delete_user', body: { user_id })

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req) => {
  try {
    const { user_id } = await req.json();
    if (!user_id) return new Response(JSON.stringify({ error: 'user_id required' }), { status: 400 });

    const url = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(url, serviceKey);

    // TODO: چک سوپرادمین بودن فراخواننده (با JWT)
    // برای سادگی، پیشنهاد: از JWT داخل Authorization header استفاده کنید و role را از profiles بخوانید.

    const { error } = await supabase.auth.admin.deleteUser(user_id);
    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 400 });
    }

    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
