module scenes.marching_cube_scene;

import scene;
import raylib; 
import renderable;
import marching_cube;
import std.random: uniform;

class MarchingCubeScene : Scene {

    Model cubeModel;
    const uint ChunkDimX = 20;
    const uint ChunkDimY = 20;
    const uint ChunkDimZ = 20;
    MarchingCube!(ChunkDimX,ChunkDimY,ChunkDimZ) marchingCube;

    this() {
            renderables ~= Renderable(RenderableType.Light, lighting.lightPosition);

            renderables ~= Renderable(RenderableType.Grid, Vector3Zero);

            Mesh cubeMesh = GenMeshCube(2.0, 2.0, 2.0);
            cubeModel = LoadModelFromMesh(cubeMesh);
            cubeModel.materials[0].shader = lighting.shader; // if you miss this, then the shader would not be applied to this object
            renderables ~= Renderable(RenderableType.Model, Vector3(-4,0,-4), cubeModel);

            // marching cube
            marchingCube = new MarchingCube!(20,20,20)();
            // chunk.fillWithSphere(Vector3(8,8,8), 4);
            // chunk.fillWithTerrain();
            // this.fillCorridor();
            this.fillRoom(10,10,10);
            marchingCube.triangulate();
            marchingCube.createMesh(Colors.RED, true);
            marchingCube.createModel(Colors.RED, lighting.shader);
            // chunk.invertNormals();
            addRenderable(Renderable(RenderableType.Model, Vector3(2,0,2), marchingCube.model));
    }

    ~this() {
        UnloadModel(cubeModel);
    }

    void fillRandom() {
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int y = 0; y < ChunkDimY; ++y) {
                for (int z = 0; z < ChunkDimZ; ++z) {
                    marchingCube.data[x][y][z] = 1.0; // 0.4 + uniform01 / 2.0;
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
                    marchingCube.data[x][y][z] = value <= (radius^2) ? 1.0 : 0.0;
                }
            }
        }
    }

    void fillWithTerrain() {
        /*
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int y = 0; y < ChunkDimY; ++y) {
                for (int z = 0; z < ChunkDimZ; ++z) {
                    marchingCube.data[x][y][z] = 0.0f;
                }
            }
        }
        */
        for (int x = 0; x < ChunkDimX; ++x) {
            for (int z = 0; z < ChunkDimZ; ++z) {
                // float a = (x+z) / 40.0;
                marchingCube.data[x][1][z] = uniform(0.5, 1.0);
            }
        }

        for(int x = 10; x < 14; x++) {
            marchingCube.data[x][2][10] = 1.0;
            marchingCube.data[x][2][13] = 1.0;
            marchingCube.data[x][3][10] = 1.0;
            marchingCube.data[x][3][13] = 1.0;
        }
        for(int y = 10; y < 14; y++) {
            marchingCube.data[10][2][y] = 1.0;
            marchingCube.data[13][2][y] = 1.0;
            marchingCube.data[10][3][y] = 1.0;
            marchingCube.data[13][3][y] = 1.0;
        }
        marchingCube.data[11][1][11] = 0.5;
        marchingCube.data[11][1][12] = 0.5;
        marchingCube.data[12][1][12] = 0.5;
        marchingCube.data[12][1][11] = 0.5;
    }

    void fillCorridor() {
        for(uint z=1; z<5; z++) {
            marchingCube.data[1][z][1] = 1.0;
            marchingCube.data[2][z][1] = 1.0;
            marchingCube.data[3][z][1] = 1.0;
            marchingCube.data[4][z][1] = 1.0;
            marchingCube.data[5][z][1] = 1.0;

            marchingCube.data[1][z][2] = 1.0;
            marchingCube.data[2][z][2] = 1.0;
            marchingCube.data[3][z][2] = 1.0;
            marchingCube.data[4][z][2] = 1.0;
            marchingCube.data[5][z][2] = 1.0;

            marchingCube.data[1][z][4] = 1.0;
            marchingCube.data[2][z][4] = 1.0;
            marchingCube.data[3][z][4] = 1.0;
            marchingCube.data[4][z][4] = 1.0;
            marchingCube.data[5][z][4] = 1.0;

            marchingCube.data[1][z][5] = 1.0;
            marchingCube.data[2][z][5] = 1.0;
            marchingCube.data[3][z][5] = 1.0;
            marchingCube.data[4][z][5] = 1.0;
            marchingCube.data[5][z][5] = 1.0;

            marchingCube.data[1][z][3] = 1.0;
            marchingCube.data[2][z][3] = 1.0;

            marchingCube.data[4][z][3] = 1.0;
            marchingCube.data[5][z][3] = 1.0;

            marchingCube.data[3][z][6] = 1.0;
            marchingCube.data[3][z][7] = 1.0;
            marchingCube.data[3][z][8] = 1.0;
            marchingCube.data[3][z][9] = 1.0;

            marchingCube.data[4][z][6] = 1.0;
            marchingCube.data[4][z][7] = 1.0;
            marchingCube.data[4][z][8] = 1.0;
            marchingCube.data[4][z][9] = 1.0;
        }
    }

    void fillRoom(uint width, uint height, uint depth) {
        for(uint y=1; y<height-1; y++) {
            for(uint x=1; x<width; x+=1) {
                for(uint z=1; z<depth; z+=1) {
                    if((x>=1 && x<4) || x==width-1 || (z>=1 && z<4) || z==depth-1) marchingCube.data[x][y][z] = 1.0;
                }
            }
        }
    }
}