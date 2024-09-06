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
				DrawGrid(10, 1);
                foreach(r; scene.renderables) {
                    switch(r.type) {
                        case RenderableType.Model:
                            DrawModel(r.model, r.position, 1.0, Colors.WHITE);
                        break;
                        case RenderableType.Light:
                            DrawSphere(r.position, 0.5, Colors.WHITE);
                        break;
                        default:
                        break;
                    }
                }
				// BeginShaderMode(shader); // optional ?
					// DrawCube(Vector3(0,0.5,0), 1,1,1, Colors.GREEN);
					// DrawModel(cubeModel, Vector3(0,1,0), 1, Colors.BLUE);
					// DrawModel(chunk.model, Vector3(2,0,2), 1, Colors.PURPLE);
					// foreach(t; triangles) {
					// 	DrawTriangle3D(t.p[0], t.p[1], t.p[2], Colors.RED);
					// }
				// EndShaderMode();
		    EndMode3D();
	    EndDrawing();
    }
}