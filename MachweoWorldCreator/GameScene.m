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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMotionTypes:) name:@"motionTypeChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMotionSpeeds:) name:@"motionSpeedChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNode) name:@"delete node" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSnappingPermissions:) name:@"changeSnapPermission" object:nil];
        
        ObstacleSignifier* nodeForWorldScrolling = [ObstacleSignifier node];
        [world addChild:nodeForWorldScrolling];
        
        
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
    [self sendCurrentlySelectedSpriteNotification];

    
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
    [self sendCurrentlySelectedSpriteNotification];

}

-(void)mouseDown:(NSEvent *)theEvent{
    CGPoint locInSelf = [theEvent locationInNode:self];
    CGPoint locInWorld = [theEvent locationInNode:world];
    SKNode* selectedNode = [world nodeAtPoint:locInWorld];
    
    if ([selectedNode isKindOfClass:[SKSpriteNode class]]) {
        if (draggedSprite != selectedNode) {
            draggedSprite = (SKSpriteNode*)selectedNode;
            [self sendCurrentlySelectedSpriteNotification];
            [self addOutlineNodeAroundSprite:draggedSprite];
        }
        draggedSpriteOffset = CGVectorMake((draggedSprite.frame.origin.x + (draggedSprite.frame.size.width / 2)) - locInWorld.x, (draggedSprite.frame.origin.y + (draggedSprite.frame.size.height / 2) - locInWorld.y));
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
    
//    CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
//    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
//    outlineNode.path = path;
//    CGPathRelease(path);
    
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

//    CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
//    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
//    outlineNode.path = path;
//    CGPathRelease(path);
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
   // CGPoint previousPosition = world.position;
    //world.position = CGPointMake(world.position.x - dragDiff.dx, world.position.y);
    SKSpriteNode* leftMostNode = nil;

    for (SKSpriteNode* node in world.children) {
        if (leftMostNode == nil) {
            leftMostNode = node;
        }

        float leftEdgeOfLeftMost = leftMostNode.position.x - (leftMostNode.size.width / 2);
        float leftEdgeOfNode = node.position.x - (node.size.width / 2);

        if (leftEdgeOfNode < leftEdgeOfLeftMost) {
            leftMostNode = node;
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
       // CGPoint leftMostNodeDesiredPos = CGPointMake(leftMostNode.position.x - dragDiff, <#CGFloat y#>)
        float fractionalCoefficient = leftMostNode.zPosition / 10;
        //.1f is the default y parallax coefficient
        CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * dragDiff.dx, fractionalCoefficient * dragDiff.dy * .1f);
        CGPoint leftMostNodeDesiredPos = CGPointMake(leftMostNode.position.x - parallaxAdjustedDifference.dx, leftMostNode.position.y);
        CGPoint posInScene = [self convertPoint:leftMostNodeDesiredPos fromNode:world];
        if ((posInScene.x - leftMostNode.size.width / 2) > 0) {
            return;
        }
        
    }
    
    for (SKSpriteNode* sprite in world.children) {
        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            sprite.position = CGPointMake(sprite.position.x - dragDiff.dx, sprite.position.y);
        }
        if ([sprite isKindOfClass:[DecorationSignifier class]]) {
            //sprite.position = CGPointMake(sprite.position.x - dragDiff.dx, sprite.position.y - dragDiff.dy);
            //10 is the default obstacle z pos
            float fractionalCoefficient = sprite.zPosition / 10;
            //.1f is the default y parallax coefficient
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * dragDiff.dx, fractionalCoefficient * dragDiff.dy * .1f);
            sprite.position = CGPointMake(sprite.position.x - parallaxAdjustedDifference.dx, sprite.position.y);
            
        }
        
    }
}

-(void)sendCurrentlySelectedSpriteNotification{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:draggedSprite, @"sprite", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentlySelectedSpriteMayHaveChanged" object:nil userInfo:dict];
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
    [draggedSprite removeFromParent];
    [outlineNode removeFromParent];
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
    CGPoint convertedOrigin = [self convertPoint:CGPointMake(draggedSprite.frame.origin.x, draggedSprite.frame.origin.y) fromNode:world];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(convertedOrigin.x, convertedOrigin.y, draggedSprite.size.width, draggedSprite.size.height), NULL);
    outlineNode.path = path;
    CGPathRelease(path);

}

@end
