module lighting;

import raylib;
import std.math;

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
		angle = (angle + delta) % (raylib.PI * 2.0);
		lightPosition.x = cos(angle) * 30.0;
		lightPosition.z = sin(angle) * 30.0;
        SetShaderValue(shader, lightPosLoc, &lightPosition, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    }

    void teardown() {
        UnloadShader(shader);
    }
}
