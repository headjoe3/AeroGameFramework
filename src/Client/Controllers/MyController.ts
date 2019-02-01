import Aero = require("Shared/Modules/Aero");

export class MyController extends Aero.Controller {
    Start() {
        this.Services.MyService.DoSomethingAsync("Hello")
            .then(str => print("Got async response '" + str + "'"))
        this.Services.MyService.DoSomething2Async()
    }
}