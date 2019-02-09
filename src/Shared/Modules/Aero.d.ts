export = Aero
declare namespace Aero {
    abstract class Service {
        /** If set to true, the service will not be initialized or started. */
        public Disabled?: boolean

        /** Asynchronous function called at runtime after all services have been initialized */
        public Start(): void
        /** Synchronous function called at runtime after all services have been imported, but before they are started */
        public Init(): void

        /** Server-side services */
        Services: GlobalAeroServices
        /** (DEPRECATED) Server-side modules */
        //Modules: GlobalAeroServerModules
        /** (DEPRECATED) Shared modules */
        //Shared: GlobalAeroSharedModules
    }
    abstract class Controller {
        /** If set to true, the controller will not be initialized or started. */
        public Disabled?: boolean

        /** Asynchronous function called at runtime after all controllers have been initialized */
        public Start(): void
        /** Synchronous function called at runtime after all controllers have been imported, but before they are started */
        public Init(): void

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

    /** Wraps an event in a single-client event interface */
    // @ts-ignore
    function ClientEvent<T extends (player: Player, ...args: any[]) => any>(event: Event<T>): Event<(...args: (ClientEventArguments<T>)) => void>

    type ClientEventArguments<T> = T extends (player: Player, ...args: infer U) => void ? U : never;
    type x<T extends (player: Player, ...args: any[]) => void> = (...args: ClientEventArguments<T>) => void
    const x: x<(player: Player, thing: string) => void>

    /** Wraps an event in a "all clients" event interface */
    function AllClientsEvent<T extends (...args: any[]) => any>(event: Event<T>): Event<T>

    /** An asynchronous function that should fire two ways and yield, but with unkown user input types. */
    function ServerSync<T extends (...args: any[]) => any>(func: (player: Player, ...args: unknown[]) => ReturnType<T>): (...args: FunctionArguments<T>) => ReturnType<T>

    /** An asynchronous function that should fire one-way and return a promise. */
    function ServerAsync<T extends (...args: any[]) => any>(func: (player: Player, ...args: unknown[]) => ReturnType<T>): (...args: FunctionArguments<T>) => Promise<ReturnType<T>>

    /** An asynchronous function that should fire one-way without returning */
    function ServerAsyncVoid<T extends (...args: any[]) => void>(func: (player: Player, ...args: unknown[]) => void): (...args: FunctionArguments<T>) => void

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

    type AeroServer = Service
    type AeroClient = Controller

    /** Gets the aero server if it has been loaded */
    function GetServer(): AeroServer | undefined
    /** Gets the aero server if it has been loaded */
    function GetClient(): AeroClient | undefined
    /** Yields until the aero server has been loaded */
    function WaitForServer(): AeroServer
    /** Yields until the aero client has been loaded */
    function WaitForClient(): AeroClient

    function CallAll(componentList: Object, asynchronous: boolean, functionName: string, ...params: any[]): void
} 