import Aero = require("Shared/Modules/Aero");

declare class Gamepad {
    IsDown(keyCode: Enum.KeyCode): boolean
	IsConnected(): boolean
	GetState(keyCode: Enum.KeyCode): InputObject
	SetMotor(motor: Enum.VibrationMotor, value: number): void
	StopMotor(motor: Enum.VibrationMotor): void
	StopAllMotors(): void
	IsMotorSupported(motor: Enum.VibrationMotor): boolean
	IsVibrationSupported(): boolean
	GetMotorValue(motor: Enum.VibrationMotor): number
	ApplyDeadzone(value: number, deadzoneThreshold: number): number
	
	static ButtonDown: Aero.Event<(keyCode: Enum.KeyCode) => void>
	static ButtonUp: Aero.Event<(keyCode: Enum.KeyCode) => void>
	static Changed: Aero.Event<(keyCode: Enum.KeyCode, input: InputObject) => void>
	static Connected: Aero.Event<() => void>
	static Disconnected(): Aero.Event<() => void>
}

declare class Keyboard {
    IsDown(keyCode: Enum.KeyCode): boolean
	AreAllDown(...keyCodes: Enum.KeyCode[]): boolean
	AreAnyDown(...keyCodes: Enum.KeyCode[]): boolean
}

declare class Mouse {
    GetPosition(): Vector2
	GetDelta(): Vector2
	Lock(): void
	LockCenter(): void
	Unlock(): void
	SetMouseIcon(iconId: number): void
	SetMouseIconEnabled(isEnabled: boolean): void
	IsMouseIconEnabled(): boolean
	Cast(ignoreDescendantsInstance: Instance, terrainCellsAreCubes?: boolean, ignoreWater?: boolean): [BasePart | undefined, Vector3, Vector3, Enum.Material]
	CastWithIgnoreList(ignoreDescendantsTable: Instance[], terrainCellsAreCubes?: boolean, ignoreWater?: boolean): [BasePart | undefined, Vector3, Vector3, Enum.Material]
	CastWithWhitelist(whitelistDescendantsTable: Instance[], ignoreWater?: boolean): [BasePart | undefined, Vector3, Vector3, Enum.Material]
	
	static LeftDown: Aero.Event<() => void>
	static LeftUp: Aero.Event<() => void>
	static RightDown: Aero.Event<() => void>
	static RightUp: Aero.Event<() => void>
	static MiddleDown: Aero.Event<() => void>
	static MiddleUp: Aero.Event<() => void>
	static Moved: Aero.Event<() => void>
    static Scrolled: Aero.Event<(amount: number) => void>
}

export = UserInput
declare class UserInput extends Aero.Controller {
    Init(): void

    Get(type: "Gamepad"): Gamepad
    Get(type: "Keyboard"): Keyboard
    Get(type: "Mouse"): Mouse
    Get(type: "Gamepad" | "Keyboard" | "Mouse"): Object
}