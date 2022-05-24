import Quest2Controller from "./Controllers/Quest2Controller";

export default class LaserPointer {
	private RenderStepDisconnect: Callback;
	public Controller: Quest2Controller; // TODO: Update when more controllers are supported
	public readonly RootPart: Part;
	public Length: number;
	public Visible: boolean;
	public RaycastParams: RaycastParams;
	public readonly RaycastResult: RaycastResult;
	public readonly Destroying: RBXScriptSignal;

	public constructor(controller: Quest2Controller);

	public Destroy(): void;
}
