{{flutter_js}}
{{flutter_build_config}}

// CanvasKit's CPU surface works around a Flutter hot-restart WebGL bug, but it
// is slower. Keep GPU acceleration enabled by default and make the workaround
// opt-in by adding ?cpu_renderer=1 to the local URL when it is needed.
const forceCpuRenderer =
  new URLSearchParams(window.location.search).get('cpu_renderer') === '1';

_flutter.loader.load({
  config: {
    canvasKitForceCpuOnly: forceCpuRenderer,
  },
});
