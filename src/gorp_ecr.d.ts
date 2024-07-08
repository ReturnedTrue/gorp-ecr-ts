import ecr from "@rbxts/ecr";
import gorp from "@rbxts/gorp";

declare namespace gorp_ecr {
	export function init(packages: { ecr: typeof ecr, gorp: typeof gorp }): void;
}

export default gorp_ecr;
