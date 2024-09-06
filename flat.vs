#version 330

in vec3 vertexPosition;
in vec3 vertexNormal;

uniform mat4 mvp;
uniform vec3 lightPosition;

out vec3 fragColor;

void main() {
    vec3 normal = normalize(vertexNormal);
    vec3 lightDir = normalize(lightPosition - vertexPosition);
    float intensity = max(dot(normal, lightDir), 0.0);
    fragColor = vec3(1.0, 0.0, 0.0) * intensity; // Red color with lighting

    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
