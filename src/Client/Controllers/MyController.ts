import Aero = require("Shared/Modules/Aero");

export class MyController extends Aero.Controller {
    Start() {
        this.Services.MyService.Greet("Joe")
            .then(serverMessage => print("Got message back from the server: " + serverMessage))
    }
}