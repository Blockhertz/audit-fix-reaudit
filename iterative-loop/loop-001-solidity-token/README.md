# Loop 001 — Solidity ERC-20 Token

## Overview

An iterative loop is a repeated audit → fix → re-audit cycle: the AI auditor
scans a contract, a developer applies the suggested fixes, and the contract is
re-audited to verify the fix did not introduce a new vulnerability. Rounds
repeat until no CRITICAL or HIGH findings remain. This loop tested the cycle
on a minimal Solidity ETH deposit/withdraw vault, with the specific goal of
observing whether the auditor could catch a second-order vulnerability
introduced by the first round of fixes.

## Contract

A minimal Solidity ETH vault (`pragma solidity ^0.8.20`). Users call
`deposit()` to send ETH into the contract and `withdraw(amount)` to pull it
back out; balances are tracked in a `mapping(address => uint256)`. Round 3
inherits from OpenZeppelin `Ownable` and `ReentrancyGuard`.

## Rounds

### Round 1 — Initial Audit
- Model used: Blockhertz AI Auditor (specific model not recorded in the audit transcript; repo README notes Claude Sonnet 4.6 was used across the experiment)
- Risk score: **95/100 (critical)**
- Key findings:
  - **[CRITICAL]** Reentrancy in `withdraw()` — state updated after external call
  - **[LOW]** No zero-amount check in `withdraw()`
  - **[LOW]** `getBalance()` returns the contract balance, not the caller's balance

### Round 2 — Fix v1 + Re-audit
- What was fixed: the reentrancy bug — in `FixedToken_v1.sol`, `balances[msg.sender] -= amount` was moved to execute BEFORE the external `call{value: amount}("")`, making `withdraw()` CEI-compliant. However, a new `drainFunds(address payable recipient)` function was added with no access control.
- Model used: Blockhertz AI Auditor (same as Round 1)
- Risk score: **95/100 (critical)**
- Remaining issues:
  - **[CRITICAL]** Unprotected `drainFunds()` — any caller can transfer the entire contract balance to any address (second-order vulnerability introduced during the fix)
  - **[MEDIUM]** No event emissions for deposit, withdraw, or drain
  - **[LOW]** `transfer()` used instead of `call()` in `drainFunds()`
  - **[LOW]** Missing zero-amount check in `withdraw()`
  - **[LOW]** No constructor / owner initialization

### Round 3 — Final Fix + Re-audit
- What was fixed: `FixedToken_v2.sol` inherits `Ownable` and `ReentrancyGuard`; `withdraw()` gains the `nonReentrant` modifier and a zero-amount check; `drainFunds()` gains `onlyOwner` and switches from `transfer()` to the checked low-level `call` pattern; `Deposited`, `Withdrawn`, and `Drained` events are emitted on every state change; the constructor sets the owner via `Ownable(msg.sender)`.
- Model used: Blockhertz AI Auditor (same as Round 1)
- Risk score: **35/100 (medium)**
- Outcome: **✓ All checks passed** — no CRITICAL or HIGH findings remain. The 8 remaining findings are 2 MEDIUM (defense-in-depth on `drainFunds()`: missing `nonReentrant`, missing zero-address check), 4 LOW (centralization risk, missing `receive()`, zero-value deposit, stale balance records after drain), and 2 GAS (custom errors, event ordering).

## Key Takeaway

This loop demonstrates why a single audit is not enough. The Round 1 fix
correctly removed the reentrancy bug, but introduced an unprotected
`drainFunds()` function that would have let anyone drain the contract — a
strictly more severe vulnerability than the one being patched. Without the
Round 2 re-audit, this regression would have shipped to mainnet. The loop
also shows that re-auditing surfaces diminishing-severity findings: the
Round 3 contract still has 8 findings, but they are all MEDIUM-or-lower
defense-in-depth suggestions, not fund-loss paths. The audit-fix-reaudit
methodology is specifically designed to catch the second-order class of
failure that caused Round 2 to still score 95/100.
