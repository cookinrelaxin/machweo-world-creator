//
//  SpriteDragSourceImageView.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/18/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "SpriteDragSourceImageView.h"

@implementation SpriteDragSourceImageView

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    // Drawing code here.
//}

- (void)mouseDown:(NSEvent*)event
{
    /*------------------------------------------------------
     catch mouse down events in order to start drag
     --------------------------------------------------------*/
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, NSPasteboardTypeString, nil]];
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    //NSRect draggingRect = self.bounds;
    NSRect draggingRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.image.size.width, self.image.size.height);
    [dragItem setDraggingFrame:draggingRect contents:[self image]];
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:event source:self];
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    draggingSession.draggingFormation = NSDraggingFormationNone;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    return NSDragOperationCopy;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    /*------------------------------------------------------
     accept activation click as click in window
     --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
     method called by pasteboard to support promised
     drag types.
     --------------------------------------------------------*/

    if ([type isEqualToString:NSPasteboardTypeTIFF]) {
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    }
    else if ([type isEqualToString:NSPasteboardTypeString]){
        //NSLog(@"calling for a string");
        [sender setString:self.image.name forType:NSPasteboardTypeString];
    }

}

@end
