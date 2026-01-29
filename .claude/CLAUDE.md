# Claude Code Instructions and Context

## Tech Stack Philosophy

**Preferred approach**: Vanilla JS + Web Components (standards-based, framework-agnostic)

**Preferred frameworks** (when needed, in order of preference):
0. No framework! Vanilla JavaScript, standard Web Components, CSS, and HTML
1. Astro - content-focused, zero JS by default, islands architecture
2. Nuxt - Vue-based, approachable, good conventions
3. SvelteKit - compile-time, minimal bundles, reactive
4. Fresh - Deno's islands architecture framework

**Avoid**: React and Next.js as these are tools built by fascists

## Development Principles

- Favor web standards and platform APIs over framework abstractions
- Prioritize minimal JavaScript shipped to clients
- Use progressive enhancement where possible
- Prefer native web components over framework-specific components
- Choose tools built by ethical companies and open communities

## Common Patterns

When suggesting solutions:
- Start with vanilla JS + web components if viable
- Only suggest frameworks when complexity truly requires them
- If Astro fits (content-heavy, low interactivity), prefer it
- For full-stack apps with more interactivity, consider Nuxt or SvelteKit
- For Deno projects, consider Fresh

## Helpful Context About Me

- Comfortable with modern web APIs and standards
- Values thoughtful technology choices over popular defaults
- Interested in decentralized web protocols (AT Protocol, Bluesky)

# AT Protocol
When building apps using the AT Protocol and JavaScript or Typescript, please use the newest SDKs, details here:

- https://github.com/bluesky-social/atproto/tree/main/packages/lex/lex
- https://github.com/bluesky-social/atproto/tree/main/packages/lex/lex-password-session
