module noro.pages.menu;

import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.page;
import noro.programs.editor;
import noro.pages.survivalGuide;

Element[] MenuPage() {
	Element[] ret;

	ret ~= new TextElement("Welcome to noro!");
	ret ~= new TextElement("Select a program from the list below");
	ret ~= new TextElement("");

	ret ~= new LinkElement("Text editor", () {
		auto app = App.Instance();

		auto window    = new UIWindow(50, 30);
		window.pos     = Vec2!ushort(0, 1);
		window.name    = "Editor";
		window.program = new EditorProgram();
		app.ui.Add(window);
	});

	ret ~= new LinkElement("Survival guide", () {
		auto app = App.Instance();

		auto bufSize = app.screen.buffer.GetSize();

		auto window    = new UIWindow(bufSize.x, cast(ushort) (bufSize.y - 1));
		window.pos     = Vec2!ushort(0, 1);
		window.name    = "Survival guide";
		window.program = new PageProgram(SurvivalGuidePage());
		app.ui.Add(window);
	});

	return ret;
}
