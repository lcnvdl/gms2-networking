# Remote Procedure Call
## 1. Definition
In distributed computing, a remote procedure call (RPC) is when a computer program causes a procedure (subroutine) to execute in a different address space (commonly on another computer on a shared network), which is coded as if it were a normal (local) procedure call, without the programmer explicitly coding the details for the remote interaction.

## 2. RPC in Auto-magic Networking System
The main idea is to allow Senders and Receivers to call functions almost as easily as if they were called within the same instance.

## 3. Registering RPC
When the application is being loaded, you must prepare the ground for RPC. The first step you have to do is register the functions.

### 3.1. Simple function register
_CREATE EVENT_
```javascript
nw_rpc_register("my_function", function(myArgs) {
  return myArgs.a + myArgs.b;
});
```

### 3.2. Security
You can add some security settings, in order to prevent the bad usage of the RPC.

#### Complete example (with all 4 variations)
_CREATE EVENT_
```javascript
nw_rpc_register("rpc_fn", function(myArgs) {
  show_debug_message("RPC works!");
});

nw_rpc_register("broadcast_fn", function(myArgs) {
  show_debug_message("Broadcast works!");
});

nw_rpc_register("multiply", function(myArgs) {
  return myArgs.a * myArgs.b;
});

nw_rpc_register("check_on_sender", function(myArgs) {
  return "Sender is OK";
});

//  Allows calling or broadcasting
nw_rpc_set_security("rpc_fn", { from: "sender", to: "1-*" });

//  Allows calling only by broadcasting
nw_rpc_set_security("add", { from: "sender", to: "*" });

//  Allows only calling by rpc
nw_rpc_set_security("multiply", { from: "sender", to: "1" });

//  Allows calling from Receiver to Sender
nw_rpc_set_security("multiply", { from: "receiver" });
```

## 4. Interactions

### 4.1. Rpc Call - Sender (client) calls to Receiver (server)
The Sender is on client-side.
The Receiver is on server-side (and it's replicated on the rest of clients).

The Sender calls to the Server-side Receiver's function, in order to receive an answer.

![Class Diagram](./Diagrams/rpc/rpc_sender_call.png)

[Diagram code](./Diagrams/rpc/rpc_sender_call.plantuml)

#### How to call it?
In the Sender, you must call:
```javascript
nw_rpc_sender_call("my_function", myArgs, myCallback);
```
The callback will run once the Sender receives the answer from the Receiver.
_The function will fail if the sender is not running on client-side._

### 4.2. Rpc Call - Receiver (client or server) calls to Sender (server or client)
The Receiver calls to the Senders's function, in order to receive an answer.

![Class Diagram](./Diagrams/rpc/rpc_receiver_call.png)

[Diagram code](./Diagrams/rpc/rpc_receiver_call.plantuml)

#### How to call it?
In the Receiver, you must call:
```javascript
nw_rpc_receiver_call("my_function", myArgs, myCallback);
```
The callback will run once the Receiver receives the answer from the Sender.

### 4.3. Rpc Call - Sender (client or server) broadcasts to Receivers (server or client)
The Sender broadcasts calling each Receiver's function. It won't expect an answer, but an [ACK](https://en.wikipedia.org/wiki/Acknowledgement_(data_networks)).

![Class Diagram](./Diagrams/rpc/rpc_sender_broadcast.png)

[Diagram code](./Diagrams/rpc/rpc_sender_broadcast.plantuml)


#### How to call it?
In the Sender, you must call:
```javascript
nw_rpc_sender_broadcast("my_function", myArgs, myCallback);
```
The callback will run once the Sender receives all ACK signals.

