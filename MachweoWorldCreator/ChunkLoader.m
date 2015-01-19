//
//  ChunkLoader.m
//  tgrrn
//
//  Created by John Feldcamp on 12/26/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChunkLoader.h"
#import "ObstacleSignifier.h"
#import "DecorationSignifier.h"

typedef enum ElementVarieties
{
    spriteNode,
    type,
    name,
    xPosition,
    yPosition,
    zPosition,
    isRightMostNode,
    motionType,
    speedType
} Element;

typedef enum NodeTypes
{
    obstacle,
    decoration
} Node;

@implementation ChunkLoader{
    // as simple as possible for now. assume all nodes are obstacles
    NSMutableArray* obstacleArray;
    NSMutableArray* decorationArray;
    NSMutableArray* backgroundArray;

    SKSpriteNode *currentNode;
    Element currentElement;
    Node currentNodeType;
    
    BOOL charactersFound;
    BOOL validFile;
    
}

-(instancetype)initWithFile:(NSString*)fileName{
    obstacleArray = [NSMutableArray array];
    decorationArray = [NSMutableArray array];
    backgroundArray = [NSMutableArray array];

    NSXMLParser* chunkParser;
    
    BOOL success;
    //NSURL *xmlURL = [NSURL fileURLWithPath:fileName];
//    NSURL *xmlURL = [[NSBundle mainBundle]
//                    URLForResource: fileName withExtension:@"xml"];
    NSURL *xmlURL = [[NSBundle mainBundle]
                     URLForResource:fileName withExtension:@"xml"];

    if(xmlURL){
       // NSLog(@"fileName: %@", fileName);
      //  NSLog(@"xmlURL: %@", xmlURL);
        chunkParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];

        if (chunkParser){
            validFile = true;
            NSLog(@"parse chunk");
            [chunkParser setDelegate:self];
            [chunkParser setShouldResolveExternalEntities:YES];
            success = [chunkParser parse];
        }
    }
    else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"invalid file. dude, the level file has to be within the fucking /assets/levels folder"];
        [alert setInformativeText:@"bitch"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // These objects are created here so that if a document is not found they will not be created
  //  NSLog(@"did start document");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"spriteNode"]) {
        currentElement = spriteNode;
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        currentElement = name;
        return;
    }
    if ([elementName isEqualToString:@"type"]) {
        currentElement = type;
        return;
    }
    if ([elementName isEqualToString:@"xPosition"]) {
        currentElement = xPosition;
        return;
    }
    if ([elementName isEqualToString:@"yPosition"]) {
        currentElement = yPosition;
        return;
    }
    if ([elementName isEqualToString:@"zPosition"]) {
        currentElement = zPosition;
        return;
    }
    if ([elementName isEqualToString:@"isRightMostNode"]) {
        currentElement = isRightMostNode;
        return;
    }
    if ([elementName isEqualToString:@"motionType"]) {
        currentElement = motionType;
        return;
    }
    if ([elementName isEqualToString:@"speedType"]) {
        currentElement = speedType;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"spriteNode"]) {
        if (currentNode != nil) {
            switch (currentNodeType) {
                case obstacle:
                    [obstacleArray addObject:currentNode];
                    break;
                case decoration:
                    [decorationArray addObject:currentNode];
                    break;
            }
            return;
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        if (currentElement == name) {
            NSImage *spriteTexture = [NSImage imageNamed:string];
            if (spriteTexture) {
                if (currentNodeType == obstacle) {
                    currentNode = [ObstacleSignifier spriteNodeWithTexture:[SKTexture textureWithImage:spriteTexture]];
                }
                else if (currentNodeType == decoration) {
                    currentNode = [DecorationSignifier spriteNodeWithTexture:[SKTexture textureWithImage:spriteTexture]];
                }
            }
            else{
                currentNode = nil;
            }
            //NSLog(@"name: %@", string);
            currentNode.name = string;
            return;
        }
        if (currentElement == xPosition) {
            //NSLog(@"xPosition: %@", string);
            currentNode.position = CGPointMake([string floatValue], currentNode.position.y);
            return;
        }
        if (currentElement == yPosition) {
            //NSLog(@"yPosition: %@", string);
            currentNode.position = CGPointMake(currentNode.position.x, [string floatValue]);
            return;
        }
        if (currentElement == zPosition) {
            //NSLog(@"zPosition: %@", string);
            currentNode.zPosition = [string floatValue];
            return;
        }
        if (currentElement == type) {
            //NSLog(@"yPosition: %@", string);
            if ([string isEqualToString:@"ObstacleSignifier"]) {
                currentNodeType = obstacle;
                return;
            }
            if ([string isEqualToString:@"DecorationSignifier"]) {
                currentNodeType = decoration;
                return;
            }
        }
        if (currentElement == isRightMostNode) {
            return;
        }
        if (currentElement == motionType) {
            if ([currentNode isKindOfClass:[ObstacleSignifier class]]) {
                ObstacleSignifier* obs = (ObstacleSignifier*)currentNode;
                obs.currentMotionType = [string intValue];
                return;
            }
        }
        if (currentElement == speedType) {
            if ([currentNode isKindOfClass:[ObstacleSignifier class]]) {
                ObstacleSignifier* obs = (ObstacleSignifier*)currentNode;
                obs.currentSpeedType = [string intValue];
                return;
            }
        }
    }
}

-(void)loadWorld:(SKNode*)world{
    if (validFile) {
        NSLog(@"load world");
        for (SKSpriteNode *obstacle in obstacleArray) {
            obstacle.zPosition = 16;
            [world addChild:obstacle];
        }
        for (SKSpriteNode *deco in decorationArray) {
            [world addChild:deco];
        }
        for (SKSpriteNode *bg in backgroundArray) {
            [world addChild:bg];
        }
    }
    
}
@end
