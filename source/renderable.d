module renderable;

import raylib: Vector3, Model, Quaternion, BoundingBox;

enum RenderableType {
    Grid, Model, Light, Gizmo
}

struct Renderable {
    RenderableType type;
    Vector3 position;
    Model model;
    bool bounding_box;
    BoundingBox modelBB;
}
