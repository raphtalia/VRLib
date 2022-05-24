export default class VRDevice {
	public readonly UserCFrame: CFrame;
	public readonly UserPosition: Vector3;
	public readonly Velocity: Vector3;
	public readonly Destroying: RBXScriptSignal;

	public Destroy(): void;
}
