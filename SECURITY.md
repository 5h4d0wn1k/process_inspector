# Security Policy

## Scope

`Process Inspector` is an educational Linux process-inspection tool. It is designed for local learning and experimentation, not for high-assurance production incident response.

Current limitations:

- Linux-only
- reads from `/proc`
- minimal validation and no privilege separation
- not hardened against hostile local environments

## Reporting a Security Issue

If you find a vulnerability in this repository itself, avoid posting exploit details publicly first.

Preferred approach:

1. Open a private security advisory on GitHub, if available.
2. If that is not available, contact the maintainer privately through GitHub before public disclosure.

Please include:

- affected file or behavior
- impact
- steps to reproduce
- suggested fix, if you have one

## Operational Warning

Do not treat this project as a complete forensic or detection platform. It is a learning-oriented `/proc` inspector that will evolve over time.
