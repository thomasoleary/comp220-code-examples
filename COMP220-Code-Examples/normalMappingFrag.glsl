#version 330 core

struct DirectionalLight
{
	vec4 diffuseColour;
	vec4 specularColour;
	vec3 direction;
};

struct PointLight
{
	vec4 diffuseColour;
	vec4 specularColour;
	vec3 position;
};

const int MAX_NO_OF_POINT_LIGHTS=8;

in vec4 vertexColourOut;
in vec2 vertexTextureCoordOut;
in vec3 vertexNormalsOut;
in vec3 viewDirection;
in vec3 worldVertexPosition;
in mat3 tangentMatrix;

out vec4 colour;

uniform sampler2D diffuseTexture;
uniform sampler2D specularTexture;
uniform sampler2D normalTexture;

uniform vec4 ambientMaterialColour;
uniform vec4 diffuseMaterialColour;
uniform vec4 specularMaterialColour;
uniform float specularMaterialPower;

uniform DirectionalLight directionalLight;

uniform PointLight pointLights[MAX_NO_OF_POINT_LIGHTS];
uniform int numberOfPointLights;

uniform vec4 ambientLightColour;


vec4 CalculateLightColour(vec3 normal, vec4 diffuseLightColour,vec4 specularLightColour,vec3 lightDirection,vec4 diffuseTextureColour,vec4 specularTextureColour)
{
	vec3 tangentLightDir=normalize(tangentMatrix*lightDirection);
	vec3 tangentViewDir=normalize(tangentMatrix*viewDirection);

	float nDotl=clamp(dot(normal,tangentLightDir),0.0,1.0);

	vec3 halfWay=normalize(tangentLightDir+tangentViewDir);

	float nDoth=pow(clamp(dot(normal,halfWay),0.0,1.0),specularMaterialPower);

	return 	(diffuseLightColour*nDotl*diffuseMaterialColour*diffuseTextureColour)+
			(specularLightColour*nDoth*specularMaterialColour*specularTextureColour);
}

vec4 CalculatePointLight(vec3 normal, int currentLightIndex,vec4 diffuseTextureColour,vec4 specularTextureColour)
{
	vec3 lightDirection=worldVertexPosition-pointLights[currentLightIndex].position;
	float lightDistance=length(lightDirection);
	lightDirection=normalize(lightDirection);

	vec4 colour=CalculateLightColour(normal,
									pointLights[currentLightIndex].diffuseColour,
									pointLights[currentLightIndex].specularColour,
									lightDirection,
									diffuseTextureColour,specularTextureColour);

	float attenuation=1.0/(1.0+0.1*lightDistance+0.01*lightDistance*lightDistance);

	return colour*attenuation;
}

vec4 CalculateDirectionLightColour(vec3 normal,vec4 diffuseTextureColour,vec4 specularTextureColour)
{
	return CalculateLightColour(normal,
								directionalLight.diffuseColour,
								directionalLight.specularColour,
								directionalLight.direction,
								diffuseTextureColour,specularTextureColour);
}


void main()
{
	vec4 diffuseTextureColour=texture(diffuseTexture,vertexTextureCoordOut);

	vec4 specularTextureColour=texture(specularTexture,vertexTextureCoordOut);
	
	vec3 normal=texture(normalTexture,vertexTextureCoordOut).rgb;
	normal=normalize(normal * 2.0 - 1.0);
	normal=normalize(tangentMatrix*normal);

	vec4 finalColour=CalculateDirectionLightColour(normal,diffuseTextureColour,specularTextureColour);

	for (int i=0;i<numberOfPointLights;i++)
	{
		finalColour+=CalculatePointLight(normal,i,diffuseTextureColour,specularTextureColour);
	}

	colour=(ambientLightColour*ambientMaterialColour)+finalColour;
}