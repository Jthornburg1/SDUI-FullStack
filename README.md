# Server-driven forms

A small SwiftUI app that lists forms defined in JSON and served by Python.

Run the server from the repo root with Python 3.10 or later.

```sh
python3 FormServer/server.py
```

Open `ServerDrivenSample/ServerDrivenSample.xcodeproj` in Xcode and run the app in an iOS simulator. It fetches the form list from `http://127.0.0.1:8080`.

Edit the JSON files in `FormServer/forms/` to change what the server returns.
