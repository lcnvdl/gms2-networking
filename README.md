# gms2-networking
Almost-magic Networking System for Game Maker Studio +2.3.

## Features
* Auto-magic synchronization between objects. _There is no longer a need to invent new protocols or mess up your code._
* Smooth synchronization. _Latency is hidden by using a smooth value assignment algorithm._
* Security layer. _You can add server-side validations to prevent cheating._
* Independent of the network engine. _You can use a base class to implement your preferred network engine. For my own project I used Http 3 sockets!_
* You don't need to know how to handle sockets or buffers.

## Diagram
![Class Diagram](https://www.plantuml.com/plantuml/png/VPBHIyCm4CRVyrSSVT912-BR41aEySKfE1W8UxccjpKslOpaDX7rVxTpcJIRsrjw-Trt-RxhA0XwMRTMAMqn17WYUNU-cI3ZadmiJZzOpz0RB2tjIyGL-UGZf4qlfCbiUcKiWtZK0hlxEmnqpql3b8v-c3p6ibgXRhfMoARaEoMOceeo-5GG9SRM4Cj-m5zvHuyTYtVM7briLPxBDz8oGsig5EVLjrBiXC2RPItW5htN3U7LhK4ZWsbNbbfYWSei5kIt9_fbmfmlh6a8Qf7LDGId6v80bRMNnKwuT2AkxPHFFs88yKW127KDeOiTvho9oHTAfTk1cw8upFwOY8iuoyGapn2zGFwvFOvS7MuJylphjgS2Gp1SapSIb4fDG7QLmI3F8HjaqLz7QyU2XZiwDPJoqMtI4VKJBlcdKpQradITNbuYCUh6hLlx0m00)

[Diagram code](./docs/Diagrams/class_diagram.txt)

## Code convention
All the code must respect the rules in the convention file:
[Code convention](docs/code_convention.md)

> It is required. Otherwise, all changes will be rejected.

## Contributing
Please follow this guidelines before contribute:
[Contributing](./docs/CONTRIBUTING.md)

## Troubleshooting
Please follow this guidelines when reporting bugs and feature requests:

1. Use [GitHub Issues](https://github.com/lcnvdl/gms2-networking/issues) board to report bugs and feature requests (not our email address)
2. Please **always** write steps to reproduce the error. That way we can focus on fixing the bug, not scratching our heads trying to reproduce it.

Thanks for understanding!

## Author
* [Website](https://lrasente.tumblr.com)
* [Portfolio](https://lcnvdl.github.io)

## License
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/lcnvdl/gms2-networking/blob/master/LICENSE)

This project is licensed under the terms of the [MIT license](/LICENSE).
