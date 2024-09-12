module scenes.reality_scene;

import scene;
import reality;
import raylib;
import renderable;
import mesher;

class RealityScene : Scene {

    this() {
        setClearColor(Colors.DARKGRAY);
        addRenderable(Renderable(RenderableType.Grid));
        addRenderable(Renderable(RenderableType.Gizmo));
        auto reality = new Reality!(20,20);
        reality.genModel(lighting.shader);
        realityId = addRenderable(Renderable(RenderableType.Model, Vector3(-1, 0, -1), reality.model, true));
    }

}