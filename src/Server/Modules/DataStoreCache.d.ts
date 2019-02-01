import Aero = require("Shared/Internal/Aero");

export = Cache
declare class Cache {
    constructor(name?: string, scope?: string)
	
	public Name?: string
    public Scope?: string
    
	public Failed: Aero.Event<(method: string, key: string, errorMessage: string) => void>
	
	Get(key: string): any
	Set(key: string, value: any): void
    Remove(key: string): void
	Load(key: string): {[0]: any, [1]: true} | undefined
    OnUpdate(key: string, callback: (value: any) => void): void
    
	Flush(key: string): void
	FlushAll(): void
    FlushAllConcurrent(): void
    
	Destroy(): void
}