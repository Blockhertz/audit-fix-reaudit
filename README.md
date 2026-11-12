# audit-fix-reaudit

A controlled experiment demonstrating the iterative AI-assisted smart contract
audit loop — audit → fix → re-audit — using Claude Sonnet 4.5 and the
Blockhertz AI Smart Contract Auditor.

**Results: 95 → 95 → 35/100**

## Overview

Most developers audit their smart contract once, apply fixes, and deploy to
mainnet. This experiment tests whether that assumption is safe — and shows
it is not.

The iterative audit loop works as follows:

1. **Audit** — scan the contract for vulnerabilities
2. **Fix** — apply the suggested fixes
3. **Re-audit** — scan again to verify the fix did not introduce new vulnerabilities
4. **Repeat** — until the contract reaches a safe risk score

## Experiment

**Tool:** [Blockhertz AI Smart Contract Auditor](https://blockhertz.com/tools/ai-auditor)  
**Plugin:** [hardhat-blockhertz](https://www.npmjs.com/package/hardhat-blockhertz)  
**Model:** Claude Sonnet 4.5  
**Contract type:** ERC-20 style token with deposit/withdraw functionality

## Results

| Round | Contract | Score | Severity | Key Finding |
|-------|----------|-------|----------|-------------|
| 1 | VulnerableToken.sol | 95/100 | Critical | Reentrancy in withdraw() — state updated after external call |
| 2 | FixedToken_v1.sol | 95/100 | Critical | Second-order vulnerability: unprotected drainFunds() introduced during fix |
| 3 | FixedToken_v2.sol | 35/100 | Medium | No critical or high findings — ✓ All checks passed |

## Key Finding

The fix applied in Round 1 introduced a **second-order vulnerability** — a new
critical bug created by the fix process itself. The AI auditor caught it in
Round 2. Without re-auditing, this vulnerability would have been deployed to
mainnet undetected.

Round 3 applied all recommended fixes. The contract passed all critical and
high severity checks and was deemed safe to deploy.

## Observation

AI audit output shows some variance between runs — different run sessions
produced slightly different finding descriptions for the same contract, while
the risk score and core findings remained consistent. This suggests that
measuring variance across runs is itself a research question worth studying
at scale.

## Files

```
contracts/
  VulnerableToken.sol     # Round 1 — original vulnerable contract (95/100)
  FixedToken_v1.sol       # Round 2 — reentrancy fixed, second-order bug introduced (95/100)
  FixedToken_v2.sol       # Round 3 — all critical/high findings resolved (35/100)

audit-results/
  round-1.txt             # Full AI audit output — Round 1
  round-2.txt             # Full AI audit output — Round 2
  round-3.txt             # Full AI audit output — Round 3
```


## How to Run

```bash
# Clone the repo
git clone https://github.com/Blockhertz/audit-fix-reaudit
cd audit-fix-reaudit

# Install dependencies
npm install

# Add your Blockhertz API key
cp .env.example .env
# Edit .env and add your BLOCKHERTZ_API_KEY
# Get a free key at: https://blockhertz.com/tools/dashboard/api-keys

# Run audit on each contract
npx hardhat blockhertz-audit --contract contracts/VulnerableToken.sol --yes true
npx hardhat blockhertz-audit --contract contracts/FixedToken_v1.sol --yes true
npx hardhat blockhertz-audit --contract contracts/FixedToken_v2.sol --yes true
```

## Context

This experiment is part of a research proposal submitted to the
Anthropic Research Residency (November 2026), proposing to run this
iterative loop across hundreds of real contracts at scale — building
the defensive equivalent of Anthropic's SCONE-bench
("AI Agents Find $4.6M in Blockchain Smart Contract Exploits").

## Tools Used

- [Blockhertz AI Smart Contract Auditor](https://blockhertz.com/tools/ai-auditor)
- [hardhat-blockhertz](https://www.npmjs.com/package/hardhat-blockhertz) npm plugin
- Claude Sonnet 4.5 (via Blockhertz API)
- Solidity 0.8.20
- OpenZeppelin Contracts v5

## Author

Muhammad Asif — Founder, [Blockhertz](https://blockhertz.com)

## License

MIT
