# WAVE

**Media infrastructure for the agentic internet.** One call shape moves live and on-demand media across every transport, and both kinds of user — people and agents — discover it, call it, and pay for it per call.

Like Stripe is for payments and Resend is for email — **WAVE is for media.**

---

## What WAVE is

- **One API, every transport.** WebRTC, SRT, RIST, NDI, OMT, Dante, SMPTE ST 2110, MoQ, RTMP, HLS, DASH — spoken through a single contract instead of a dozen integrations.
- **A media engine underneath.** The open-core [WAVE Media Engine](https://wave.online/protocol) handles clock, integrity, sync, reliability, and metering once; each transport is a thin adapter on top.
- **Agent-native commerce.** Every capability is machine-discoverable and individually metered, with native HTTP-402 (x402) payment negotiation so agents can transact for media under your governance.
- **Edge-native.** A hub-and-spoke architecture on the Cloudflare edge, federating to one gateway that enforces auth, scope, entitlement, and metering.

## Packages

| Package | Description | npm |
|---------|-------------|-----|
| [`@wave-av/sdk`](https://github.com/wave-av/sdk) | TypeScript SDK — 45 module subpaths | [![npm](https://img.shields.io/npm/v/@wave-av/sdk.svg)](https://www.npmjs.com/package/@wave-av/sdk) |
| [`@wave-av/adk`](https://github.com/wave-av/adk) | Agent Developer Kit — MCP tools + agent templates | [![npm](https://img.shields.io/npm/v/@wave-av/adk.svg)](https://www.npmjs.com/package/@wave-av/adk) |
| [`@wave-av/mcp-server`](https://github.com/wave-av/mcp-server) | MCP server for Claude, Cursor, and Windsurf | [![npm](https://img.shields.io/npm/v/@wave-av/mcp-server.svg)](https://www.npmjs.com/package/@wave-av/mcp-server) |
| [`@wave-av/cli`](https://github.com/wave-av/cli) | Command-line interface for the WAVE streaming platform | [![npm](https://img.shields.io/npm/v/@wave-av/cli.svg)](https://www.npmjs.com/package/@wave-av/cli) |
| [`@wave-av/workflow-sdk`](https://github.com/wave-av/workflow-sdk) | Build and execute workflows on the WAVE platform | [![npm](https://img.shields.io/npm/v/@wave-av/workflow-sdk.svg)](https://www.npmjs.com/package/@wave-av/workflow-sdk) |
| [`@wave-av/dispatch`](https://github.com/wave-av/dispatch-edge) | Local-first AI routing — edge worker + client SDKs | [![npm](https://img.shields.io/npm/v/@wave-av/dispatch.svg)](https://www.npmjs.com/package/@wave-av/dispatch) |

Python developers: [`wave-sdk`](https://github.com/wave-av/sdk-python) on PyPI.

## Quick start

```bash
# SDK — build media features into your app
npm install @wave-av/sdk

# MCP server — give AI agents media capabilities
npx @wave-av/mcp-server

# ADK — build autonomous media agents
npm install @wave-av/adk
```

## For developers

```typescript
import { Wave } from '@wave-av/sdk';

const wave = new Wave({ apiKey: process.env.WAVE_API_KEY! });

const clip = await wave.clips.create({
  title: 'Best moment',
  source: { type: 'stream', id: 'stream_123', start_time: 120, end_time: 150 },
});

const clips = await wave.clips.list({ status: 'ready' });
```

## For AI agents

Add to your `.mcp.json`:

```json
{
  "wave": {
    "command": "npx",
    "args": ["-y", "@wave-av/mcp-server"],
    "env": { "WAVE_API_KEY": "your_key" }
  }
}
```

Tools for streams, studio, analytics, billing, and production controls — and every capability is payable over x402, so agents can pay as they go.

## Platform

- **Every transport, one API** — WebRTC, SRT, RIST, NDI, OMT, Dante, ST 2110, MoQ, RTMP, HLS, DASH.
- **Real-time and on-demand** — low-latency live paths plus recording, clips, captions, transcription, search, and more.
- **Agent commerce built in** — x402 payment negotiation and metered usage on every capability.
- **Usage-based pricing** — pay for what you use. See [pricing](https://wave.online/pricing).

## Links

- [wave.online](https://wave.online) — the platform
- [Developer portal](https://developer.wave.online) — keys, references, quickstarts
- [Documentation](https://docs.wave.online)
- [Agent commerce](https://wave.online/agent-commerce) · [Protocol](https://wave.online/protocol) · [The name](https://wave.online/av)
- [Status](https://wave.online/status)
- [npm](https://www.npmjs.com/package/@wave-av/sdk)

## Security

Report vulnerabilities to **security@wave.online**. See [SECURITY.md](SECURITY.md).

## License

MIT — operated by WAVE Online, LLC.
