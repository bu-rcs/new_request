---
description: Build troubleshooting context for this HPC request workspace
---

You are helping an HPC facilitator troubleshoot a researcher's issue in this request workspace. Build a working understanding of the request and record it.

Do the following, then stop and report:

1. **Structure** — Read `./CLAUDE.md` for the workspace layout.
2. **Problem & links** — Read the context files in `./context/` (`problem.md`, `links.md`, and any other notes the facilitator added) — but **not** the contents of `./context/logs/`, which is handled in step 4. This is the researcher's reported problem and the references to use; if `links.md` has URLs central to the problem, fetch the key ones.
3. **Scripts** — Inventory `./scripts/`: list the researcher's scripts, identify the language(s), the likely entry point(s), and how they are intended to be run. Note anything related to the reported problem.
4. **Logs** — Look in `./context/logs/` for facilitator-uploaded build/job logs. **Do not read whole logs — they can be huge** (multi-MB logs are common). For each file, sample the **head and tail** (e.g. `head -n 40 <log>` and `tail -n 40 <log>`) to identify what it is (build/compile/install vs. job/run output). For anything that looks like a **build/compile/install log you MUST triage it — never hand-`grep`/`cat` it.** Resolve the triage tool from this workspace's `.claude` symlink (which points into the tooling repo) so it works regardless of PATH:
   ```
   TRIAGE="$(dirname "$(readlink -f .claude)")/bin/triage_build_log.sh"
   "$TRIAGE" context/logs/<log>
   ```
   (or invoke the `triage-build-log` skill, which does the same). Record each log's classification + key finding. If the triage shows an **R package install failure**, recommend the **`r-install-debugger`** agent as the next step (don't run it yourself here) — **but gate that recommendation per the rule below**.
   - **Before recommending any compile-heavy reproduction** (e.g. the `r-install-debugger` agent), check whether `context/` actually contains the researcher's **exact command** and **verbatim error text / screenshot**. If either is missing, your top recommended next step is to *ask the facilitator for them* — not to reproduce. The actual command and error are cheap and frequently reveal a shallow root cause (wrong/missing package name, stale `00LOCK`, non-writeable library, wrong repo) that needs no compilation.
   - **Diagnose cheap → expensive.** Order: (1) read the exact command + error, (2) check for stale `00LOCK-*` dirs and library write-permission issues, (3) only then run the `r-install-debugger` agent to reproduce a genuine build/compile failure.
5. **Environment** — Read `./module_load.sh` (modules, `R_LIBS_USER`, toolset PATH, cache/config isolation) and, if present, `./env_setup/renv.lock` (reproduced R package versions). Note the version(s) and any packages relevant to the issue.
6. **Write the summary** — Create or update `./context/SUMMARY.md` with these sections:
   - **Problem** — concise statement of the issue (from `context/`).
   - **Environment** — module/version, key packages, how to activate (`source module_load.sh`).
   - **Scripts** — inventory with entry point(s) and run command(s).
   - **Logs** — for each log in `context/logs/`: what it is, and the triage classification / key finding (not the raw log).
   - **Links / References** — from `context/links.md`.
   - **Open questions** — what's unclear, split into: **(a) for the facilitator** — gaps you can likely fill from what you already know or can look up; and **(b) for the researcher** — information that isn't in the workspace and can't be inferred, phrased as ready-to-forward questions.

   Treat `SUMMARY.md` as a living document, but when new evidence *contradicts* an earlier finding, **replace** the stale section rather than appending a new one — don't leave the file holding both the old guess and the new fact. If several sections are now wrong, rewrite the whole file once instead of layering many partial edits.

7. **Clarify** — Before finalizing, judge whether the context is actually enough to troubleshoot. If key information is missing or ambiguous, **ask clarifying questions rather than guessing** — don't force a conclusion past a genuine gap. I (the facilitator) may not have realized what was worth including, so raise it. Sort each question by who can answer it:
   - **For me (the facilitator)** — things I likely know or can determine but didn't record (e.g. what "it doesn't work" concretely means, which node/queue/module, expected vs. actual behavior, whether a workaround was tried). Ask these directly.
   - **For the researcher** — information that isn't in the workspace and can't be inferred (e.g. the exact command they ran, verbatim error text or a screenshot, the R version they used, dataset/path locations). Say plainly that these probably need to go back to the researcher, and phrase each as a question I can forward as-is.

   Ask only where an answer would genuinely change the diagnosis; if the context is already sufficient, say so and move on. This is the same instinct behind the reproduction gate in step 4 (ask for the exact command + error before reproducing) — applied to the whole request.

Then give me a short (5–10 line) summary of the request, surface the clarifying questions from step 7 (grouped **for me** vs. **for the researcher**), and ask which part to investigate first. Do not start changing the researcher's scripts yet.
