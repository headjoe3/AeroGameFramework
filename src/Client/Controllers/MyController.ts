import Aero = require("Shared/Modules/Aero");

export class MyController extends Aero.Controller {
    Start() {
        // Call asynchronous function
        this.Services.MyService.Greet("Joe")
            .then(serverMessage => print("Got message back from the server: " + serverMessage))

        // Connect to player event
        this.Services.MyService.OnCoinsUpdate.Connect(coins => {
            print("I now have " + coins + " coins!")
        })

        // Connect to all players event
        this.Services.MyService.OnTimeRemainingUpdate.Connect(timeRemaining => {
            print(timeRemaining + " seconds remaining.")
        })

        // Call synchronous function
        this.Services.MyService.DoSomething()
    }
}