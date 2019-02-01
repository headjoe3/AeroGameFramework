export = PID
declare class PID {
    constructor(kp: number, ki: number, kd: number)
    SetInput(input: number, clampToMinMax?: boolean): void
    SetTarget(target: number, clampToMinMax?: boolean): void

    Compute(): number

    SetTunings(kp: number, ki: number, kd: number): void
	SetSampleTime(sampleTimeMillis: number): void
	SetOutputLimits(min: number, max: number): void
	ClearOutputLimits(): void
		
	Run(callbackBefore: (oldValue: number) => void, callbackAfter: (newValue: number) => void): void
	Stop(): void
	Pause(): void
	Resume(): void
		
	Clone(): PID
}