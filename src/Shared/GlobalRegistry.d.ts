import {MyService, MyServiceClient} from "../Server/Services/MyService"
import { StoreService } from "Server/Services/StoreService";
import { DataService } from "Server/Services/DataService";

// In order to expose your service's types, you must add it to the global registry
declare global {

    // Server

    interface GlobalAeroServices {
        StoreService: StoreService
        DataService: DataService

        // Add service classes here
        MyService: MyService
    }
    interface GlobalAeroClientInterfaces {
        // Add service client interface classes here
        MyService: MyServiceClient
    }
    interface GlobalAeroServerModules {
        // Add server modules here
    }

    // Client

    interface GlobalAeroControllers {
        // Add controllers classes here
    }
    interface GlobalAeroClientModules {
        // Add client modules here
    }

    // Shared

    interface GlobalAeroSharedModules {
        // Add shared modules here
    }
}