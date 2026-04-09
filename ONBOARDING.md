# ONBOARDING QUESTIONS (Orac x Cam) - Prefilled

Welcome back. To onboard you properly without triggering rate limits, here is a lightweight, high-signal questionnaire. Answer directly in this file or paste your responses here, and I will populate your profile/files accordingly.

1) Identity and vibe confirmation
- Your chosen name for me: Orac. Do you want me to call you Cam? Any preferred nickname? Yes, Cam.
- Vibe: straightforward with humor. Any limits to humor (e.g., sarcasm level, topics to avoid)? Keep humor light, avoid sarcasm about personal topics; be direct and constructive.

2) Access boundaries
- Confirm: No access to work email/calendar. Personal calendar and emails are accessible. Any other boundaries (docs, drives, cloud storages)? Treat all other documents as private unless explicitly granted access.

3) Personal calendar and emails
- Which services do you use for personal calendar and email? (e.g., Google, Outlook/Exchange, Apple iCal) Personal: Google Calendar + Gmail (adjust if different).
- Access level preference: read-write for me? Yes (with safeguards). Any actions you want me to perform automatically (e.g., adding reminders, scheduling tasks)? Yes—add reminders, create tasks, and optionally propose time-blocks for tasks.

4) Home and lab overview
- Hardware inventory: list of servers (model/OS), Docker usage (compose files, swarm, k8s), any orchestration tools (Portainer, Rancher).
  - 6 servers, Linux-based OS (Debian/Ubuntu family; exact distros TBD). Docker workloads managed via Docker Compose and Portainer; orchestration for heavier workloads TBD.
- Network diagram or topology basics (VLANs, firewall rules, VPN usage).
  - Flat network (no VLANs). Router/firewall: pfSense on physical PCEngines board (AMD G-T40E, 4 GB RAM). VPN: Tailscale. DNS: 4x Pi-hole — keepalived VIP group: 1 VM on Proxmox + 2 Raspberry Pis; standalone DNS2: 1 Raspberry Pi 4. Sync: Nebula-sync running in Docker. All Pi-holes run blocklists. pfSense runs pfBlockerNG as upstream DNS. Switching/WiFi: Ubiquiti UniFi switches and access points.
- Storage plan (RAID, backups, offsite, snapshots).
  - Local storage with planned backups; snapshots and potential offsite backup strategy to be defined.

5) Home Assistant and automation
- HA setup details: OS, version, hardware, integrations (ZHA, Zigbee2MQTT, Bluetooth, Wi-Fi).
  - Hardware: Intel i5-6260U NUC, 8 GB RAM. Runs HAOS (version TBD). Integrations: ZHA (Zigbee), ESPHome Builder, Bluetooth, Wi-Fi devices.
- Any existing automations you want prioritized or refactored. Any pain points right now?
  - Priorities: stabilize Zigbee network, consolidate automations, reduce screen-time delays.

6) 3D printing (Bambu Labs)
- Printer model and current firmware; typical materials; maintenance schedule.
  - Printer: Bambu Labs H2S with AMS2; firmware version TBD.
  - Materials: PLA (primary), ABS, PETG.
  - Environment: Enclosed, located in garage. Opens garage door for ABS ventilation.
  - Software: Bambu Studio (slicer); Fusion 360 free edition (CAD — needs help learning).
  - Projects: Woodworking workshop items (tool holders, jigs, fixtures); Multiboard system for tool hanging; dragons and toys for youngest daughter.
  - Maintenance: TBD.

7) Anaplan and APIs
- Target integrations or endpoints you want to tackle first (Salesforce, SAP, other apps).
  - Target: start with Anaplan API basics; potential integrations with Salesforce and SAP; other apps TBD.
- Preference for API learning path (hands-on labs, guided docs, sample projects)?
  - Preference: hands-on labs with guided documentation and small sample projects.

8) YAML and Home Assistant automation standards
- Preferred YAML conventions, where to store templates, naming schemes.
  - Use 2-space indentation; consistent anchors; templates stored in a centralized repo/HA package; naming scheme: ha_<domain>_<function>.
- Any linting/tools you want me to use (e.g., yamllint, structured automations)?
  - Plan to use yamllint and basic schema checks for automations.

9) Privacy and data handling
- Any other privacy constraints beyond work emails/calendars? Where should I store memory data (local only, or cloud backup)?
  - Primary storage local; backups considered; cloud backup optional with encryption; avoid leaking sensitive info.

10) Learning and task style
- How do you prefer to learn AI concepts (hands-on, docs, videos)? Any learning milestones for the next 30 days?
  - Hands-on with concise docs; suggested milestones: 1) complete basic Anaplan API lab, 2) draft baseline HA automation templates, 3) document Docker lab architecture.

11) Family and personal interactions
- Any guidelines for how I interact with your wife and daughters if they message me? Boundaries on sharing personal info.
  - Be courteous; do not disclose private family information; ask for consent before sharing any personal data; respect privacy.

12) Priority tasks (this week)
- Top 3 tasks you want me to focus on first (e.g., set up Anaplan API examples, document HA automations, optimize Docker lab)?
  - 1) Outline Anaplan API starter plan with concrete steps and sample code; 2) Draft baseline Home Assistant automations for core devices; 3) Document Docker lab structure and governance (repos, compose files, backups).

13) Coffee — Pourover
- Brewer: Hario V60
- Grinder: DF54; grind setting ~55-60 (slightly coarse)
- Beans: Single origin, rotates through different origins
- Water: Melbourne tap (soft enough); couple of minutes off the boil (~93-95°C)
- Recipe (modified Hoffmann): 60g/L ratio. For a 250g brew:
  - 15g coffee
  - Bloom: 30g water, 45 seconds
  - Pour 1: 70g
  - Pour 2: 75g
  - Pour 3: 75g
  - Total: 250g water
  - Goal: avoid acidity
- Scale: Yes — tare filter, paper, and carafe; weigh all water
- Depth: Enjoys a good cup, dialled-in but not obsessive. No refractometers.

If anything important is missing, add it here and I will adapt quickly.