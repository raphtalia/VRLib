import Headset from "./Headset";

export default class VRCamera {
	private RenderStepDisconnect: Callback;
	public Headset: Headset;
	public Height: number;
	public WorldCFrame: CFrame;
	public WorldPosition: Vector3;
	public HeadCFrame: CFrame;
	public HeadPosition: Vector3;
	public readonly Destroying: RBXScriptSignal;

	public constructor(headset: Headset);

	public Destroy(): void;
}
