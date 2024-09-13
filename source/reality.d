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
    Empty, Plain, SlopeS, SlopeE, SlopeN, SlopeW, DiagNW, DiagNE, DiagSE, DiagSW
}

struct Block {
    BlockType type;
    float ceilHeight = 1.0;
    float floorHeight = 0.0;
    Color color = Colors.DARKGRAY;
}

class Reality(uint Width, uint Height) {
    Block[Height][Width] blocks;
    Mesh mesh;
    Model model;
    bool meshCreated = false;

    this() {
        void set(uint x, uint y, BlockType t, Color c) {
            blocks[y][x].type = t;
            blocks[y][x].color = c;
        }

        set(8,8, BlockType.Plain, Colors.PURPLE);

        set(2,2, BlockType.Empty, Colors.GRAY);

        set(2,1, BlockType.SlopeS, Colors.RED);
        set(1,2, BlockType.SlopeW, Colors.BLUE);
        set(3,2, BlockType.SlopeE, Colors.GREEN);
        set(2,3, BlockType.SlopeN, Colors.YELLOW);

        // set(5,5, BlockType.Empty, Colors.GRAY);
        set(5,4, BlockType.DiagNE, Colors.RED);
        set(6,4, BlockType.DiagNW, Colors.BLUE);
        set(6,5, BlockType.DiagSW, Colors.GREEN);
        set(5,5, BlockType.DiagSE, Colors.YELLOW);
    }

    Triangle[] triangulate() {
        Triangle[] tris;
        Color c;

        Triangle tri(Vector3[] v, uint i1, uint i2, uint i3, Color c) {
            return Triangle([v[i1], v[i2], v[i3]], c);
        }
        
        Triangle[] quad(Vector3[] v, uint i0, uint i1, uint i2, uint i3, Color c) {
            return [
                Triangle([v[i1], v[i2], v[i3]], c),
                Triangle([v[i2], v[i1], v[i0]], c)
            ];
        }

        for(int x=0; x<Width; x++) {
            for(int y=0; y<Height; y++) {
                Block b = blocks[y][x];
                // if(b.type == BlockType.Empty) continue;

                Vector3[] cv = getVertices(b, V3i(x,0,y));
                c = b.color;

                switch(b.type) {
                    case BlockType.Empty:
                        tris ~= quad(cv, 0,4,1,5, c); // bottom
                    break;

                    case BlockType.Plain:
                        tris ~= quad(cv, 0,2,1,3, c); // left
                        tris ~= quad(cv, 4,5,6,7, c); // right
                        tris ~= quad(cv, 0,4,2,6, c); // front
                        tris ~= quad(cv, 5,1,7,3, c); // back
                        tris ~= quad(cv, 2,6,3,7, c); // top
                        // tris ~= quad(cv, 5,4,1,0, c); // bottom
                    break;

                    case BlockType.SlopeS:
                        tris ~= quad(cv, 0, 4, 3, 7, c);
                        tris ~= quad(cv, 3, 7, 1, 5, c);
                        // tris ~= quad(cv, 0, 1, 4, 5, c); // bottom
                        tris ~= tri(cv, 5, 4, 7, c);
                        tris ~= tri(cv, 0, 1, 3, c);
                    break;

                    case BlockType.SlopeE:
                        tris ~= quad(cv, 5, 3, 4, 2, c);
                        // tris ~= quad(cv, 0, 1, 4, 5, c); // bottom
                        tris ~= quad(cv, 0, 2, 1, 3, c);
                        tris ~= tri(cv, 0, 2, 4, c);
                        tris ~= tri(cv, 5, 3, 1, c);
                    break;

                    case BlockType.SlopeN:
                        tris ~= tri(cv, 0, 1, 2, c);
                        tris ~= tri(cv, 6, 5, 4, c);
                        tris ~= quad(cv, 0, 4, 2, 6, c);
                        tris ~= quad(cv, 2, 6, 1, 5, c);
                        // tris ~= quad(cv, 0, 1, 4, 5, c); // bottom
                    break;

                    case BlockType.SlopeW:
                        tris ~= quad(cv, 0, 6, 1, 7, c);
                        tris ~= tri(cv, 0, 6, 4, c);
                        tris ~= tri(cv, 5, 7, 1, c);
                        tris ~= quad(cv, 6, 4, 7, 5, c);
                        // tris ~= quad(cv, 0, 1, 4, 5, c); // bottom
                    break;

                    case BlockType.DiagNE:
                        tris ~= quad(cv, 4,1,6,3, c);
                        tris ~= quad(cv, 0,4,2,6, c);
                        tris ~= quad(cv, 0,2,1,3, c);
                        tris ~= tri(cv, 2, 3, 6, c);
                    break;

                    case BlockType.DiagNW:
                        tris ~= quad(cv, 0,2,5,7, c);
                        tris ~= quad(cv, 0,4,2,6, c);
                        tris ~= quad(cv, 4,5,6,7, c);
                        tris ~= tri(cv, 2, 7, 6, c);
                    break;

                    case BlockType.DiagSW:
                        tris ~= quad(cv, 1,4,3,6, c);
                        tris ~= quad(cv, 1,3,5,7, c);
                        tris ~= quad(cv, 4,5,6,7, c);
                        tris ~= tri(cv, 3, 7, 6, c);
                    break;

                    case BlockType.DiagSE:
                        tris ~= quad(cv, 0,5,2,7, c);
                        tris ~= quad(cv, 0,2,1,3, c);
                        tris ~= quad(cv, 1,3,5,7, c);
                        tris ~= tri(cv, 2, 3, 7, c);
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
        Mesh mesh = createMesh(triangles, false);
        UploadMesh(&mesh, false);
        model = LoadModelFromMesh(mesh);
        // if(!IsModelReady(model)) { writeln("Model is NOT ready !"); }
        model.materials[0].shader = shader; // if you miss this, then the shader would not be applied to this object
    }

}