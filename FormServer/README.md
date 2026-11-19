# Server-driven forms: local server

This is a standalone Python server for the new iOS app you will build. It has no third-party dependencies and does not modify OpsDesk. Requires Python 3.10 or later.

## Run

```sh
cd /Users/jonathanthornburg/QTSTestApp/FormServer
python3 server.py
```

Leave that terminal running. Stop with Control-C. If port 8080 is busy, use `python3 server.py --port 8081`.

```sh
curl http://127.0.0.1:8080/api/forms
curl http://127.0.0.1:8080/api/forms/contact
curl http://127.0.0.1:8080/api/forms/appointment
curl http://127.0.0.1:8080/api/forms/feedback
```

`GET /health` checks server availability. Unknown endpoints return JSON with status 404. Other common HTTP methods return JSON with status 405 and `Allow: GET`. Responses use `application/json` and disable caching while you experiment. Query parameters are currently ignored.

Edit files in `forms/` and fetch again to see changes; no restart is needed. Add another JSON file with a matching `id` to add another form to the catalog. Invalid JSON produces a 500 response; at startup it prevents the server from starting. This is a local development server, with no authentication or persistence.

## What server-driven UI means

The server sends a **description** of a screen. Your app decodes that description and creates native SwiftUI or UIKit controls. JSON does not create controls by itself: you write a renderer that maps each supported field type to a native view.

For example, a `text` field becomes a SwiftUI `TextField`, a `toggle` becomes a `Toggle`, and `singleSelect` becomes a `Picker`. The app supplies native styling, accessibility, state management and navigation. The server decides which supported controls appear, their order, labels, choices and validation rules.

Once your renderer works, changing a label, rearranging fields or adding a form using supported controls only requires a server JSON change. A new kind of control still requires an app update. Treat the JSON as data; never execute code supplied by the server.

## API contract (version 1)

`GET /api/forms` returns a catalog with `schemaVersion` and a `forms` array. Each entry contains `id`, `title`, `description`, and a relative `path` to fetch its definition.

Each form definition has:

| Property | Meaning |
| --- | --- |
| `schemaVersion` | JSON contract version; currently `1`. Reject unsupported versions with a friendly error. |
| `id` | Stable form identifier matching its filename. |
| `revision` | Content revision. Increment this when changing a form's meaning. |
| `title`, `description` | Screen heading and introductory text. |
| `sections` | Ordered sections, each containing `id`, `title`, and ordered `fields`. |
| `actions` | Buttons the app may render; currently only a local `preview` action. |

Field IDs are unique within a form. Every field has `id`, `type`, `label`, and `required`. Optional properties include `placeholder`, `defaultValue`, `options`, `validation`, and `visibleWhen`. Missing `defaultValue` means an empty value, an empty selection array, or `false` for a toggle. A slider without a default starts at its minimum. Omit unanswered optional fields from an answer object.

| `type` | Suggested native control | Answer JSON value |
| --- | --- | --- |
| `text` | TextField | string |
| `email` | TextField with email keyboard | string |
| `phone` | TextField with phone keyboard | string |
| `multilineText` | TextEditor | string |
| `number` | TextField with numeric keyboard or Stepper | number |
| `singleSelect` | Picker | option's string `value` |
| `multiSelect` | Rows with checkmarks | array of option `value` strings |
| `toggle` | Toggle | boolean |
| `date` | DatePicker displaying date | `YYYY-MM-DD` string |
| `time` | DatePicker displaying time | `HH:mm` string, 24-hour local wall time |
| `slider` | Slider | number |

Options have `value` (stable identifier) and `label` (display text). Keep answers keyed by field ID rather than label. For example:

```json
{
  "formId": "contact",
  "revision": 1,
  "values": {
    "fullName": "Alex Morgan",
    "email": "alex@example.com",
    "topic": "general",
    "message": "Hello!"
  }
}
```

This is an example answer object for your app to build, not a server endpoint. The server intentionally accepts GET only. The `preview` action should validate visible fields and show answers locally; it does not submit, save, book an appointment or send a message.

## Validation and conditional fields

Your renderer implements these rules:

- `required`: a visible field must have a value; trim text before checking emptiness. Boolean `false` and numeric `0` are valid answers. A required toggle means an answer is present, not consent must be true.
- `minLength` / `maxLength`: text length, counted as user-perceived characters.
- `min` / `max`: inclusive numeric bounds.
- `integerOnly`: reject fractional numbers when true.
- `step`: numeric increments measured from `min` (used by sliders).
- `email`: perform a reasonable email format check for nonempty values. Keyboard choice alone does not validate input.
- Selections: only values listed in `options` are valid.
- `visibleWhen: {"fieldId": "followUp", "equals": true}`: show the field only when the referenced answer exactly equals the supplied JSON value. Hidden fields are excluded from validation and preview answers.

Unknown optional properties can be ignored. For an unknown field or action type, show an unsupported-form message and disable its action; silently dropping a required field could make the form impossible to complete correctly. The server checks basic version/filename consistency but does not fully validate authored form definitions. A future submission API must independently validate all answers; client validation alone is insufficient.

## Connecting your app

For the iOS Simulator on this Mac, start with base URL `http://127.0.0.1:8080`. Fetch the catalog with `URLSession`, decode the selected definition with `JSONDecoder`, then render sections and fields. Keep loading, error and retry states in your app. Use a separate typed answer store so editing answers does not mutate the definition.

For a physical iPhone on the same Wi-Fi network, run:

```sh
python3 server.py --host 0.0.0.0
```

Use `http://<your-Mac-LAN-IP>:8080` in the app. `0.0.0.0` is a listening address, not a destination URL. On an iPhone, `localhost` refers to the phone itself. Allow the Python process through your Mac firewall if prompted. LAN mode exposes this demo to other devices on that network; use a trusted development network.

For local HTTP development, configure the app's App Transport Security local-network exception (`NSAppTransportSecurity` → `NSAllowsLocalNetworking`) as needed for your chosen local address. On a device, also supply `NSLocalNetworkUsageDescription` describing why the app connects to your Mac and grant local-network access. Use HTTPS for a deployed service; avoid a blanket transport-security exception in a shipped app.

Apple documents these settings in [NSAllowsLocalNetworking](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking) and [NSLocalNetworkUsageDescription](https://developer.apple.com/documentation/bundleresources/information-property-list/nslocalnetworkusagedescription).

## Verify the server

```sh
python3 -m unittest -v
```

Tests start their own temporary server on an available port and stop it afterward.
