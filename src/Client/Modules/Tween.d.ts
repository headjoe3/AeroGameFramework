declare interface Easing {
	In: {
		Linear: (t: number, b: number, c: number, d: number) => number;
		Sine: (t: number, b: number, c: number, d: number) => number;
		Back: (t: number, b: number, c: number, d: number, s?: number) => number;
		Quad: (t: number, b: number, c: number, d: number) => number;
		Quart: (t: number, b: number, c: number, d: number) => number;
		Quint: (t: number, b: number, c: number, d: number) => number;
		Bounce: (t: number, b: number, c: number, d: number) => number;
		Elastic: (t: number, b: number, c: number, d: number, a: number, p: number) => number;
		Expo: (t: number, b: number, c: number, d: number) => number;
		Cubic: (t: number, b: number, c: number, d: number) => number;
		Circ: (t: number, b: number, c: number, d: number) => number;
	};
	Out: {
		Linear: (t: number, b: number, c: number, d: number) => number;
		Sine: (t: number, b: number, c: number, d: number) => number;
		Back: (t: number, b: number, c: number, d: number, s?: number) => number;
		Quad: (t: number, b: number, c: number, d: number) => number;
		Quart: (t: number, b: number, c: number, d: number) => number;
		Quint: (t: number, b: number, c: number, d: number) => number;
		Bounce: (t: number, b: number, c: number, d: number) => number;
		Elastic: (t: number, b: number, c: number, d: number, a: number, p: number) => number;
		Expo: (t: number, b: number, c: number, d: number) => number;
		Cubic: (t: number, b: number, c: number, d: number) => number;
		Circ: (t: number, b: number, c: number, d: number) => number;
	};
	InOut: {
		Linear: (t: number, b: number, c: number, d: number) => number;
		Sine: (t: number, b: number, c: number, d: number) => number;
		Back: (t: number, b: number, c: number, d: number, s?: number) => number;
		Quad: (t: number, b: number, c: number, d: number) => number;
		Quart: (t: number, b: number, c: number, d: number) => number;
		Quint: (t: number, b: number, c: number, d: number) => number;
		Bounce: (t: number, b: number, c: number, d: number) => number;
		Elastic: (t: number, b: number, c: number, d: number, a: number, p: number) => number;
		Expo: (t: number, b: number, c: number, d: number) => number;
		Cubic: (t: number, b: number, c: number, d: number) => number;
		Circ: (t: number, b: number, c: number, d: number) => number;
	};
	OutIn: {
		Sine: (t: number, b: number, c: number, d: number) => number;
		Back: (t: number, b: number, c: number, d: number, s?: number) => number;
		Quad: (t: number, b: number, c: number, d: number) => number;
		Quart: (t: number, b: number, c: number, d: number) => number;
		Quint: (t: number, b: number, c: number, d: number) => number;
		Bounce: (t: number, b: number, c: number, d: number) => number;
		Elastic: (t: number, b: number, c: number, d: number, a: number, p: number) => number;
		Expo: (t: number, b: number, c: number, d: number) => number;
		Cubic: (t: number, b: number, c: number, d: number) => number;
		Circ: (t: number, b: number, c: number, d: number) => number;
	};
}

export = Tween
declare class Tween {
    constructor(tweenInfo: TweenInfo, callbackFunction: (updatedValue: number) => void)
    static Easing: Easing
    Play(): void
    Pause(): void
    Cancel(): void
    ResetState(): void
}