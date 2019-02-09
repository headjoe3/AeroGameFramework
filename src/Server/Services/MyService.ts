import * as Aero from "Shared/Modules/Aero"

const TIME_REMAINING_UPDATE = new Aero.Event<(timeRemaining: number) => void>()
const PLAYER_COINS_UPDATE = new Aero.Event<(player: Player, coins: number) => void>()

// Server service
export class MyService extends Aero.Service {
    Init() {
    }
    Start() {
    }
    DoSomething(player: Player) {
        // Fire an event to a single player
        PLAYER_COINS_UPDATE.Fire(player, 1)

        // Fire an event to all players
        TIME_REMAINING_UPDATE.Fire(20)
    }
}

// Client-interfacing methods
export class MyServiceClient extends Aero.ClientInterface<MyService> {
    DoSomething = Aero.ServerSync((player) => {
        this.Server.DoSomething(player)
    })
    DoSomethingAsync = Aero.ServerAsync<(arg1: string) => string>((player: Player, arg1) => {
        // This should automatically be asynchronous
        return "Hello from " + tostring(this.Server)
    })
    DoSomething2Async = Aero.ServerAsyncVoid((player: Player, arg1) => {
        // This should automatically be asynchronous
        print("Hello async void")
    })
    Greet = Aero.ServerAsync<(clientName: string) => string>((player: Player, clientName) => {
        // This should automatically be asynchronous
        return "Hello, " + clientName
    })
    OnTimeRemainingUpdate = Aero.AllClientsEvent(TIME_REMAINING_UPDATE)
    OnCoinsUpdate = Aero.ClientEvent(PLAYER_COINS_UPDATE)
}