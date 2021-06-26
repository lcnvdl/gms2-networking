# gms2-networking
Almost-magic Networking System for Game Maker Studio +2.3.

## Features
* **Auto-magic synchronization between objects**. _There is no longer a need to invent new protocols or mess up your code._
* **Smooth synchronization**. _Latency is hidden by using a smooth value assignment algorithm._
* **Security layer**. _You can add server-side validations to prevent cheating._
* **Independent of the network engine**. _You can use a base class to implement your preferred network engine. For my own project I used Http2 sockets!_
* **Easy to use**. _You don't need to know how to handle sockets or buffers._

### More features...
* **Simple messages system.** _Send an receive custom objects (like [Socket.io](https://github.com/socketio/socket.io)), recommended for advanced developers._
* **Global variables synchronization.**
* **Remote Procedure Calls (RPC) _//Work in progress//_.** _You can call instance functions, regardless of where they are on the network._

## Diagram
![Class Diagram](https://www.plantuml.com/plantuml/png/TPBHIyCm4CRVyrSSVTB12kBRsCDmY2zEmS50sCirlMsnQLAIwqJK_ztCTfesx2sz-zsNtFTruHaTjxKMKgFty4JyRbsrGeDxSdrn_M7a1ft2GjEvHAOaD_Zmmw4NagIEKHaBpmubGzU_Gq_tPgyC3Qz-M3tsPT6WhC8eP6joGGdMggGCFWNq4akjoF3V1UToHo-jOMUrJXedbUVYZIHlKAiIsJhnBOInJC2s0RkBtZQ3Lzk2H0EgRZJLP1XAjTkHEvteb_5RSwLLHN1WRcx1MraHUoYrliuxsS8ospeeNtx23FeZUI2K1_31TDYQO-zxBiGm6vZd-TZvb4XZI9cnZoaHXvLsKyF5Fm_ph-aqoHPceCo1d68ln709o6uoc8IPR991rmgq3EAeJA3ZXHA-RyOJdVw8Y__e4HklCfww55uiiGYtjRN-0G00)

[Diagram code](./docs/Diagrams/class_diagram.txt)

## Contributing

### Guidelines
Please follow this guidelines before contribute:
[Contributing](./docs/CONTRIBUTING.md)

### Code convention
All the code must respect the rules in the convention file:
[Code convention](docs/code_convention.md)

> It is required. Otherwise, all changes will be rejected.

### Troubleshooting
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
