
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GOCARDLESS_API_URL = "https://api-sandbox.gocardless.com"; // Use sandbox for testing
const GOCARDLESS_ACCESS_TOKEN = Deno.env.get("GOCARDLESS_ACCESS_TOKEN");

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const body = await req.json();
    console.log("Received request body:", body);

    const { amount, currency, description, user_id } = body;

    const response = await fetch(`${GOCARDLESS_API_URL}/billing_requests`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${GOCARDLESS_ACCESS_TOKEN}`,
        "GoCardless-Version": "2015-07-06",
      },
      body: JSON.stringify({
        billing_requests: {
          payment_request: {
            amount: amount,
            currency: currency,
            description: description,
          },
          mandate_request: {
            scheme: "bacs",
            redirect_uri: "propertystalker://payment-success",
          },
          metadata: {
            user_id: user_id,
          },
        },
      }),
    });

    const data = await response.json();

    // Log the raw successful response from GoCardless
    console.log("GoCardless API Success:", JSON.stringify(data, null, 2));

    if (!response.ok) {
      console.error("GoCardless API Error:", data);
      throw new Error(data.error?.message || "GoCardless API error");
    }

    // IMPORTANT CHANGE: Return the whole `data` object, not just `data.billing_requests`
    return new Response(JSON.stringify(data), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Catch block error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
