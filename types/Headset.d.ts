import VRDevice from "./VRDevice";

export default class Headset extends VRDevice {
	public readonly RawUserCFrame: CFrame;
	public readonly RawUserPosition: Vector3;
	public UserCFrameOffset: CFrame;
	public UserPositionOffset: Vector3;

	public constructor();

	public Recenter(): void;
}
