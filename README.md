# LetsWatch

<div align="center">

# LetsWatch Media Server

**A high-performance independent media server with Emby-compatible APIs.**

> LetsWatch is **not Emby**.  
> LetsWatch is an independent media server that provides compatibility with selected Emby API behavior.

<br />

![Status](https://img.shields.io/badge/status-active-22c55e?style=for-the-badge)
![Issue Tracker](https://img.shields.io/badge/repository-issue%20tracker-blue?style=for-the-badge)
![Go](https://img.shields.io/badge/built%20with-Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/storage-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Emby API](https://img.shields.io/badge/Emby%20API-compatible-52B54B?style=for-the-badge)
![License](https://img.shields.io/badge/license-proprietary-lightgrey?style=for-the-badge)

</div>

---

## Overview

**LetsWatch** is a high-performance media server designed for media browsing, search, metadata access, direct playback, user state tracking, and local media library management.

It is built as an independent server implementation and provides compatibility with selected **Emby API** behavior to support compatible clients and workflows.

This repository is used as the public issue tracker for LetsWatch.

---

## Important Notice

> [!IMPORTANT]
> **LetsWatch is not Emby.**

LetsWatch is an independent media server project.  
It is not affiliated with, endorsed by, or derived from Emby.

Emby API compatibility is provided only to improve client interoperability. Compatibility does not mean identical behavior, complete API coverage, or official Emby support.

---

## Repository Purpose

This repository is intended for:

- Bug reports
- Client compatibility reports
- Emby API compatibility feedback
- Feature suggestions
- Documentation feedback
- General issue tracking

---

## What You Can Report

Please open an issue if you encounter:

| Type | Examples |
|---|---|
| Bug | Unexpected errors, crashes, incorrect responses |
| Playback Issue | Failed playback, broken stream URLs, seeking problems |
| Client Compatibility | A compatible client cannot connect, browse, search, or play media correctly |
| API Compatibility | Behavior differs from expected Emby-compatible API behavior |
| Performance Issue | Slow browsing, delayed search, library loading problems |
| Feature Request | Suggestions for new capabilities or compatibility improvements |

---

## Before Opening an Issue

Please check the following first:

- Search existing issues to avoid duplicates.
- Confirm the problem is reproducible.
- Remove private information from logs and screenshots.
- Include the client name and version if the issue is client-related.
- Include the affected API endpoint only if it is relevant and safe to share.

---

## Good Issue Reports

A useful issue report usually includes:

- A clear title
- What you were trying to do
- What happened instead
- Steps to reproduce
- Expected behavior
- Client name and version, if applicable
- LetsWatch version, build, or deployment channel, if known
- Relevant logs with secrets removed
- Screenshots or examples, if helpful

Please avoid posting:

- Access tokens
- API keys
- Passwords
- Database credentials
- Private server addresses
- Internal service URLs
- Full production configuration files
- Sensitive media metadata

---

## Emby API Compatibility

LetsWatch provides compatibility with selected Emby API behavior. This is intended to make compatible clients and integrations work smoothly where possible.

When reporting compatibility issues, please include:

- Client or integration name
- Client version
- Action being performed
- Affected endpoint, if known
- Expected behavior
- Actual behavior
- Minimal request or response example, if safe to share

Example:

```text
Client: Example Media Client 1.2.3
Action: Browse latest media items
Endpoint: GET /emby/Users/{UserId}/Items/Latest

Expected:
The client displays the latest media items.

Actual:
The client shows an empty list.
```

---

## Project Status

LetsWatch is under active development.

API behavior, compatibility coverage, and supported client workflows may change over time as the server evolves.

---

## Support Policy

This issue tracker is maintained for public feedback and compatibility tracking.  
Responses may depend on issue clarity, reproducibility, priority, and available maintenance time.

For the best chance of a useful response, please provide clear reproduction steps and avoid vague reports such as “it does not work.”

---

## Disclaimer

LetsWatch is an independent project.  
Names, trademarks, and product references belong to their respective owners.

Emby compatibility references are used only to describe client interoperability behavior.

---

<div align="center">

**LetsWatch Media Server**  
Independent. Fast. Compatible.

</div>
