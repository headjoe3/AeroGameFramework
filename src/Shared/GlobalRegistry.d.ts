import {MyService, MyServiceClient} from "../Server/Services/MyService"
import { StoreService } from "Server/Services/StoreService";
import { DataService } from "Server/Services/DataService";
import Aero = require("Shared/Modules/Aero");
import { MyController } from "Client/Controllers/MyController";
import UserInput = require("Client/Controllers/UserInput");

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