import { Hand } from "../Hand";
import Button from "../Inputs/Button";
import Thumbstick from "../Inputs/Thumbstick";
import Trigger from "../Inputs/Trigger";
import VRDevice from "../VRDevice";

export default class Quest2Controller extends VRDevice {
	private RenderStepDisconnect: Callback;
	public readonly WorldCFrame: CFrame;
	public readonly WorldPosition: Vector3;
	public readonly Hand: Hand;
	public GamepadNum: Enum.UserInputType;
	public TouchpadMode: Enum.VRTouchpadMode;
	public readonly Controls: {
		GripTrigger: Trigger;
		IndexTrigger: Trigger;
		Thumbstick: Thumbstick;
		Button1: Button;
		Button2: Button;
	};
	public readonly VibrationValue: number;

	public constructor(hand: Hand, gamepadNum?: Enum.UserInputType);

	public SetMotor(vibrationValue: number): void;

	public Vibrate(vibrationValue: number, duration?: number): Promise<void>;
}
