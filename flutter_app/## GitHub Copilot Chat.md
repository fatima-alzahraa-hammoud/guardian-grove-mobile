## GitHub Copilot Chat

- Extension Version: 0.28.1 (prod)
- VS Code: vscode/1.101.1
- OS: Windows

## Network

User Settings:

```json
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:

- DNS ipv4 Lookup: 140.82.121.5 (197 ms)
- DNS ipv6 Lookup: Error (150 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (2 ms)
- Electron fetch (configured): HTTP 200 (2590 ms)
- Node.js https: HTTP 200 (3410 ms)
- Node.js fetch: HTTP 200 (1632 ms)
- Helix fetch: HTTP 200 (3889 ms)

Connecting to https://api.individual.githubcopilot.com/_ping:

- DNS ipv4 Lookup: 140.82.112.21 (123 ms)
- DNS ipv6 Lookup: Error (156 ms): getaddrinfo ENOTFOUND api.individual.githubcopilot.com
- Proxy URL: None (7 ms)
- Electron fetch (configured): timed out after 10 seconds
- Node.js https: HTTP 200 (2585 ms)
- Node.js fetch: HTTP 200 (2181 ms)
- Helix fetch: HTTP 200 (5461 ms)

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).
