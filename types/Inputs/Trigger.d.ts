import AnalogInput from "./AnalogInput";

export default class Trigger extends AnalogInput {
	public readonly RawPosition: number;
	public readonly TriggerThreshold: number;

	public constructor(threshold: number);

	public UpdateTriggerAbsolute(pos: Vector2): void;

	public UpdateTriggerDelta(delta: Vector2): void;

	public SetTriggerThreshold(threshold: number): void;
}
