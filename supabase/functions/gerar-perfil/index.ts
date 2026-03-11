import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const SYSTEM_PROMPT = `Você é um analista de perfil comportamental especializado. Analise as transcrições de calls de mentoria e gere um perfil comportamental detalhado do mentorado.

Você deve retornar um JSON com EXATAMENTE esta estrutura:

{
  "dimensoes": {
    "big_five": {
      "abertura": 0-100,
      "conscienciosidade": 0-100,
      "extroversao": 0-100,
      "amabilidade": 0-100,
      "neuroticismo": 0-100
    },
    "disc": {
      "dominancia": 0-100,
      "influencia": 0-100,
      "estabilidade": 0-100,
      "conformidade": 0-100
    },
    "quatro_zonas": {
      "genialidade": 0-100,
      "excelencia": 0-100,
      "competencia": 0-100,
      "incompetencia": 0-100
    },
    "modos_esquematicos": {
      "crianca_vulneravel": 0-100,
      "crianca_zangada": 0-100,
      "protetor_desligado": 0-100,
      "capitulador": 0-100,
      "adulto_saudavel": 0-100
    },
    "eneagrama": {
      "tipo_principal": 1-9,
      "asa": 1-9 ou null,
      "nivel_integracao": 0-100,
      "centro_dominante": "instintivo" ou "emocional" ou "mental"
    },
    "human_design": {
      "tipo": "Manifestor" ou "Gerador" ou "Gerador Manifestante" ou "Projetor" ou "Refletor",
      "estrategia": "texto",
      "autoridade": "texto",
      "perfil": "texto"
    }
  },
  "comunicacao": {
    "estilo_predominante": "texto curto",
    "pontos_fortes": ["item1", "item2", "item3"],
    "areas_desenvolvimento": ["item1", "item2", "item3"],
    "gatilhos_emocionais": ["item1", "item2", "item3"],
    "estrategias_recomendadas": ["item1", "item2", "item3"],
    "medos": ["item1", "item2"],
    "desejos": ["item1", "item2"],
    "valores": ["item1", "item2"],
    "dores": ["item1", "item2"]
  }
}

REGRAS:
- Scores de 0 a 100 (inteiros)
- Listas com 3-5 itens cada
- Infira os valores baseado nas evidências textuais das calls
- Se não houver evidência suficiente para alguma dimensão, use valores moderados (40-60) e indique na comunicacao
- Para Eneagrama e Human Design: infira o tipo mais provável, pode ser null se não houver evidência suficiente
- Retorne APENAS o JSON, sem texto antes ou depois
- O JSON deve ser válido e parseável`;

const MAX_CONTEXT_CHARS = 80000;

function buildCallContext(calls) {
  const parts = [];

  for (const call of calls) {
    const callParts = [];
    callParts.push("\n--- Call: " + (call.data_call || "sem data") + " ---");

    if (call.resumo) callParts.push("Resumo: " + call.resumo);
    if (call.principais_topicos)
      callParts.push("Tópicos: " + call.principais_topicos);
    if (call.decisoes_tomadas && call.decisoes_tomadas.length)
      callParts.push("Decisões: " + call.decisoes_tomadas.join("; "));
    if (call.gargalos && call.gargalos.length)
      callParts.push("Gargalos: " + call.gargalos.join("; "));
    if (call.feedbacks_consultora && call.feedbacks_consultora.length)
      callParts.push("Feedbacks: " + call.feedbacks_consultora.join("; "));
    if (call.proximos_passos && call.proximos_passos.length)
      callParts.push(
        "Próximos passos: " + call.proximos_passos.join("; ")
      );

    parts.push(callParts.join("\n"));

    // Verifica tamanho total
    if (parts.join("\n").length > MAX_CONTEXT_CHARS) {
      parts.pop();
      break;
    }
  }

  return parts.join("\n");
}

Deno.serve(async (req) => {
  // Preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { mentorado_id } = await req.json();

    if (!mentorado_id) {
      return new Response(
        JSON.stringify({ error: "mentorado_id é obrigatório" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Cliente Supabase admin
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Busca últimas 10 calls via view (junta calls_mentoria + analises_call)
    const { data: calls, error: callsError } = await supabase
      .from("vw_god_calls")
      .select(
        "data_call, resumo, principais_topicos, decisoes_tomadas, gargalos, feedbacks_consultora, proximos_passos"
      )
      .eq("mentorado_id", mentorado_id)
      .order("data_call", { ascending: false })
      .limit(10);

    if (callsError) throw callsError;

    if (!calls || calls.length === 0) {
      return new Response(
        JSON.stringify({
          error: "Nenhuma call encontrada para este mentorado",
        }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Monta texto de contexto a partir das calls
    const contexto = buildCallContext(calls);

    // Busca nome do mentorado para contexto
    const { data: mentorado } = await supabase
      .from("god_mentees")
      .select("name")
      .eq("id", mentorado_id)
      .maybeSingle();

    const nomeTexto = mentorado && mentorado.name
      ? "Mentorado: " + mentorado.name + "\n"
      : "";

    // Chama API do Claude
    const claudeResponse = await fetch(
      "https://api.anthropic.com/v1/messages",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-5-20250514",
          max_tokens: 4096,
          system: SYSTEM_PROMPT,
          messages: [
            {
              role: "user",
              content:
                nomeTexto +
                "Seguem as transcrições/resumos das últimas " +
                calls.length +
                " calls de mentoria deste mentorado. Analise e gere o perfil comportamental completo em JSON:\n\n" +
                contexto,
            },
          ],
        }),
      }
    );

    if (!claudeResponse.ok) {
      const errBody = await claudeResponse.text();
      throw new Error(
        "Claude API error " + claudeResponse.status + ": " + errBody
      );
    }

    const claudeData = await claudeResponse.json();
    const responseText =
      claudeData.content && claudeData.content[0]
        ? claudeData.content[0].text
        : "";

    // Parseia JSON da resposta (trata possíveis blocos de código markdown)
    let jsonStr = responseText.trim();
    if (jsonStr.startsWith("```")) {
      jsonStr = jsonStr
        .replace(/^```(?:json)?\n?/, "")
        .replace(/\n?```$/, "");
    }

    const perfil = JSON.parse(jsonStr);

    // Upsert na tabela perfil_comportamental
    const { error: upsertError } = await supabase
      .from("perfil_comportamental")
      .upsert(
        {
          mentorado_id: mentorado_id,
          dimensoes: perfil.dimensoes || {},
          comunicacao: perfil.comunicacao || {},
          notas_texto:
            "Gerado automaticamente via IA a partir de " +
            calls.length +
            " calls.",
          fonte: "ai_claude",
          fonte_detalhes:
            "claude-sonnet-4-5 | " +
            calls.length +
            " calls | " +
            new Date().toISOString(),
          created_by: "ai_auto",
        },
        { onConflict: "mentorado_id" }
      );

    if (upsertError) throw upsertError;

    return new Response(
      JSON.stringify({
        success: true,
        perfil: perfil,
        calls_analisadas: calls.length,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Erro em gerar-perfil:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Erro interno" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
