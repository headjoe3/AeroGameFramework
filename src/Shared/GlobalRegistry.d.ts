import {MyService, MyServiceClient} from "../Server/Services/MyService"
import { StoreService, StoreServiceClient } from "Server/Services/StoreService";
import { DataService, DataServiceClient } from "Server/Services/DataService";
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
        StoreService: StoreServiceClient
        DataService: DataServiceClient

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