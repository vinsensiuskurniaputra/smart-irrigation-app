## 🔹 AI Prompt for Your Project

> I am building a Flutter app using **Clean Architecture**.
> My project structure looks like this:
>
> ```
> lib/
> ├── commons/
> │   └── widgets/
> ├── core/
> │   ├── config/
> │   │   ├── assets/
> │   │   └── theme/
> │   ├── constants/
> │   │   └── API/
> │   │       └── api_urls.dart
> │   ├── network/
> │   ├── services/
> │   └── utils/
> ├── features/
> │   ├── auth/
> │   │   ├── data/
> │   │   │   ├── models/
> │   │   │   ├── repositories/
> │   │   │   └── services/
> │   │   ├── domain/
> │   │   │   ├── entities/
> │   │   │   ├── repositories/
> │   │   │   └── usecases/
> │   │   └── presentation/
> │   │       ├── controllers/
> │   │       ├── pages/
> │   │       └── widgets/
> │   ├── device/
> │   ├── home/
> │   └── onboarding/
> ├── app.dart
> ├── main.dart
> └── routes.dart
> ```
>
> **Rules for code generation:**
>
> 1. Always follow this folder structure.
> 2. All API endpoints must be imported from `core/constants/API/api_urls.dart` and never hardcoded inside services or repositories.
> 3. Use **Clean Architecture layers**:
>
>    * `services` → low-level API calls (using Dio/http).
>    * `models` → handle JSON serialization/deserialization.
>    * `repositories/data` → concrete repository implementations that call `services`.
>    * `repositories/domain` → abstract repository interfaces.
>    * `entities` → pure domain objects (no framework dependencies).
>    * `usecases` → application-specific logic that calls domain repositories.
>    * `controllers` → state management (Provider/Bloc/etc.).
>    * `pages` → Flutter screens (UI).
>    * `widgets` → reusable UI components.
> 4. Keep dependencies clean:
>
>    * **Domain** does not depend on **Data** or **Presentation**.
>    * **Presentation** only depends on **Domain**.
>    * **Data** depends on both **Domain** and **Core**.
> 5. Use dependency injection with `service_locator.dart`.
> 6. Do not hallucinate code. If some detail is unclear, add `// TODO`.
> 7. Always show imports correctly based on this structure.
>
> **Example request:**
> “Generate a login feature implementation (service, model, repository, usecase, controller, and page) using the `/login` endpoint. Ensure the endpoint is imported from `api_urls.dart`.”
