//
//  TextureShader.metal
//  ProcedualTorus
//
//  Created by jimbook on 7/9/2025.
//

#include <metal_stdlib>
using namespace metal;

struct Args {
    float time;
};

bool equal(half a, half b) {
    return abs(a - b) < 1E-2;
}

[[kernel]]
void textureShader(uint2 gid [[thread_position_in_grid]],
                   constant Args *args [[buffer(0)]],
                   texture2d<half, access::read> textureIn [[texture(0)]],
                   texture2d<half, access::write> textureOut [[texture(1)]],
                   texture2d<half, access::write> drawableOut [[texture(2)]])
{
    half aliveCount = 0;
    aliveCount += textureIn.read(uint2(gid.x - 1, gid.y + 1)).r; // Top-left
    aliveCount += textureIn.read(uint2(gid.x,     gid.y + 1)).r; // Top-center
    aliveCount += textureIn.read(uint2(gid.x + 1, gid.y + 1)).r; // Top-right
    aliveCount += textureIn.read(uint2(gid.x - 1, gid.y - 1)).r; // Bottom-left
    aliveCount += textureIn.read(uint2(gid.x,     gid.y - 1)).r; // Bottom-center
    aliveCount += textureIn.read(uint2(gid.x + 1, gid.y - 1)).r; // Bottom-right
    aliveCount += textureIn.read(uint2(gid.x - 1, gid.y)).r;     // Middle-left
    aliveCount += textureIn.read(uint2(gid.x + 1, gid.y)).r;     // Middle-right
    
    half cell = textureIn.read(gid).r;
    
    if (equal(aliveCount, 3)) {
        cell = 1.0;
    } else if (!equal(aliveCount, 2)) {
        cell = 0.0;
    }
    
    half4 finalColor = half4(cell, cell, cell, 1.0);
    textureOut.write(finalColor, gid);
    drawableOut.write(finalColor, gid);
}
