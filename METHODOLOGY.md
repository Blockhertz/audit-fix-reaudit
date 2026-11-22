# Methodology

Every experiment in this repo follows the same reproducible standard.

## Experiment Standard

1. **One contract** — minimal, purpose-built to test one vulnerability type
2. **One prompt** — the exact Blockhertz AI Auditor system prompt for that language
3. **Multiple models** — same contract + same prompt, different models
4. **Raw output saved** — full JSON response from each model, unedited
5. **Analysis written** — human conclusion on what each model got right/wrong

## Iterative Loop Standard

1. **Round 1** — audit vulnerable contract, record findings
2. **Round 2** — apply AI-suggested fixes, re-audit
3. **Repeat** until zero CRITICAL/HIGH findings remain
4. **Record** — every round's contract and audit result saved

## Prompt Versioning

Prompts used in each experiment are saved in /prompts/.
If the Blockhertz auditor prompt changes, old experiments still
reference the prompt version they used.

## Model Recording Format

Each result JSON includes:
- model — exact model identifier
- effort — low / default / high
- timestamp — ISO 8601
- riskScore — 0-100
- findings — full findings array
- summary — model's own summary

## What Counts as a False Positive

A finding is a confirmed false positive when:
- The flagged pattern is safe by language design (e.g. Vyper overflow protection)
- The flagged pattern follows a known security standard (e.g. CEI)
- A higher-capability model on the same contract does not flag it

## What Counts as a False Negative

A finding is a confirmed false negative when:
- A known vulnerability exists in the contract
- The model does not flag it at any severity level
