module noro.pages.survivalGuide;

import std.array;
import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.page;

private static string survivalGuide = cast(string) import("runtime/survival_guide.txt");

Element[] SurvivalGuidePage() {
	Element[] ret;

	foreach (ref line ; survivalGuide.split("\n")) {
		ret ~= new TextElement(line);
	}

	return ret;
}
