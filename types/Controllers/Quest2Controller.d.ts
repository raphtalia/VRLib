import { Hand } from "../Hand";
import Button from "../Inputs/Button";
import Thumbstick from "../Inputs/Thumbstick";
import Trigger from "../Inputs/Trigger";
import VRDevice from "../VRDevice";

export default class Quest2Controller extends VRDevice {
	private HeartbeatConnection: RBXScriptConnection;
	public readonly Hand: Hand;
	public GamepadNum: Enum.UserInputType;
	public readonly Controls: {
		GripTrigger: Trigger;
		IndexTrigger: Trigger;
		Thumbstick: Thumbstick;
		Button1: Button;
		Button2: Button;
	};
	public readonly GripTriggerPosition: number;
	public readonly IndexTriggerPosition: number;
	public readonly ThumbstickLocation: Vector2;
	public readonly VibrationValue: number;
	public readonly Button1Down: RBXScriptSignal;
	public readonly Button1Up: RBXScriptSignal;
	public readonly Button2Down: RBXScriptSignal;
	public readonly Button2Up: RBXScriptSignal;
	public readonly GripTriggerUp: RBXScriptSignal;
	public readonly GripTriggerDown: RBXScriptSignal;
	public readonly GripTriggerFullyUp: RBXScriptSignal;
	public readonly GripTriggerFullyDown: RBXScriptSignal;
	public readonly IndexTriggerUp: RBXScriptSignal;
	public readonly IndexTriggerDown: RBXScriptSignal;
	public readonly IndexTriggerFullyUp: RBXScriptSignal;
	public readonly IndexTriggerFullyDown: RBXScriptSignal;
	public readonly ThumbstickUp: RBXScriptSignal;
	public readonly ThumbstickDown: RBXScriptSignal;
	public readonly ThumbstickReleased: RBXScriptSignal;
	public readonly ThumbstickEdgeEntered: RBXScriptSignal;
	public readonly ThumbstickEdgeLeft: RBXScriptSignal;
	public readonly GripTriggerChanged: RBXScriptSignal;
	public readonly IndexTriggerChanged: RBXScriptSignal;
	public readonly ThumbstickChanged: RBXScriptSignal;

	public constructor(hand: Hand, gamepadNum?: Enum.UserInputType);

	public IsThumbstickDown(): boolean;

	public IsButton1Down(): boolean;

	public IsButton2Down(): boolean;

	public SetMotor(vibrationValue: number): void;

	public Vibrate(vibrationValue: number, duration?: number): Promise<void>;
}
