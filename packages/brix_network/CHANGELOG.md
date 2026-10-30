## Unreleased

- Docs: README and pub.dev screenshot of the `PrettyNetworkLogger` console; neutral example paths ("items").

## 1.2.1

- `PrettyNetworkLogger`: writes to the IDE console through `dart:developer`, one call at a time, so colours show on iOS too. `output: print` for a terminal.

## 1.2.0

- `PrettyNetworkLogger`: rounded boxes and the brix mark `▰`, matching `BrixLogger` from brix 1.3.0.

## 1.1.0

- `BrixApi.download`: files (PDF, image, spreadsheet, ...) as a `DownloadedFile`: bytes, `contentType`, `fileName` (from `Content-Disposition`), `isPdf`, `isImage`, `sizeLabel`, with optional `onProgress`. An error answer instead of the file is read like any other call.
- `NetworkRequest.wantsBytes` / `onReceiveProgress` for your own `NetworkClient`; `DownloadedFile.fromBytes(bytes, headers: ...)` builds the file.
- The console log shows a file as `<binary 245 KB / application/pdf>`.

## 1.0.1

- README: flow diagrams showing what happens on a tap / in a call.

## 1.0.0

First release.

- `BrixApi`: `get`, `post`, `put`, `patch`, `delete`, `upload`, `request`; every call returns a brix `Result`, data parsed with `Json`.
- `DioNetworkClient` (default): timeout, retries for GET / PUT / DELETE only, cancel (`RequestCancel`), upload progress; `NetworkClient` to use any other library.
- `ResponseReader`: envelope (Node, NestJS, Laravel, custom), FastAPI, Django REST and custom readers; messages and field errors from any error shape.
- `StandardStatus.map` (maps a status to a `Failure`), replaceable with `statusMapper`.
- A 401 calls `onUnauthorized` once for many calls, `logoutOn401` to skip paths (login).
- Identical GETs at the same time share one request.
- `PrettyNetworkLogger`: one readable box per call, secrets hidden, off in release builds.
