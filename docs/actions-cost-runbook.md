# GitHub Actions cost runbook

How to use the weekly cost audit report and what to do when it flags a heavy workflow.

The audit is run by [`.github/workflows/actions-cost-audit.yml`](../.github/workflows/actions-cost-audit.yml), a sibling to [`private-actions-monitor.yml`](../.github/workflows/private-actions-monitor.yml). It runs every Sunday ~21:00 UTC and posts a tracking Issue with label `actions-cost-report`.

## Why this matters

The 2026-05-25 → 2026-05-28 account-level Actions blackout (see [`thinkyou0714/obsidian-vault#124`](https://github.com/thinkyou0714/obsidian-vault/issues/124)) happened because the account's spending limit was set lower than the actual monthly burn. Three things to reduce the chance of recurrence:

1. **Raise the spending limit** so normal activity has headroom — human task at https://github.com/settings/billing/spending_limit.
2. **Cut the actually-large burners** so you don't need as much headroom — that's what this audit + this runbook are for.
3. **Detect the next blackout fast** — the [`private-actions-monitor.yml`](../.github/workflows/private-actions-monitor.yml) sibling does that.

## Reading the report

Each audit Issue has two tables.

**Per-repo breakdown.** Totals over the last 30 days, sorted by compute. Use this to spot which repo is driving the bill.

**Top burners (15 most expensive workflows).** This is where the leverage is. Each row has a `heavy` flag (⚠️) using two thresholds:

- total compute > **3000 sec / 30d** (≈50 min/month) — meaningful absolute cost, OR
- avg per-run > **120 sec** with > **10 runs** — high per-run cost that happens often

Both are conservative — if a workflow trips either flag it's worth a look. Workflows below those thresholds aren't worth optimizing (the engineering time costs more than the saved minutes).

## Standard optimization patterns

These are the four patterns that cover ~90% of useful cuts. Apply the cheapest one that fits.

### 1. `paths-ignore` — skip runs that touch nothing relevant

When a code-quality workflow (CodeQL, Lighthouse, e2e tests, vault audit) fires on docs-only or generated-file PRs it burns minutes for zero signal. Add a `paths-ignore` list to the trigger.

```yaml
on:
  pull_request:
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - 'LICENSE'
      - '.editorconfig'
```

**Pitfalls:**
- Use `paths-ignore` (negative), not `paths` (positive). Positive lists are easy to under-specify — a new code dir gets forgotten and the workflow silently stops running.
- Never exclude `package.json`, `pnpm-lock.yaml`, `tsconfig.json`, `*.lockb`, `*.toml`, or workflow files themselves — those changes legitimately need full CI.
- `paths-ignore` only applies to the matched `on:` event. A workflow with `push:` and `pull_request:` needs the ignore list on both.

**Precedent in this account:** [`obsidian-vault#125`](https://github.com/thinkyou0714/obsidian-vault/pull/125) widened `vault-audit.yml`'s `paths-ignore` from 1 to 8 patterns.

### 2. `concurrency: cancel-in-progress: true` — drop superseded runs

On a rapid PR push (force-push, fixup, rebase), the older run is still chewing minutes. Cancel it:

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

**Why this is safe:** cancelled runs report as `cancelled`, not `failure`, so branch protection isn't tricked into letting un-tested code merge. The most recent push always runs to completion.

**Pitfall:** for workflows that publish/deploy (release tags, production deploys), set `cancel-in-progress: false` instead — you don't want a partial deploy half-cancelled.

### 3. Schedule cron reduction — daily → weekly for low-signal audits

A daily scheduled audit on a repo that rarely changes wastes 6 of 7 runs. Drop to weekly:

```yaml
on:
  schedule:
    - cron: '0 21 * * 0'   # Sundays only
```

Use this for low-signal scheduled jobs (broken-link check, dependency report). Keep daily for security scans and anything that needs prompt notification.

### 4. Conditional skip on early signal

When a workflow has a long-running step (Playwright, CodeQL autobuild, Docker push), guard it on a cheap pre-check:

```yaml
- id: changed
  uses: tj-actions/changed-files@v45
  with:
    files: |
      apps/web/**
      packages/ui/**

- name: Run e2e
  if: steps.changed.outputs.any_changed == 'true'
  run: pnpm e2e
```

This is more invasive than `paths-ignore` (changes the workflow logic) and only worth it when `paths-ignore` can't distinguish the cases.

## How to act on a flagged workflow

For each ⚠️ row in the report:

1. Open the workflow file (`<repo>/.github/workflows/<file>`).
2. Look at the `on:` block:
   - Triggers `push: branches: [main]` and `pull_request: branches: [main]` are the two most common high-volume triggers
   - If both are present, `paths-ignore` belongs on **both**
3. Decide which pattern fits:
   - Docs / generated reports touched by PRs → **`paths-ignore`** (pattern 1)
   - Rapid PR pushes stack runs → **`concurrency`** (pattern 2)
   - Low-signal scheduled job → **schedule cron reduction** (pattern 3)
   - Long-running step that often does nothing useful → **conditional skip** (pattern 4)
4. Open a small PR (one workflow file ideally; at most one repo's worth).

## Tuning the thresholds

The thresholds (3000 sec total, 120 sec avg + 10 runs) live in [`actions-cost-audit.yml`](../.github/workflows/actions-cost-audit.yml) as `HEAVY_TOTAL_SEC` / `HEAVY_AVG_SEC` / `HEAVY_MIN_RUNS`. Edit them if the report flags too much (raise) or too little (lower). They're conservative on purpose — most accounts that fit the spending-limit failure mode (this one) burn most of their compute in 2–4 workflows, and these thresholds surface those.

## Maintaining the REPOS list

The hardcoded `REPOS` arrays in [`actions-cost-audit.yml`](../.github/workflows/actions-cost-audit.yml) and [`private-actions-monitor.yml`](../.github/workflows/private-actions-monitor.yml) must match each other. The **single source of truth for which repos are in scope** is [`.github/monitor-config.json`](../.github/monitor-config.json) — when adding or removing a repo:

1. Edit `.github/monitor-config.json` first (this documents *which* repos are in scope and **why** any are excluded — see the `$repos_excluded` block)
2. Update the `REPOS` arrays in both workflows to match
3. Commit all three changes in the same PR

### Why some repos are excluded

The `$repos_excluded` block in [`.github/monitor-config.json`](../.github/monitor-config.json) lists every account-owned repo NOT in the monitored set with the reason:

- **Public repos** (e.g. `codex-toolkit`, `zenn-content`) have unlimited free Actions and can't be impacted by the spending limit — monitoring them is noise
- **Private repos with zero workflows** (e.g. `claude-lab-config` at time of writing) would 404 on the Actions API
- **Archived repos** don't run workflows

Recheck the excluded list periodically — a private repo gaining its first workflow needs to be added; a previously-monitored repo going public should be removed.

A future v3 could make both workflows `require()` the JSON config at runtime (via a checkout step) so the `REPOS` array literally lives in one place. Not done yet because the duplication is visible and infrequently edited.

## Limits of the audit

- **Pagination cap.** The audit reads up to 1000 runs per repo per 30 days (10 pages × 100). Repos pushing more than 1000 runs/month (none currently — think-you-lab tops out at ~1000) will have their tail truncated. The report will still flag the heavy workflows correctly.
- **No real billing API.** The audit uses `(updated_at - run_started_at)` as a proxy for billable minutes. This includes a small amount of queueing time (usually <5 sec) and excludes per-job minute rounding. For exact billable minutes, see the GitHub Settings → Billing → Plans and usage page.
- **`startup_failure` runs excluded.** These are tracked by [`private-actions-monitor.yml`](../.github/workflows/private-actions-monitor.yml), not here. A spike in `startup_failure` indicates a budget incident, not a cost problem.

## Related

- [`private-actions-monitor.yml`](../.github/workflows/private-actions-monitor.yml) — sibling that catches blackouts AFTER they start.
- [`thinkyou0714/obsidian-vault#124`](https://github.com/thinkyou0714/obsidian-vault/issues/124) — diagnosis of the 2026-05-25 blackout.
- [`thinkyou0714/obsidian-vault#125`](https://github.com/thinkyou0714/obsidian-vault/pull/125) — `vault-audit.yml` paths-ignore widening (precedent for pattern 1).
