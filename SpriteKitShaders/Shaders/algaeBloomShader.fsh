//
// Simple example shader, removes red and blue channels to leave
// our texture green-tinted. Demo shader for related blog post:
// http://sound-of-silence.com
// For LICENSE information please see AppDelegate.swift.
//

void main() {
    vec4 color = SKDefaultShading();
    gl_FragColor = vec4(0.0, color.g * color.a, 0.0, color.a);
}

