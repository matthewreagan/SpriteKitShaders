//
// 8/3/18 Demo shader for SpriteKit blog post by Matt Reagan.
// More info: http://sound-of-silence.com  |  @hmblebee
// For LICENSE information please see AppDelegate.swift.
//
// A shader which applies several different effects to
// create a water-like effect on the texture:
//
//      1. Warps the texture with a moving sine wave form
//      2. Slowly scrolls the texture horizontally (wrapping)
//      3. Applies a blue darkening/subtraction color effect to the edges
//         of the texture (also with a moving sine wave)
//      4. Applies a circular alpha masking by cropping any pixels outside
//         of a given radius
//
// +------------------------------------------------------------------------+
// This shader should compile and run in both Metal and OpenGL environments.
// (You can use PrefersOpenGL key in the app's Info.plist to toggle.)
// It could most definitely be improved! This shader is entirely for
// fun / demonstration purposes. - Matt
// +------------------------------------------------------------------------+

//
// Ensure backwards compatibility here with GLSL on
// non-Metal hardware, modulus operator may not be available.
//

int glMod(int a, int b) {
    float fa = a;
    float fb = b;
    return int(a - (b * floor(fa/fb)));
}

//
// Our shader main() function which does all the work and should set the
// resulting pixel color on gl_FragColor before completing.
//

void main() {
    
    // Define some variables for our principal wave form and drift
    float speed = u_time * 0.7;
    float frequency = 20.0;
    float intensity = 0.005;
    int driftSteps = 1200;
    
    // Get the current pixel coordinate we're operating on
    vec2 coord = v_tex_coord;
    
    // Check the distance of this coordinate from our texture center
    float distanceFromCenter = distance(coord, vec2(0.5,0.5));
    
    // If the distance is greater than 0.5 (a perfect circle within our
    // original square texture), we can finish immediately, we set a
    // clear color to effectively crop the pixel
    if (distanceFromCenter > 0.5) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        
        // Calculate the 'drift' (horizontal scrolling) based on u_time
        float driftAmount = glMod(int(u_time * 80), driftSteps);
        float adj = driftAmount / driftSteps;
        
        // Here the wave form is applied by offsetting the actual pixel
        // color we'll return based on cos/sin functions. We also apply
        // the 'drift' amount to the x coordinate to provide a slow
        // horizontal scrolling effect. Note that fract() is called on the
        // resulting coord.x as part of the calculation which allows us
        // to wrap the coordinate around if we exceed 1.0.
        coord.x += cos((coord.x + speed) * frequency) * intensity + adj;
        coord.x = fract(coord.x);
        coord.y += sin((coord.y + speed) * frequency) * intensity;
        
        // Get the color at the new coordinate we've calculated
        vec4 newColor = texture2D(u_texture, coord);
        
        // Finally, we apply a darkening effect here to the edges of the pool.
        // Set up a few values for the effect first
        float edgeShadowDistance = 0.16;
        float edgeShadowThreshold = (0.5 - edgeShadowDistance);
        float edgeShadowRippleIntensity = 0.16;
        float edgeShadowDarkeningValue = 50.0;
        
        // Check if this pixel is within the edge shadow threshold to be darkened
        if (distanceFromCenter > edgeShadowThreshold) {
            
            float darkenAmount = (distanceFromCenter - edgeShadowThreshold) / edgeShadowDistance;
            darkenAmount -= edgeShadowRippleIntensity;
            
            // Here we use cos() to give our edge darkening a nice moving wave shape
            // based on both the X,Y coordinates as well as the progressing simulation
            // time. (Try removing coord.x and coord.y from the calculation to see the
            // edge pulse instead.)
            float edgeCosineWaveValue = cos((coord.x + coord.y + glMod(int(u_time * 30), 2000)) * edgeShadowDarkeningValue);
            
            // Some final adjustments here to further adjust the output color
            darkenAmount += edgeCosineWaveValue * edgeShadowRippleIntensity;
            darkenAmount /= 2.3;
            darkenAmount = max(darkenAmount, 0.0);
            
            // For an additional subtlety we further adjust the edges of the rendered
            // texure by fading them slightly (reducing the alpha value)
            float edgeFadeDistance = edgeShadowDistance / 3.0;
            float edgeFadeThreshold = (0.5 - edgeFadeDistance);
            if (distanceFromCenter > edgeFadeThreshold) {
                float edgeFadeAmount = 1.0 - ((distanceFromCenter - edgeFadeThreshold) / edgeFadeDistance / 2.6);
                newColor.a = edgeFadeAmount;
            }
            
            // Here the final edge darkening adjustment is subtracted from our RGB values
            // (and the alpha value is multiplied). Try adding rather than subtracting for an edge glow
            gl_FragColor = vec4((newColor.rgb - darkenAmount) * newColor.a, newColor.a);
        } else {
            // If we're not applying any edge effects we can finish up immediately.
            gl_FragColor = newColor;
        }
    }
}

