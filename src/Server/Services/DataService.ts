import * as Aero from "Shared/Modules/Aero"
import Cache = require("Server/Modules/DataStoreCache")

// Data Service
// Crazyman32
// February 3, 2017

/*
	
	Server:
		PLAYER DATA METHODS:
	
			DataService:Set(player, key, value)
			DataService:Get(player, key)
			DataService:Remove(player, key)
			DataService:Flush(player)
			DataService:FlushKey(player, key)
			DataService:FlushAll()
			DataService:FlushAllConcurrent()
		GLOBAL DATA METHODS:
				
			DataService:SetGlobal(key, value)
			DataService:GetGlobal(key)
			DataService:RemoveGlobal(key)
			DataService:OnUpdateGlobal(key, callback)
			DataService:FlushGlobal(key)
			DataService:FlushAllGlobal()
		CUSTOM DATA METHODS:
		
			DataService:SetCustom(name, scope, key, value)
			DataService:GetCustom(name, scope, key)
			DataService:RemoveCustom(name, scope, key)
			DataService:OnUpdateCustom(name, scope, key, callback)
			DataService:FlushCustom(name, scope, key)
			DataService:FlushAllCustom(name, scope, key)
		
		GAME CLOSING CALLBACK:
			DataService:BindToClose(callbackFunction)
		EVENTS:
			DataService.PlayerFailed(player, method, key, errorMessage)
			DataService.GlobalFailed(method, key, errorMessage)
			DataService.CustomFailed(name, scope, method, key, errorMessage)
		
	
	Client:
	
		DataService:Get(key)
		DataService.Failed(method, key, errorMessage)
	
*/


const SCOPE = "PlayerData"
const AUTOSAVE_INTERVAL = 60

const NAME_SCOPE_KEY_FORMAT = "name=%s;scope=%s"

const PLAYER_FAILED_EVENT = new Aero.Event<(player: Player, method: string, key: string, errMsg: string) => void>()
const GLOBAL_FAILED_EVENT = new Aero.Event<(method: string, key: string, errMsg: string) => void>()
const CUSTOM_FAILED_EVENT = new Aero.Event<(name: string, scope: string, method: string, key: string, errMsg: string) => void>()
const CLIENT_FAILED_EVENT = new Aero.Event<(player: Player, method: string, key: string, errMsg: string) => void>()

const playerCaches = new Map<Player, Cache>()
const customCaches = new Map<string, Cache>()
let globalCache: Cache

const boundToCloseFuncs: (() => void)[] = []

export class DataService extends Aero.Service {
    private GameClosing = false
    private PlayerFailedEvent = PLAYER_FAILED_EVENT
    private GlobalFailedEvent = GLOBAL_FAILED_EVENT
    private CustomFailedEvent = CUSTOM_FAILED_EVENT
    private ClientFailedEvent = CLIENT_FAILED_EVENT
    GetPlayerCache(player: Player) {
        let cache = playerCaches.get(player)
        if ((!cache)) {
            if ((player.UserId > 0)) {
                cache = new Cache(tostring(player.UserId), SCOPE)
            } else {
                // Guest/offline cache (not linked to DataStore):
                cache = new Cache()
            }
            playerCaches.set(player, cache)
            cache.Failed.Connect((method, key, errMsg) => {
                this.PlayerFailedEvent.Fire(player, method, key, errMsg)
                this.ClientFailedEvent.Fire(player, method, key, errMsg)
            })
        }
        return cache
    }
    GetCustomCache(name: string, scope: string) {
        let nameScopeKey = NAME_SCOPE_KEY_FORMAT.format(name, scope)
        let cache = customCaches.get(nameScopeKey)
        if ((!cache)) {
            cache = new Cache(name, scope)
            customCaches.set(nameScopeKey, cache)
            cache.Failed.Connect((method, key, errMsg) => {
                this.CustomFailedEvent.Fire(name, scope, method, key, errMsg)
            })
        }
        return cache
    }
    Set(player: Player, key: string, value: unknown) {
        this.GetPlayerCache(player).Set(key, value)
    }
    Get(player: Player, key: string) {
        return this.GetPlayerCache(player).Get(key)
    }
    Remove(player: Player, key: string) {
        this.GetPlayerCache(player).Remove(key)
    }
    SetGlobal(key: string, value: any) {
        globalCache.Set(key, value)
    }
    GetGlobal(key: string) {
        return globalCache.Get(key)
    }
    RemoveGlobal(key: string) {
        globalCache.Remove(key)
    }
    OnUpdateGlobal(key: string, callback: (value: any) => void) {
        return globalCache.OnUpdate(key, callback)
    }
    SetCustom(name: string, scope: string, key: string, value: any) {
        this.GetCustomCache(name, scope).Set(key, value)
    }
    GetCustom(name: string, scope: string, key: string) {
        return this.GetCustomCache(name, scope).Get(key)
    }
    RemoveCustom(name: string, scope: string, key: string) {
        this.GetCustomCache(name, scope).Remove(key)
    }
    OnUpdateCustom(name: string, scope: string, key: string, callback: (value: any) => void) {
        return this.GetCustomCache(name, scope).OnUpdate(key, callback)
    }
    Flush(player: Player) {
        this.GetPlayerCache(player).FlushAll()
    }
    FlushKey(player: Player, key: string) {
        this.GetPlayerCache(player).Flush(key)
    }
    FlushGlobal(key: string) {
        globalCache.Flush(key)
    }
    FlushAllGlobal() {
        globalCache.FlushAll()
    }
    FlushCustom(name: string, scope: string, key: string) {
        this.GetCustomCache(name, scope).Flush(key)
    }
    FlushAllCustom(name: string, scope: string, key: string) {
        this.GetCustomCache(name, scope).FlushAll()
    }
    FlushAll() {
        playerCaches.forEach(cache => {
            cache.FlushAll()
        })
        customCaches.forEach(cache => {
            cache.FlushAll()
        })
        globalCache.FlushAll()
    }
    FlushAllConcurrent() {
        // If closing, schedule synchronous flush all instead
        if (this.GameClosing) {
            Cache.GameCloseManager.Schedule(() => this.FlushAll())
            return
        }

        const thread = coroutine.running()
        let numCaches = 0
        let numFlushed = 0
        playerCaches.forEach(() => {
            numCaches++
        })
        customCaches.forEach(() => {
            numCaches++
        })
        if (numCaches === 0) { return }

        const IncFlushed = () => {
            numFlushed++
            if (numFlushed === numCaches) {
                assert(coroutine.resume(thread))
            }
        }
        playerCaches.forEach(cache => {
            spawn(() => {
                cache.FlushAllConcurrent()
                IncFlushed()
            })
        })
        customCaches.forEach(cache => {
            print("Saving custom cache", cache)
            spawn(() => {
                cache.FlushAll()
                IncFlushed()
            })
        })
        globalCache.FlushAll()
        coroutine.yield()
    }
    BindToClose(func: () => void) {
        boundToCloseFuncs.push(func)
    }
    AutoSaveLoop() {
        while ((!this.GameClosing)) {
            this.FlushAll()
            wait(AUTOSAVE_INTERVAL)
        }
    }
    Start() {
	
        this.GameClosing = false
        
        const FireBoundToCloseCallbacks = () => {
            boundToCloseFuncs.forEach(func => {
                Cache.GameCloseManager.Schedule(() => {
                    pcall(func)
                })
            })
        }
        
        // Flush cache:
        const PlayerRemoving = (player: Player) => {
            if ((this.GameClosing)) { return }
            this.Flush(player)
            wait(5)
            const cache = playerCaches.get(player)
            if (cache) {
                cache.Destroy()
                playerCaches.delete(player)
            }
        }
        
        const GameClosing = () => {
            this.GameClosing = true
            Cache.GameCloseManager.HandleScheduledRequests()

            FireBoundToCloseCallbacks()
            playerCaches.forEach(cache => {
                Cache.GameCloseManager.Schedule(() => cache.FlushAll())
            })
            customCaches.forEach(cache => {
                Cache.GameCloseManager.Schedule(() => cache.FlushAll())
            })
            Cache.GameCloseManager.Schedule(() => globalCache.FlushAll())

            Cache.GameCloseManager.CompleteRequestsUntilFinished()
        }
        
        game.GetService("Players").PlayerRemoving.Connect(PlayerRemoving)
        
        game.BindToClose(GameClosing)
        
        delay(AUTOSAVE_INTERVAL, () => {
            this.AutoSaveLoop()
        })
        
    }
    Init() {
    
        globalCache = new Cache("global", "global")
        globalCache.Failed.Connect((method, key, errMsg) => {
            this.GlobalFailedEvent.Fire(method, key, errMsg)
        })
    
    }

    // Temporarily disabled until existing data store system can be ported
    Disabled = true
}


export class DataServiceClient extends Aero.ClientInterface<DataService> {
    ClientFailed = Aero.ClientEvent(CLIENT_FAILED_EVENT)
    Get = Aero.ServerSync<(key: string) => any>((player, key) => {
        if (typeof key === "string") {
            return this.Server.Get(player, key)
        }
    })
}