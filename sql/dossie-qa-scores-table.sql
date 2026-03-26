-- RAGAS Quality Gate Scores — stores evaluation results per dossiê generation
-- EPIC 3: Automated quality assessment for AI-generated dossiês

CREATE TABLE IF NOT EXISTS dossie_qa_scores (
    id BIGSERIAL PRIMARY KEY,
    mentorado_id BIGINT REFERENCES mentorados(id) ON DELETE CASCADE,
    scores JSONB NOT NULL,          -- {faithfulness: 0.91, answer_correctness: 0.87, context_precision: 0.89}
    verdict TEXT NOT NULL CHECK (verdict IN ('approved', 'needs_review', 'failed', 'error')),
    dossie_chars INTEGER DEFAULT 0,
    source_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_qa_scores_mentorado ON dossie_qa_scores(mentorado_id);
CREATE INDEX IF NOT EXISTS idx_qa_scores_verdict ON dossie_qa_scores(verdict);
CREATE INDEX IF NOT EXISTS idx_qa_scores_created ON dossie_qa_scores(created_at DESC);

-- RLS
ALTER TABLE dossie_qa_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read dossie_qa_scores"
    ON dossie_qa_scores FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Service write dossie_qa_scores"
    ON dossie_qa_scores FOR INSERT
    TO service_role
    WITH CHECK (true);
