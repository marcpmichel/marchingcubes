import raylib;
import renderer;
import scene;

void main() {
	Renderer renderer = Renderer(720, 480, "Marching Cubes");
	Scene scene = new Scene();

    while(!WindowShouldClose()) {
		scene.update(GetFrameTime());
		renderer.render(scene);
    }
	
    CloseWindow();
}

// vim: ts=4 sw=4

