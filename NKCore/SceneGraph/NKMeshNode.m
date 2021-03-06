//
//  NKMeshNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//

#import "NodeKitten.h"


@implementation NKMeshNode

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size {
    
    self = [super initWithSize:size];
    if (self) {
        self.size = size;
        
        if (self.size.z == 0) {
            [self setSize:V3Make(self.size.x, self.size.y, 1.)];
        }
        
        self.alpha = 1.0f;
        
        if (texture) {
            _textures = [@[texture] mutableCopy];
            _numTextures = 1;
            [NKTextureManager addNode:self forTexture:texture];
        }
        
        _color = color;
        
        if (!color && _numTextures) {
            _color = NKWHITE;
        }
        
        _primitiveType = primitive;
        
        NSString *pstring = [NKStaticDraw stringForPrimitive:primitive];
        
        if ([[NKStaticDraw meshesCache]objectForKey:pstring]) {
            _vertexBuffer = [[NKStaticDraw meshesCache]objectForKey:pstring];
        }
        
        
        else {
            
            switch (primitive) {
                    
                case NKPrimitiveSphere:
                    _vertexBuffer = [NKVertexBuffer sphereWithStacks:12 slices:14 squash:1.];
                    break;
                    
                case NKPrimitiveLODSphere:
                    _vertexBuffer = [NKVertexBuffer lodSphere:14];
                    break;
                    
                case NKPrimitiveCube:
                    _vertexBuffer = [NKVertexBuffer defaultCube];
                    break;
                    
                case NKPrimitiveRect:
                    _vertexBuffer = [NKVertexBuffer defaultRect];
                    break;
                    
                case NKPrimitiveAxes:
                    _vertexBuffer = [NKVertexBuffer axes];
                    break;
                    
                default:
                    break;
                    
            }
            
            [[NKStaticDraw meshesCache] setObject:_vertexBuffer forKey:pstring];
            
            NSLog(@"add primitive: %@ to mesh cache with %lu vertices", pstring, (unsigned long)_vertexBuffer.numVertices);
            
        }
        
        switch (primitive) {
                
            case NKPrimitiveSphere: case NKPrimitiveLODSphere:
                _drawMode = GL_TRIANGLE_STRIP;
                self.cullFace = NKCullFaceFront;
                break;
                
            case NKPrimitiveCube:
                _drawMode = GL_TRIANGLES;
                self.cullFace = NKCullFaceBack;
                break;
                
            case NKPrimitiveRect:
                _drawMode = GL_TRIANGLE_STRIP;
                self.cullFace = NKCullFaceFront;
                //self.cullFace = NKCullFaceBoth;
                break;
                
            case NKPrimitiveAxes:
                _drawMode = GL_LINES;
                break;
                
            default:
                break;
                
        }
        
        
    }
    
    return self;
}

-(instancetype)initWithVertexBuffer:(NKVertexBuffer*)buffer drawMode:(GLenum)drawMode texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size {
    
    self = [super initWithSize:size];
    if (self) {
        self.size = size;
        
        if (self.size.z == 0) {
            [self setSize:V3Make(self.size.x, self.size.y, 1.)];
        }
        
        self.alpha = 1.0f;
        _colorBlendFactor = 1.;
        
        if (texture) {
            _textures = [@[texture] mutableCopy];
            _numTextures = 1;
            [NKTextureManager addNode:self forTexture:texture];
        }
        
        _color = color;
        self.cullFace = NKCullFaceNone;
        _vertexBuffer = buffer;
        _drawMode = drawMode;
        
    }
    return self;
}

-(instancetype)initWithObjNamed:(NSString *)name {
    return [self initWithObjNamed:name withSize:V3MakeF(1.) normalize:false anchor:false];
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize {
    return [self initWithObjNamed:name withSize:size normalize:normalize anchor:false];
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize anchor:(bool)anchor {
    
    NKVertexBuffer *buf;
    
    if ([[NKStaticDraw meshesCache]objectForKey:name]) {
        buf = [[NKStaticDraw meshesCache]objectForKey:name];
        NSString *textureName;
        
        if (!textureName) {
            self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:nil color:NKWHITE size:buf.boundingBoxSize];
        }
        else{
            self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:[NKTexture textureWithImageNamed:textureName] color:NKWHITE size:buf.boundingBoxSize];
        }
        self.cullFace = NKCullFaceBack;
        return self;
    }
    
    else {
        
        NSString *textureName;
        NSUInteger numElements;
        
        //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"space_frigate_6" ofType:@"obj"];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
        int p = 0;
        if (filePath) {
            NSError *error;
            NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            if (myText) {
                
                NSMutableArray *vertices = [[NSMutableArray alloc] init];
                NSMutableArray *expandedVertices = [[NSMutableArray alloc] init];
                NSMutableArray *texCoords = [[NSMutableArray alloc] init];
                NSMutableArray *expandedTexCoords = [[NSMutableArray alloc] init];
                NSMutableArray *normals = [[NSMutableArray alloc] init];
                NSMutableArray *expandedNormals = [[NSMutableArray alloc] init];
                
                NSArray *lines = [myText componentsSeparatedByString:@"\n"];
                //NSLog(@"lines has %d lines", [lines count]);
                for (NSString *astring in lines){
                    if ([astring hasPrefix:@"v "]){
                        [vertices addObject:astring];
                    }
                    else if ([astring hasPrefix:@"vt "]){ // TEXCOORDS
                        [texCoords addObject:astring];
                    }
                    else if ([astring hasPrefix:@"vn "]){ // NORMAL
                        [normals addObject:astring];
                    }
                    
                    else if ([astring hasPrefix:@"f "]){
                        NSArray *iArray = [astring arrayWithNoSpaces];
                        int i;
                        //NSLog(@"xxx");
                        for (i = 1; i < [iArray count]; i++) {
                            NSArray *bArray = [[iArray objectAtIndex:i] componentsSeparatedByString:@"/"];
                            
                            [expandedVertices addObject:[vertices objectAtIndex:[[bArray objectAtIndex:0] intValue] - 1]];
                            [expandedTexCoords addObject:[texCoords objectAtIndex:[[bArray objectAtIndex:1] intValue] - 1]];
                            [expandedNormals addObject:[normals objectAtIndex:[[bArray objectAtIndex:2] intValue] - 1]];
                            //extract coords for tangent
                        }
                        //NSLog(@"end xxx");
                    }
                    //                else if ([astring hasPrefix:@"t "]){ // TEXTURE NAME
                    //                    NSArray *iArray = [astring arrayWithNoSpaces];
                    //                    textureName = [iArray objectAtIndex:1];
                    //                    NSLog(@"texture name is %@", textureName);
                    //
                    //                }
                    //                else if ([astring hasPrefix:@"ex "]){
                    //                    NSArray *iArray = [astring arrayWithNoSpaces];
                    //                    textureName = [iArray objectAtIndex:1];
                    //                    NSLog(@"texture name is %@", textureName);
                    //
                    //                }
                    
                    //}
                    
                }
                
                numElements = [expandedVertices count];
                
                NKPrimitiveArray *buffer = malloc(sizeof(NKPrimitiveArray)*numElements);
                
                float minx = 1000000., maxx = -1000000.;
                float miny = 1000000., maxy = -1000000.;
                float minz = 1000000., maxz = -1000000.;
                
                V3t finalModelSize;
                
                if (normalize) {
                    
                    for (p = 0; p < [expandedVertices count]; p++){ // FIND LARGEST VALUE
                        
                        NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                        NSUInteger cq = [c count];
                        
                        //NSLog(@"v %@ %@ %@",[c objectAtIndex:cq - 3], [c objectAtIndex:cq -2],[c objectAtIndex:cq -1]);
                        
                        float t = [[c objectAtIndex:cq - 3] floatValue];
                        if (t < minx)
                            minx = t;
                        if (t > maxx)
                            maxx = t;
                        
                        
                        t = [[c objectAtIndex:cq -2] floatValue];
                        if (t < miny)
                            miny = t;
                        if (t > maxy)
                            maxy = t;
                        
                        
                        t = [[c objectAtIndex:cq -1] floatValue];
                        if (t < minz)
                            minz = t;
                        if (t > maxz)
                            maxz = t;
                        
                    };
                    
                    float width = fabsf(maxx - minx);
                    float height = fabsf(maxy - miny);
                    float depth = fabsf(maxz - minz);
                    
                    NKLogV3(@"min", V3Make(minx, miny, minz));
                    NKLogV3(@"max", V3Make(maxx, maxy, maxz));
                    NKLogV3(@"center", V3Make((minx+maxx), (miny+maxy), (minz+maxz)));
                    
                    V3t modelSize = V3Make(width, height, depth);
                    
                    V3t modelInverse = V3Divide(V3MakeF(2.), modelSize);
                    
                    V3t modelNormalized = V3UnitRetainAspect(modelSize);
                    
                    finalModelSize = V3Multiply(size, modelNormalized);
                    
                    //                NKLogV3(@"obj size:", modelSize);
                    //                NKLogV3(@"obj divisor:", modelInverse);
                    //                NKLogV3(@"normalized size", modelNormalized);
                    //                NKLogV3(@"normalized center", offsetNormalized);
                    
                    for (p = 0; p < [expandedVertices count]; p++){
                        // VERTICES
                        NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                        NSUInteger cq = [c count];
                        
                        V3t vertex = V3Make([[c objectAtIndex:cq - 3] floatValue], [[c objectAtIndex:cq - 2] floatValue], [[c objectAtIndex:cq - 1] floatValue]);
                        
                        if (anchor) {
                            V3t offset = V3Make((minx+maxx), (miny+maxy), (minz+maxz));
                            V3t offsetNormalized = V3Divide(offset, modelSize);
                            buffer[p].vertex = V3Subtract(V3Multiply(vertex, modelInverse),offsetNormalized);
                        }
                        else {
                            buffer[p].vertex = V3Multiply(vertex, modelInverse);
                        }
                    }
                    
                }
                else {
                    finalModelSize = size;
                    
                    for (p = 0; p < [expandedVertices count]; p++){
                        // VERTICES
                        NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                        NSUInteger cq = [c count];
                        V3t vertex = V3Make([[c objectAtIndex:cq - 3] floatValue], [[c objectAtIndex:cq - 2] floatValue], [[c objectAtIndex:cq - 1] floatValue]);
                        if (anchor) {
                            V3t offset = V3Make((minx+maxx), (miny+maxy), (minz+maxz));
                            buffer[p].vertex = V3Subtract(vertex,offset);
                        }
                        else {
                            buffer[p].vertex = vertex;
                        }
                    }
                }
                for (p = 0; p < [expandedVertices count]; p++){
                    // TEXCOORDS
                    NSArray *c =  [[expandedTexCoords objectAtIndex:p] componentsSeparatedByString:@" "];
                    NSUInteger cq = [c count];
                    buffer[p].texCoord.x = [[c objectAtIndex:cq-2] floatValue];
                    buffer[p].texCoord.y = [[c objectAtIndex:cq-1] floatValue];
                    // NORMALS
                    c =  [[expandedNormals objectAtIndex:p] componentsSeparatedByString:@" "];
                    cq = [c count];
                    buffer[p].normal.x = [[c objectAtIndex:cq -3] floatValue];
                    buffer[p].normal.y = [[c objectAtIndex:cq -2] floatValue];
                    buffer[p].normal.z = [[c objectAtIndex:cq - 1] floatValue];
                    // COLORS
                    buffer[p].color.r = 1.0;
                    buffer[p].color.g = 1.0;
                    buffer[p].color.b = 1.0;
                    buffer[p].color.a = 1.0;
                }
                
                buf = [[NKVertexBuffer alloc] initWithSize:sizeof(NKPrimitiveArray)*numElements numberOfElements:numElements data:buffer setup:[NKVertexBuffer primitiveSetupBlock]];
                
                buf.boundingBoxSize = finalModelSize;
                
                [[NKStaticDraw meshesCache] setObject:buf forKey:name];
                
                NSLog(@"cache obj named: %@", name);
                
                free(buffer);
                
                NKLogV3(@"object bounding box size", finalModelSize);
                
            }
            
            if (!textureName) {
                self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:nil color:NKWHITE size:buf.boundingBoxSize];
            }
            else{
                self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:[NKTexture textureWithImageNamed:textureName] color:NKWHITE size:buf.boundingBoxSize];
            }
            
            self.cullFace = NKCullFaceBack;
            
            return self;
            
        }
        
    }
    
    return nil;
    
}

-(void)chooseShader {
    if (_numTextures) {
        if (_numTextures) {
            NKTexture *t = _textures[0];
            
            if ([t isKindOfClass:[NKVideoTexture class]]) {
                    self.shader = [NKShaderProgram newShaderNamed:@"videoTextureShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:-1 numLights:1 withBatchSize:0];
            }
            else {
                self.shader = [NKShaderProgram newShaderNamed:@"uColorTextureLightShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:_numTextures numLights:1 withBatchSize:0];
            }
        }
    }
    else {
        self.shader = [NKShaderProgram newShaderNamed:@"uColorLightShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:0 numLights:1 withBatchSize:0];
    }
}

-(void)setScene:(NKSceneNode *)scene {
    [super setScene:scene];
    
    if (!self.shader) {
        //NSLog(@"choose shader");
        [self chooseShader];
    }
    
}

-(void)setColor:(NKByteColor *)color {
    _color = color;
}

-(void)setDrawMode:(GLenum)drawMode {
    _drawMode = drawMode;
}

-(NKVertexBuffer*)vertexBuffer {
    return _vertexBuffer;
}

-(void)setTexture:(NKTexture *)texture {
    
    NSArray *oldTex = [_textures copy];
    
    for (NKTexture *t in oldTex) {
        [NKTextureManager removeNode:self forTexture:t];
    }
    
    if (texture) {
        _numTextures = 1;
        if (!_textures){
            [self chooseShader];
        }
        _textures = [@[texture] mutableCopy];
        [NKTextureManager addNode:self forTexture:texture];
    }
    
    else {
        if (_textures) {
            [self chooseShader];
        }
        [_textures removeAllObjects];
        _textures = nil;
        _numTextures = 0;
    }

}

-(int)lodForDistance {
    
    float distance = V3Distance(self.scene.camera.globalPosition, self.globalPosition) * .125;
    
    float size = self.size.width;
    
    int lod = 0;
    
    if (size < distance) {
        
        float diff = (distance - size) / distance;
        
        lod = diff * ((float)_vertexBuffer.numVertices);
    }
    
    return lod;
}

-(void)setupViewMatrix {
    
    M16t mvp;
    
    if (_forceOrthographic) {
        mvp = M16Multiply(self.scene.camera.orthographicMatrix,M16Multiply(M16MakeLookAt(V3Make(0, 0, 1), V3MakeF(0), V3Make(0, 1, 0)),M16ScaleWithV3(M16IdentityMake(), _size)));
    }
    
    else {
        M16t modelView = M16Multiply(self.scene.camera.viewMatrix,M16ScaleWithV3(self.globalTransform, _size));
        
        if([self.scene.activeShader uniformNamed:NKS_M16_MV] ){
            [[self.scene.activeShader uniformNamed:NKS_M16_MV] bindM16:modelView];
        }
        
        if ([self.scene.activeShader uniformNamed:NKS_M9_NORMAL]){
            [[self.scene.activeShader uniformNamed:NKS_M9_NORMAL] bindM9:M16GetInverseNormalMatrix(modelView)];
        }
        
        mvp = M16Multiply(self.scene.camera.projectionMatrix,modelView);
    }
    
    [[self.scene.activeShader uniformNamed:NKS_M16_MVP] bindM16:mvp];
    
}

-(void)bindTextures {
    if (_numTextures) {
        if (self.scene.boundTexture != _textures[0]) {
            [_textures[0] bind];
            if ([_textures[0] isKindOfClass:[NKVideoTexture class]]) {
                //NSLog(@"binding tex scale: %f %f", [(NKVideoTexture*)_textures[0] size].x, [(NKVideoTexture*)_textures[0] size].y);
                NKVideoTexture* t = _textures[0];
                
                [[self.scene.activeShader uniformNamed:NKS_TEXTURE_RECT_SCALE] bindV2:V2Make(t.width, t.height)];
            }
            else {
                [[self.scene.activeShader uniformNamed:NKS_TEXTURE_RECT_SCALE] bindV2:P2Make(1, 1)];
            }
            self.scene.boundTexture = _textures[0];
        }
    }
}


//-(void)pushStyle {
//    
//    [super pushStyle];
//    
//    if (_lineWidth != 0) {
//#if NK_USE_GL3
//        [[self.scene.activeShader uniformNamed:NKS_F1_GL_LINEWIDTH] bindF1:_lineWidth];
//#else
//        glLineWidth(_lineWidth);
//#endif
//    }
//    if (_pointSize) {
//        glPointSize(_pointSize);
//    }
//    
//}

-(void)customDraw {
    
    if (self.color || _numTextures) {
        
        [self setupViewMatrix];
        [self pushStyle];
        
        if ([self.scene.activeShader uniformNamed:NKS_V4_COLOR]){
            if (!_color) {
                [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4:[NKCLEAR C4Color]];
            }else {
                [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4:[self glColor]];
            }
        }
        
        [self bindTextures];
        
        if (self.scene.boundVertexBuffer != _vertexBuffer) {
            [_vertexBuffer bind];
            self.scene.boundVertexBuffer = _vertexBuffer;
        }
        
        if (_vertexBuffer.indexBuffer){
            [_vertexBuffer.indexBuffer bind];
            glDrawElements(_drawMode, _vertexBuffer.indexBuffer.numElements, GL_UNSIGNED_INT, 0);
            [_vertexBuffer.indexBuffer unbind];
        }
        else{
            if (_usesLOD) {
                int lod = [self lodForDistance];
                glDrawArrays(_drawMode, _vertexBuffer.elementOffset[lod], _vertexBuffer.elementSize[lod]);
            }
            else {
                glDrawArrays(_drawMode, 0, _vertexBuffer.numVertices);
            }
        }
        
        if (_drawBoundingBox) {
            NKVertexBuffer*v = [NKStaticDraw cachedPrimitive:NKPrimitiveCube];
            [v bind];
            glDrawArrays(GL_LINES, 0, v.numVertices);
        }
        
    }
    
}

-(void)customdrawWithHitShader {
    
    [self setupViewMatrix];

    [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4:self.uidColor.C4Color];
    
    if (self.scene.boundVertexBuffer != _vertexBuffer) {
        [_vertexBuffer bind];
        self.scene.boundVertexBuffer = _vertexBuffer;
    }
    
    if (_usesLOD) {
        int lod = [self lodForDistance];
        glDrawArrays(_drawMode, _vertexBuffer.elementOffset[lod], _vertexBuffer.elementSize[lod] );
    }
    else {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexBuffer.numVertices);
        
    }
}

-(void)unload {
    
    for (NKTexture *t in _textures) {
        [NKTextureManager removeNode:self forTexture:t];
    }
    [super unload];
}

@end

