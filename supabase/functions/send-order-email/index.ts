import { createClient } from 'jsr:@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { record, old_record } = await req.json()

    if (!record || record.status === old_record?.status) {
      return new Response('no relevant change', { status: 200 })
    }
    if (!['approved', 'rejected'].includes(record.status)) {
      return new Response('not a status we email for', { status: 200 })
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: userData, error: userError } =
      await supabaseAdmin.auth.admin.getUserById(record.customer_id)

    if (userError || !userData?.user?.email) {
      return new Response('no email found for customer', { status: 200 })
    }

    const email = userData.user.email
    const subject = record.status === 'approved'
      ? 'Your Dream Pharmacy order was approved'
      : 'Your Dream Pharmacy order was rejected'
    const body = record.status === 'approved'
      ? 'Good news! Your order has been approved and is being processed.'
      : `We're sorry, your order was rejected.${record.rejection_reason ? ' Reason: ' + record.rejection_reason : ''}`

    const resendRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Dream Pharmacy <onboarding@resend.dev>',
        to: email,
        subject,
        text: body,
      }),
    })

    const resendResult = await resendRes.text()
    return new Response(resendResult, { status: resendRes.status })
  } catch (e) {
    return new Response(String(e), { status: 500 })
  }
})
