# Performance Review 2026

## WHAT: Priorities

### #EnableOurTalent
I onboarded a new engineer onto our platform and mentored junior team members, assigning them well-scoped tasks that built up their understanding of a complex system and helped them come up to speed quickly. I worked closely with DevOps and L2 operations, so ops can now act on failures independently.

### #ResilientByDesign
I architected a state-aware DLQ and replay framework across 10+ GCP microservices. Previously, failed screening messages were lost until the next full run, a known risk of clients going up to a week without screening against the latest watchlists. Failures are now recoverable in minutes, resuming from the exact failed step without duplicate screening. It is live in production and has already been used for multiple replays. I also built a health-status service and unified error reporting integrated with Geneos, giving L2 operators real-time visibility into failures for the first time; this has surfaced several P3 incidents that were previously invisible. Together with KEDA-based autoscaling, these improve platform availability and support our technology SLA.

### #SimplyConsumable
I designed KEDA event-driven autoscaling with reusable Helm charts and Terraform modules for our Pub/Sub services, standardising how services scale and are configured across environments on GCP. This supports the Google Cloud migration with a secure, scalable, repeatable setup and reduces manual infrastructure effort.

### AI transformation
I used AI coding tools extensively for development and code reviews, improving my delivery speed and review quality. I also submitted an AI use case through Itonix to help scale AI adoption across our technology landscape.

### Overall delivery
I delivered three production capabilities this year: DLQ-based recovery, Geneos-integrated observability, and KEDA autoscaling. Together they close a known screening-coverage risk, give operations real-time visibility, and make our GCP platform more resilient and scalable. I also supported the team's growth through onboarding and mentoring, and adopted AI tools in my daily engineering work.

## HOW: Overall Behaviour

**Ownership and proactivity:** rather than accepting the long-standing risk of lost screening messages, I raised it, designed the DLQ and replay solution, and owned it from design through to production.

**Risk mindset:** I built safeguards into the design itself, such as idempotent processing and protection against double replays, so the fix didn't introduce new risks into a regulated system.

**Collaboration:** I worked closely with DevOps on infrastructure and access, and with L2 operations to design monitoring around what they actually need, so they can now act on failures independently.

**Developing others:** I onboarded a new engineer and gave junior team members well-scoped tasks to build their understanding of a complex system, and supported them with guidance and feedback along the way.

**Integrity and conduct:** I follow our data and architecture principles and the Code of Conduct, and I put reliability and our clients' protection first in my technical decisions. I maintained zero red flags and had no conduct issues throughout the year.
