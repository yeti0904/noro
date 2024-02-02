module noro.pages.survivalGuide;

import std.array;
import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.page;

private static const string[] pages = [
	cast(string) import("runtime/survivalGuide/00-noro.txt"),
	cast(string) import("runtime/survivalGuide/01-editor.txt"),
	cast(string) import("runtime/survivalGuide/02-files.txt")
];

private enum Page {
	Noro   = 0,
	Editor = 1,
	Files  = 2
}

private static Element[] homePage;

private Element[] MakePage(string text) {
	Element[] ret;

	ret ~= new LinkElement("Home page", (PageProgram page) {
		page.LoadElements(homePage);
	});
	ret ~= new TextElement("");

	foreach (ref line ; text.split("\n")) {
		ret ~= new TextElement(line);
	}

	return ret;
}

Element[] SurvivalGuidePage() {
	homePage = [];
	homePage ~= new TextElement("Noro surival guide");
	homePage ~= new TextElement("Written by yeti0904");
	homePage ~= new TextElement("");
	homePage ~= new TextElement("Pages:");
	homePage ~= new LinkElement("00 - noro", (PageProgram page) {
		page.LoadElements(pages[Page.Noro].MakePage());
	});
	homePage ~= new LinkElement("01 - editor", (PageProgram page) {
		page.LoadElements(pages[Page.Editor].MakePage());
	});
	homePage ~= new LinkElement("02 - file manager", (PageProgram page) {
		page.LoadElements(pages[Page.Files].MakePage());
	});

	return homePage;
}
