# audit-fix-reaudit

A living research repository studying AI-assisted smart contract security —
iterative audit-fix-reaudit loops, model comparison, and false positive/negative
cataloging across Solidity, Vyper, Rust, and Move.

Built alongside [Blockhertz AI Smart Contract Auditor](https://blockhertz.com/tools/ai-auditor).

This repository represents independent research into AI-assisted smart contract
security, conducted with consumer API access as a proof of concept. The methodology
is designed as a defensive counterpart to offensive benchmarks like Anthropic's
SCONE-bench — measuring not whether AI can find vulnerabilities, but whether it
can fix them iteratively and how reasoning depth affects false positive rates
across model tiers.

## Iterative Loop Results

| # | Contract | Language | Rounds | Final Score | Key Finding |
|---|---|---|---|---|---|
| 001 | VulnerableToken | Solidity | 3 | 35/100 | Second-order vulnerability introduced by fix — caught in Round 2 |

## Experiments

| # | Vulnerability | Language | Models | Result |
|---|---|---|---|---|
| 001 | CEI Reentrancy (false positive) | Vyper | Haiku 4.5 vs Opus 4.7 | Haiku: CRITICAL ❌ / Opus: PASS ✅ |
| 002 | Haiku Self-Correction via Forced Trace | Vyper | Haiku 4.5 (×2) + Haiku 5.5 | Haiku 4.5 self-corrected 75→45. Haiku 5.5 no FP (35). |

Full details → [`experiments/001-vyper-cei-reentrancy/`](experiments/001-vyper-cei-reentrancy/) · [`experiments/002-haiku-self-correction/`](experiments/002-haiku-self-correction/)

## Key Findings

**Iterative loop:** A fix applied in Round 1 introduced a second-order vulnerability.
The AI auditor caught it in Round 2. Without re-auditing, this would have deployed
to mainnet undetected.

**Model reasoning gap:** Haiku 4.5 flags CEI-correct Vyper contracts as CRITICAL
reentrancy. Opus 4.7 at low effort correctly identifies the CEI pattern (risk score
18/100 vs 75/100). This gap is not fixable by prompt engineering alone.

**Score variance:** Same contract (FixedToken_v2.sol), two runs, 20-point difference
(35/100 vs 15/100). Audit scores alone are not a reliable verification method.
The only trustworthy signal is whether an offensive agent can still extract funds.

## How to Run

```bash
git clone https://github.com/Blockhertz/audit-fix-reaudit
cd audit-fix-reaudit
npm install
cp .env.example .env
# Add your BLOCKHERTZ_API_KEY from blockhertz.com/tools/dashboard/api-keys

npx hardhat blockhertz-audit --contract contracts/VulnerableToken.sol --yes true
npx hardhat blockhertz-audit --contract contracts/FixedToken_v1.sol --yes true
npx hardhat blockhertz-audit --contract contracts/FixedToken_v2.sol --yes true
```

## Context

Anthropic's SCONE-bench proved AI can find and exploit smart contract
vulnerabilities (offensive side). This repo builds the defensive equivalent —
proving AI can fix them, using the same measurement methodology.

See [`scone-bench-context/`](scone-bench-context/) for full background.

## Tools Used

- [Blockhertz AI Smart Contract Auditor](https://blockhertz.com/tools/ai-auditor)
- [hardhat-blockhertz](https://www.npmjs.com/package/hardhat-blockhertz)
- Claude Sonnet 4.6 / Haiku 4.5 / Opus 4.7 (via Anthropic API)
- Solidity 0.8.20, Vyper 0.3.x
- OpenZeppelin Contracts v5

## Author

Muhammad Asif — Founder, [Blockhertz](https://blockhertz.com)

## License

MIT