import Quest2Controller from "../Controllers/Quest2Controller";

export default class Quest2ControllerAdornee {
	private HeartbeatConnection: RBXScriptConnection;
	public Controller: Quest2Controller;
	public readonly Model: Model;
	public readonly RootPart: BasePart;
	public readonly Destroying: RBXScriptSignal;

	public constructor();

	public Destroy(): void;
}
