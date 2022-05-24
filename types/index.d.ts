export * as ControllerAdornees from "./ControllerAdornees";
export * as Controllers from "./Controllers";
export { Hand } from "./Hand";
export { default as Headset } from "./Headset";
export { default as LaserPointer } from "./LaserPointer";
export { default as VRCamera } from "./VRCamera";

export declare function waitForUserCFrameAsync(userCFrame: Enum.UserCFrame): Promise<void>;
