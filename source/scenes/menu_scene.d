module scenes.menu_scene;

import scene;
import events;
import raylib: Rectangle, Colors;
import raygui;

class MenuScene : Scene {
    string[] items = [ "One", "Two", "Three" ];

    this() {
    }

    override void update(float delta) {
        uiCamera.zoom += delta;
    }

    override void drawUI() {
        GuiPanel(Rectangle(160, 100, 320, 200), "Scene selection");
        bool one = GuiButton(Rectangle(180, 140, 280, 20), "One");
        bool two = GuiButton(Rectangle(180, 180, 280, 20), "Two");
        bool three = GuiButton(Rectangle(180, 220, 280, 20), "Three");
        // if(one) UIBroadcaster.send(UIEvent(EventType.Scene, "One"));
        // if(two) UIBroadcaster.send(UIEvent(EventType.Scene, "Two"));
        // if(three) UIBroadcaster.send(UIEvent(EventType.Scene, "Three"));
    }
}