declare class SmoothDamp {
	public MaxSpeed: number
	Update(currentVector: Vector3, targetVector: Vector3, smoothTime: number): Vector3
	UpdateAngle(currentVector: Vector3, targetVector: Vector3, smoothTime: number): Vector3
}

export = Smooth

declare class Smooth {
    constructor(initialValue: Vector3, smoothTime: number)
    static SmoothDamp: SmoothDamp
    
    public Value: Vector3
	public Goal: Vector3
	public SmoothTime: number
	
	Update(goal: Vector3): Vector3
	UpdateAngle(goal: Vector3): Vector3
	SetMaxSpeed(speed: number): void
	GetMaxSpeed(): number
}