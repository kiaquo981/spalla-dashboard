import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";

interface Mentorado {
  id: number;
  nome: string;
}

interface Call {
  uuid: string;
  topic: string;
  date: string;
}

const Index = () => {
  const [mentorados, setMentorados] = useState<Mentorado[]>([]);
  const [calls, setCalls] = useState<Call[]>([]);
  const [mentoradoId, setMentoradoId] = useState("");
  const [callId, setCallId] = useState("");
  const [tipoCall, setTipoCall] = useState("acompanhamento");
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setLoadingData(true);
      try {
        const [mentoradosRes, callsRes] = await Promise.all([
          fetch("https://webhook.manager01.feynmanproject.com/webhook/Buscar_dados_call_mentorado", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({}),
          }),
          fetch("https://webhook.manager01.feynmanproject.com/webhook/gravacao_7d", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({}),
          }),
        ]);

        if (mentoradosRes.ok) {
          const data = await mentoradosRes.json();
          const list = Array.isArray(data) ? data : data.mentorados || data.data || [];
          setMentorados(list.map((m: any) => ({
            id: m.id ?? m.mentorado_id ?? m.ID,
            nome: m.nome ?? m.name ?? m.Nome ?? `Mentorado ${m.id}`,
          })).sort((a: Mentorado, b: Mentorado) => a.nome.localeCompare(b.nome, 'pt-BR')));
        } else {
          toast.error("Erro ao buscar mentorados.");
        }

        if (callsRes.ok) {
          const data = await callsRes.json();
          const list = Array.isArray(data) ? data : data.calls || data.data || [];
          const sorted = list.map((c: any) => ({
            uuid: c.uuid ?? c.zoom_uuid ?? c.UUID ?? c.id,
            topic: c.topic ?? c.Topic ?? c.titulo ?? c.name ?? `Call ${c.uuid}`,
            date: c.start_time ?? c.date ?? c.created_at ?? c.Start_time ?? c.Date ?? '',
          })).sort((a: Call, b: Call) => new Date(b.date).getTime() - new Date(a.date).getTime());
          setCalls(sorted);
        } else {
          toast.error("Erro ao buscar calls.");
        }
      } catch {
        toast.error("Falha ao carregar dados.");
      } finally {
        setLoadingData(false);
      }
    };
    fetchData();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const id = Number(mentoradoId);
    if (!mentoradoId || isNaN(id)) {
      toast.error("Mentorado ID deve ser um número válido.");
      return;
    }
    if (!callId.trim()) {
      toast.error("Call ID é obrigatório.");
      return;
    }

    setLoading(true);
    try {
      const payload: Record<string, unknown> = {
        mentorado_id: id,
        zoom_uuid: callId.trim(),
      };
      if (tipoCall) payload.tipo_call = tipoCall;

      const res = await fetch(
        "https://webhook.manager01.feynmanproject.com/webhook/processar-call-manual",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload),
        }
      );

      if (res.ok) {
        toast.success("Call processada com sucesso!");
        setMentoradoId("");
        setCallId("");
      } else {
        toast.error(`Erro: ${res.status} ${res.statusText}`);
      }
    } catch {
      toast.error("Falha na conexão com o webhook.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-start justify-center bg-background p-4 pt-12">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle className="text-center">Processar Call Manual</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label>Call (gravação)</Label>
              {loadingData ? (
                <p className="text-sm text-muted-foreground">Carregando...</p>
              ) : (
                <Select
                  value={callId}
                  onValueChange={setCallId}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione a call" />
                  </SelectTrigger>
                  <SelectContent position="popper" side="bottom" className="max-h-60">
                    {calls.map((c) => (
                      <SelectItem key={c.uuid} value={c.uuid}>
                        {c.topic}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
              {callId && (
                <div className="text-xs text-muted-foreground space-y-0.5">
                  <p>UUID: {callId}</p>
                  <p>Data: {calls.find(c => c.uuid === callId)?.date ? new Date(calls.find(c => c.uuid === callId)!.date).toLocaleString('pt-BR') : '—'}</p>
                </div>
              )}
            </div>

            <div className="space-y-2">
              <Label>Mentorado</Label>
              {loadingData ? (
                <p className="text-sm text-muted-foreground">Carregando...</p>
              ) : (
                <Select
                  value={mentoradoId}
                  onValueChange={setMentoradoId}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione o mentorado" />
                  </SelectTrigger>
                  <SelectContent position="popper" side="bottom">
                    {mentorados.map((m) => (
                      <SelectItem key={m.id} value={String(m.id)}>
                        {m.nome}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
              {mentoradoId && (
                <p className="text-xs text-muted-foreground">ID: {mentoradoId}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label>Tipo Call (opcional)</Label>
              <Select value={tipoCall} onValueChange={setTipoCall}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="acompanhamento">Acompanhamento</SelectItem>
                  <SelectItem value="onboarding">Onboarding</SelectItem>
                  <SelectItem value="estrategia">Estratégia</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Button type="submit" className="w-full" disabled={loading || loadingData}>
              {loading ? "Enviando..." : "Enviar"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default Index;
