//
//  TerrainImageView.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "TerrainImageView.h"
#import <SpriteKit/SpriteKit.h>
@implementation TerrainImageView

- (void)mouseDown:(NSEvent*)event
{
//    /*------------------------------------------------------
//     catch mouse down events in order to start drag
//     --------------------------------------------------------*/
//    NSPasteboardItem *pbItem = [NSPasteboardItem new];
//    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, NSPasteboardTypeString, nil]];
//    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
//    //NSRect draggingRect = self.bounds;
//    NSRect draggingRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.image.size.width, self.image.size.height);
//    [dragItem setDraggingFrame:draggingRect contents:[self image]];
//    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:event source:self];
//    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
//    draggingSession.draggingFormation = NSDraggingFormationNone;
    
    SKTexture* thisTex = [SKTexture textureWithImage:[self image]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"terrain texture selected" object:nil userInfo:[NSDictionary dictionaryWithObject:thisTex forKey:@"texture"]];
}

//- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
//{
//    /*------------------------------------------------------
//     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
//     --------------------------------------------------------*/
//    return NSDragOperationCopy;
//}

//- (BOOL)acceptsFirstMouse:(NSEvent *)event
//{
//    /*------------------------------------------------------
//     accept activation click as click in window
//     --------------------------------------------------------*/
//    //so source doesn't have to be the active window
//    return YES;
//}

//- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
//{
//    /*------------------------------------------------------
//     method called by pasteboard to support promised
//     drag types.
//     --------------------------------------------------------*/
//    
//    if ([type isEqualToString:NSPasteboardTypeTIFF]) {
//        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
//    }
//    else if ([type isEqualToString:NSPasteboardTypeString]){
//        //NSLog(@"calling for a string");
//        [sender setString:self.image.name forType:NSPasteboardTypeString];
//    }
//    
//}


@end
