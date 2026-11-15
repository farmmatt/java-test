# Core Application Specification (`java-test`)

## Purpose
Defines the baseline application entrypoint, startup behavior, and health/readiness verification for `java-test`.

## Requirements

### Requirement: Application Entrypoint & Startup Greeting
The application entrypoint (`com.example.app.App`) MUST initialize cleanly on Java 21 and provide a deterministic startup greeting for health/smoke verification.

#### Scenario: Standard Application Startup
- **GIVEN** the Java 21 runtime environment is configured
- **WHEN** `App.main` or `new App().greeting()` is invoked
- **THEN** a non-null greeting containing `java-test` is returned and logged without errors
