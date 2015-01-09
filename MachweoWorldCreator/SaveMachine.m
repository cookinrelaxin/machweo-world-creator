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

-(void)saveWorld:(SKNode *)world{
    NSLog(@"saveScene");
    
    SKSpriteNode* leftMostNode = nil;
    
    for (SKSpriteNode* node in world.children) {
        if ([node isKindOfClass:[DecorationSignifier class]]) {
            
            if (leftMostNode == nil) {
                leftMostNode = node;
            }
            
            float leftEdgeOfLeftMost = leftMostNode.position.x - (leftMostNode.size.width / 2);
            float leftEdgeOfNode = node.position.x - (node.size.width / 2);
            
            if (leftEdgeOfNode < leftEdgeOfLeftMost) {
                leftMostNode = node;
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
    for (SKSpriteNode* sprite in world.children) {
        
        NSXMLElement *spriteNode = [NSXMLElement elementWithName:@"spriteNode"];
        [root addChild:spriteNode];
        
        NSString* typeString = @"placeholder";
        if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
            typeString = @"ObstacleSignifier";
        }
        else if ([sprite isKindOfClass:[DecorationSignifier class]]) {
            typeString = @"DecorationSignifier";
        }
        NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:typeString];
        [spriteNode addChild:type];
        
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:sprite.name];
        [spriteNode addChild:name];
        
        //if ([sprite isKindOfClass:[ObstacleSignifier class]]) {
         //   float xPos = sprite.position.x - xDifference;
        //    NSXMLElement *xPosition = [NSXMLElement elementWithName:@"xPosition" stringValue:[NSString stringWithFormat:@"%f", xPos]];
        //    [spriteNode addChild:xPosition];
        //}
        //else if ([sprite isKindOfClass:[DecorationSignifier class]]) {
            float fractionalCoefficient = sprite.zPosition / leftMostNode.zPosition;
            float parallaxAdjustedDifference = fractionalCoefficient * xDifference;
            float xPos = sprite.position.x - parallaxAdjustedDifference;
            NSXMLElement *xPosition = [NSXMLElement elementWithName:@"xPosition" stringValue:[NSString stringWithFormat:@"%f", xPos]];
            [spriteNode addChild:xPosition];
        //}
        
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
