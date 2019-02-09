# Aero-ts Change Log

### Version 1.0.1
- Removed support for RegisterEvent. Events are now constructed using the following syntax:
```ts
const MY_EVENT = new Aero.Event<(myParameter: string) => void>()
```
- Renamed ClientInterface wrappers `Aero.Sync`, `Aero.Async`, `Aero.AsyncVoid` to `Aero.ServerSync`, `Aero.ServerAsync`, `Aero.ServerAsyncVoid`
- Added two more ClientInterface wrappers, whick take in an event as a paremeter: `Aero.ClientEvent` and `Aero.AllClientsEvent`. This is now the only way to register client events; type safety can be preserved using these wrappers.
- Controllers and Services folder now load services recursively. This is made possible by the fact that roblox-ts modules have multiple exports.
Only Controller and Service classes exported from their respective modules will be instanced and started. All other exports will be ignored.

Sub-folders must now be added to the global registry as "FolderName.ModuleName"
For example, if you wanted to create a folder of WeaponControllers, you can now add them to the global registry like this:
```ts
import {WeaponInputController} from "Client/Controllers/WeaponControllers/WeaponInputController"

interface GlobalAeroControllers extends Record<string, Aero.Controller> {
    WeaponControllers {
        WeaponInputController: WeaponInputController
    }
}
```
Note that registered names must strictly match folder/module names, regardless of what is exported.
- Added functions `Aero.GetServer()`, `Aero.GetClient()`, `Aero.WaitForServer()`, and `Aero.WaitForServer()`
Thes can be used to access the aero core with type safety. Use this instead of _G.AeroServer and _G.AeroClient, as it may be deprecated in the future.
- StoreService and DataService now have typesafe client interfaces—and now include runtime type checks that were missing in the original AGF
