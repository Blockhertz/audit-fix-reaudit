# False Positives Catalog

Confirmed cases where the AI auditor flagged safe code as vulnerable.

| # | Experiment | Model | Finding | Severity Assigned | Why It's Wrong |
|---|---|---|---|---|---|
| 001 | 001-vyper-cei-reentrancy | Haiku 4.5 | Reentrancy in withdraw | CRITICAL | Contract follows CEI — state decremented before send |

## Models Tested Without False Positive

Reference for cross-model comparison on the same experiments.

| Experiment | Model | Risk Score | Reentrancy FP | Notable |
|---|---|---|---|---|
| 001-vyper-cei-reentrancy | GPT-6 | 20 | NO | Correctly identified CEI + `@nonreentrant`. Found real compilation bug (missing `@payable`) and 2300-gas stipend limitation that Claude models missed. |
