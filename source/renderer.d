module renderer;

import raylib;
import renderable;
import scene;

struct Renderer {

    uint viewPortWidth = 720;
    uint viewPortHeight = 480;

    this(uint width, uint height, const(char*)windowTitle) {
        viewPortHeight = height;
        viewPortWidth = width;

        InitWindow(viewPortWidth, viewPortHeight, windowTitle);

        SetExitKey(KeyboardKey.KEY_ESCAPE);

        DisableCursor(); // Limit cursor to relative movement inside the window
        SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    }

    void render(Scene scene) {
	    BeginDrawing();
		    ClearBackground(Colors.BLACK);
		    BeginMode3D(scene.camera);
                foreach(r; scene.renderables) {
                    switch(r.type) {
                        case RenderableType.Model:
                            DrawModel(r.model, r.position, 1.0, Colors.WHITE);
                        break;
                        case RenderableType.Light:
                            DrawSphere(r.position, 0.5, Colors.WHITE);
                        break;
                        case RenderableType.Grid:
                            DrawGrid(10, 1);
                        break;
                        default:
                        break;
                    }
                }
		    EndMode3D();
	    EndDrawing();
    }
}