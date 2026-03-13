## Workflow: Observability

Goals
- Ensure systems are observable across metrics, logs, traces, and events.
- Enable fast, low‑MTTR incident resolution and proactive SLO tracking.

Guidance
- Define SLOs/SLIs for critical user journeys; alert on error budget burn rates.
- Metrics: RED/USE methods; standard labels (service, env, version, region).
- Logs: structured JSON, no secrets; consistent correlation IDs propagated end‑to‑end.
- Traces: sample intelligently; instrument with OpenTelemetry where possible.
- Dashboards: owner, purpose, and runbook links; avoid noisy, unactionable panels.
- Alerts: page only on actionable signals; include links to runbooks and dashboards.

Checklist
- OpenTelemetry enabled for services where feasible
- Golden dashboards exist for each service with owner set
- Alerts tied to SLOs and include runbook links
- Log PII scrubbing enabled; retention policy documented
- On-call rotation documented; escalation policy defined
