/*! coi-serviceworker v0.1.7 | MIT License | © Guido Zuidhof | https://github.com */
if (typeof window === 'undefined') {
    self.addEventListener("install", () => self.skipWaiting());
    self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
    self.addEventListener("fetch", (event) => {
        if (event.request.cache === "only-if-cached" && event.request.mode !== "same-origin") return;
        event.respondWith(
            fetch(event.request).then((response) => {
                if (response.status === 0) return response;
                const newHeaders = new Headers(response.headers);
                newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
                newHeaders.set("Cross-Origin-Embedder-Policy", "require-corp");
                return new Response(response.body, {
                    status: response.status,
                    statusText: response.statusText,
                    headers: newHeaders,
                });
            }).catch((e) => console.error(e))
        );
    });
} else {
    (() => {
        const script = document.currentScript;
        const reload = () => window.location.reload();
        if (window.crossOriginIsolated !== false) return;
        if (window.navigator.serviceWorker) {
            window.navigator.serviceWorker.register(script.src).then((registration) => {
                registration.addEventListener("updatefound", () => {
                    registration.installing.addEventListener("statechange", (event) => {
                        if (event.target.state === "activated") reload();
                    });
                });
                if (registration.active && !window.navigator.serviceWorker.controller) reload();
            }, (err) => console.error("COI service worker registration failed", err));
        }
    })();
}
