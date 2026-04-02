# WAVE

**The video layer for AI agents.** Stream, produce, and deliver live video at enterprise scale.

Like Stripe is for payments and Resend is for email — **WAVE is for live streaming and video.**

---

## Packages

| Package | Description | npm |
|---------|-------------|-----|
| [`@wave-av/sdk`](https://github.com/wave-av/sdk) | TypeScript SDK — 34 API modules | [![npm](https://img.shields.io/npm/v/@wave-av/sdk.svg)](https://www.npmjs.com/package/@wave-av/sdk) |
| [`@wave-av/adk`](https://github.com/wave-av/adk) | Agent Developer Kit — 10 MCP tools, 5 agent templates | [![npm](https://img.shields.io/npm/v/@wave-av/adk.svg)](https://www.npmjs.com/package/@wave-av/adk) |
| [`@wave-av/mcp-server`](https://github.com/wave-av/mcp-server) | MCP server for Claude, Cursor, and Windsurf | [![npm](https://img.shields.io/npm/v/@wave-av/mcp-server.svg)](https://www.npmjs.com/package/@wave-av/mcp-server) |

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

19 tools available: streams, studio, analytics, billing, production controls.

## Platform

- **8 streaming protocols** — WebRTC, SRT, RTMP, NDI, HLS, DASH, WHIP, OMT
- **Sub-16ms latency** — glass-to-glass, real-time production
- **100M+ concurrent viewers** — enterprise-grade infrastructure
- **99.99% uptime SLA** — multi-region, automatic failover
- **SOC 2 Type II certified** — enterprise security and compliance

## Links

- [Developer portal](https://wave.online/developers)
- [Documentation](https://docs.wave.online)
- [API reference](https://docs.wave.online/api)
- [Status](https://status.wave.online)
- [npm](https://www.npmjs.com/org/wave-av)

## Security

Report vulnerabilities to **security@wave.online**. See [SECURITY.md](SECURITY.md).

## License

MIT
