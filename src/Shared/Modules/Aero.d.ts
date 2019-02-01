export = Aero
declare namespace Aero {
    abstract class Service {
        /** Asynchronous function called at runtime after all services have been initialized */
        public Start(): void
        /** Synchronous function called at runtime after all services have been imported, but before they are started */
        public Init(): void
        
        public RegisterEvent(name: string): void
        public RegisterClientEvent(name: string): void
        
        public ConnectEvent(name: string, listener: (...args: any[]) => void): void
        public ConnectClientEvent(name: string, listener: (client: Player, ...args: any[]) => void): void

        public FireEvent(name: string, ...args: any[]): void
        public FireClientEvent(name: string, player: Player, ...args: any[]): void
        public FireAllClientsEvent(name: string, ...args: any[]): void

        /** Server-side services */
        Services: GlobalAeroServices
        /** (DEPRECATED) Server-side modules */
        //Modules: GlobalAeroServerModules
        /** (DEPRECATED) Shared modules */
        //Shared: GlobalAeroSharedModules
    }
    abstract class Controller {
        /** Asynchronous function called at runtime after all controllers have been initialized */
        public Start(): void
        /** Synchronous function called at runtime after all controllers have been imported, but before they are started */
        public Init(): void
        
        public ConnectEvent(name: string, listener: (...args: any[]) => void): void
        public RegisterEvent(name: string): void

        public FireEvent(name: string, ...args: any[]): void

        /** Client-side controllers */
        Controllers: GlobalAeroControllers
        /** Client interfaces to server-side services */
        Services: GlobalAeroClientInterfaces
        /** (DEPRECATED) Client-side modules */
        //Modules: GlobalAeroClientModules
        /** (DEPRECATED) Shared modules */
        //Shared: GlobalAeroSharedModules
        /** The local player */
        Player: Player
    }

    abstract class ClientInterface<ServiceType> {
        constructor(server: ServiceType)
        /** (Server-side only): Reverence to the server service being interfaced */
        public Server: ServiceType
    }

    /** An asynchronous function that should fire two ways and yield, but with unkown user input types. */
    function Sync<T extends (...args: any[]) => any>(func: (player: Player, ...args: unknown[]) => ReturnType<T>): (...args: FunctionArguments<T>) => ReturnType<T>

    /** An asynchronous function that should fire one-way and return a promise. */
    function Async<T extends (...args: any[]) => any>(func: (player: Player, ...args: unknown[]) => ReturnType<T>): (...args: FunctionArguments<T>) => Promise<ReturnType<T>>

    /** An asynchronous function that should fire one-way without returning */
    function AsyncVoid<T extends (...args: any[]) => void>(func: (player: Player, ...args: unknown[]) => void): (...args: FunctionArguments<T>) => void

    class Connection<T extends (...args: any[]) => void> {
        constructor(listener: T )
    }
    class Event<T extends (...args: any[]) => void> {
        constructor()
        Fire(...args: FunctionArguments<T>): void
        Wait(): ReturnType<T>
        Connect(functionHandler: T): Connection<T>
        DisconnectAll(): void
        Destroy(): void
    }
    class ListenerList {
        constructor()
    
        Connect<T extends Aero.Event<U> | RBXScriptSignal<U>, U extends (...args: any[]) => void>(event: T, func: U): T
        BindToRenderStep(name: string, priority: number, func: (deltaTime: number) => void): void
        BindAction(
            actionName: string,
            funcToBind: (actionName: string, inputState: Enum.UserInputState, inputObj: InputObject) => void,
            createTouchBtn: boolean,
            ...inputTypes: (Enum.KeyCode | Enum.PlayerActions | Enum.UserInputType)[]
        ): void
        BindActionAtPriority(
            actionName: string,
            funcToBind: (actionName: string, inputState: Enum.UserInputState, inputObj: InputObject) => void,
            createTouchBtn: boolean,
            priorityLevel: number,
            ...inputTypes: (Enum.KeyCode | Enum.PlayerActions | Enum.UserInputType)[]
        ): void
    
        DisconnectAll(): void
        DisconnectEvents(): void
        DisconnectRenderSteps(): void
        DisconnectActions(): void
    }
} 