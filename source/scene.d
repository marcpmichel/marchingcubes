module scene;

import raylib;
import renderable;
import chunk;
import std.math : cos, sin;

struct Lighting {
	Vector3 ambientColor;
	Vector3 lightPosition = Vector3(0.0, 20.0, 0.0);
	Shader shader;
	int ambientColorLoc;
	int lightPosLoc;
    float angle = 0.0;

    void setup() {
        shader = LoadShader("vs.glsl", "fs.glsl");
        lightPosLoc = GetShaderLocation(shader, "lightPosition");

        ambientColorLoc = GetShaderLocation(shader, "ambientColor");
        ambientColor = Vector3(0.9, 0.9, 1.0);
        SetShaderValue(shader, ambientColorLoc, &ambientColor, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    }

    void update(float delta) {
		angle = (angle + delta) % (PI * 2.0);
		lightPosition.x = cos(angle) * 30.0;
		lightPosition.z = sin(angle) * 30.0;
        SetShaderValue(shader, lightPosLoc, &lightPosition, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    }
}

class Scene {
    Renderable[] renderables;
    Lighting lighting = Lighting();
    uint sunId;

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
        renderables ~= Renderable(RenderableType.Light, lighting.lightPosition);

        renderables ~= Renderable(RenderableType.Grid, Vector3Zero);

        Mesh cubeMesh = GenMeshCube(2.0, 2.0, 2.0);
        cubeModel = LoadModelFromMesh(cubeMesh);
        cubeModel.materials[0].shader = lighting.shader; // if you miss this, then the shader would not be applied to this object
        renderables ~= Renderable(RenderableType.Model, Vector3(0,0,0), cubeModel);

        // marching cube
        auto chunk = new Chunk!(20,20,20)();
        // chunk.fillWithSphere(Vector3(8,8,8), 4);
        // chunk.fillWithTerrain();
        chunk.fillCorridor();
        chunk.triangulate();
        chunk.createMesh(Colors.RED, true);
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
        renderables[sunId].position = lighting.lightPosition;
    }
}