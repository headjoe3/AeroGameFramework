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
    DoSomething = Aero.Sync(() => {
        this.Server.DoSomething()
    })
    DoSomethingAsync = Aero.Async<(arg1: string) => string>((player: Player, arg1) => {
        // This should automatically be asynchronous
        return "Hello from " + tostring(this.Server)
    })
    DoSomething2Async = Aero.AsyncVoid((player: Player, arg1) => {
        // This should automatically be asynchronous
        print("Hello async void")
    })
    Greet = Aero.Async<(clientName: string) => string>((player: Player, clientName) => {
        // This should automatically be asynchronous
        return "Hello, " + clientName
    })
}