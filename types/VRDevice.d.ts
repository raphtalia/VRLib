export default class VRDevice {
	public readonly CFrame: CFrame;
	public readonly Position: Vector3;
	public readonly Velocity: Vector3;
	public readonly Destroying: RBXScriptSignal;

	public Destroy(): void;
}
