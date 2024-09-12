#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec4 vertexColor;

out vec4 fragColor;
out vec3 fragPosition;
out vec3 fragNormal;

uniform mat4 matModel;
uniform mat4 matView;
uniform mat4 matProjection;

void main() {
    fragPosition = vec3(matModel * vec4(vertexPosition, 1.0));

    // vec3 edge1 = vec3(gl_in[1].gl_Position) - vec3(gl_in[0].gl_Position);
    // vec3 edge2 = vec3(gl_in[2].gl_Position) - vec3(gl_in[0].gl_Position);
    // vec3 faceNormal = normalize(cross(edge2, edge1));
    // fragNormal = faceNormal;

    fragNormal = vertexNormal;  

    fragColor = vertexColor;
    
    gl_Position = matProjection * matView * vec4(fragPosition, 1.0);
}