"""Local, dependency-free server-driven form API. Run: python3 server.py."""

import argparse
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

FORMS_DIR = Path(__file__).resolve().parent / "forms"


def load_forms():
    """Read on every request so editing a JSON file needs no restart."""
    forms = {}
    for path in sorted(FORMS_DIR.glob("*.json")):
        form = json.loads(path.read_text(encoding="utf-8"))
        if form["schemaVersion"] != 1 or form["id"] != path.stem:
            raise ValueError(f"Invalid schemaVersion or id in {path.name}")
        forms[form["id"]] = form
    return forms


class Handler(BaseHTTPRequestHandler):
    def respond(self, status, payload):
        body = (json.dumps(payload, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlsplit(self.path).path.rstrip("/") or "/"
        if path == "/health":
            self.respond(200, {"status": "ok", "schemaVersion": 1})
            return
        if path == "/":
            self.respond(200, {
                "name": "Server-Driven Forms Demo",
                "schemaVersion": 1,
                "links": {"forms": "/api/forms", "health": "/health"},
            })
            return
        try:
            forms = load_forms()
            if path == "/api/forms":
                self.respond(200, {"schemaVersion": 1, "forms": [
                    {"id": form["id"], "title": form["title"],
                     "description": form["description"],
                     "path": f"/api/forms/{form['id']}"}
                    for form in forms.values()
                ]})
            elif path.startswith("/api/forms/") and path[len("/api/forms/"):] in forms:
                self.respond(200, forms[path[len("/api/forms/"):]])
            else:
                self.respond(404, {"error": {"code": "not_found", "message": "Endpoint or form not found."}})
        except (ValueError, KeyError, OSError, TypeError):
            self.log_error("Could not load form definitions; check the JSON files in %s", FORMS_DIR)
            self.respond(500, {"error": {"code": "invalid_form_definition", "message": "The server could not load its form definitions."}})

    def do_POST(self):
        self.send_error_json_method()

    do_PUT = do_POST
    do_PATCH = do_POST
    do_DELETE = do_POST
    do_HEAD = do_POST
    do_OPTIONS = do_POST

    def send_error_json_method(self):
        body = json.dumps({"error": {"code": "method_not_allowed", "message": "This demo supports GET requests only."}}).encode()
        self.send_response(405)
        self.send_header("Allow", "GET")
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)
        self.close_connection = True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1", help="Use 0.0.0.0 to allow a physical iPhone on your LAN")
    parser.add_argument("--port", type=int, default=8080)
    args = parser.parse_args()
    load_forms()
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"Form server listening on http://{args.host}:{args.port}", flush=True)
    print("GET /api/forms to discover form definitions. Press Ctrl+C to stop.", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
