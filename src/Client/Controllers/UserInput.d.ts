import Aero = require("Shared/Modules/Aero");

export = UserInput
declare class UserInput extends Aero.Controller {
    Init(): void
    Get(type: string): void
}