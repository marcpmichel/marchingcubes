module renderable;

import raylib: Vector3, Model, Quaternion;

enum RenderableType {
    Grid, Model, Light
}

struct Renderable {
    RenderableType type;
    Vector3 position;
    Model model;
}
