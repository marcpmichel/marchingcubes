module chunk;

import raylib: Vector3, Vector3Normalize, Vector3CrossProduct, Vector3Subtract, Vector3Scale,
               Color, Colors, 
               Mesh, UploadMesh, Model, LoadModelFromMesh, IsModelReady,
               BoundingBox, GetModelBoundingBox, Shader;
import tables;
import std.math : abs;
import std.random : uniform;
import std.stdio : writeln;

class Chunk(uint ChunkDimX, uint ChunkDimY, uint ChunkDimZ) {

    struct Triangle {
        Vector3[3] p; // Positions of the triangle vertices
        Color c;
    }

    struct Cube {
        Vector3[] p; // Positions of the cube points
        float[] val; // Values at the cube points

        Triangle[] march(float isoLevel) { // , int[256] edgeTable, int[256][16] triTable) {

            Vector3 interpolate(Vector3 p1, Vector3 p2, float val1, float val2, float isoLevel) {
                if (abs(isoLevel - val1) < 0.00001) return p1;
                if (abs(isoLevel - val2) < 0.00001) return p2;
                if (abs(val1 - val2) < 0.00001) return p1;
                float t = (isoLevel - val1) / (val2 - val1);
                return Vector3(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y), p1.z + t * (p2.z - p1.z));
            }

            int cubeIndex = 0;
            if (val[0] < isoLevel) cubeIndex |= 1;
            if (val[1] < isoLevel) cubeIndex |= 2;
            if (val[2] < isoLevel) cubeIndex |= 4;
            if (val[3] < isoLevel) cubeIndex |= 8;
            if (val[4] < isoLevel) cubeIndex |= 16;
            if (val[5] < isoLevel) cubeIndex |= 32;
            if (val[6] < isoLevel) cubeIndex |= 64;
            if (val[7] < isoLevel) cubeIndex |= 128;

            int edges = edgeTable[cubeIndex];
            if (edges == 0) return [];

            Vector3[12] vertList;
            if (edges & 1) vertList[0] = interpolate(p[0], p[1], val[0], val[1], isoLevel);
            if (edges & 2) vertList[1] = interpolate(p[1], p[2], val[1], val[2], isoLevel);
            if (edges & 4) vertList[2] = interpolate(p[2], p[3], val[2], val[3], isoLevel);
            if (edges & 8) vertList[3] = interpolate(p[3], p[0], val[3], val[0], isoLevel);
            if (edges & 16) vertList[4] = interpolate(p[4], p[5], val[4], val[5], isoLevel);
            if (edges & 32) vertList[5] = interpolate(p[5], p[6], val[5], val[6], isoLevel);
            if (edges & 64) vertList[6] = interpolate(p[6], p[7], val[6], val[7], isoLevel);
            if (edges & 128) vertList[7] = interpolate(p[7], p[4], val[7], val[4], isoLevel);
            if (edges & 256) vertList[8] = interpolate(p[0], p[4], val[0], val[4], isoLevel);
            if (edges & 512) vertList[9] = interpolate(p[1], p[5], val[1], val[5], isoLevel);
            if (edges & 1024) vertList[10] = interpolate(p[2], p[6], val[2], val[6], isoLevel);
            if (edges & 2048) vertList[11] = interpolate(p[3], p[7], val[3], val[7], isoLevel);

            Triangle[] triangles;
            for (int i = 0; triTable[cubeIndex][i] != -1; i += 3) {
                Triangle tri;
                tri.p = [
                    vertList[triTable[cubeIndex][i]],
                    vertList[triTable[cubeIndex][i + 1]],
                    vertList[triTable[cubeIndex][i + 2]]
                ];
                triangles ~= tri;
            }

            return triangles;
        }

    }

    float[ChunkDimX][ChunkDimY][ChunkDimZ] data = 0;
    Triangle[] triangles;
    Mesh mesh;
    Model model;
    BoundingBox modelBB;
    bool meshCreated;

    this() {

    }

    void triangulate(float isoLevel = 0.5) {
        Cube cube;
        for (int x = 0; x < ChunkDimX - 1; ++x) {
            for (int y = 0; y < ChunkDimY - 1; ++y) {
                for (int z = 0; z < ChunkDimZ - 1; ++z) {
                    cube.p = [
                        Vector3(x, y, z), Vector3(x + 1, y, z), Vector3(x + 1, y + 1, z),
                        Vector3(x, y + 1, z), Vector3(x, y, z + 1), Vector3(x + 1, y, z + 1),
                        Vector3(x + 1, y + 1, z + 1), Vector3(x, y + 1, z + 1)
                    ];
                    cube.val = [
                        data[x][y][z], data[x + 1][y][z],
                        data[x + 1][y + 1][z], data[x][y + 1][z],
                        data[x][y][z + 1], data[x + 1][y][z + 1],
                        data[x + 1][y + 1][z + 1], data[x][y + 1][z + 1]
                    ];

                    triangles ~= cube.march(isoLevel);
                }
            }
        }
    }

    
    void createMesh(Color color = Colors.WHITE, bool invert_normals=false) {
        uint triangleCount = cast(uint) triangles.length;
        mesh.triangleCount = triangleCount;
        mesh.vertexCount = triangleCount * 3;

        float[] vertices;
        vertices.length = mesh.vertexCount * 3;
        float[] normals;
        normals.length = mesh.vertexCount * 3;
        ubyte[] colors;
        colors.length = mesh.vertexCount * Color.sizeof;
        foreach (uint n, t; triangles) {
            for (uint i = 0; i < 3; i++) {
                Vector3 normal = Vector3Normalize( Vector3CrossProduct( Vector3Subtract(t.p[1], t.p[0]), Vector3Subtract(t.p[2], t.p[0])));
                if(invert_normals) normal = Vector3Scale(normal, -1.0);

                vertices[n * 9 + i * 3 + 0] = t.p[i].x;
                vertices[n * 9 + i * 3 + 1] = t.p[i].y;
                vertices[n * 9 + i * 3 + 2] = t.p[i].z;
                normals[n * 9 + i * 3 + 0] = normal.x;
                normals[n * 9 + i * 3 + 1] = normal.y;
                normals[n * 9 + i * 3 + 2] = normal.z;
                colors[n * 12 + i * 4 + 0] = color.r;
                colors[n * 12 + i * 4 + 1] = color.g;
                colors[n * 12 + i * 4 + 2] = color.b;
                colors[n * 12 + i * 4 + 3] = color.a;
            }
        }
        mesh.vertices = vertices.ptr;
        mesh.normals = normals.ptr;
        mesh.colors = colors.ptr;

        UploadMesh(&mesh, false);
        meshCreated = true;
    }

    void createModel(Color color = Colors.WHITE, Shader shader) {
        // Mesh mcMesh = chunk.createMesh(Colors.RED);
        if(!meshCreated) { assert(false, "mesh not created"); }
        createMesh(color);
        // Mesh mcMesh = createMesh(triangles);
        // Model mcModel = LoadModelFromMesh(mcMesh);
        model = LoadModelFromMesh(mesh);

        if(!IsModelReady(model)) {
            writeln("Model is NOT ready !");
        }
        model.materials[0].shader = shader; // if you miss this, then the shader would not be applied to this object
        modelBB = GetModelBoundingBox(model);
    }

    void fillRandom() {
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int y = 0; y < ChunkDimY; ++y) {
                for (int z = 0; z < ChunkDimZ; ++z) {
                    data[x][y][z] = 1.0; // 0.4 + uniform01 / 2.0;
                }
            }
        }
    }


    void fillWithSphere(Vector3 pos, uint radius) {
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int y = 0; y < ChunkDimY; ++y) {
                for (int z = 0; z < ChunkDimZ; ++z) {
                    float dx = (x - pos.x);
                    float dy = (y - pos.y);
                    float dz = (z - pos.z);
                    float value = dx * dx + dy * dy + dz * dz;
                    data[x][y][z] = value <= (radius^2) ? 1.0 : 0.0;
                }
            }
        }
    }

    void fillWithTerrain() {
        /*
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int y = 0; y < ChunkDimY; ++y) {
                for (int z = 0; z < ChunkDimZ; ++z) {
                    data[x][y][z] = 0.0f;
                }
            }
        }
        */
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int z = 0; z < ChunkDimZ; ++z) {
                // float a = (x+z) / 40.0;
                data[x][1][z] = uniform(0.5, 1.0);
            }
        }

        for(int x = 10; x < 14; x++) {
            data[x][2][10] = 1.0;
            data[x][2][13] = 1.0;
            data[x][3][10] = 1.0;
            data[x][3][13] = 1.0;
        }
        for(int y = 10; y < 14; y++) {
            data[10][2][y] = 1.0;
            data[13][2][y] = 1.0;
            data[10][3][y] = 1.0;
            data[13][3][y] = 1.0;
        }
        data[11][1][11] = 0.5;
        data[11][1][12] = 0.5;
        data[12][1][12] = 0.5;
        data[12][1][11] = 0.5;
    }

    void fillCorridor() {
            data[1][1][1] = 1.0;
            data[1][1][2] = 1.0;
            data[2][1][1] = 1.0;
            data[2][1][2] = 1.0;
    }
}