import raylib;
import renderer;
import scene;
import scenes.marching_cube_scene;
import scenes.reality_scene;
import scenes.voxel_scene;

void main() {
	Renderer renderer = Renderer(720, 480, "Marching Cubes");
	// Scene scene = new MarchingCubeScene();
	Scene scene = new RealityScene();
	// Scene scene = new VoxelScene();

    while(!WindowShouldClose()) {
		scene.update(GetFrameTime());
			for(;;) { 
				SceneEvent e = scene.popEvent;
				if(e == SceneEvent.None) break;
				switch(e) {
					case SceneEvent.SetClearColor:
						renderer.clearColor = scene.clearColor;
					break;
					default: break;
				}
			}
		renderer.render(scene);
    }
	
    CloseWindow();
}

// vim: ts=4 sw=4

