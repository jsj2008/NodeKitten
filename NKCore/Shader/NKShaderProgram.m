//
//  NOCShaderProgram.m
//  Nature of Code
//
//  Created by William Lindmeier on 2/2/13.
//  Copyright (c) 2013 wdlindmeier. All rights reserved.
//

#import "NodeKitten.h"


@implementation NKShaderProgram
{
    NSString *_vertShaderPath;
    NSString *_fragShaderPath;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        self.name = name;
        
        _vertShaderPath = [[NSBundle mainBundle] pathForResource:self.name
                                                          ofType:@"vsh"];
        _fragShaderPath = [[NSBundle mainBundle] pathForResource:self.name
                                                          ofType:@"fsh"];
        // NOTE: Maybe this should just return nil?
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_vertShaderPath] );
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_fragShaderPath] );
        
        _vertexSource =  [NSString stringWithContentsOfFile:_vertShaderPath encoding:NSUTF8StringEncoding error:nil];
        _fragmentSource = [NSString stringWithContentsOfFile:_fragShaderPath encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (instancetype)initWithVertexShader:(NSString *)vertShaderName fragmentShader:(NSString *)fragShaderName
{
    self = [super init];
    if(self)
    {
        int dotIndex = [vertShaderName rangeOfString:@"."].location;
        if ( dotIndex != NSNotFound )
        {
            self.name = [vertShaderName substringToIndex:dotIndex];
        }
        else
        {
            self.name = vertShaderName;
        }
        
        _vertShaderPath = [[NSBundle mainBundle] pathForResource:vertShaderName ofType:nil];
        _fragShaderPath = [[NSBundle mainBundle] pathForResource:fragShaderName ofType:nil];
        
        // NOTE: Maybe this should just return nil?
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_vertShaderPath] );
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_fragShaderPath] );
        
        _vertexSource =  [NSString stringWithContentsOfFile:_vertShaderPath encoding:NSUTF8StringEncoding error:nil];
        _fragmentSource = [NSString stringWithContentsOfFile:_fragShaderPath encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

//- (id)initWithDictionary:(NSDictionary*)shaderDict name:(NSString*)name{
//
//    NSAssert(shaderDict, @"ERROR no shaderDict");
//
//    self = [super init];
//
//    if (self) {
//
//        _name = name;
//
//        extensions = [shaderDict[NKS_EXTENSIONS] copy];
//        attributes = [shaderDict[NKS_ATTRIBUTES] copy];
//        uniforms = [shaderDict[NKS_UNIFORMS] copy];
//        varyings = [shaderDict[NKS_VARYINGS] copy];
//
//        vertMain = [shaderDict[NKS_VERT_MAIN] copy];
//        fragMain = [shaderDict[NKS_FRAG_MAIN] copy];
//
//        mode = [shaderDict[NKS_VERT_MODULES] copy];
//        fragModules = [shaderDict[NKS_FRAG_MODULES] copy];
//
//        _vertexSource = [self vertexString];
//#if NK_LOG_GL
//        NSLog(@"%@",_vertexSource);
//#endif
//        _fragmentSource = [self fragmentString];
//#if NK_LOG_GL
//        NSLog(@"%@",_fragmentSource);
//#endif
//    }
//
//    return self;
//}


-(instancetype)initWithVertexSource:(NSString *)vertexSource fragmentSource:(NSString *)fragmentSource {
    self = [super init];
    if(self)
    {
        _vertexSource = vertexSource;
        _fragmentSource = fragmentSource;
    }
    return self;
}

+(instancetype)shaderNamed:(NSString*)name {
    if ([NKShaderManager programCache][name]) {
        return [NKShaderManager programCache][name];
    }
    NSLog(@"ERROR shader program named: %@ not found", name);
    return nil;
}

//+(instancetype)newShaderNamed:(NSString *)name vertModules:(NSArray *)vertModules fragModules:(NSArray *)fragModules withBatchSize:(int)batchSize {
//
//    if ([NKShaderManager programCache][name]) {
//        return [NKShaderManager programCache][name];
//    }
//
//    NSLog(@"new shader dict");
//
//    NSMutableDictionary* shaderDict = [[NSMutableDictionary alloc]init];
//
//    // ALLOCATE ARRAYS
//
//    shaderDict[NKS_ATTRIBUTES] = [[NSMutableArray alloc]init];
//    shaderDict[NKS_UNIFORMS] = [[NSMutableSet alloc]init];
//    shaderDict[NKS_VARYINGS] = [[NSMutableSet alloc]init];
//    shaderDict[NKS_VERT_MAIN] = [NSMutableArray array];
//    shaderDict[NKS_FRAG_MAIN] = [[NSMutableArray alloc]init];
//    shaderDict[NKS_PROGRAMS] = [[NSMutableArray alloc]init];
//
//    // ADD BASICS
//
//    [shaderDict[NKS_ATTRIBUTES] addObject:nksa(NKS_TYPE_V4, NKS_V4_POSITION)];
//    [shaderDict[NKS_ATTRIBUTES] addObject:nksa(NKS_TYPE_V3, NKS_V3_NORMAL)];
//    [shaderDict[NKS_ATTRIBUTES] addObject:nksa(NKS_TYPE_V2, NKS_V2_TEXCOORD)];
//    [shaderDict[NKS_ATTRIBUTES] addObject:nksa(NKS_TYPE_V4, NKS_V4_COLOR)];
//
//    if (batchSize) {
//        [shaderDict[NKS_UNIFORMS] addObject:nksua(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MVP, batchSize)];
//    }
//    else {
//        [shaderDict[NKS_UNIFORMS] addObject:nksu(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MVP)];
//    }
//
//    // INSTANCE ID's for batch
//
//    if (batchSize) {
//        shaderDict[NKS_EXTENSIONS]=@[nks(NKS_EXT_DRAW_INSTANCED),nks(NKS_EXT_GPU_SHADER)];
//    }
//
//    /////// DO VERT MODULES /////////
//
//    for (int i = 0; i < vertModules.count; i++) {
//    }
//
//    /////// DO FRAG MODULES /////////
//
//    for (int i = 0; i < fragModules.count; i++) {
//    }
//
//    /////// COMPILE /////////
//
//    NKShaderProgram *newShader = [[NKShaderProgram alloc] initWithDictionary:shaderDict name:name];
//
//    if ([newShader load]) {
//        [NKShaderManager programCache][name]=newShader;
//        NSLog(@"*** generate shader *%d* named: %@ ***", newShader.glPointer, name);
//    }
//    else {
//        NSLog(@"ERROR LOADING SHADER");
//    }
//
//    return newShader;
//
//}

+(instancetype)newShaderNamed:(NSString*)name colorMode:(NKS_COLOR_MODE)colorMode numTextures:(NSUInteger)numTex numLights:(int)numLights withBatchSize:(int)batchSize {
    
    if ([NKShaderManager programCache][name]) {
        return [NKShaderManager programCache][name];
    }
    
    return [[NKShaderProgram alloc] initWithName:name colorMode:colorMode numTextures:numTex numLights:numLights withBatchSize:batchSize];
}

-(instancetype)initWithName:(NSString*)name colorMode:(NKS_COLOR_MODE)colorMode numTextures:(NSUInteger)numTex numLights:(int)numLights withBatchSize:(int)batchSize {
    
    if ( self = [super init] ) {
        
        _name = name;
        
        attributes = [NSMutableArray array];
        uniforms = [NSMutableSet set];
        varyings = [NSMutableSet set];
        vertMain = [NSMutableArray array];
        fragMain = [NSMutableArray array];
        modules = [NSMutableArray array];
        extPrograms = [NSMutableArray array];
        
        NSLog(@"init shader");
        
         // ADD BASICS
        
        [self addAttribute:nksa(NKS_TYPE_V4, NKS_V4_POSITION)];
        [self addAttribute:nksa(NKS_TYPE_V3, NKS_V3_NORMAL)];
        [self addAttribute:nksa(NKS_TYPE_V2, NKS_V2_TEXCOORD)];
        [self addAttribute:nksa(NKS_TYPE_V4, NKS_V4_COLOR)];
        
        if (batchSize) {
            [self addUniform:nksua(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MVP, batchSize)];
        }
        else {
            [self addUniform:nksu(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MVP)];
        }
        
        // INSTANCE ID's for batch
        
        if (batchSize) {
            extensions = @[nks(NKS_EXT_DRAW_INSTANCED),nks(NKS_EXT_GPU_SHADER)];
        }
        // ADD COLOR
        
        if (colorMode != NKS_COLOR_MODE_NONE) {
            [modules addObject:[NKShaderModule vertexColorModule:colorMode batchSize:batchSize]];
        }
        
        //    if (colorMode == NKS_COLOR_MODE_UNIFORM) {
        //        if (batchSize) {
        //            [shaderDict[NKS_UNIFORMS] addObject:nksua(NKS_PRECISION_MEDIUM, NKS_TYPE_V4, NKS_V4_COLOR, batchSize)];
        //        }
        //        else {
        //            [shaderDict[NKS_UNIFORMS] addObject:nksu(NKS_PRECISION_MEDIUM, NKS_TYPE_V4, NKS_V4_COLOR)];
        //        }
        //    }
        //
        //    if (colorMode != NKS_COLOR_MODE_NONE) {
        //        [shaderDict[NKS_VARYINGS] addObject:nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V4, NKS_V4_COLOR)];
        //    }
        
        // STYLE
        
#if NK_USE_GL3
        [shaderDict[NKS_UNIFORMS] addObject:nksu(NKS_PRECISION_MEDIUM, NKS_TYPE_F1, NKS_F1_GL_LINEWIDTH)];
#endif
        
        if (numLights) {
            
            [uniforms addObjectsFromArray:@[nksu(NKS_PRECISION_NONE, NKS_TYPE_INT, NKS_I1_NUM_LIGHTS),
                                            nksu(NKS_PRECISION_NONE, NKS_STRUCT_LIGHT, NKS_LIGHT)
                                            ]];
            
            if (batchSize) {
                [uniforms addObject:nksua(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MV, batchSize)];
                [uniforms addObject:nksua(NKS_PRECISION_MEDIUM, NKS_TYPE_M9, NKS_M9_NORMAL, batchSize)];
            }
            else {
                [uniforms addObject:nksu(NKS_PRECISION_HIGH, NKS_TYPE_M16, NKS_M16_MV)];
                [uniforms addObject:nksu(NKS_PRECISION_MEDIUM, NKS_TYPE_M9, NKS_M9_NORMAL)];
            }
            if (![self varyingNamed:NKS_V3_NORMAL]) {
                [varyings addObject:nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V3, NKS_V3_NORMAL)];
            }
            
            [varyings addObject:nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V3, NKS_V3_EYE_DIRECTION)];
            
            if (![self varyingNamed:NKS_V4_POSITION]) {
                [varyings addObject:nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V4, NKS_V4_POSITION)];
            }
            
            [varyings addObject:nksv(NKS_PRECISION_LOW, NKS_TYPE_V3, NKS_V3_LIGHT_DIRECTION)];
            [varyings addObject:nksv(NKS_PRECISION_LOW, NKS_TYPE_V3, NKS_V3_LIGHT_HALF_VECTOR)];
            [varyings addObject:nksv(NKS_PRECISION_LOW, NKS_TYPE_F1, NKS_F1_ATTENUATION)];
            
            [fragMain addObject:nksi(NKS_PRECISION_LOW, NKS_TYPE_V4, NKS_V4_LIGHT_COLOR)];
            
            [modules addObject:[NKShaderModule lightModule:true batchSize:batchSize]];
//#if NK_USE_GLES
//            [extPrograms addObject:@"lqLightProgram"];
//#else
//            [extPrograms addObject:@"hqLightProgram"];
//#endif
            
        }
        
        if (numTex == -1){ // quick vid fix
            [uniforms addObject: nksu(NKS_PRECISION_LOW, NKS_TYPE_SAMPLER_CORE_VIDEO, NKS_S2D_TEXTURE)];
            [uniforms addObject: nksu(NKS_PRECISION_MEDIUM, NKS_TYPE_V2, NKS_TEXTURE_RECT_SCALE)];
            [varyings addObject: nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V2, NKS_V2_TEXCOORD)];
            
            [fragMain addObject:nksi(NKS_PRECISION_LOW, NKS_TYPE_V4, NKS_V4_TEX_COLOR)];
            
            if ([self uniformNamed:NKS_S2D_TEXTURE].type == NKS_TYPE_SAMPLER_2D) {
                [vertMain addObject:@"v_texCoord0 = vec2(a_texCoord0.x, 1. - a_texCoord0.y);"];
            }
            else {
                [vertMain addObject:@"v_texCoord0 = vec2(a_texCoord0.x, 1. - a_texCoord0.y) * u_textureScale;"];
            }
            
        }
        
        else if (numTex) {
            //[shaderDict[NKS_UNIFORMS] addObject: nksu(NKS_PRECISION_MEDIUM, NKS_TYPE_V2, NKS_TEXTURE_RECT_SCALE)];
            [uniforms addObject: nksu(NKS_PRECISION_LOW, NKS_TYPE_SAMPLER_2D, NKS_S2D_TEXTURE)];
            [varyings addObject: nksv(NKS_PRECISION_MEDIUM, NKS_TYPE_V2, NKS_V2_TEXCOORD)];
            [fragMain addObject:nksi(NKS_PRECISION_LOW, NKS_TYPE_V4, NKS_V4_TEX_COLOR)];
            
            [vertMain addObject:shaderLineWithArray(@[[self varyingNamed:NKS_V2_TEXCOORD],@"=",[self attributeNamed:NKS_V2_TEXCOORD]])];
        }
        
        // VERTEX main()
        
        //    if (colorMode == NKS_COLOR_MODE_UNIFORM) {
        //        if (batchSize) {
        //#if NK_USE_GLES
        //            [shaderDict[NKS_VERTEX_MAIN] addObject:@"v_color = u_color[gl_InstanceIDEXT];"];
        //#else
        //            [shaderDict[NKS_VERT_MAIN] addObject:@"v_color = u_color[gl_InstanceID];"];
        //#endif
        //        }
        //        else {
        //            [shaderDict[NKS_VERT_MAIN] addObject:shaderLineWithArray(@[[shaderDict varyingNamed:NKS_V4_COLOR],@"=",[shaderDict uniformNamed:NKS_V4_COLOR]])];
        //        }
        //    }
        //
        //    else if (colorMode == NKS_COLOR_MODE_VERTEX){
        //            [shaderDict[NKS_VERT_MAIN] addObject:shaderLineWithArray(@[[shaderDict varyingNamed:NKS_V4_COLOR],@"=",[shaderDict attributeNamed:NKS_V4_COLOR]])];
        //    }
        
        
        
        if ([self uniformNamed:NKS_M9_NORMAL]) {
            if (batchSize) {
#if NK_USE_GLES
                [vertMain addObject:@"v_normal = normalize(u_normalMatrix[gl_InstanceIDEXT] * a_normal);"];
#else
                [vertMain addObject:@"v_normal = normalize(u_normalMatrix[gl_InstanceID] * a_normal);"];
#endif
            }
            else {
                [vertMain addObject:@"v_normal = normalize(u_normalMatrix * a_normal);"];
            }
        }
        
        // do EYE space postion
        
        if ([self uniformNamed:NKS_M16_MV]) {
            if (batchSize) {
#if NK_USE_GLES
                [vertMain addObject:@"v_position = u_modelViewMatrix[gl_InstanceIDEXT] * a_position;"];
#else
                [vertMain addObject:@"v_position = u_modelViewMatrix[gl_InstanceID] * a_position;"];
#endif
            }
            else {
                [vertMain addObject:@"v_position = u_modelViewMatrix * a_position;"];
            }
        }
        
        // last do RASTER space position
        
        if ([self uniformNamed:NKS_M16_MVP]) {
            
            if (batchSize) {
#if NK_USE_GLES
                [vertMain addObject:@"gl_Position = u_modelViewProjectionMatrix[gl_InstanceIDEXT] * a_position;"];
#else
                [vertMain addObject:@"gl_Position = u_modelViewProjectionMatrix[gl_InstanceID] * a_position;"];
#endif
            }
            else {
                [vertMain addObject:@"gl_Position = u_modelViewProjectionMatrix * a_position;"];
            }
            
        }
        
        //   NKShaderProgram *newShader = [[NKShaderProgram alloc] initWithDictionary:shaderDict name:name];
    
#if NK_LOG_GL
        NSLog(@"format shader strings");
#endif
        _vertexSource = [self vertexString];
#if NK_LOG_GL
        NSLog(@"%@",_vertexSource);
#endif
        _fragmentSource = [self fragmentString];
#if NK_LOG_GL
        NSLog(@"%@",_fragmentSource);
#endif
#if NK_LOG_GL
        NSLog(@"load shader");
#endif
        
        if ([self load]) {
            [NKShaderManager programCache][name]=self;
            NSLog(@"*** generate shader *%d* named: %@ ***", self.glPointer, self.name);
        }
        else {
            NSLog(@"ERROR LOADING SHADER");
        }
        
    }
    
    
    return self;
    
}

-(NSArray*)uniformNames {
    NSMutableArray *names = [NSMutableArray array];
    
    for (NKShaderVariable *v in uniforms) {
        [names addObject:v.nameString];
    }
    
    return names;
    
}

-(NSString*)vertexString {
    
    NSMutableString *shader = [NKS_GLSL_VERSION mutableCopy];
    [shader appendNewLine:@"\n //***"];
    [shader appendNewLine:@"//NK VERTEX SHADER"];
    [shader appendNewLine:@"//***"];
    
#if NK_USE_GL3
    [shader appendNewLine:@"#version 330 core"];
#else
    for (NSString* s in extensions) {
        [shader appendNewLine:s];
    }
#endif
    
    
#if NK_USE_GLES
    [shader appendNewLine:@"precision highp float;"];
#else
    
#endif
    
    for (NKShaderModule *module in modules){
        [shader appendString:module.types];
    }
//    for (NSString *s in extPrograms){
//        [shader appendString:shaderStringWithDirective(s, @"@interface")];
//    }
    
    for (NKShaderVariable* v in attributes) {
        [shader appendNewLine:[v declarationStringForSection:NKS_VERTEX_SHADER]];
    }
    for (NKShaderVariable* v in uniforms) {
        [shader appendNewLine:[v declarationStringForSection:NKS_VERTEX_SHADER]];
    }
    for (NKShaderVariable* v in varyings) {
        [shader appendNewLine:[v declarationStringForSection:NKS_VERTEX_SHADER]];
    }
    
    for (NKShaderModule *module in modules){
            for (NKShaderVariable* v in module.uniforms){
                [shader appendNewLine:[v declarationStringForSection:NKS_VERTEX_SHADER]];
            }
            for (NKShaderVariable* v in module.varyings){
                [shader appendNewLine:[v declarationStringForSection:NKS_VERTEX_SHADER]];
            }
    }
        
    [shader appendNewLine:@"void main() {"];
    
    for (NSString* s in vertMain) {
        [shader appendNewLine:s];
    }
    
    for (NKShaderModule *module in modules){
            if (module.vertexMain) {
                [shader appendString:module.vertexMain];
            }
    }
    for (NSString *s in extPrograms){
        [shader appendString:shaderStringWithDirective(s, @"@vertmain")];
    }
    
    [shader appendNewLine:@"}"];
    
    return shader;
}

-(NSString*)fragmentString {
    
    NSMutableString *shader = [NKS_GLSL_VERSION mutableCopy];
    
    [shader appendNewLine:@"//***"];
    [shader appendNewLine:@"//NK FRAGMENT SHADER"];
    [shader appendNewLine:@"//***"];
    
#if NK_USE_GL3
    [shader appendNewLine:@"#version 330 core"];
    
    [shader appendNewLine:@"layout ( location = 0 ) out vec4 FragColor;"];
    
#else
    for (NSString* s in extensions) {
        [shader appendNewLine:s];
    }
#endif
    
#if NK_USE_GLES
    [shader appendNewLine:@"precision highp float;"];
#else
#endif
    
//    for (NSString *s in extPrograms){
//        [shader appendString:shaderStringWithDirective(s, @"@interface")];
//    }
    for (NKShaderModule *module in modules){
        [shader appendString:module.types];
    }
    
    for (NKShaderVariable* v in uniforms) {
        [shader appendNewLine:[v declarationStringForSection:NKS_FRAGMENT_SHADER]];
    }
    for (NKShaderVariable* v in varyings) {
        [shader appendNewLine:[v declarationStringForSection:NKS_FRAGMENT_SHADER]];
    }
    
    for (NKShaderModule *module in modules){
            for (NKShaderVariable* v in module.uniforms){
                [shader appendNewLine:[v declarationStringForSection:NKS_FRAGMENT_SHADER]];
            }
            for (NKShaderVariable* v in module.varyings){
                [shader appendNewLine:[v declarationStringForSection:NKS_FRAGMENT_SHADER]];
            }
    }
    

    [shader appendNewLine:@"void main() {"];
    
    [shader appendNewLine:@"//GENERATED INLINES"];
    
    for (NKShaderVariable* v in fragMain) {
        [shader appendNewLine:[v declarationStringForSection:NKS_FRAGMENT_SHADER]];
    }
    
    if ([self uniformNamed:NKS_S2D_TEXTURE]) {
        
#if NK_USE_GL3
        [shader appendString:shaderStringWithDirective(@"textureProgram", @"@330fragmain")];
#else
        if ([self uniformNamed:NKS_S2D_TEXTURE].type == NKS_TYPE_SAMPLER_2D_RECT) {
            [shader appendString:@"texColor =  texture2DRect(u_texture,v_texCoord0);"];
        }
        else {
            [shader appendString:@"texColor =  texture2D(u_texture,v_texCoord0);"];
        }
#endif
    }
    
    for (NKShaderModule *m in modules){
        if (m.fragmentMain) {
                    [shader appendString:m.fragmentMain];
        }
    }
    
    for (NSString* s in fragMain) {
        if ([s isKindOfClass:[NSString class]]) {
            [shader appendNewLine:s];
        }
    }
    
    NSMutableArray *colorMults = [NSMutableArray array];
    
    for (NKShaderModule *module in modules) {
        for (NKShaderVariable *v in module.outputColor) {
            [colorMults addObject:v];
        }
    }

    //    if ([dict varyingNamed:NKS_V4_COLOR]) {
    //        [colorMults addObject:[dict varyingNamed:NKS_V4_COLOR]];
    //    }
    
    if ([self uniformNamed:NKS_S2D_TEXTURE]) {
        [colorMults addObject:[self fragVarNamed:NKS_V4_TEX_COLOR]];
    }
    if ([self uniformNamed:NKS_LIGHT]) {
        [colorMults addObject:[self fragVarNamed:NKS_V4_LIGHT_COLOR]];
    }
    
    [shader appendString:shaderLineWithArray(@[nks(NKS_V4_GL_FRAG_COLOR), @" = ", operatorString(colorMults, @"*"),@";"])];
    
    [shader appendNewLine:@"}"];
    
    return shader;
    
}


- (BOOL)load
{
    
    GLuint vertShader, fragShader;
    
    // Create shader program.
    self.glPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    if ( ![self compileShader:&vertShader type:GL_VERTEX_SHADER shaderSource:_vertexSource] )
    {
#if NK_LOG_GL
        NSLog(@"%@",_vertexSource);
#endif
        NSAssert(0,@"Failed to compile VERTEX shader: %@", self.name);
        //NSLog(@"Failed to compile VERTEX shader: %@", self.name);
        return NO;
    }
    
    // Create and compile fragment shader.
    if ( ![self compileShader:&fragShader type:GL_FRAGMENT_SHADER shaderSource:_fragmentSource] )
    {
#if NK_LOG_GL
        NSLog(@"%@",_fragmentSource);
#endif
        NSAssert(0,@"Failed to compile FRAGMENT shader: %@", self.name);
        //NSLog(@"Failed to compile FRAGMENT shader: %@", self.name);
        return NO;
    }
    
    GetGLError();
    
    // Attach vertex shader to program.
    glAttachShader(self.glPointer, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.glPointer, fragShader);
    
    GetGLError();
    
    numAttributes = 0;
    
    //#if TARGET_OS_IPHONE
    for (NKShaderVariable *v in attributes) {
        NSString *attrName = v.nameString;
        glEnableVertexAttribArray(numAttributes);
        glBindAttribLocation(self.glPointer, numAttributes, [attrName UTF8String]);
        numAttributes++;
    }
    //#endif
    
    GetGLError();
    
    // Link program.
    if ( ![self linkProgram:self.glPointer] )
    {
        
        NSLog(@"Failed to link program: %@", self.name);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.glPointer)
        {
            glDeleteProgram(self.glPointer);
            self.glPointer = 0;
        }
        
        return NO;
    }
    
    GetGLError();
    
    for (NKShaderVariable *v in attributes) {
        
        //        switch (v.name) {
        //            case NKS_V2_TEXCOORD:
        //                v.glLocation = NKS_TEX
        //                break;
        //
        //            default:
        //                break;
        //        }
        v.glLocation = glGetAttribLocation(self.glPointer, [v.nameString UTF8String]);
        if (v.glLocation) {
            //glEnableVertexAttribArray(v.glLocation);
        }
        
#if NK_LOG_GL
        NSLog(@"Attribute location %d, string %@",v.glLocation, v.nameString);
#endif
    }
    
    GetGLError();
    
    for (NKShaderVariable *v in uniforms) {
        int uniLoc = glGetUniformLocation(self.glPointer, [v.nameString UTF8String]);
        if (uniLoc > -1)
        {
            v.glLocation = uniLoc;//_uniformLocations[uniName] = @(uniLoc);
            //NSLog(@"Uniform location %d, %@",v.glLocation, v.nameString);
        }
        else
        {
            NSLog(@"WARNING: Couldn't find location for uniform named: %@", v.nameString);
        }
    }
    
    for (NKShaderModule *m in modules){
        if ([m isKindOfClass:[NKShaderModule class]]) {
            
            for (NKShaderVariable *v in m.uniforms) {
                int uniLoc = glGetUniformLocation(self.glPointer, [v.nameString UTF8String]);
                if (uniLoc > -1)
                {
                    v.glLocation = uniLoc;//_uniformLocations[uniName] = @(uniLoc);
                    //NSLog(@"Uniform location %d, %@",v.glLocation, v.nameString);
                }
                else
                {
                    NSLog(@"WARNING: Couldn't find location for uniform named: %@", v.nameString);
                }
            }
        }
    }
    
    GetGLError();
    
    if ([self uniformNamed:NKS_LIGHT]) {
        
        [self uniformNamed:NKS_LIGHT].glLocation = glGetUniformLocation(self.glPointer, "u_light.position");
        
        //        NSArray *members = @[@"isEnabled",@"isLocal",@"isSpot",@"ambient",@"color",@"position",@"halfVector",@"coneDirection",
        //                             @"spotCosCutoff", @"spotExponent",@"constantAttenuation",@"linearAttenuation",@"quadraticAttenuation"];
        //
        //        for (NSString *member in members) {
        //
        //            NSString *name = [@"u_light." stringByAppendingString:member];
        //            int uniLoc = glGetUniformLocation(self.glPointer, [name UTF8String]);
        //            if (uniLoc > -1)
        //            {
        //                // NSLog(@"Uniform location %d, %@",uniLoc, name);
        //            }
        //
        //        }
        
    }
    // Store the locations in an immutable collection
    
    // Release vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(self.glPointer, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader)
    {
        glDetachShader(self.glPointer, fragShader);
        glDeleteShader(fragShader);
    }
    
    GetGLError();
    
    return YES;
    
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    return [self compileShader:shader type:type shaderSource:
            [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type shaderSource:(NSString *)shaderSource {
    
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[shaderSource UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader: %@", self.name);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
    
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(NK_GL_DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - QUERY

-(BOOL)isEqual:(id)object {
    return _glPointer == ((NKShaderProgram*)object).glPointer;
}

-(void)addAttribute:(NKShaderVariable*)attribute {
    [attributes addObject:attribute];
}

-(void)addUniform:(NKShaderVariable*)uniform{
    [uniforms addObject:uniform];
}

-(void)addVarying:(NKShaderVariable*)varying {
    [varyings addObject:varying];
}

-(void)addModule:(NKShaderModule*)module {
    [modules addObject:module];
}

-(NKShaderVariable*)attributeNamed:(NKS_ENUM)name {
    
    for (NKShaderVariable *v in attributes){
        if (v.name == name) return v;
    }
    return nil;
}

-(NKShaderVariable*)uniformNamed:(NKS_ENUM)name {
    for (NKShaderModule *module in modules) {
            for (NKShaderVariable *v in module.uniforms){
                if (v.name == name) return v;
            }
    }
    
    for (NKShaderVariable *v in uniforms){
        if (v.name == name) return v;
    }
    
    return nil;
}

-(NKShaderVariable*)varyingNamed:(NKS_ENUM)name {
    for (NKShaderModule *module in modules) {
            for (NKShaderVariable *v in module.varyings){
                if (v.name == name) return v;
            }
    }
    
    for (NKShaderVariable *v in varyings){
        if (v.name == name) return v;
    }
    
    return nil;
}


-(NKShaderVariable*)vertVarNamed:(NKS_ENUM)name {
    for (NKShaderVariable *v in vertMain){
        if ([v isKindOfClass:[NKShaderVariable class]]) {
            if (v.name == name) return v;
        }
    }
    return nil;
}

-(NKShaderVariable*)fragVarNamed:(NKS_ENUM)name {
    for (NKShaderVariable *v in fragMain){
        if ([v isKindOfClass:[NKShaderVariable class]]) {
            if (v.name == name) return v;
        }
    }
    return nil;
}

- (void)unload
{
    if (self.glPointer)
    {
        NSLog(@"unload shader %d", self.glPointer);
        glDeleteProgram(self.glPointer);
        self.glPointer = 0;
    }
}

-(void)dealloc {
    [self unload];
}

- (void)use
{
    glUseProgram(self.glPointer);
}

#define gl_debug

//- (void)enableAttribute3D:(NSString *)attribName withArray:(const GLvoid*)arrayValues
//{
//    NSNumber *attrVal = self.attributes[attribName];
//    assert(attrVal);
//    GLuint attrLoc = [attrVal intValue];
//    glVertexAttribPointer(attrLoc, 3, GL_FLOAT, GL_FALSE, 0, arrayValues);
//    glEnableVertexAttribArray(attrLoc);
//}
//
//- (void)enableAttribute2D:(NSString *)attribName withArray:(const GLvoid*)arrayValues
//{
//    NSNumber *attrVal = self.attributes[attribName];
//    assert(attrVal);
//    GLuint attrLoc = [attrVal intValue];
//    glVertexAttribPointer(attrLoc, 2, GL_FLOAT, GL_FALSE, 0, arrayValues);
//    glEnableVertexAttribArray(attrLoc);
//}

//- (void)disableAttributeArray:(NSString *)attribName
//{
//    NSNumber *attrVal = self.attributes[attribName];
//    assert(attrVal);
//    GLuint attrLoc = [attrVal intValue];
//    glDisableVertexAttribArray(attrLoc);
//}

@end
