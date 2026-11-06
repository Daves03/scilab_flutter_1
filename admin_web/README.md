# SciLab admin web

From `admin_web`, run:

```sh
npm install
npm run dev
npm run build
```

The production output is written to `dist`.

## Gemini quiz generation

Development and production builds load `GEMINI_API_KEY` and optional
`GEMINI_MODEL` from the repository root's ignored `.gemini.local.json`, shared
with the Flutter app. The build exposes these as `VITE_GEMINI_API_KEY` and
`VITE_GEMINI_MODEL` for the web quiz generator.

To override either value, set the corresponding `VITE_` environment variable
when building, or copy `.env.example` to `.env.local` and supply your values.
On build servers without `.gemini.local.json`, configure `VITE_GEMINI_API_KEY`
in the build environment. `VITE_GEMINI_MODEL` is optional; when omitted, the
portal discovers available models.

Restart the development server or rebuild and redeploy `dist` after changing
the configuration. These values are embedded in the browser bundle; restrict
the API key to your hosting domains and the Generative Language API.
