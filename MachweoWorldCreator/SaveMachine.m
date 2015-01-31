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
#import "TerrainSignifier.h"

@implementation SaveMachine

-(void)saveWorld:(SKNode *)world{
    NSLog(@"saveScene");
    
    SKSpriteNode* rightMostNode = nil;
    SKSpriteNode* leftMostNode = nil;
    
    for (SKSpriteNode* node in world.children) {
        if ((int)node.zPosition == 1) {
            
            if (leftMostNode == nil) {
                leftMostNode = node;
            }
            if (rightMostNode == nil) {
                rightMostNode = node;
            }
            {
                float leftEdgeOfLeftMost = leftMostNode.position.x - (leftMostNode.size.width / 2);
                float leftEdgeOfNode = node.position.x - (node.size.width / 2);
                
                if (leftEdgeOfNode < leftEdgeOfLeftMost) {
                    leftMostNode = node;
                }
            }
            {
                float rightEdgeOfRightMost = rightMostNode.position.x + (rightMostNode.size.width / 2);
                float rightEdgeOfNode = node.position.x + (node.size.width / 2);
                
                if (rightEdgeOfNode > rightEdgeOfRightMost) {
                    rightMostNode = node;
                }
            }
            
        }
    }
    NSLog(@"[leftMostNode class]: %@", [leftMostNode class]);
    float xDifference = leftMostNode.position.x - (leftMostNode.size.width / 2);
    NSLog(@"xDifference: %f", xDifference);
    
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"worldnodes"];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    for (SKNode* sprite in world.children) {
        if ([sprite isKindOfClass:[TerrainSignifier class]]) {
           TerrainSignifier* terrainNode = (TerrainSignifier*)sprite;
            NSXMLElement *terrainNodeElement = [NSXMLElement elementWithName:@"node"];
            [root addChild:terrainNodeElement];
            
            NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:@"TerrainSignifier"];
            [terrainNodeElement addChild:type];
            
            NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:terrainNode.name];
            [terrainNodeElement addChild:name];
            
            
            float fractionalCoefficient = terrainNode.zPosition / leftMostNode.zPosition;
            float parallaxAdjustedDifference = fractionalCoefficient * xDifference;
            //float xPos = terrainNode.position.x - parallaxAdjustedDifference;
//            NSXMLElement *xPosition = [NSXMLElement elementWithName:@"xPosition" stringValue:[NSString stringWithFormat:@"%f", xPos]];
//            [terrainNodeElement addChild:xPosition];
//
//            NSXMLElement *yPosition = [NSXMLElement elementWithName:@"yPosition" stringValue:[NSString stringWithFormat:@"%f", terrainNode.position.y]];
//            [terrainNodeElement addChild:yPosition];

            NSXMLElement *zPosition = [NSXMLElement elementWithName:@"zPosition" stringValue:[NSString stringWithFormat:@"%f", terrainNode.zPosition]];
            [terrainNodeElement addChild:zPosition];
            
            NSXMLElement *lineVertices = [NSXMLElement elementWithName:@"lineVertices"];
            [terrainNodeElement addChild:lineVertices];
            
            NSArray *sortedArray;
            sortedArray = [terrainNode.lineVertices sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                float x1 = [(NSValue*)a pointValue].x;
                float x2 = [(NSValue*)b pointValue].x;
                return x1 > x2;
            }];
            
            for (NSValue* value in sortedArray) {
                NSPoint point = [value pointValue];
                point = CGPointMake(point.x - parallaxAdjustedDifference, point.y);
                NSXMLElement *lineVertex = [NSXMLElement elementWithName:@"lineVertex"];
                NSXMLElement *lineVertexXPoint = [NSXMLElement elementWithName:@"lineVertexXPoint" stringValue:[NSString stringWithFormat:@"%f", point.x]];
                [lineVertex addChild:lineVertexXPoint];
                NSXMLElement *lineVertexYPoint = [NSXMLElement elementWithName:@"lineVertexYPoint" stringValue:[NSString stringWithFormat:@"%f", point.y]];
                [lineVertex addChild:lineVertexYPoint];
                
                [lineVertices addChild:lineVertex];
            }

            NSXMLElement *shapeVertices = [NSXMLElement elementWithName:@"shapeVertices"];
            [terrainNodeElement addChild:shapeVertices];
            
            for (NSValue* value in terrainNode.shapeVertices) {
                NSPoint point = [value pointValue];
                point = CGPointMake(point.x - parallaxAdjustedDifference, point.y);
                NSXMLElement *shapeVertex = [NSXMLElement elementWithName:@"shapeVertex"];
                NSXMLElement *shapeVertexXPoint = [NSXMLElement elementWithName:@"shapeVertexXPoint" stringValue:[NSString stringWithFormat:@"%f", point.x]];
                [shapeVertex addChild:shapeVertexXPoint];
                NSXMLElement *shapeVertexYPoint = [NSXMLElement elementWithName:@"shapeVertexYPoint" stringValue:[NSString stringWithFormat:@"%f", point.y]];
                [shapeVertex addChild:shapeVertexYPoint];

                [shapeVertices addChild:shapeVertex];

            }

            continue;
        }

        NSXMLElement *spriteNode = [NSXMLElement elementWithName:@"node"];
        NSString* typeString = @"placeholder";

        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            ObstacleSignifier* obs = (ObstacleSignifier*)sprite;
            NSXMLElement *motionType = [NSXMLElement elementWithName:@"motionType" stringValue:[NSString stringWithFormat:@"%d", obs.currentMotionType]];
            [spriteNode addChild:motionType];
            NSXMLElement *speedType = [NSXMLElement elementWithName:@"speedType" stringValue:[NSString stringWithFormat:@"%d", obs.currentSpeedType]];
            [spriteNode addChild:speedType];
            
            typeString = @"ObstacleSignifier";
        }
        else if ([sprite isKindOfClass:[DecorationSignifier class]]) {
            typeString = @"DecorationSignifier";
        }
        else{
            continue;
        }
        
        [root addChild:spriteNode];
        NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:typeString];
        [spriteNode addChild:type];
        
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:sprite.name];
        [spriteNode addChild:name];
        
        if (sprite == rightMostNode) {
            NSXMLElement *isRightMostNode = [NSXMLElement elementWithName:@"isRightMostNode" stringValue:@"yes"];
            [spriteNode addChild:isRightMostNode];
        }
        else{
            NSXMLElement *isRightMostNode = [NSXMLElement elementWithName:@"isRightMostNode" stringValue:@"no"];
            [spriteNode addChild:isRightMostNode];
        }

        float fractionalCoefficient = sprite.zPosition / leftMostNode.zPosition;
        float parallaxAdjustedDifference = fractionalCoefficient * xDifference;
        float xPos = sprite.position.x - parallaxAdjustedDifference;
        NSXMLElement *xPosition = [NSXMLElement elementWithName:@"xPosition" stringValue:[NSString stringWithFormat:@"%f", xPos]];
        [spriteNode addChild:xPosition];
        
        NSXMLElement *yPosition = [NSXMLElement elementWithName:@"yPosition" stringValue:[NSString stringWithFormat:@"%f", sprite.position.y]];
        [spriteNode addChild:yPosition];
        
        NSXMLElement *zPosition = [NSXMLElement elementWithName:@"zPosition" stringValue:[NSString stringWithFormat:@"%f", sprite.zPosition]];
        [spriteNode addChild:zPosition];
        
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
