module scene;

import raylib;
import renderable;
import marching_cube;
import reality;
import std.math : cos, sin;
import lighting;
import std.range: front, popFront;

enum SceneEvent { None, SetClearColor }

class Scene {
    Renderable[] renderables;
    uint renderableId = 0;
    Color clearColor;
    SceneEvent[] events;

    Lighting lighting = Lighting();
    uint sunId;
    uint realityId;

	float angle = 0;

	auto camera = Camera3D(
			Vector3(0, 0, 8),             // Camera position
			Vector3(0, 0, 0),               // Camera looking at point
			Vector3(0, 1, 0),               // Camera up vector (rotation towards target)
			60,                             // Camera field-of-view Y
			CameraProjection.CAMERA_PERSPECTIVE);     // Camera mode type

    this() {
        lighting.setup();
    }

    ~this() {
        lighting.teardown();
    }

    final uint addRenderable(Renderable r) {
        renderables ~= r;
        return renderableId++;
    }

    void setClearColor(Color c) {
        clearColor = c;
        events ~= SceneEvent.SetClearColor;
    }

    void drawUI() {
    }

    bool hasEvents() { return events.length > 0; }
    SceneEvent popEvent() { 
        if(events.length < 1) return SceneEvent.None;
        SceneEvent e=events.front; 
        events.popFront; 
        return e; 
    }

    void update(float delta) {
	    UpdateCamera(&camera, CameraMode.CAMERA_FREE);
        lighting.update(delta);
        renderables[sunId].position = lighting.lightPosition;
        renderables[realityId].position = Vector3(-2, 0, -2);
    }
}