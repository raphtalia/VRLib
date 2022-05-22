import VRDevice from "./VRDevice";

export default class Headset extends VRDevice {
	public Height: number;

	public constructor();

	public Recenter(): void;

	public MoveTo(cf: CFrame, addheight?: boolean): void;
}
