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
#import "SaveMachine.h"
#import "ChunkLoader.h"

const int SNAP_THRESHOLD = 5;

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
@end

@implementation GameScene{
    SKSpriteNode* draggedSprite;
    CGVector draggedSpriteOffset;
    CGPoint previousClickLocation;
    SKNode *world;
    SKSpriteNode* leftBorder;
    SKSpriteNode* rightBorder;
    SaveMachine *saveMachine;
    SKShapeNode* outlineNode;
    
    BOOL allowSnapping;
    
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
}

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        world = [SKNode node];
        [self addChild:world];
        
        CGSize sideBorderSize = CGSizeMake(size.width / 40, size.height);
        //CGSize topAndBottomBorderSize = CGSizeMake(size.width, size.height / 30);

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNode) name:@"delete node" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSnappingPermissions:) name:@"changeSnapPermission" object:nil];
        
        allowSnapping = true;



    }
    return self;

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
    sprite.zPosition = 10;
    sprite.name = name;
    [world addChild:sprite];
    draggedSprite = sprite;
    [self addOutlineNodeAroundSprite:draggedSprite];
    [self sendCurrentlySelectedImageNotification:name andCurrentZposition:sprite.zPosition];

    
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
    [self addOutlineNodeAroundSprite:draggedSprite];
    [self sendCurrentlySelectedImageNotification:name andCurrentZposition:sprite.zPosition];

}

-(void)mouseDown:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGPoint locInWorld = [theEvent locationInNode:world];
    SKNode* selectedNode = [world nodeAtPoint:locInWorld];
    
    if ([selectedNode isKindOfClass:[SKSpriteNode class]]) {
        draggedSprite = (SKSpriteNode*)selectedNode;
        [self sendCurrentlySelectedImageNotification:draggedSprite.name andCurrentZposition:draggedSprite.zPosition];
        draggedSpriteOffset = CGVectorMake((draggedSprite.frame.origin.x + (draggedSprite.frame.size.width / 2)) - locInWorld.x, (draggedSprite.frame.origin.y + (draggedSprite.frame.size.height / 2) - locInWorld.y));
        [self addOutlineNodeAroundSprite:draggedSprite];
        
    }
    else {
        draggedSprite = nil;
        [outlineNode removeFromParent];
    }

    previousClickLocation = locInSelf;
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
    
    CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
    outlineNode.path = path;
    CGPathRelease(path);
    
}


-(void)addOutlineNodeAroundSprite:(SKSpriteNode*)sprite{
    CGPoint convertedOrigin = [self convertPoint:CGPointMake(sprite.frame.origin.x, sprite.frame.origin.y) fromNode:world];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, sprite.size.width, sprite.size.height), NULL);
    if (outlineNode) {
        [outlineNode removeFromParent];
    }
    outlineNode = [SKShapeNode node];
    outlineNode.zPosition = sprite.zPosition + 1;
    outlineNode.path = path;
    outlineNode.lineWidth = 2.0f;
    CGPathRelease(path);
    outlineNode.strokeColor = [NSColor blackColor];
    [self addChild:outlineNode];
}

-(void)mouseDragged:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGPoint locInWorld = [theEvent locationInNode:world];
    if (draggedSprite) {
        [self dragSprite:locInWorld];
    }
    previousClickLocation = locInSelf;

    CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
    outlineNode.path = path;
    CGPathRelease(path);
    
}

-(void)dragSprite:(CGPoint)locInWorld{
    CGPoint correctedPos = CGPointMake(locInWorld.x + draggedSpriteOffset.dx, locInWorld.y + draggedSpriteOffset.dy);
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

-(void)snapSpriteToNeighborsEdges:(SKSpriteNode*)sprite{
    float spriteHalfWidth = sprite.size.width / 2;
    float spriteHalfHeight = sprite.size.height / 2;
    
    float spriteLeftX = sprite.position.x - spriteHalfWidth;
    float spriteRightX = sprite.position.x + spriteHalfWidth;
    float spriteBottomY = sprite.position.y - spriteHalfHeight;
    float spriteTopY = sprite.position.y + spriteHalfHeight;

    for (SKSpriteNode* otherSprite in world.children) {
        if (sprite == otherSprite) {
            continue;
        }
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

-(void)snapSpriteToNeighborsCenters:(SKSpriteNode*)sprite{
    //baller, baller, baller.
    for (SKSpriteNode* otherSprite in world.children) {
        if (sprite == otherSprite) {
            continue;
        }
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

-(void)scrollWorld:(CGVector)dragDiff{
   // NSLog(@"world.position: %f, %f", world.position.x, world.position.y);
    CGPoint previousPosition = world.position;
    world.position = CGPointMake(world.position.x - dragDiff.dx, world.position.y);
    if (world.position.x > 0) {
       // NSLog(@"world.position.x > 0");
        world.position = CGPointMake(0, world.position.y);
        leftBorder.hidden = false;
    }
    else{
        leftBorder.hidden = true;
    }
    CGRect worldFrame = [world calculateAccumulatedFrame];
    float maxX = CGRectGetMaxX(worldFrame);
    //NSLog(@"maxX: %f", maxX);
    if (maxX <= 0) {
        //NSLog(@"maxX <= 0");
        world.position = previousPosition;
        rightBorder.hidden = false;
    }
    else{
        rightBorder.hidden = true;
    }
}

-(void)sendCurrentlySelectedImageNotification:(NSString*)imageName andCurrentZposition:(int)zPosition{
    //NSLog(@"zPosition: %i", zPosition);
//    if(!imageName || !zPosition){
//       //  NSLog(@"imageName: %@", imageName);
        NSLog(@"zPosition: %i", zPosition);
//
//       // NSLog(@"something is wrong");
//    }
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:imageName, @"imageName", [NSNumber numberWithInt:zPosition], @"zPosition", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentlySelectedImageChanged" object:nil userInfo:dict];
}

-(void)changeZpositions:(NSNotification*)notification{
   // NSLog(@"%@", notification.name);
    NSString* nameOfSpritesToChange = [notification.userInfo objectForKey:@"imageName"];
    int zPosition = [[notification.userInfo objectForKey:@"zPosition"] intValue];
   // NSLog(@"change zposition of sprites named %@ to %d", nameOfSpritesToChange, zPosition);
    
    [world enumerateChildNodesWithName:nameOfSpritesToChange usingBlock: ^(SKNode *node, BOOL *stop){
        SKSpriteNode *sprite = (SKSpriteNode *)node;
        sprite.zPosition = zPosition;
    }];

}

-(void)deleteNode{
    [draggedSprite removeFromParent];
    [outlineNode removeFromParent];
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
