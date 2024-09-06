import raylib;
import std.stdio;
import std.math;
import std.algorithm;
import std.array;
import std.random;
import std.math;
import std.string;
import tables;

alias Vec3 = Vector3;
// struct Vec3 {
//     float x, y, z;
// }

struct Chunk {
    Vec3[] p; // Positions of the chunk points
    float[] val; // Values at the chunk points
}

struct Triangle {
    Vec3[3] p; // Positions of the triangle vertices
	Color c;
}

Vec3 interpolate(Vec3 p1, Vec3 p2, float val1, float val2, float isoLevel) {
    if (abs(isoLevel - val1) < 0.00001) return p1;
    if (abs(isoLevel - val2) < 0.00001) return p2;
    if (abs(val1 - val2) < 0.00001) return p1;
    float t = (isoLevel - val1) / (val2 - val1);
    return Vec3(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y), p1.z + t * (p2.z - p1.z));
}

Triangle[] marchingCubes(Chunk chunk, float isoLevel) { // , int[256] edgeTable, int[256][16] triTable) {
    int cubeIndex = 0;
    if (chunk.val[0] < isoLevel) cubeIndex |= 1;
    if (chunk.val[1] < isoLevel) cubeIndex |= 2;
    if (chunk.val[2] < isoLevel) cubeIndex |= 4;
    if (chunk.val[3] < isoLevel) cubeIndex |= 8;
    if (chunk.val[4] < isoLevel) cubeIndex |= 16;
    if (chunk.val[5] < isoLevel) cubeIndex |= 32;
    if (chunk.val[6] < isoLevel) cubeIndex |= 64;
    if (chunk.val[7] < isoLevel) cubeIndex |= 128;

    int edges = edgeTable[cubeIndex];
    if (edges == 0) return [];

    Vec3[12] vertList;
    if (edges & 1) vertList[0] = interpolate(chunk.p[0], chunk.p[1], chunk.val[0], chunk.val[1], isoLevel);
    if (edges & 2) vertList[1] = interpolate(chunk.p[1], chunk.p[2], chunk.val[1], chunk.val[2], isoLevel);
    if (edges & 4) vertList[2] = interpolate(chunk.p[2], chunk.p[3], chunk.val[2], chunk.val[3], isoLevel);
    if (edges & 8) vertList[3] = interpolate(chunk.p[3], chunk.p[0], chunk.val[3], chunk.val[0], isoLevel);
    if (edges & 16) vertList[4] = interpolate(chunk.p[4], chunk.p[5], chunk.val[4], chunk.val[5], isoLevel);
    if (edges & 32) vertList[5] = interpolate(chunk.p[5], chunk.p[6], chunk.val[5], chunk.val[6], isoLevel);
    if (edges & 64) vertList[6] = interpolate(chunk.p[6], chunk.p[7], chunk.val[6], chunk.val[7], isoLevel);
    if (edges & 128) vertList[7] = interpolate(chunk.p[7], chunk.p[4], chunk.val[7], chunk.val[4], isoLevel);
    if (edges & 256) vertList[8] = interpolate(chunk.p[0], chunk.p[4], chunk.val[0], chunk.val[4], isoLevel);
    if (edges & 512) vertList[9] = interpolate(chunk.p[1], chunk.p[5], chunk.val[1], chunk.val[5], isoLevel);
    if (edges & 1024) vertList[10] = interpolate(chunk.p[2], chunk.p[6], chunk.val[2], chunk.val[6], isoLevel);
    if (edges & 2048) vertList[11] = interpolate(chunk.p[3], chunk.p[7], chunk.val[3], chunk.val[7], isoLevel);

    Triangle[] triangles;
    for (int i = 0; triTable[cubeIndex][i] != -1; i += 3) {
        Triangle tri;
        tri.p = [vertList[triTable[cubeIndex][i]], vertList[triTable[cubeIndex][i + 1]], vertList[triTable[cubeIndex][i + 2]]];
        triangles ~= tri;
    }

    return triangles;
}


Triangle[] processVolume(float[20][20][20] volume, float isoLevel) {
    Triangle[] triangles;

    int nx = cast(uint)volume.length;
    int ny = cast(uint)volume[0].length;
    int nz = cast(uint)volume[0][0].length;

    for (int x = 0; x < nx - 1; ++x) {
        for (int y = 0; y < ny - 1; ++y) {
            for (int z = 0; z < nz - 1; ++z) {
                Chunk chunk;
                chunk.p = [
                    Vec3(x, y, z), Vec3(x + 1, y, z), Vec3(x + 1, y + 1, z), Vec3(x, y + 1, z),
                    Vec3(x, y, z + 1), Vec3(x + 1, y, z + 1), Vec3(x + 1, y + 1, z + 1), Vec3(x, y + 1, z + 1)
                ];
                chunk.val = [
                    volume[x][y][z], volume[x + 1][y][z], volume[x + 1][y + 1][z], volume[x][y + 1][z],
                    volume[x][y][z + 1], volume[x + 1][y][z + 1], volume[x + 1][y + 1][z + 1], volume[x][y + 1][z + 1]
                ];

                triangles ~= marchingCubes(chunk, isoLevel);
            }
        }
    }

    return triangles;
}

void fillChunkWithRandom(ref float[20][20][20] volume) {
    for (int x = 0; x < 20; ++x) {
        for (int y = 0; y < 20; ++y) {
            for (int z = 0; z < 20; ++z) {
				volume[x][y][z] = 1.0; // 0.4 + uniform01 / 2.0;
			}
		}
	}
}

void fillChunkWithTerrain(ref float[20][20][20] volume) {
    for (int x = 0; x < 20; ++x) {
        for (int y = 0; y < 20; ++y) {
            for (int z = 0; z < 20; ++z) {
				volume[x][y][z] = 0.0f;
			}
		}
	}
    for (int x = 0; x < 20; ++x) {
		for (int z = 0; z < 20; ++z) {
			// float a = (x+z) / 40.0;
			volume[x][1][z] = uniform(0.5, 1.0);
		}
	}

	for(int x = 10; x < 14; x++) {
		volume[x][2][10] = 1.0;
		volume[x][2][13] = 1.0;
		volume[x][3][10] = 1.0;
		volume[x][3][13] = 1.0;
	}
	for(int y = 10; y < 14; y++) {
		volume[10][2][y] = 1.0;
		volume[13][2][y] = 1.0;
		volume[10][3][y] = 1.0;
		volume[13][3][y] = 1.0;
	}
	volume[11][1][11] = 0.5;
	volume[11][1][12] = 0.5;
	volume[12][1][12] = 0.5;
	volume[12][1][11] = 0.5;
}

void fillChunkWithSphere(ref float[20][20][20] volume, float r) {
    int nx = volume.length;
    int ny = volume[0].length;
    int nz = volume[0][0].length;

    float centerX = (nx - 1) / 2.0;
    float centerY = (ny - 1) / 2.0;
    float centerZ = (nz - 1) / 2.0;

    for (int x = 0; x < nx; ++x) {
        for (int y = 0; y < ny; ++y) {
            for (int z = 0; z < nz; ++z) {
                float dx = (x - centerX);
                float dy = (y - centerY);
                float dz = (z - centerZ);
                float value = dx * dx + dy * dy + dz * dz;
                volume[x][y][z] = value <= r * r ? 1.0 : 0.0;
            }
        }
    }
}


Mesh createMesh(Triangle[] triangles, Color color=Colors.WHITE) {
	Mesh mesh;
	uint triangleCount = cast(uint) triangles.length;
	mesh.triangleCount = triangleCount;
	mesh.vertexCount = triangleCount * 3;

	float[] vertices; vertices.length = mesh.vertexCount * 3;
	float[] normals; normals.length = mesh.vertexCount * 3;
	ubyte[] colors; colors.length = mesh.vertexCount * Color.sizeof;
	foreach(uint n, t; triangles) {
		for(uint i=0; i<3; i++) {
			Vector3 normal = Vector3Normalize(Vector3CrossProduct(Vector3Subtract(t.p[1], t.p[0]), Vector3Subtract(t.p[2], t.p[0])));
			vertices[n*9+i*3+0] = t.p[i].x;
			vertices[n*9+i*3+1] = t.p[i].y;
			vertices[n*9+i*3+2] = t.p[i].z;
			normals[n*9+i*3+0] = normal.x;
			normals[n*9+i*3+1] = normal.y;
			normals[n*9+i*3+2] = normal.z;
            colors[n*12 + i*4 + 0] = color.r;
            colors[n*12 + i*4 + 1] = color.g;
            colors[n*12 + i*4 + 2] = color.b;
            colors[n*12 + i*4 + 3] = color.a;
		}
	}
	mesh.vertices = vertices.ptr;
	mesh.normals = normals.ptr;
	mesh.colors = colors.ptr;

	UploadMesh(&mesh, false);
	return mesh;
}


void main() {
    // Example usage
    Chunk chunk;
    chunk.p = [Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(1, 1, 0), Vec3(0, 1, 0),
              Vec3(0, 0, 1), Vec3(1, 0, 1), Vec3(1, 1, 1), Vec3(0, 1, 1)];
    // grid.val = [0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0];
    chunk.val = [0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0,
    		1.0, 0.5, 0.7, 0.4, 0.1, 0.0, 1.0, 0.0];

    float isoLevel = 0.5;
    // Triangle[] triangles = marchingCubes(grid, isoLevel);
    // Triangle[] triangles ~= marchingCubes(grid, isoLevel);

    float[20][20][20] volume;

    fillChunkWithSphere(volume, 5.0);
	// fillChunkWithRandom(volume);
	// fillChunkWithTerrain(volume);

    Triangle[] triangles = processVolume(volume, isoLevel);
    writeln("Generated ", triangles.length, " triangles.");

    InitWindow(720, 480, "Marching Cubes");

	SetExitKey(KeyboardKey.KEY_ESCAPE);

	DisableCursor(); // Limit cursor to relative movement inside the window
	SetTargetFPS(60); // Set our game to run at 60 frames-per-second

	auto camera = Camera3D(
			Vector3(0, 0, 8),             // Camera position
			Vector3(0, 0, 0),               // Camera looking at point
			Vector3(0, 1, 0),               // Camera up vector (rotation towards target)
			60,                             // Camera field-of-view Y
			CameraProjection.CAMERA_PERSPECTIVE);     // Camera mode type

	Shader shader = LoadShader("vs.glsl", "fs.glsl");
	// Shader shader = LoadShaderFromMemory(vertex_shader.toStringz, fragment_shader.toStringz);
	int lightPosLoc = GetShaderLocation(shader, "lightPosition");
    // int cameraPosLoc = GetShaderLocation(shader, "cameraPosition");

	int ambientColorLoc = GetShaderLocation(shader, "ambientColor");
	auto ambientColor = Vector3(1.0, 1.0, 1.0);

	Mesh cubeMesh = GenMeshCube(2.0, 2.0, 2.0);
	writeln(cubeMesh);
    Model cubeModel = LoadModelFromMesh(cubeMesh);

  	cubeModel.materials[0].shader = shader; // if you miss this, then the shader would not be applied to this object

	Mesh mcMesh = createMesh(triangles);
	Model mcModel = LoadModelFromMesh(mcMesh);
	if(!IsModelReady(mcModel)) {
		writeln("Model is NOT ready !");
	}
  	mcModel.materials[0].shader = shader; // if you miss this, then the shader would not be applied to this object
	auto mcModelBB = GetModelBoundingBox(mcModel);

	Vector3 lightPosition = Vector3(0.0, 30.0, 00.0);
	float angle = 0;

    while(!WindowShouldClose()) {
		angle = angle + GetFrameTime();
		lightPosition.x = cos(angle) * 30.0;
		lightPosition.z = sin(angle) * 30.0;
	    UpdateCamera(&camera, CameraMode.CAMERA_FREE);
	    BeginDrawing();
		    ClearBackground(Colors.BLACK);
		    BeginMode3D(camera);
				DrawGrid(10, 1);
				SetShaderValue(shader, lightPosLoc, &lightPosition, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
				SetShaderValue(shader, ambientColorLoc, &ambientColor, ShaderUniformDataType.SHADER_UNIFORM_VEC3);

				// BeginShaderMode(shader); // optional ?
					// DrawCube(Vector3(0,0.5,0), 1,1,1, Colors.GREEN);
					DrawModel(cubeModel, Vector3(0,1,0), 1, Colors.BLUE);
					DrawModel(mcModel, Vector3(2,0,2), 1, Colors.PURPLE);
					// foreach(t; triangles) {
					// 	DrawTriangle3D(t.p[0], t.p[1], t.p[2], Colors.RED);
					// }
				// EndShaderMode();
				DrawBoundingBox(mcModelBB, Colors.WHITE);
				DrawCube(Vector3(2,0,2), 1, 1, 1, Colors.GREEN);
				DrawSphere(lightPosition, 0.5, Colors.WHITE);
		    EndMode3D();
	    EndDrawing();
    }
	
 	UnloadModel(cubeModel);
    UnloadShader(shader);
    CloseWindow();
}

// vim: ts=4 sw=4

