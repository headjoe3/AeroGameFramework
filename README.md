<div align="center"><img width=25% src="/imgs/logo_256.png"></div>
<h1 align="center">aero-ts</h1>
<br>
<div align="center">A typescript port to Crazyman32's AeroGameFramework</div>

# Overview
AeroGameFramework is a framework made by Crazyman32 that simplifies server/client script organization and communication interfaces between them.
This is a [Roblox-TypeScript](https://roblox-ts.github.io/) port to that framework

# Warning
Aero-ts is still in its early stages, and may be prone to bugs. Because there is currently no universal installer, even if I fix bugs with the framework, you will have to manually update the files from this repository. The bright side is that you are free to change and configure the internals however you wish without your changes being overridden. Because this is a holistic framework and is meant to simplify the organization of your game as a whole, feel free to re-organize it how you wish.

# Installation
Currently, aero-ts has no standard installer, as it relies on the placement of files and Rojo partitions in a Roblox-TS project. For this reason, you will have to manually organize the files you want to include.

**You can download this repository and start building your project** if you already have rojo and roblox-ts installed.

OR

If you have an existing project, you can either port your project to this project, or manually place the core modules from this repository into it.

Luckily, a manual installation is not too difficult, and is highly customizable. Here are some steps to integrating aero-ts into your game:

1. Make sure you have [`Roblox-TS`](https://github.com/roblox-ts/roblox-ts) and `rbx-types` installed and updated to their latest versions
2. Configure your sync plugin to output to the following locations:
- Server code: `ServerScriptService.Aero`
- Client code: `StarterPlayer.StarterPlayerScripts.Aero`
- Shared code: `ReplicatedStorage.Aero`

You can view the `rojo.json` file in this repository for reference

3. Copy the core scripts from this repository, and put them in the appropriate folders
- Client entry point: `Client/AeroClient.client.lua` file, `Client/Controllers` folder (contents are not essential)
- Server entry point: `Server/AeroServer.server.lua` file, `Client/Server` folder (contents are not essential)
- Shared core module: `Shared/Modules/Aero` folder, `Shared/Modules/Aero.d.ts` file, `Shared/Modules/FastSpawn.lua` file
- Anywhere: `Shared/GlobalRegistry.d.ts` file

4. If you chose not to include any services/contollers, check the `GlobalRegistry.d.ts` file and remove any lines that reference the modules you left out.

# Getting started

First of all, read [Crazyman32's tutorial](https://github.com/Sleitnick/AeroGameFramework) or watch his [video tutorial series](https://www.youtube.com/watch?v=8ta0cHX1ceE&index=1&list=PLk3R4TM3pnqv7doCTUHtn-wkydaA08npc) in order to gain an understanding of how the AeroGameFramework is structured.

Secondly, make sure you are familiar with Roblox-TS and Rojo, and the process of compiling your TypeScript codebase into a roblox game.

# Differences from the original AeroGameFramework

While the concept is the same, aero-ts has some major changes from the original framework. Here are a few major differences:
### Services and Controllers exported are classes
```ts
import * as Aero from "Shared/Modules/Aero"

// Server service
export class MyService extends Aero.Service {
    Init() {
    }
    Start() {
    }
    DoSomething() {
    }
}
```
Even though they are loaded and instanced in the same way as regular AGF, Services and Controllers are now formatted as classes and can be exported alongside other things in each module. This allows type information to be retained when accessing another service, as well as making variables and methods public or private.

### Client interfaces are separate exported classes
Client interfaces are accessed in the same way through controllers (`this.Services.MyService`) — however, they are now defined as a separate export, are not required on all services

```ts
import * as Aero from "Shared/Modules/Aero"

// Server service
export class MyService extends Aero.Service {
    Init() {
    }
    Start() {
    }
    DoSomething() {
    }
}

// Client-interfacing methods
export class MyServiceClient extends Aero.ClientInterface<MyService> {
    DoSomethingAsync = Aero.AsyncVoid(() => {
        this.Server.DoSomething()
    })
}
```

### Client-interfacing methods now fall into three categories: Sync, Async, and AsyncVoid
When I began porting the framework, I noticed that the DataService and StoreService implementations did not have any type checks whatsoever for player-interfacing functions. While I don't know how exactly this could be exploited, client-interfacing methods must now be wrapped in `Aero.Sync`, `Aero.Async`, or `Aero.AsyncVoid` function wrappers. Using the magic of TypeScript, these functions *force you* to not trust the client's input!
![You can't fool the compiler!](https://i.imgur.com/ilEXSp0.png)
aero-ts forces the first parameter to be typed as "Player", and any other parameters to be typed as "unknown", because after all—You don't know what the client will send you.
You can still define the *expected* parameter types in your client-interfacing method using the type argument of Sync/Async/AsyncVoid
![Much better!](https://i.imgur.com/Db82sma.png)

"Sync" will automatically connect a RemoteFunction for your client interface, while "Async" and "AsyncVoid" will connect RemoteEvents (yes, I know I've minimized the use of Register/Connect/FireClientEvent, but this is far simpler and more convenient anyways.)

"Async" will return a roblox-TS internal [promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) for the return parameter of your client-interfacing method. This will be a two-way connection, even if it uses a RemoteEvent.

"AsyncVoid" will only fire from the client to the server, and never expect a return parameter.

Because the client interface's types is **shared** between the server and the client, you only have to define the interface parameters and values in *one place*! 
```ts
import Aero = require("Shared/Modules/Aero");

export class MyController extends Aero.Controller {
    Start() {
        this.Services.MyService.Greet("Joe")
            .then(serverMessage => print("Got message back from the server: " + serverMessage))
    }
}
```
Both the client Controller and the server Service know that the client interface method "Greet" expects a string and returns a string
![Intellisense](https://i.imgur.com/z3Q7BO1.png)

### Services, Controllers, and ClientInterfaces must be registered in `GlobalRegistry.d.ts`
In order to expose the "Services" and "Controllers" properties of Services and Controllers, the types of each service and controller must first be globally exposed. This is achieved through a file in the `Shared` folder called `GlobalRegistry.d.ts`. This is an ambient TypeScript file (meaning it will not actually be compiled), which allows everything to be typesafe.

By default, some services and controllers ported from the original AeroGameFramework are already included in the global registry file:
```ts
import {MyService, MyServiceClient} from "../Server/Services/MyService"
import { StoreService } from "Server/Services/StoreService";
import { DataService } from "Server/Services/DataService";
import { MyController } from "Client/Controllers/MyController";
import UserInput = require("Client/Controllers/UserInput");

import Aero = require("Shared/Modules/Aero");

// In order to expose your service's types, you must add it to the global registry
// NOTE: The key must match the module's name, and the module must be placed directly in the corresponding Services/Controllers folder!
declare global {

    // Server

    interface GlobalAeroServices extends Record<string, Aero.Service> {
        StoreService: StoreService
        DataService: DataService

        // Add your services here
        MyService: MyService
    }

    interface GlobalAeroClientInterfaces extends Record<string, Aero.ClientInterface<Aero.Service>>  {
        // Add your client interfaces here
        MyService: MyServiceClient
    }

    // Client

    interface GlobalAeroControllers extends Record<string, Aero.Controller> {
        UserInput: UserInput

        // Add your controllers here
        MyController: MyController
    }
}
```

When adding a Service or Controller, make sure to add it to the global registry as well. **The registered name of your service or controller (on the left hand side) MUST match the name of the file that it comes from, regardless of what its exported service, client interface, or controller is called**

Once you add a service/controller to the global registry, you may now access it within another service or controller using `this.Services`, and `this.Controllers`

### Modules are NOT lazy-loaded, and act like regular modules without any injection
The only objects that can access other Services or Controllers are Services and Controllers. This was done intentionally, as it seems to me like bad practice to expose them otherwise. The "Modules" folder no longer has any special meaning (except in Shared.Modules, which is where the Aero core is located), and should be used for utility classes, functions, and data that should accomplish its task without invoking other services or having circular dependencies.

If absolutely need to access the Services or Controllers, you can use `_G.AeroClient` and `_G.AeroServer` to find them.

### Other differences/similarities
- Injected functions like `RegisterEvent` are the same; however, `RegisterClientEvent` is no longer preferred, as `Aero.Async` and `Aero.AsyncVoid` allows these events to have strict types for the client, and unknown types for the server.
- `ReplicatedStorage.Aero.Shared` is now just `ReplicatedStorage.Aero.Modules`
- `_G.Aero` is now `_G.AeroClient` to distinguish it from the Aero core module in ReplicatedStorage
- Certain modules, like `Event` and `ListenerList` are now in the core Aero namespace instead of the modules folder
