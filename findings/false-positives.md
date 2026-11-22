# False Positives Catalog

Confirmed cases where the AI auditor flagged safe code as vulnerable.

| # | Experiment | Model | Finding | Severity Assigned | Why It's Wrong |
|---|---|---|---|---|---|
| 001 | 001-vyper-cei-reentrancy | Haiku 3.5 | Reentrancy in withdraw | CRITICAL | Contract follows CEI — state decremented before send |
