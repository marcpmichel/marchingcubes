module scene;

import raylib;
import renderable;
import chunk;
import std.math : cos, sin;

struct Lighting {
	Shader shader;
	int ambientColorLoc;
	Vector3 ambientColor;
	int lightPosLoc;
	Vector3 lightPosition = Vector3(0.0, 30.0, 0.0);
    float angle = 0.0;

    void setup() {
        shader = LoadShader("vs.glsl", "fs.glsl");
        lightPosLoc = GetShaderLocation(shader, "lightPosition");
        ambientColorLoc = GetShaderLocation(shader, "ambientColor");
        ambientColor = Vector3(1.0, 1.0, 1.0);
        SetShaderValue(shader, ambientColorLoc, &ambientColor, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    }

    void update(float delta) {
		angle = angle + delta;
		lightPosition.x = cos(angle) * 30.0;
		lightPosition.z = sin(angle) * 30.0;
        SetShaderValue(shader, lightPosLoc, &lightPosition, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    }
}

class Scene {
    Renderable[] renderables;
    Lighting lighting = Lighting();
    Renderable sun;

	float angle = 0;

    Model cubeModel;

	auto camera = Camera3D(
			Vector3(0, 0, 8),             // Camera position
			Vector3(0, 0, 0),               // Camera looking at point
			Vector3(0, 1, 0),               // Camera up vector (rotation towards target)
			60,                             // Camera field-of-view Y
			CameraProjection.CAMERA_PERSPECTIVE);     // Camera mode type


    this() {
        lighting.setup();
        sun = Renderable(RenderableType.Light, lighting.lightPosition);
        renderables ~= sun;

        Mesh cubeMesh = GenMeshCube(2.0, 2.0, 2.0);
        cubeModel = LoadModelFromMesh(cubeMesh);
        cubeModel.materials[0].shader = lighting.shader; // if you miss this, then the shader would not be applied to this object
        renderables ~= Renderable(RenderableType.Model, Vector3(0,0,0), cubeModel);

        // marching cube
        Chunk chunk = new Chunk();
        // chunk.fillWithSphere(Vector3(8,8,8), 4);
        chunk.fillWithTerrain();
        chunk.triangulate();
        chunk.createMesh(Colors.RED);
        chunk.createModel(Colors.RED, lighting.shader);
        renderables ~= Renderable(RenderableType.Model, Vector3(2,0,2), chunk.model);
    }

    ~this() {
        UnloadModel(cubeModel);
        UnloadShader(lighting.shader);
    }

    void update(float delta) {
	    UpdateCamera(&camera, CameraMode.CAMERA_FREE);
        lighting.update(delta);
        sun.position = lighting.lightPosition;
    }
}