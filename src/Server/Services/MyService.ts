import * as Aero from "Shared/Internal/Aero"

// Server service
export class MyService extends Aero.Service {
    Init() {
        this.RegisterEvent("Hello!")
    }
    Start() {
        this.DoThing()
        this.ConnectEvent("Hello", (whom: string) => {

        })
        print("Hello service!")
    }

    DoOtherThing() {

    }

    DoThing() {
        this.Services.MyService.DoOtherThing()
        //this.Services.NonexistentService.DoThing()
    }
}

// Client-interfacing methods
export class MyServiceClient extends Aero.ClientInterface<MyService> {
    DoSomething = Aero.Sync(() => {
        this.Server.DoThing()
    })
    DoSomethingAsync = Aero.Async<(arg1: string) => string>((player: Player, arg1) => {
        // This should automatically be asynchronous
        return "Hello from " + tostring(this.Server)
    })
    DoSomething2Async = Aero.AsyncVoid((player: Player, arg1) => {
        // This should automatically be asynchronous
        print("Hello async void")
    })
}