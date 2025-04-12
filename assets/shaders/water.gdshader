shader_type canvas_item;
render_mode unshaded;

uniform float aspect_ratio = 0.5;

uniform vec2 time_factor = vec2(2.0, 3.0);
uniform vec2 offset_factor = vec2(5.0, 2.0);
uniform vec2 amplitude = vec2(0.05, 0.05);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 scale = vec2(1.0, 1.0);

void fragment() {
	vec2 wave_uv_offset;
	vec2 uv = SCREEN_UV;
	wave_uv_offset.x += sin(TIME * time_factor.x + (uv.x + uv.y) * offset_factor.x);
	wave_uv_offset.y += cos(TIME * time_factor.y + (uv.x + uv.y) * offset_factor.y);

	//vec4 c = vec4(UV.x, UV.y, 0.0, 1.0);
	vec4 c = textureLod(screen_texture, SCREEN_UV + (wave_uv_offset * SCREEN_PIXEL_SIZE * amplitude), 0.0);
	
	
	COLOR = c;
}

//void fragment() {
	//vec2 tiled_uvs = UV * tile_factor;
	//tiled_uvs.y *= aspect_ratio;
	//
	//vec2 wave_uv_offset;
	//wave_uv_offset.x += sin(TIME * time_factor.x + (tiled_uvs.x + tiled_uvs.y) * offset_factor.x);
	//wave_uv_offset.y += cos(TIME * time_factor.y + (tiled_uvs.x + tiled_uvs.y) * offset_factor.y);
	//
//
	//COLOR = vec4(1.0, 1.0, 1.0 ,1.0); //texture(TEXTURE, tiled_uvs + wave_uv_offset * amplitude);
//}