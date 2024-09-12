module renderer;

import raylib;
import renderable;
import scene;

struct Renderer {

    uint viewPortWidth = 720;
    uint viewPortHeight = 480;
    @property Color clearColor = Color(0x9E, 0xEC, 0xFF);

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
		    ClearBackground(clearColor);
            // rlDisableBackfaceCulling();
		    BeginMode3D(scene.camera);
                foreach(r; scene.renderables) {
                    switch(r.type) {
                        case RenderableType.Model:
                            DrawModel(r.model, r.position, 1.0, Colors.WHITE);
                            if(r.bounding_box) {
                                DrawBoundingBox(GetModelBoundingBox(r.model), Colors.WHITE);
                            }
                        break;
                        case RenderableType.Light:
                            DrawSphere(r.position, 0.5, Colors.WHITE);
                        break;
                        case RenderableType.Grid:
                            DrawGrid(10, 1);
                        break;
                        case RenderableType.Gizmo:
                            DrawLine3D(Vector3Zero, Vector3(1,0,0), Colors.RED);
                            DrawLine3D(Vector3Zero, Vector3(0,1,0), Colors.GREEN);
                            DrawLine3D(Vector3Zero, Vector3(0,0,1), Colors.BLUE);
                        break;
                        default:
                        break;
                    }
                }
		    EndMode3D();
	    EndDrawing();
    }
}