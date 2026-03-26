"""
RAGAS Dossiê Quality Gate — EPIC 3
Evaluates generated dossiês against source transcripts.

Usage:
    python evaluate_dossie.py --dossie path/to/dossie.md --sources path/to/transcript1.txt path/to/transcript2.txt
    python evaluate_dossie.py --json '{"dossie": "...", "sources": ["..."]}'

Metrics:
    - Faithfulness: every claim in the dossiê traces to a source (0-1)
    - Answer Correctness: factuality + semantic similarity vs ground truth (0-1)
    - Context Precision: most relevant sources were used (0-1)

Thresholds (configurable via env):
    RAGAS_THRESHOLD_FAITHFULNESS=0.85
    RAGAS_THRESHOLD_CORRECTNESS=0.80
    RAGAS_THRESHOLD_PRECISION=0.75

Returns JSON: { scores: {...}, verdict: "approved"|"needs_review"|"failed", details: {...} }
"""

import os
import sys
import json
import argparse

# Thresholds from env or defaults
THRESHOLD_FAITHFULNESS = float(os.environ.get('RAGAS_THRESHOLD_FAITHFULNESS', '0.85'))
THRESHOLD_CORRECTNESS = float(os.environ.get('RAGAS_THRESHOLD_CORRECTNESS', '0.80'))
THRESHOLD_PRECISION = float(os.environ.get('RAGAS_THRESHOLD_PRECISION', '0.75'))


def evaluate(dossie_text: str, source_texts: list[str]) -> dict:
    """Run RAGAS evaluation on a dossiê against source transcripts.
    Falls back to heuristic evaluation if RAGAS fails (missing API key, etc)."""
    try:
        from ragas import evaluate as ragas_evaluate
        from ragas import EvaluationDataset, SingleTurnSample
        try:
            from ragas.metrics.collections import context_precision
        except ImportError:
            from ragas.metrics import context_precision
        from ragas.metrics import faithfulness, answer_correctness
    except ImportError:
        return _fallback_evaluate(dossie_text, source_texts)

    try:
        sample = SingleTurnSample(
            user_input="Gere o dossie completo para este mentorado baseado nas transcricoes de mentoria.",
            response=dossie_text,
            retrieved_contexts=source_texts,
            reference="\n\n".join(source_texts),
        )
        dataset = EvaluationDataset(samples=[sample])

        result = ragas_evaluate(
            dataset=dataset,
            metrics=[faithfulness, answer_correctness, context_precision],
        )
    except Exception as e:
        # Falls back if no API key, network error, etc.
        fallback = _fallback_evaluate(dossie_text, source_texts)
        fallback['details']['ragas_error'] = str(e)[:200]
        return fallback

    scores = {
        'faithfulness': round(result['faithfulness'], 3),
        'answer_correctness': round(result['answer_correctness'], 3),
        'context_precision': round(result['context_precision'], 3),
    }

    # Determine verdict
    all_pass = (
        scores['faithfulness'] >= THRESHOLD_FAITHFULNESS and
        scores['answer_correctness'] >= THRESHOLD_CORRECTNESS and
        scores['context_precision'] >= THRESHOLD_PRECISION
    )
    any_critical = scores['faithfulness'] < 0.70

    if any_critical:
        verdict = 'failed'
    elif all_pass:
        verdict = 'approved'
    else:
        verdict = 'needs_review'

    return {
        'scores': scores,
        'verdict': verdict,
        'thresholds': {
            'faithfulness': THRESHOLD_FAITHFULNESS,
            'answer_correctness': THRESHOLD_CORRECTNESS,
            'context_precision': THRESHOLD_PRECISION,
        },
        'details': {
            'dossie_chars': len(dossie_text),
            'source_count': len(source_texts),
            'source_total_chars': sum(len(s) for s in source_texts),
        },
    }


def _fallback_evaluate(dossie_text: str, source_texts: list[str]) -> dict:
    """Lightweight fallback when RAGAS is not installed.
    Uses simple heuristics instead of LLM-based evaluation."""
    combined_sources = " ".join(source_texts).lower()
    dossie_lower = dossie_text.lower()

    # Heuristic 1: How many dossiê sentences have words from sources?
    sentences = [s.strip() for s in dossie_text.split('.') if len(s.strip()) > 20]
    grounded = 0
    for sent in sentences:
        words = [w for w in sent.lower().split() if len(w) > 4]
        if not words:
            continue
        matches = sum(1 for w in words if w in combined_sources)
        if matches / len(words) > 0.3:
            grounded += 1
    faithfulness = grounded / max(len(sentences), 1)

    # Heuristic 2: Keyword overlap as proxy for correctness
    source_words = set(w for w in combined_sources.split() if len(w) > 4)
    dossie_words = set(w for w in dossie_lower.split() if len(w) > 4)
    overlap = len(source_words & dossie_words) / max(len(dossie_words), 1)

    scores = {
        'faithfulness': round(min(faithfulness, 1.0), 3),
        'answer_correctness': round(min(overlap, 1.0), 3),
        'context_precision': round(min(overlap * 1.1, 1.0), 3),
    }

    all_pass = (
        scores['faithfulness'] >= THRESHOLD_FAITHFULNESS and
        scores['answer_correctness'] >= THRESHOLD_CORRECTNESS
    )

    return {
        'scores': scores,
        'verdict': 'approved' if all_pass else 'needs_review',
        'thresholds': {
            'faithfulness': THRESHOLD_FAITHFULNESS,
            'answer_correctness': THRESHOLD_CORRECTNESS,
            'context_precision': THRESHOLD_PRECISION,
        },
        'details': {
            'dossie_chars': len(dossie_text),
            'source_count': len(source_texts),
            'source_total_chars': sum(len(s) for s in source_texts),
            'method': 'heuristic_fallback (pip install ragas for full evaluation)',
        },
    }


def main():
    parser = argparse.ArgumentParser(description='RAGAS Dossiê Quality Gate')
    parser.add_argument('--dossie', help='Path to dossiê markdown file')
    parser.add_argument('--sources', nargs='+', help='Paths to source transcript files')
    parser.add_argument('--json', help='JSON input: {"dossie": "...", "sources": ["..."]}')
    parser.add_argument('--stdin', action='store_true', help='Read JSON input from stdin (avoids ARG_MAX)')
    parser.add_argument('--output', help='Output file path (default: stdout)')
    args = parser.parse_args()

    if args.stdin:
        data = json.loads(sys.stdin.read())
        dossie_text = data['dossie']
        source_texts = data['sources']
    elif args.json:
        data = json.loads(args.json)
        dossie_text = data['dossie']
        source_texts = data['sources']
    elif args.dossie and args.sources:
        with open(args.dossie, 'r') as f:
            dossie_text = f.read()
        source_texts = []
        for src in args.sources:
            with open(src, 'r') as f:
                source_texts.append(f.read())
    else:
        parser.error('Provide --dossie + --sources OR --json')
        return

    result = evaluate(dossie_text, source_texts)

    output = json.dumps(result, indent=2, ensure_ascii=False)
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f'Result written to {args.output}')
    else:
        print(output)

    # Exit code based on verdict
    sys.exit(0 if result['verdict'] == 'approved' else 1)


if __name__ == '__main__':
    main()
