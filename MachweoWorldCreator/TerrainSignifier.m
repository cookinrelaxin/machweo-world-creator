//
//  TerrainSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "TerrainSignifier.h"

@implementation TerrainSignifier{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
}

-(instancetype)initWithTexture:(SKTexture*)terrainTexture inNode:(SKNode*)node{
    if (self = [super init]) {
        _vertices = [NSMutableArray array];
        _lineNode = [SKNode node];
        [node addChild:_lineNode];
        [node addChild:self];
        _terrainTexture = terrainTexture;
        

    }
    return self;
}

-(void)addVertex:(NSPoint)vertex{
    if (_vertices.count > 0) {
        NSPoint firstVertex = [(NSValue*)[_vertices firstObject] pointValue];
        float distance = sqrtf(powf((vertex.x - firstVertex.x), 2) + powf((vertex.y - firstVertex.y), 2));
        if ((distance < 20) && (_vertices.count > 20)) {
            vertex = firstVertex;
            _isClosed = true;
        }
        
        NSPoint lastVertex = [(NSValue*)[_vertices lastObject] pointValue];
        [self addLineNodeBetweenVertices:lastVertex :vertex];
    }
    //NSLog(@"add vertex");
    [_vertices addObject:[NSValue valueWithPoint:vertex]];
    
    
}

-(void)addLineNodeBetweenVertices:(NSPoint)v1 :(NSPoint)v2{
    SKShapeNode* currentLineNode = [SKShapeNode node];
    currentLineNode.zPosition = self.zPosition;
    currentLineNode.antialiased = false;
    currentLineNode.physicsBody = nil;
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    currentLineNode.lineWidth = 1;
    CGPathMoveToPoint(pathToDraw, NULL, v1.x, v1.y);
    CGPathAddLineToPoint(pathToDraw, NULL, v2.x, v2.y);
    currentLineNode.path = pathToDraw;
    [_lineNode addChild:currentLineNode];
    CGPathRelease(pathToDraw);
}

-(void)closeLoopAndFillTerrain{
    SKShapeNode* textureShapeNode = [self shapeNodeWithVertices:_vertices];
    SKTexture* texFromShapeNode = [((SKScene*)_lineNode.parent.parent).view textureFromNode:textureShapeNode];
    SKSpriteNode* maskWrapper = [SKSpriteNode spriteNodeWithTexture:texFromShapeNode];
    _cropNode = [SKCropNode node];
    SKTexture* croppedTexture = [SKTexture textureWithRect:CGRectMake(0, 0, maskWrapper.size.width / _terrainTexture.size.width, maskWrapper.size.height / _terrainTexture.size.height) inTexture:_terrainTexture];

    SKSpriteNode* pattern = [[SKSpriteNode alloc] initWithTexture:croppedTexture];
    pattern.name = @"pattern";

    [_cropNode addChild:pattern];
    
    pattern.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
    maskWrapper.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
    _cropNode.maskNode = maskWrapper;
    
    _cropNode.zPosition = self.zPosition;

    [self addChild:_cropNode];
    _isClosed = false;
}

-(SKShapeNode*)shapeNodeWithVertices:(NSArray*)vertexArray{
    SKShapeNode* node = [SKShapeNode node];
    node.position = CGPointZero;
    node.zPosition = self.zPosition;
    node.fillColor = [NSColor whiteColor];
    node.antialiased = false;
    node.physicsBody = nil;
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    node.lineWidth = 1;
    
    NSPoint firstVertex = [(NSValue*)[vertexArray firstObject] pointValue];
    vertexOffset = CGVectorMake(firstVertex.x, firstVertex.y);
    //CGPathMoveToPoint(pathToDraw, NULL, firstVertex.x, firstVertex.y);
    CGPathMoveToPoint(pathToDraw, NULL, 0, 0);
    for (NSValue* value in vertexArray) {
        NSPoint vertex = [value pointValue];
        if (CGPointEqualToPoint(vertex, firstVertex)) {
            continue;
        }
        //NSLog(@"vertex: %f, %f", vertex.x, vertex.y);
        CGPathAddLineToPoint(pathToDraw, NULL, vertex.x - vertexOffset.dx, vertex.y - vertexOffset.dy);
    }
    node.path = pathToDraw;
    pathBoundingBox = CGPathGetPathBoundingBox(pathToDraw);
    CGPathRelease(pathToDraw);
    return node;
}

-(void)cleanUpAndRemoveLines{
    [_lineNode removeFromParent];
    
}



@end
