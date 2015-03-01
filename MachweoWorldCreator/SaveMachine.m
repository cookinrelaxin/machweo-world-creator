//
//  SaveMachine.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "SaveMachine.h"

#import "ObstacleSignifier.h"
#import "DecorationSignifier.h"

@implementation SaveMachine

-(void)saveWorld:(SKNode *)world withTerrainPool:(NSMutableArray*)terrainPool{
    NSLog(@"saveScene");
    
    //SKSpriteNode* rightMostNode = nil;
    SKSpriteNode* leftMostNode = nil;
    
    float minZposition = FLT_MAX;
    for (SKSpriteNode* node in world.children) {
        if (node.zPosition < minZposition) {
            minZposition = node.zPosition;
        }
    }

    
    for (SKSpriteNode* node in world.children) {
//        if ([node.name isEqualToString:@"nodeForWorldScrolling"]) {
//            NSLog(@"[sprite.name isEqualToString:nodeForWorldScrolling]");
//            continue;
//        }
        //if ((int)node.zPosition == 1) {
            
            if (leftMostNode == nil) {
                leftMostNode = node;
            }
//            if (rightMostNode == nil) {
//                rightMostNode = node;
//            }
            {
                float leftEdgeOfLeftMost = leftMostNode.position.x - (leftMostNode.size.width / 2);
                float leftEdgeOfNode = node.position.x - (node.size.width / 2);
                
                if (leftEdgeOfNode < leftEdgeOfLeftMost) {
                    if (node.zPosition == minZposition) {
                    leftMostNode = node;
                    }
                }
            }
//            {
//                float rightEdgeOfRightMost = rightMostNode.position.x + (rightMostNode.size.width / 2);
//                float rightEdgeOfNode = node.position.x + (node.size.width / 2);
//                
//                if (rightEdgeOfNode > rightEdgeOfRightMost) {
//                    rightMostNode = node;
//                }
//            }
            
        //}
    }
    NSLog(@"[leftMostNode class]: %@", [leftMostNode class]);
    float xDifference = leftMostNode.position.x - (leftMostNode.size.width / 2);
    NSLog(@"xDifference: %f", xDifference);
    
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"worldnodes"];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    NSArray* sortedSprites = [world.children sortedArrayUsingComparator: ^NSComparisonResult(SKSpriteNode *sprite1, SKSpriteNode *sprite2) {
        return (sprite1.position.x > sprite2.position.x);
    }];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    //NSArray* sortedSprites = [world.children sortedArrayUsingDescriptors:@[sortDescriptor]];


    
    
    for (SKSpriteNode* sprite in sortedSprites) {
//        if ([sprite.name isEqualToString:@"nodeForWorldScrolling"]) {
//            NSLog(@"[sprite.name isEqualToString:nodeForWorldScrolling]");
//            continue;
//        }
       // NSLog(@"sprite.zPosition: %f", sprite.zPosition);
        
        NSXMLElement *spriteNode = [NSXMLElement elementWithName:@"node"];
        [root addChild:spriteNode];
        NSString* typeString = @"placeholder";
        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            typeString = @"ObstacleSignifier";
        }
        else if ([sprite isKindOfClass:[DecorationSignifier class]]) {
            typeString = @"DecorationSignifier";
            //NSLog(@"(DecorationSignifier*)sprite.uniqueID: %@",((DecorationSignifier*)sprite).uniqueID);
        }
        NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:typeString];
        [spriteNode addChild:type];
        
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:sprite.name];
        [spriteNode addChild:name];
        
        NSXMLElement *uniqueID = [NSXMLElement elementWithName:@"uniqueID" stringValue:[NSString stringWithFormat:@"%u", arc4random_uniform(1000000)]];
        [spriteNode addChild:uniqueID];
        
//        if (sprite == rightMostNode) {
//            NSXMLElement *isRightMostNode = [NSXMLElement elementWithName:@"isRightMostNode" stringValue:@"yes"];
//            [spriteNode addChild:isRightMostNode];
//        }
//        else{
//            NSXMLElement *isRightMostNode = [NSXMLElement elementWithName:@"isRightMostNode" stringValue:@"no"];
//            [spriteNode addChild:isRightMostNode];
//        }

        float fractionalCoefficient = sprite.zPosition / leftMostNode.zPosition;
        //NSLog(@"fractionalCoefficient: %f", fractionalCoefficient);
        float parallaxAdjustedDifference = fractionalCoefficient * xDifference;
        //NSLog(@"parallaxAdjustedDifference: %f", parallaxAdjustedDifference);

        float xPos = sprite.position.x - parallaxAdjustedDifference;
        NSXMLElement *xPosition = [NSXMLElement elementWithName:@"xPosition" stringValue:[NSString stringWithFormat:@"%f", xPos]];
        [spriteNode addChild:xPosition];
        
        NSXMLElement *yPosition = [NSXMLElement elementWithName:@"yPosition" stringValue:[NSString stringWithFormat:@"%f", sprite.position.y]];
        [spriteNode addChild:yPosition];
        
        NSXMLElement *zPosition = [NSXMLElement elementWithName:@"zPosition" stringValue:[NSString stringWithFormat:@"%f", sprite.zPosition]];
        [spriteNode addChild:zPosition];
        
        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            ObstacleSignifier* obs = (ObstacleSignifier*)sprite;
            NSXMLElement *motionType = [NSXMLElement elementWithName:@"motionType" stringValue:[NSString stringWithFormat:@"%d", obs.currentMotionType]];
            [spriteNode addChild:motionType];
            NSXMLElement *speedType = [NSXMLElement elementWithName:@"speedType" stringValue:[NSString stringWithFormat:@"%d", obs.currentSpeedType]];
            [spriteNode addChild:speedType];
        }
    }
    
    NSXMLElement *terrainPoolNode = [NSXMLElement elementWithName:@"terrainPool"];
    [root addChild:terrainPoolNode];
    for (NSString* name in terrainPool) {
        NSXMLElement *terrainPoolMember = [NSXMLElement elementWithName:@"terrainPoolMember" stringValue:name];
        [terrainPoolNode addChild:terrainPoolMember];
    }

    NSError *error = nil;
    BOOL isValid = [xmlDoc validateAndReturnError:&error];
    
    if (isValid){
        NSLog(@"document is valid");
        [self exportXMLDocument:xmlDoc];
        //NSOpenPanel *panel = [NSOpenPanel openPanel];
        
    }
    
    else{
        NSLog(@"document is invalid: %@", [error localizedDescription]);
    }
}

- (void)exportXMLDocument:(NSXMLDocument*)doc{
    // Set the default name for the file and show the panel.
    NSSavePanel*    panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"my fun fun fun fun level.xml"];
    [panel beginSheetModalForWindow:[NSWindow new] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL*  theFile = [panel URL];
                NSData *xmlData = [doc XMLDataWithOptions:NSXMLNodePrettyPrint];
                if (![xmlData writeToURL:theFile atomically:YES]) {
                    NSBeep();
                    NSLog(@"Could not write document out...");
                }
        }
    }];

}



@end
