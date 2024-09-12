module reality;

import raylib: Vector3, Vector3Normalize, Vector3CrossProduct, Vector3Subtract,
               Color, Colors, 
               Mesh, Model, BoundingBox, GetModelBoundingBox, IsModelReady, UploadMesh, LoadModelFromMesh, Shader;
import raylib.raymathext;
import std.stdio;
import std.algorithm;
import mesher;

// Reality Engine was the name of the engine used by Ultima Underworl and System Shock.

alias normalize = Vector3Normalize;

enum BlockType {
    Empty, Plain, SlopeS
}

struct Block {
    BlockType type;
    float ceilHeight = 2.0;
    float floorHeight = 0.0;
    Color color = Colors.DARKGRAY;
}

class Reality(uint Width, uint Height) {
    Block[Height][Width] blocks;
    Mesh mesh;
    Model model;
    bool meshCreated = false;

    this() {
        blocks[0][0].type = BlockType.SlopeS;
        blocks[0][0].color = Colors.RED;
        blocks[0][1].type = BlockType.SlopeS;
        blocks[0][1].color = Colors.GREEN;
        blocks[1][0].type = BlockType.Plain;
        blocks[1][0].color = Colors.YELLOW;
        blocks[1][1].type = BlockType.Plain;
        blocks[1][1].color = Colors.BLUE;

    }

    Triangle[] triangulate() {
        Triangle[] tris;
        Color c;
        for(int x=0; x<Width; x++) {
            for(int y=0; y<Height; y++) {
                Block b = blocks[y][x];
                // if(b.type == BlockType.Empty) continue;

                Vector3[] cv = getVertices(b, V3i(x,0,y));
                c = b.color;

                switch(b.type) {
                    case BlockType.Empty:
                        // top
                        // tris ~= Triangle([cv[3], cv[6], cv[7]], c);
                        // tris ~= Triangle([cv[6], cv[3], cv[2]], c); 

                        // bottom
                        tris ~= Triangle([cv[5], cv[0], cv[1]], c);
                        tris ~= Triangle([cv[0], cv[5], cv[4]], c); 
                    break;

                    case BlockType.Plain:
                        // left
                        tris ~= Triangle([cv[0], cv[3], cv[1]], c);
                        tris ~= Triangle([cv[3], cv[0], cv[2]], c); 

                        // right 
                        tris ~= Triangle([cv[5], cv[6], cv[4]], c);
                        tris ~= Triangle([cv[6], cv[5], cv[7]], c); 

                        // front
                        tris ~= Triangle([cv[4], cv[2], cv[0]], c);
                        tris ~= Triangle([cv[2], cv[4], cv[6]], c); 

                        // back
                        tris ~= Triangle([cv[1], cv[7], cv[5]], c);
                        tris ~= Triangle([cv[7], cv[1], cv[3]], c); 

                        // top
                        tris ~= Triangle([cv[3], cv[6], cv[7]], c);
                        tris ~= Triangle([cv[6], cv[3], cv[2]], c); 

                        // bottom
                        tris ~= Triangle([cv[5], cv[0], cv[1]], c);
                        tris ~= Triangle([cv[0], cv[5], cv[4]], c); 
                    break;

                    case BlockType.SlopeS:
                        tris ~= Triangle([cv[0], cv[3], cv[1]], c); // left
                        tris ~= Triangle([cv[4], cv[7], cv[5]], c); // right

                        tris ~= Triangle([cv[4], cv[3], cv[7]], c); // slant
                        tris ~= Triangle([cv[4], cv[0], cv[3]], c); // slant

                        tris ~= Triangle([cv[1], cv[7], cv[5]], c); // back
                        tris ~= Triangle([cv[7], cv[1], cv[3]], c); 

                        tris ~= Triangle([cv[5], cv[0], cv[1]], c); // bottom
                        tris ~= Triangle([cv[0], cv[5], cv[4]], c); 
                    break;

                    case BlockType.SlopeE:
                        // left
                        tris ~= Triangle([cv[0], cv[3], cv[1]], c);
                        tris ~= Triangle([cv[3], cv[0], cv[2]], c); 

                        // right 
                        tris ~= Triangle([cv[5], cv[6], cv[4]], c);
                        tris ~= Triangle([cv[6], cv[5], cv[7]], c); 

                        // front
                        tris ~= Triangle([cv[4], cv[2], cv[0]], c);
                        tris ~= Triangle([cv[2], cv[4], cv[6]], c); 

                        // back
                        tris ~= Triangle([cv[1], cv[7], cv[5]], c);
                        tris ~= Triangle([cv[7], cv[1], cv[3]], c); 

                        // top
                        tris ~= Triangle([cv[3], cv[6], cv[7]], c);
                        tris ~= Triangle([cv[6], cv[3], cv[2]], c); 

                        // bottom
                        tris ~= Triangle([cv[5], cv[0], cv[1]], c);
                        tris ~= Triangle([cv[0], cv[5], cv[4]], c); 
                    break;

                    default:
                    break;
                }
            }
        }
        return tris;
    }

    Vector3[] getVertices(Block b, V3i pos) {
        float base = max(b.floorHeight, 0);
        float height = max(b.ceilHeight - base, 1);
                return [
                    Vector3(pos.x, pos.y + base, pos.z),
                    Vector3(pos.x, pos.y + base, pos.z + 1),
                    Vector3(pos.x, pos.y + height, pos.z),
                    Vector3(pos.x, pos.y + height, pos.z + 1),
                    Vector3(pos.x + 1, pos.y + base, pos.z),
                    Vector3(pos.x + 1, pos.y + base, pos.z + 1),
                    Vector3(pos.x + 1, pos.y + height , pos.z),
                    Vector3(pos.x + 1, pos.y + height, pos.z + 1) 
                ];
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