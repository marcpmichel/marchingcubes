module mesher;
import raylib : Color, Mesh, Vector3, Vector3Normalize, Vector3CrossProduct, Vector3Subtract, Vector3Scale;


struct V3i {
    uint x;
    uint y;
    uint z;
}

struct Triangle {
    Vector3[3] p; // Positions of the triangle vertices
    Color c;
}

Mesh createMesh(Triangle[] triangles, bool inverted=false) {
    Mesh mesh;
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
            if(inverted) normal = Vector3Scale(normal, -1.0);

            vertices[n * 9 + i * 3 + 0] = inverted ? t.p[i].z : t.p[i].x;
            vertices[n * 9 + i * 3 + 1] = t.p[i].y;
            vertices[n * 9 + i * 3 + 2] = inverted ? t.p[i].x : t.p[i].z;
            normals[n * 9 + i * 3 + 0] = normal.x;
            normals[n * 9 + i * 3 + 1] = normal.y;
            normals[n * 9 + i * 3 + 2] = normal.z;
            colors[n * 12 + i * 4 + 0] = t.c.r;
            colors[n * 12 + i * 4 + 1] = t.c.g;
            colors[n * 12 + i * 4 + 2] = t.c.b;
            colors[n * 12 + i * 4 + 3] = t.c.a;
        }
    }
    mesh.vertices = vertices.ptr;
    mesh.normals = normals.ptr;
    mesh.colors = colors.ptr;

    return mesh;
}