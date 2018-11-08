#version 330 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec4 vertexColours;
layout(location=2) in vec2 vertexTextureCoord;
layout(location=3) in vec3 vertexNormals;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform vec3 cameraPosition;

uniform float currentTime;
uniform float deltaTime;

out vec4 vertexColoursOut;
out vec2 vertexTextureCoordOut;
out vec3 vertexNormalsOut;
out vec3 viewDirection;
out vec3 worldVertexPosition;

void main(){
	
	mat4 mvpMatrix=projectionMatrix*viewMatrix*modelMatrix;

	vec3 adjustedVertexPosition=vertexPosition;
	adjustedVertexPosition.y+=(sin(currentTime+adjustedVertexPosition.x)*10.0)*0.1;
	adjustedVertexPosition.z+=(cos(currentTime+adjustedVertexPosition.y)*10.0)*0.1;

	vec4 worldPosition=modelMatrix*vec4(adjustedVertexPosition,1.0f);
	vec4 mvpPosition=mvpMatrix*vec4(adjustedVertexPosition,1.0f);

	//worldPosition.y+=(sin(currentTime+worldPosition.x)*3.0)*0.1;
	
	vertexColoursOut=vertexColours;
	vertexTextureCoordOut=vertexTextureCoord;
	vertexNormalsOut=normalize(modelMatrix*vec4(vertexNormals,0.0f)).xyz;
	viewDirection=normalize(cameraPosition-worldPosition.xyz);
	worldVertexPosition=worldPosition.xyz;

	gl_Position=mvpPosition;
}