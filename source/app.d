import raylib;
// import std.stdio;
// import std.math;
// import std.algorithm;
// import std.array;
// import std.random;
// import std.math;
// import std.string;
// import chunk;
import renderer;
import scene;

void main() {
	Renderer renderer = Renderer(720, 480, "Marching Cubes");
	Scene scene = new Scene();
/* 
	DrawBoundingBox(chunk.modelBB, Colors.WHITE);
	DrawCube(Vector3(2,0,2), 1, 1, 1, Colors.GREEN);
	DrawSphere(lightPosition, 0.5, Colors.WHITE);
*/

    while(!WindowShouldClose()) {
		scene.update(GetFrameTime());
		renderer.render(scene);
    }
	
    CloseWindow();
}

// vim: ts=4 sw=4

