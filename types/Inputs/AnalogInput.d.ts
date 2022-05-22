export default class AnalogInput {
	public readonly Position: number;
	public readonly IsDown: boolean;
	public readonly IsFullyDown: boolean;
	public readonly Up: RBXScriptSignal;
	public readonly Down: RBXScriptSignal;
	public readonly FullyUp: RBXScriptSignal;
	public readonly FullDown: RBXScriptSignal;
	public readonly Changed: RBXScriptSignal;
}
