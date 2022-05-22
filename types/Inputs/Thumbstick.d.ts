import DigitalInput from "./DigitalInput";

export default class Thumbstick extends DigitalInput {
	public readonly RawLocation: Vector2;
	public readonly Location: Vector2;
	public readonly EdgeThreshold: number;
	public readonly IsEdge: boolean;
	public readonly Released: RBXScriptSignal;
	public readonly Changed: RBXScriptSignal;
	public readonly EdgeEntered: RBXScriptSignal;
	public readonly EdgeLeft: RBXScriptSignal;

	public constructor(edgeThreshold: number);

	public UpdateLocationAbsolute(loc: Vector2): void;

	public UpdateLocationDelta(delta: Vector2): void;

	public SetEdgeThreshold(edgeThreshold: number): void;
}
