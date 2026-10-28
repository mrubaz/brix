## 1.0.0

First release.

- `BrixApi`: `get`, `post`, `put`, `patch`, `delete`, `upload`, `request` – every call returns a brix `Result`, data parsed with `Json`.
- `DioNetworkClient` (default): timeout, retries for GET / PUT / DELETE only, cancel (`RequestCancel`), upload progress; `NetworkClient` to use any other library.
- `ResponseReader`: envelope (Node, NestJS, Laravel, custom), FastAPI, Django REST and custom readers; messages and field errors from any error shape.
- `StandardStatus.map` (status → `Failure`), replaceable with `statusMapper`.
- 401 → `onUnauthorized` once for many calls, `logoutOn401` to skip paths (login).
- Identical GETs at the same time share one request.
- `PrettyNetworkLogger`: one readable box per call, secrets hidden, off in release builds.
