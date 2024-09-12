module scenes.voxel_scene;

import scene;
import raylib;
import mesher;
import renderable;
import std.stdio;

class VoxelChunk {
    bool dirty;
    uint[V3i] data;
    static uint size = 32;
    Model model;
    Vector3 world_pos;
    static Color[] palette = [
        Color(255, 0, 0, 255),    // Rouge
        Color(0, 255, 0, 255),    // Vert
        Color(0, 0, 255, 255),    // Bleu
        Color(255, 255, 0, 255),  // Jaune
        Color(0, 255, 255, 255),  // Cyan
        Color(255, 0, 255, 255),  // Magenta
        Color(192, 192, 192, 255),// Gris clair
        Color(128, 128, 128, 255),// Gris
        Color(128, 0, 0, 255),    // Marron
        Color(128, 128, 0, 255),  // Olive
        Color(0, 128, 0, 255),    // Vert foncé
        Color(128, 0, 128, 255),  // Violet
        Color(0, 128, 128, 255),  // Vert sarcelle
        Color(0, 0, 128, 255),    // Bleu marine
        Color(255, 165, 0, 255),  // Orange
        Color(255, 192, 203, 255) // Rose
    ];

    this(V3i pos) {
        world_pos = Vector3(pos.x, pos.y, pos.z);
    }

    Vector3[8] cubeVertices(V3i pos) {
        return [
            Vector3(pos.x, pos.y, pos.z),
            Vector3(pos.x, pos.y, pos.z + 1),
            Vector3(pos.x, pos.y + 1, pos.z),
            Vector3(pos.x, pos.y + 1, pos.z + 1),
            Vector3(pos.x + 1, pos.y, pos.z),
            Vector3(pos.x + 1, pos.y, pos.z + 1),
            Vector3(pos.x + 1, pos.y + 1, pos.z),
            Vector3(pos.x + 1, pos.y + 1, pos.z + 1) 
        ];
    }

    Triangle[] triangulate() {

        Triangle[] tris;
        Color c;

        foreach(pos, voxel; data) {
            c = palette[voxel];
            Vector3[8] cv = cubeVertices(pos);
            // 1,2,3 ; 2,1,0 

            // left => 2,0,3,1
            if(pos.x > 0 && !(V3i(pos.x-1, pos.y, pos.z) in data)) {
                tris ~= Triangle([cv[0], cv[3], cv[1]], c);
                tris ~= Triangle([cv[3], cv[0], cv[2]], c); 
            }
            // right => 7,5,6,4
            if(pos.x < size-1 && !(V3i(pos.x+1, pos.y, pos.z) in data)) {
                tris ~= Triangle([cv[5], cv[6], cv[4]], c);
                tris ~= Triangle([cv[6], cv[5], cv[7]], c); 
            }
            // front => 6,4,2,0
            if(pos.z > 0 && !(V3i(pos.x, pos.y, pos.z-1) in data)) {
                tris ~= Triangle([cv[4], cv[2], cv[0]], c);
                tris ~= Triangle([cv[2], cv[4], cv[6]], c); 
            }
            // back => 3,1,7,5
            if(pos.z < size-1 && !(V3i(pos.x, pos.y, pos.z+1) in data)) {
                tris ~= Triangle([cv[1], cv[7], cv[5]], c);
                tris ~= Triangle([cv[7], cv[1], cv[3]], c); 
            }
            // top =>  2,3,6,7
            if(pos.y < size-1 && !(V3i(pos.x, pos.y+1, pos.z) in data)) {
                tris ~= Triangle([cv[3], cv[6], cv[7]], c);
                tris ~= Triangle([cv[6], cv[3], cv[2]], c); 
            }
            // bottom => 4,5,0,1
            if(pos.y > 0 && !(V3i(pos.x, pos.y-1, pos.z) in data)) {
                tris ~= Triangle([cv[5], cv[0], cv[1]], c);
                tris ~= Triangle([cv[0], cv[5], cv[4]], c); 
            }
        }
        return tris;
    }

    void genModel(Shader shader) {
        Triangle[] triangles = triangulate();
        Mesh mesh = createMesh(triangles);
        UploadMesh(&mesh, false);
        model = LoadModelFromMesh(mesh);
        // if(!IsModelReady(model)) { writeln("Model is NOT ready !"); }
        model.materials[0].shader = shader; // if you miss this, then the shader would not be applied to this object
    }

}

class VoxelWorld {
    VoxelChunk[V3i] chunks; 
    Shader shader;

    this(Shader _shader) {
        shader = _shader;
    }

    VoxelChunk getOrCreateChunk(V3i pos) {
        V3i chunkId = V3i(pos.x / VoxelChunk.size, pos.y / VoxelChunk.size, pos.z / VoxelChunk.size);
        VoxelChunk chunk;
        if(chunkId in chunks) {
            chunk = chunks[chunkId];
        }
        else {
            chunk = new VoxelChunk(pos);
            chunks[chunkId] = chunk;
        }
        return chunk;
    }

    void beginEdit() {
    }

    void endEdit() {
        writeln("Created ", chunks.length, "chunks");
        foreach(chunk; chunks) {
            if(chunk.dirty) {
                chunk.genModel(shader);
                chunk.dirty = false;
            }
        }
    }

    void addBlock(V3i pos, uint type) {
        VoxelChunk chunk = getOrCreateChunk(pos);
        V3i localPos = V3i(pos.x % VoxelChunk.size, pos.y % VoxelChunk.size, pos.z % VoxelChunk.size);
        chunk.data[localPos] = type;
        chunk.dirty = true;
    }

    void removeBlock(V3i pos) {
        VoxelChunk chunk = getOrCreateChunk(pos);
        V3i localPos = V3i(pos.x % VoxelChunk.size, pos.y % VoxelChunk.size, pos.z % VoxelChunk.size);
        chunk.data[localPos] = 0;
        chunk.dirty = true;
    }
}

class VoxelScene : Scene {

    VoxelWorld world;

    this() {
        addRenderable(Renderable(RenderableType.Grid));
        world = new VoxelWorld(lighting.shader);
        world.beginEdit();
        addRoom(V3i(1,1,1), V3i(4,3,5));
        addRoom(V3i(6,1,1), V3i(4,3,5));
        world.addBlock(V3i(5,1,3), 1);
        world.addBlock(V3i(5,2,3), 1);
        addRoom(V3i(1,1,7), V3i(5,3,4));
        world.addBlock(V3i(3,1,6), 2);
        world.addBlock(V3i(3,2,6), 2);
        world.endEdit();
        foreach(chunk; world.chunks) {
            addRenderable(Renderable(RenderableType.Model, chunk.world_pos, chunk.model));
        }
    }

    void addRoom(V3i pos, V3i size) {
        uint t = cast(uint)GetRandomValue(0, 15);
        for(uint y=pos.y; y<pos.y+size.y; y++) {
            for(uint x=pos.x; x<pos.x+size.x; x++) {
                for(uint z=pos.z; z<pos.z+size.z; z++) {
                        world.addBlock(V3i(x,y,z), t);
                }
            }
        }
    }

    // override void update(float delta) {

    // }
}