import Aero = require("Shared/Internal/Aero");

export class MyController extends Aero.Controller {
    Start() {
        this.Services.MyService.DoSomethingAsync("Hello")
            .then(str => print("Got async response '" + str + "'"))
        this.Services.MyService.DoSomething2Async()
    }
}