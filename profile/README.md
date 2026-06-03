# WAVE

**The open video layer — for humans and AI agents.** One API for live and on-demand video across every transport, built so that people *and* autonomous agents can capture, produce, deliver, and pay for media.

Like Stripe is for payments and Resend is for email — **WAVE is for audio and video.**

---

## What WAVE is

- **One API, every transport.** WebRTC, SRT, RIST, NDI, OMT, Dante, SMPTE ST 2110, MoQ, RTMP, HLS, DASH — spoken through a single contract instead of a dozen integrations.
- **A media engine underneath.** The open-core [WAVE Media Engine](https://wave.online/protocol) handles clock, integrity, sync, reliability, and metering once; each transport is a thin adapter on top.
- **Agent-native commerce.** Every capability is machine-discoverable and individually metered, with native HTTP-402 (x402) payment negotiation so agents can transact for media under your governance.
- **Edge-native.** A hub-and-spoke architecture on the Cloudflare edge, federating to one gateway that enforces auth, scope, entitlement, and metering.

## Packages

| Package | Description | npm |
|---------|-------------|-----|
| [`@wave-av/sdk`](https://github.com/wave-av/sdk) | TypeScript SDK — 34 API modules | [![npm](https://img.shields.io/npm/v/@wave-av/sdk.svg)](https://www.npmjs.com/package/@wave-av/sdk) |
| [`@wave-av/adk`](https://github.com/wave-av/adk) | Agent Developer Kit — MCP tools + agent templates | [![npm](https://img.shields.io/npm/v/@wave-av/adk.svg)](https://www.npmjs.com/package/@wave-av/adk) |
| [`@wave-av/mcp-server`](https://github.com/wave-av/mcp-server) | MCP server for Claude, Cursor, and Windsurf | [![npm](https://img.shields.io/npm/v/@wave-av/mcp-server.svg)](https://www.npmjs.com/package/@wave-av/mcp-server) |

Python developers: [`wave-sdk`](https://github.com/wave-av/sdk-python) on PyPI.

## Quick start

```bash
# SDK — build video features into your app
npm install @wave-av/sdk

# MCP server — give AI agents video capabilities
npx @wave-av/mcp-server

# ADK — build autonomous video agents
npm install @wave-av/adk
```

## For developers

```typescript
import { Wave } from '@wave-av/sdk';

const wave = new Wave({ apiKey: process.env.WAVE_API_KEY! });

const stream = await wave.pipeline.create({
  title: 'My stream',
  protocol: 'webrtc',
});
await wave.pipeline.start(stream.id);
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
- [Developer portal](https://dev.wave.online) — keys, references, quickstarts
- [Documentation](https://docs.wave.online)
- [Agent commerce](https://wave.online/agent-commerce) · [Protocol](https://wave.online/protocol) · [The name](https://wave.online/av)
- [Status](https://wave.online/status)
- [npm](https://www.npmjs.com/org/wave-av)

## Security

Report vulnerabilities to **security@wave.online**. See [SECURITY.md](SECURITY.md).

## License

MIT — operated by WAVE Online, LLC.
