# Yonga-Modbus Controller

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

## Modbus Protocol
Modbus RTU uses RS232 standard, which is also used by UART. A Modbus RTU frame consists of a UART byte sequence. Client send a read or write request, and server sends a response frame. Each data has 16 bit width.
### Read Holding Registers (03h)
This function reads a given quantity of data from a given address. A Modbus read request-response looks like that:

Request:
```
 ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ 
           Server ID       Function      Start Addr Hi   Start Addr Lo    Quantity Hi     Quantity Lo       CRC Lo          CRC Hi       STOP (3.5 Bytes)
 _____/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\__________________
```
Response:
```
 ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ...... ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ 
           Server ID       Function        Byte Count      Data 1 Hi       Data 1 Lo                       Data N Hi       Data N Lo        CRC Lo          CRC Hi       STOP (3.5 Bytes)
 _____/\______________/\______________/\______________/\______________/\______________/\_____......___/\______________/\______________/\______________/\______________/\__________________
```

Server ID: ID of server. If this ID equals the device ID, the Modbus server device will create a response. The device will ignore the frame otherwise.

Function: Function code, for read it is 03h. Our controller only supports 03h and 10h functions.

Start Addr: The address where the read will start. Our read space is 256 words, so can take a value in between 0x0000 - 0x00FF.

Quantity: Number of datas to read. For read function, it will be valid between 0x0001 - 0x007D.

CRC: 16 bit CRC for data integrity check. The server will not respond if request CRC is not OK.

Byte Count: Number of data bytes to send. It will be equal to Quantity x 2, since data width is 16 bits.

STOP: Transmitter should wait 3.5 bytes (28 bits) to finish Modbus frame.

### Write Multiple Registers (10h)
This function writes a given quantity of data to a given address. A Modbus write request-response looks like that:

Request:
```
 ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ...... ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ 
           Server ID       Function      Start Addr Hi   Start Addr Lo    Quantity Hi     Quantity Lo      Byte Count      Data 1 Hi       Data 1 Lo                       Data N Hi       Data N Lo        CRC Lo          CRC Hi       STOP (3.5 Bytes)
 _____/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\_____......___/\______________/\______________/\______________/\______________/\__________________
```
Response:
```
 ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ \/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ 
           Server ID       Function      Start Addr Hi   Start Addr Lo    Quantity Hi     Quantity Lo       CRC Lo          CRC Hi       STOP (3.5 Bytes)
 _____/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\______________/\__________________
```

Server ID: ID of server. If this ID equals the device ID, the Modbus server device will create a response. The device will ignore the frame otherwise.

Function: Function code, for write it is 10h. Our controller only supports 03h and 10h functions.

Start Addr: The address where the write will start. Our register space has 128 read-write words, so can take a value in between 0x0000 - 0x007F.

Quantity: Number of datas to write. For write function, it will be valid between 0x0001 - 0x007B.

CRC: 16 bit CRC for data integrity check. The server will not respond if request CRC is not OK.

Byte Count: Number of data bytes to send. It will be equal to Quantity x 2, since data width is 16 bits.

STOP: Transmitter should wait 3.5 bytes (28 bits) to finish Modbus frame.

For more information please visit [Modbus specifications documentations](https://modbus.org/specs.php).

## Architecture
In our simple architecture, there is a Modbus controller and an SRAM for register space. 
### Modbus Controller
Modbus Controller handles requests from client, reads and writes data to SRAM when needed. It also has a Wishbone interface, which enables memory access from management core.
### Register Space
Our register space has a read-only space and a read-write space. Read-write space is addressed between 0x00 - 0x7F, while read-only space is addressed between 0x80 - 0xFF. Note that read-only space is only read-only for Modbus requests, data can still be written there via Wishbone interface.
### Wishbone Interface
Entire register space is read and write enabled for management core. Management core can access register space via Wishbone interface. A sample code is given below.
```
// Wishbone base address: 0x30000000
// Write register address to LSB with 2 zeros padded left hand side
// Example: To write address 0x03, use address 0x3000000C
	    
while ((*(volatile uint32_t*)0x30000000) != 0x00000001); // Read address 0x00 over and over and wait until modbus client writes 0x0001 in address 0x00

(*(volatile uint32_t*)0x30000200) = 0x0000596f; // Write 0x596F in address 0x80
(*(volatile uint32_t*)0x30000204) = 0x00006e67; // Write 0x6E67 in address 0x81
(*(volatile uint32_t*)0x30000208) = 0x00006174; // Write 0x6174 in address 0x82
(*(volatile uint32_t*)0x3000020C) = 0x0000656b; // Write 0x656B in address 0x83
```
Warning: Be careful with repeated writes from management core. Since it blocks write port of SRAM when writing, it may break concurring modbus write requests. There is no such situation with SRAM reads. 
## Testbench
In testbench, the steps below occurs responsively.

1. Client sends a write request to write 0x0001 in address 0x00 first. 
2. Management core reads address 0x00 repeatedly. When it becomes 0x0001, it writes "YONGATEK" in ASCII starting from address 0x80.
3. Client sends a read request to read address starting from 0x80 to 0x83, and checks if the incoming data is as expected.

To run test, after installation you should run the command below, in caravel_yonga-modbus-controller directory
```
make verify-modbus_test-rtl
```
Installation guide can be found in [caravel_user_project directory](https://github.com/efabless/caravel_user_project/blob/main/docs/source/quickstart.rst).

## Contributors
- Burak Yakup Çakar
