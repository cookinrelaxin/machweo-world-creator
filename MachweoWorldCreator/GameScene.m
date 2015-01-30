//
//  GameScene.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "GameScene.h"
#import "ObstacleSignifier.h"
#import "DecorationSignifier.h"
#import "TerrainSignifier.h"
#import "SaveMachine.h"
#import "ChunkLoader.h"

const int SNAP_THRESHOLD = 5;
const int OBSTACLE_Z_POSITION = 100;

@implementation SKView (Right_Mouse)
-(void)rightMouseDown:(NSEvent *)theEvent {
    [self.scene rightMouseDown:theEvent];
}
-(void)rightMouseDragged:(NSEvent *)theEvent {
    [self.scene rightMouseDragged:theEvent];
}
-(void)rightMouseUp:(NSEvent *)theEvent {
    [self.scene rightMouseUp:theEvent];
}

-(void)keyDown:(NSEvent *)theEvent{
    [self.scene keyDown:theEvent];
}
@end

@implementation GameScene{
    NSMutableArray* selectedSpriteArray;
    int currentIndexInSelectedSprites;
    SKSpriteNode* draggedSprite;
    CGVector draggedSpriteOffset;
    CGPoint previousClickLocation;
    SKNode *world;
    SKSpriteNode* leftBorder;
    SKSpriteNode* rightBorder;
    SaveMachine *saveMachine;
    SKShapeNode* outlineNode;
    BOOL allowSnapping;
    
    BOOL allowTerrainDrawing;
    BOOL allowStraightLines;

    TerrainSignifier* currentTerrain;
    SKTexture* terrainTex;
    NSString* textureName;
    
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
}

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        world = [SKNode node];
        [self addChild:world];
        
        CGSize sideBorderSize = CGSizeMake(size.width / 40, size.height);

        leftBorder = [SKSpriteNode spriteNodeWithColor:[NSColor redColor] size:sideBorderSize];
        leftBorder.position = CGPointMake(sideBorderSize.width / 2, sideBorderSize.height / 2);
        leftBorder.hidden = true;
        [self addChild:leftBorder];
        
        rightBorder = [SKSpriteNode spriteNodeWithColor:[NSColor redColor] size:sideBorderSize];
        rightBorder.position = CGPointMake(size.width - sideBorderSize.width / 2, sideBorderSize.height / 2);
        rightBorder.hidden = true;
        [self addChild:rightBorder];
        
        saveMachine = [[SaveMachine alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveSaveMachineDoItsThing) name:@"save level" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLevel:) name:@"load level" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeZpositions:) name:@"zPositionChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMotionTypes:) name:@"motionTypeChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMotionSpeeds:) name:@"motionSpeedChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNode) name:@"delete node" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSnappingPermissions:) name:@"changeSnapPermission" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentTerrainTexture:) name:@"terrain texture selected" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTerrainDrawingPermissions:) name:@"changeDrawPermission" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStraightLinePermissions:) name:@"changeStraightLinePermission" object:nil];

        
        ObstacleSignifier* nodeForWorldScrolling = [ObstacleSignifier node];
        [world addChild:nodeForWorldScrolling];
        
        
        allowSnapping = true;
        allowTerrainDrawing = true;
        allowStraightLines = true;



    }
    return self;

}

-(void)changeCurrentTerrainTexture:(NSNotification*)notification{
    terrainTex = [[notification userInfo] objectForKey:@"texture"];
    textureName = [[notification userInfo] objectForKey:@"texture name"];
}

-(void)changeTerrainDrawingPermissions:(NSNotification*)notification{
    allowTerrainDrawing = [(NSNumber*)[notification.userInfo objectForKey:@"allow terrain drawing"] boolValue];
    //NSLog(@"allowTerrainDrawing: %i", allowTerrainDrawing);
}

-(void)changeStraightLinePermissions:(NSNotification*)notification{
    allowStraightLines = [(NSNumber*)[notification.userInfo objectForKey:@"allow straight lines"] boolValue];
    //NSLog(@"allowTerrainDrawing: %i", allowTerrainDrawing);
}

-(void)changeSnappingPermissions:(NSNotification*)notification{
    allowSnapping = [(NSNumber*)[notification.userInfo objectForKey:@"allow snapping"] boolValue];
}

-(void)haveSaveMachineDoItsThing{
    [saveMachine saveWorld:world];
}

-(void)loadLevel:(NSNotification*)notification{
    NSString *levelName = [notification object];
    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
    for (SKNode* node in world.children) {
        [node removeFromParent];
    }
    [cl loadWorld:world];
    
}

-(void)addObstacleSignifierForImage:(NSImage*)image fromPointInView:(CGPoint)point withName: (NSString*)name{
    ObstacleSignifier* sprite = [ObstacleSignifier spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    sprite.position = [world convertPoint:[self convertPointFromView:point] fromNode:self];
    sprite.zPosition = OBSTACLE_Z_POSITION;
    sprite.name = name;
    [world addChild:sprite];
    draggedSprite = sprite;
    [self addOutlineNode];
    [self sendCurrentlySelectedSpriteNotification];
    currentTerrain = nil;
    
}

-(void)addDecorationSignifierForImage:(NSImage*)image fromPointInView:(CGPoint)point withName: (NSString*)name{
    DecorationSignifier* sprite = [DecorationSignifier spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    sprite.position = [world convertPoint:[self convertPointFromView:point] fromNode:self];
    
    SKSpriteNode* brother = (SKSpriteNode*)[world childNodeWithName:name];
    if (brother) {
         sprite.zPosition = [world childNodeWithName:name].zPosition;
    }
    else{
        sprite.zPosition = 1;
    }
    sprite.name = name;
    [world addChild:sprite];
    draggedSprite = sprite;
    [self addOutlineNode];
    [self sendCurrentlySelectedSpriteNotification];
    currentTerrain = nil;

}

-(void)mouseDown:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGPoint locInWorld = [theEvent locationInNode:world];
   // BOOL clearSelection;x`
    if (terrainTex) {
        if (currentTerrain || allowTerrainDrawing) {
            if (allowTerrainDrawing && (!currentTerrain || !currentTerrain.permitVertices)) {
                draggedSprite = nil;
                currentTerrain = [[TerrainSignifier alloc] initWithTexture:terrainTex inNode:world];
                currentTerrain.zPosition = OBSTACLE_Z_POSITION;
                [currentTerrain addVertex:locInWorld :allowStraightLines];
            }
            currentTerrain.anchorPointForStraightLines = locInWorld;
        }
    }
    
    selectedSpriteArray = [self generateSelectedSpritesAtPoint:locInWorld];
    if (!allowTerrainDrawing) {
        if (selectedSpriteArray.count > 0) {
            if (![selectedSpriteArray containsObject:draggedSprite] && ![selectedSpriteArray containsObject:currentTerrain]) {
           // NSLog(@"sprite array count: %lu", (unsigned long)selectedSpriteArray.count);
          //  NSLog(@"currentIndexInSelectedSprites: %d", currentIndexInSelectedSprites);

            
                SKNode* selectedNode = [selectedSpriteArray objectAtIndex:currentIndexInSelectedSprites];
                 if ([selectedNode isKindOfClass:[SKSpriteNode class]]) {
                    if (draggedSprite != selectedNode) {
                        currentTerrain = nil;
                        draggedSprite = (SKSpriteNode*)selectedNode;
                        [self sendCurrentlySelectedSpriteNotification];
                        [self addOutlineNode];
                    }
                 }
                if ([selectedNode isKindOfClass:[TerrainSignifier class]]) {
                    if (currentTerrain != selectedNode) {
                        draggedSprite = nil;
                        currentTerrain = (TerrainSignifier*)selectedNode;
                        [self sendCurrentlySelectedSpriteNotification];
                        [self addOutlineNode];
                    }
                }
            }
        }
    }
//    else if(!allowTerrainDrawing){
//        draggedSprite = nil;
//        currentTerrain = nil;
//        [outlineNode removeFromParent];
//    }
    if (currentTerrain) {
        draggedSpriteOffset = CGVectorMake((currentTerrain.frame.origin.x + (currentTerrain.frame.size.width / 2)) - locInWorld.x, (currentTerrain.frame.origin.y + (currentTerrain.frame.size.height / 2) - locInWorld.y));
    }
    if (draggedSprite) {
        draggedSpriteOffset = CGVectorMake((draggedSprite.frame.origin.x + (draggedSprite.frame.size.width / 2)) - locInWorld.x, (draggedSprite.frame.origin.y + (draggedSprite.frame.size.height / 2) - locInWorld.y));
    }
    
    previousClickLocation = locInSelf;
}

-(NSMutableArray*)generateSelectedSpritesAtPoint:(CGPoint)point{
    NSArray* nodeArray = [world nodesAtPoint:point];
    selectedSpriteArray = [NSMutableArray arrayWithArray:nodeArray];
    NSMutableArray* nodesToRemove = [NSMutableArray array];
    for (SKNode* node in selectedSpriteArray) {
        if (!([node isKindOfClass:[ObstacleSignifier class]] || [node isKindOfClass:[DecorationSignifier class]] || [node isKindOfClass:[TerrainSignifier class]])) {
            [nodesToRemove addObject:node];
            continue;
        }
    }
    for (SKNode* node in nodesToRemove) {
        [selectedSpriteArray removeObject:node];
    }
    
    if (currentIndexInSelectedSprites >= selectedSpriteArray.count) {
        currentIndexInSelectedSprites = 0;
    }

    return selectedSpriteArray;
}

-(void)mouseUp:(NSEvent *)theEvent{
    if (currentTerrain) {
        [currentTerrain completeLine];
        [currentTerrain checkForClosedShape];
        if (currentTerrain.isClosed) {
            [self addOutlineNode];
            [currentTerrain closeLoopAndFillTerrain];
            [currentTerrain cleanUpAndRemoveLines];
        }
    }
}

-(void)changeCurrentlySelectedSprite{
    if (selectedSpriteArray.count > 0) {
        currentIndexInSelectedSprites ++;
        if (currentIndexInSelectedSprites >= selectedSpriteArray.count) {
            currentIndexInSelectedSprites = 0;
        }
        SKNode* selectedNode =[selectedSpriteArray objectAtIndex:currentIndexInSelectedSprites];
        if ([selectedNode isKindOfClass:[DecorationSignifier class]] || [selectedNode isKindOfClass:[ObstacleSignifier class]]) {
            draggedSprite = (SKSpriteNode*)selectedNode;
        }
        else if ([selectedNode isKindOfClass:[TerrainSignifier class]]){
            currentTerrain = (TerrainSignifier*)selectedNode;
        }
        [self sendCurrentlySelectedSpriteNotification];
        [self addOutlineNode];
    }
    else{
        currentIndexInSelectedSprites = 0;
    }
    
}

-(void)rightMouseDown:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    previousClickLocation = locInSelf;
}

-(void)rightMouseDragged:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGVector dragDiff = CGVectorMake(previousClickLocation.x - locInSelf.x, previousClickLocation.y - locInSelf.y);
    [self scrollWorld:dragDiff];
    previousClickLocation = locInSelf;
    
}

-(void)keyDown:(NSEvent *)theEvent{

    // 127 is the unicode delete char
    if ([[theEvent characters] characterAtIndex:0] == 127) {
        [self deleteNode];
    }
    // 9 is the unicode tab char
    if ([[theEvent characters] characterAtIndex:0] == 9) {
        [self changeCurrentlySelectedSprite];
        //[self deleteNode];
    }
}


-(void)addOutlineNode{
    
    if (outlineNode) {
        [outlineNode removeFromParent];
    }
    
    CGMutablePathRef path = NULL;
    SKNode* node;
    float thickness = 1;
    if (currentTerrain) {
        node = currentTerrain.cropNode;
        path = CGPathCreateMutable();
        NSPoint firstVertex = [(NSValue*)[currentTerrain.vertices firstObject] pointValue];
        firstVertex = [self convertPoint:firstVertex fromNode:world];
        CGPathMoveToPoint(path, NULL, firstVertex.x, firstVertex.y);
        for (NSValue* value in currentTerrain.vertices) {
            NSPoint vertex = [value pointValue];
            vertex = [self convertPoint:vertex fromNode:world];
            CGPathAddLineToPoint(path, NULL, vertex.x, vertex.y);
        }
        thickness = 5.0f;
        
    }
    else if(draggedSprite){
        node = draggedSprite;
        CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
        path = (CGMutablePathRef)CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
        thickness = 2.0f;
    }
    if ((draggedSprite || currentTerrain) && path) {
        outlineNode = [SKShapeNode node];
        outlineNode.zPosition = node.zPosition + 1;
       // NSLog(@"outlineNode.zPosition: %f", outlineNode.zPosition);
        //NSLog(@"node: %f", node.zPosition);

        outlineNode.path = path;
        outlineNode.lineWidth = thickness;
        CGPathRelease(path);
        outlineNode.strokeColor = [NSColor blackColor];
        [self addChild:outlineNode];
    }
    
}

-(void)mouseDragged:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGPoint locInWorld = [theEvent locationInNode:world];
    if (draggedSprite) {
          [self dragSprite:locInWorld];
    }
    
    if (currentTerrain) {
        if (allowTerrainDrawing) {
            [currentTerrain addVertex:locInWorld :allowStraightLines];
        }
        else{
            [self dragSprite:locInWorld];
        }
    }
    
    previousClickLocation = locInSelf;
}

-(void)dragSprite:(CGPoint)loc{
    if (currentTerrain) {
        [currentTerrain moveTo:loc :outlineNode :draggedSpriteOffset];
//        CGPoint correctedPos = CGPointMake(loc.x + draggedSpriteOffset.dx, loc.y + draggedSpriteOffset.dy);
//        CGVector difference = CGVectorMake(correctedPos.x - currentTerrain.cropNode.position.x, correctedPos.y - currentTerrain.cropNode.position.y);
//        NSMutableArray* newVertices = [NSMutableArray array];
//        CGMutablePathRef path = CGPathCreateMutable();
//        NSPoint firstVertex = [(NSValue*)[currentTerrain.vertices firstObject] pointValue];
//        firstVertex = [self convertPoint:firstVertex fromNode:world];
//        firstVertex = CGPointMake(firstVertex.x + difference.dx, firstVertex.y + difference.dy);
//        [newVertices addObject:[NSValue valueWithPoint:firstVertex]];
//        
//        CGPathMoveToPoint(path, NULL, firstVertex.x, firstVertex.y);
//        for (NSValue* value in currentTerrain.vertices) {
//            NSPoint vertex = [value pointValue];
//            vertex = [self convertPoint:vertex fromNode:world];
//            vertex = CGPointMake(vertex.x + difference.dx, vertex.y + difference.dy);
//            [newVertices addObject:[NSValue valueWithPoint:vertex]];
//            CGPathAddLineToPoint(path, NULL, vertex.x, vertex.y);
//        }
//        outlineNode.path = path;
//        CGPathRelease(path);
//        
//        currentTerrain.vertices = newVertices;
//        currentTerrain.cropNode.position = correctedPos;
        return;
    }
    else if (draggedSprite){
        CGPoint correctedPos = CGPointMake(loc.x + draggedSpriteOffset.dx, loc.y + draggedSpriteOffset.dy);
        draggedSprite.position = correctedPos;

        float minX  = CGRectGetMinX(draggedSprite.frame);
        float maxY  = CGRectGetMaxY(draggedSprite.frame);
        float minY  = CGRectGetMinY(draggedSprite.frame);
        if (minX <= 0) {
            draggedSprite.position = CGPointMake(0 + draggedSprite.frame.size.width / 2, draggedSprite.position.y);
        }
        if (minY <= 0 - (draggedSprite.size.height * 3/4)) {
            draggedSprite.position = CGPointMake(draggedSprite.position.x, (draggedSprite.size.height / 2) - (draggedSprite.size.height * 3/4));
        }
        if (maxY >= self.size.height + (draggedSprite.size.height * 3/4)) {
            draggedSprite.position = CGPointMake(draggedSprite.position.x, self.size.height - (draggedSprite.size.height / 2) + (draggedSprite.size.height * 3/4));
        }
        
        if (allowSnapping) {
            [self snapSpriteToNeighborsCenters:draggedSprite];
            [self snapSpriteToNeighborsEdges:draggedSprite];
        }
    }

   
}

-(void)snapSpriteToNeighborsEdges:(SKSpriteNode*)sprite{
    float spriteHalfWidth = sprite.size.width / 2;
    float spriteHalfHeight = sprite.size.height / 2;
    
    float spriteLeftX = sprite.position.x - spriteHalfWidth;
    float spriteRightX = sprite.position.x + spriteHalfWidth;
    float spriteBottomY = sprite.position.y - spriteHalfHeight;
    float spriteTopY = sprite.position.y + spriteHalfHeight;

    for (SKSpriteNode* otherSprite in world.children) {
        if ((sprite == otherSprite) || ![otherSprite isKindOfClass:[SKSpriteNode class]]) {
            continue;
        }
        
        float spriteGreaterDimension = (sprite.size.width > sprite.size.height) ? sprite.size.width : sprite.size.height;
        float otherSpriteGreaterDimension = (otherSprite.size.width > otherSprite.size.height) ? otherSprite.size.width : otherSprite.size.height;
        float distance = sqrtf(powf((sprite.position.x - otherSprite.position.x), 2) + powf((sprite.position.y - otherSprite.position.y), 2));
        
        if (distance < (spriteGreaterDimension + otherSpriteGreaterDimension)) {
            float otherSpriteHalfWidth = otherSprite.size.width / 2;
            float otherSpriteHalfHeight = otherSprite.size.height / 2;
            
            float otherSpriteLeftX = otherSprite.position.x - otherSpriteHalfWidth;
            float otherSpriteRightX = otherSprite.position.x + otherSpriteHalfWidth;
            float otherSpriteBottomY = otherSprite.position.y - otherSpriteHalfHeight;
            float otherSpriteTopY = otherSprite.position.y + otherSpriteHalfHeight;
            
            {
                float differenceFromSpriteLeftX = fabsf(spriteLeftX - otherSpriteRightX);
                if (differenceFromSpriteLeftX < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(otherSpriteRightX + spriteHalfWidth, sprite.position.y);
                }
            }
            
            {
                float differenceFromSpriteRightX = fabsf(spriteRightX - otherSpriteLeftX);
                if (differenceFromSpriteRightX < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(otherSpriteLeftX - spriteHalfWidth, sprite.position.y);
                }
            }
            
            {
                float differenceFromSpriteTopYAndOtherSpriteBottomY = fabsf(spriteTopY - otherSpriteBottomY);
                if (differenceFromSpriteTopYAndOtherSpriteBottomY < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(sprite.position.x, otherSpriteBottomY - spriteHalfHeight);
                }
            }
            
            {
                float differenceFromSpriteBottomYOtherSpriteTopY = fabsf(spriteBottomY - otherSpriteTopY);
                if (differenceFromSpriteBottomYOtherSpriteTopY < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(sprite.position.x, otherSpriteTopY + spriteHalfHeight);
                }
            }
            
            {
                float differenceFromSpriteTopYAndOtherSpriteTopY = fabsf(spriteTopY - otherSpriteTopY);
                if (differenceFromSpriteTopYAndOtherSpriteTopY < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(sprite.position.x, otherSpriteTopY - spriteHalfHeight);
                }
            }
        }
        
    }
}

-(void)snapSpriteToNeighborsCenters:(SKSpriteNode*)sprite{
    for (SKSpriteNode* otherSprite in world.children) {
        if (sprite == otherSprite || ![otherSprite isKindOfClass:[SKSpriteNode class]]) {
            continue;
        }
        float spriteGreaterDimension = (sprite.size.width > sprite.size.height) ? sprite.size.width : sprite.size.height;
        float otherSpriteGreaterDimension = (otherSprite.size.width > otherSprite.size.height) ? otherSprite.size.width : otherSprite.size.height;
        float distance = sqrtf(powf((sprite.position.x - otherSprite.position.x), 2) + powf((sprite.position.y - otherSprite.position.y), 2));
        
        if (distance < (spriteGreaterDimension + otherSpriteGreaterDimension)) {
            {
                float differenceInYPositions = fabsf(otherSprite.position.y - sprite.position.y);
                if (differenceInYPositions < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(sprite.position.x, otherSprite.position.y);
                }
            }
            {
                float differenceInXPositions = fabsf(otherSprite.position.x - sprite.position.x);
                if (differenceInXPositions < SNAP_THRESHOLD) {
                    sprite.position = CGPointMake(otherSprite.position.x, sprite.position.y);
                }
            }
        }
    }
}

-(void)scrollWorld:(CGVector)dragDiff{
   // NSLog(@"world.position: %f, %f", world.position.x, world.position.y);
   // CGPoint previousPosition = world.position;
    //world.position = CGPointMake(world.position.x - dragDiff.dx, world.position.y);
    SKSpriteNode* leftMostNode = nil;

    for (SKNode* node in world.children) {
        if ([node isKindOfClass:[TerrainSignifier class]] || [node.parent isKindOfClass:[TerrainSignifier class]]) {
            continue;
        }
        if (leftMostNode == nil) {
            leftMostNode = (SKSpriteNode*)node;
        }

        float leftEdgeOfLeftMost = leftMostNode.position.x - (leftMostNode.size.width / 2);
        float leftEdgeOfNode = node.position.x - (((SKSpriteNode*)node).size.width / 2);

        if (leftEdgeOfNode < leftEdgeOfLeftMost) {
            leftMostNode = (SKSpriteNode*)node;
        }
        
    }
    
    if (([leftMostNode isKindOfClass:[ObstacleSignifier class]])) {
        CGPoint leftMostNodeDesiredPos = CGPointMake(leftMostNode.position.x - dragDiff.dx, leftMostNode.position.y);
        CGPoint posInScene = [self convertPoint:leftMostNodeDesiredPos fromNode:world];
        if ((posInScene.x - leftMostNode.size.width / 2) > 0) {
            return;
        }

    }
    if (([leftMostNode isKindOfClass:[DecorationSignifier class]])) {
        float fractionalCoefficient = leftMostNode.zPosition / 100;
        //.1f is the default y parallax coefficient
        CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * dragDiff.dx, fractionalCoefficient * dragDiff.dy * .1f);
        CGPoint leftMostNodeDesiredPos = CGPointMake(leftMostNode.position.x - parallaxAdjustedDifference.dx, leftMostNode.position.y);
        CGPoint posInScene = [self convertPoint:leftMostNodeDesiredPos fromNode:world];
        if ((posInScene.x - leftMostNode.size.width / 2) > 0) {
            return;
        }
        
    }
    
    for (SKNode* node in world.children) {
        if ([node.parent isKindOfClass:[TerrainSignifier class]]) {
            continue;
        }
        if ([node isKindOfClass:[ObstacleSignifier class]] || [node isKindOfClass:[TerrainSignifier class]]) {
            [(TerrainSignifier*)node moveTo:CGPointMake(node.position.x - dragDiff.dx, node.position.y) :outlineNode :CGVectorMake(0, 0)];
           // draggedSpriteOffset = CGVectorMake(0, 0);
          //  [self dragSprite:CGPointMake(node.position.x - dragDiff.dx, node.position.y)];
//            if (currentTerrain) {
//                CGPathRef newPath = [currentTerrain vertexPath];
//                outlineNode.path = newPath;
//                CGPathRelease(newPath);
//                
//                //[self addOutlineNode];
//            }
            
           // node.position = CGPointMake(node.position.x - dragDiff.dx, node.position.y);
        }
        if ([node isKindOfClass:[DecorationSignifier class]]) {
            //sprite.position = CGPointMake(sprite.position.x - dragDiff.dx, sprite.position.y - dragDiff.dy);
            //10 is the default obstacle z pos
            float fractionalCoefficient = node.zPosition / 100;
            //.1f is the default y parallax coefficient
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * dragDiff.dx, fractionalCoefficient * dragDiff.dy * .1f);
            node.position = CGPointMake(node.position.x - parallaxAdjustedDifference.dx, node.position.y);
            
        }
        
    }
}

-(void)sendCurrentlySelectedSpriteNotification{
    if (currentTerrain) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:textureName, @"texture name", currentTerrain, @"terrain", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentlySelectedTerrainMayHaveChanged" object:nil userInfo:dict];
        return;
    }
    if (draggedSprite) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:draggedSprite, @"sprite", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentlySelectedSpriteMayHaveChanged" object:nil userInfo:dict];
    }
}

-(void)changeZpositions:(NSNotification*)notification{
   // NSLog(@"%@", notification.name);
    NSString* nameOfSpritesToChange = [notification.userInfo objectForKey:@"imageName"];
    int zPosition = [[notification.userInfo objectForKey:@"zPosition"] intValue];
  //  NSLog(@"change zposition of sprites named %@ to %d", nameOfSpritesToChange, zPosition);
    
    [world enumerateChildNodesWithName:nameOfSpritesToChange usingBlock: ^(SKNode *node, BOOL *stop){
        SKSpriteNode *sprite = (SKSpriteNode *)node;
        sprite.zPosition = zPosition;
    }];

}

-(void)changeMotionTypes:(NSNotification*)notification{
   __block Motion motionType;
    NSString* motionString = [notification.userInfo objectForKey:@"obstacleMotion"];
    NSLog(@"motionString: %@", motionString);
    if ([motionString isEqualToString:@"doesn't move"]) {
        motionType = motionTypeNone;
    }
    if ([motionString isEqualToString:@"moves up and down"]) {
        motionType = motionTypeUpAndDown;
    }
    if ([motionString isEqualToString:@"moves left and right"]) {
        motionType = motionTypeLeftAndRight;
    }
    if ([motionString isEqualToString:@"rotates clockwise"]) {
        motionType = motionTypeRotatesClockwise;
    }
    if ([motionString isEqualToString:@"rotates counterclockwise"]) {
        motionType = motionTypeRotatesCounterclockwise;
    }
    if ([draggedSprite isKindOfClass:[ObstacleSignifier class]]) {
        ObstacleSignifier *sprite = (ObstacleSignifier *)draggedSprite;
        sprite.currentMotionType = motionType;
    }
    
}

-(void)changeMotionSpeeds:(NSNotification*)notification{
   __block Speed speedType;
    NSString* speedString = [notification.userInfo objectForKey:@"motionSpeed"];
    NSLog(@"speedString: %@", speedString);
    if ([speedString isEqualToString:@"slowest"]) {
        speedType = speedTypeSlowest;
    }
    if ([speedString isEqualToString:@"slower"]) {
        speedType = speedTypeSlower;
    }
    if ([speedString isEqualToString:@"slow"]) {
        speedType = speedTypeSlow;
    }
    if ([speedString isEqualToString:@"fast"]) {
        speedType = speedTypeFast;
    }
    if ([speedString isEqualToString:@"faster"]) {
        speedType = speedTypeFaster;
    }
    if ([speedString isEqualToString:@"fastest"]) {
        speedType = speedTypeFastest;
    }
    
    if ([draggedSprite isKindOfClass:[ObstacleSignifier class]]) {
        ObstacleSignifier *sprite = (ObstacleSignifier *)draggedSprite;
        sprite.currentSpeedType = speedType;
    }
    
}

-(void)deleteNode{
    if (currentTerrain) {
        [currentTerrain cleanUpAndRemoveLines];
        [currentTerrain removeFromParent];
        currentTerrain = nil;
    }
    if (draggedSprite) {
        [draggedSprite removeFromParent];
        draggedSprite = nil;
    }
    if (outlineNode) {
        [outlineNode removeFromParent];
        outlineNode = nil;
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    for (SKSpriteNode* sprite in world.children) {
        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            [(ObstacleSignifier*)sprite move];
        }
    }
    if ([draggedSprite isKindOfClass:[ObstacleSignifier class]]) {
        ObstacleSignifier* obs = (ObstacleSignifier*)draggedSprite;
        if ((obs.currentMotionType == motionTypeRotatesClockwise) || (obs.currentMotionType == motionTypeRotatesCounterclockwise)) {
            [outlineNode removeFromParent];
        }
    }

    if (currentTerrain == nil) {
        CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
        CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
        outlineNode.path = path;
        CGPathRelease(path);
    }

}

@end
