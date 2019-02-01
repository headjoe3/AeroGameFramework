declare class CameraShakeInstance {
    /** Creates a new camera shake instance with the given parameters */
    constructor(magnitude: number, roughness: number, fadeInTime: number, fadeOutTime: number)
}

declare type CameraShakePreset = CameraShakeInstance

export = CameraShaker
declare class CameraShaker {
    constructor(renderPriority: number, callbackFunction: (cf: CFrame) => void)
    /** A class for creating new CameraShakeInstances */
    static CameraShakeInstance: typeof CameraShakeInstance
    /** A table of CameraShakeInstance presets */
    static Presets: {
        /** A high-magnitude, short, yet smooth shake. Should happen once. */
        Bump: CameraShakePreset
        /** An intense and rough shake. Should happen once. */
        Explosion: CameraShakePreset
        /** A continuous, rough shake. Sustained. */
        Earthquake: CameraShakePreset
        /** A bizarre shake with a very high magnitude and low roughness. Sustained. */
        BadTrip: CameraShakePreset
        /** A subtle, slow shake. Sustained. */
        HandheldCamera: CameraShakePreset
        /** A very rough, yet low magnitude shake. Sustained. */
        Vibration: CameraShakePreset
        /** A slightly rough, medium magnitude shake. Sustained. */
        RoughDriving: CameraShakePreset
    }
    /** Binds the shaker to RenderStep */
    Start(): void
    /** Unbinds the shaker from RenderStep */
    Stop(): void
    /** Begins shaking with a given camera shake instance */
    Shake(shakeInstance: CameraShakeInstance): void
    /** Fades into a shake */
    ShakeSustain(shakeInstance: CameraShakeInstance): void
    ShakeOnce(magnitude: number, roughness: number, fadeInTime?: number, fadeOutTime?: number, posInfluence?: Vector3, rotInfluence?: Vector3): void
    StartShake(magnitude: number, roughness: number, fadeInTime?: number, posInfluence?: Vector3, rotInfluence?: Vector3): void
}