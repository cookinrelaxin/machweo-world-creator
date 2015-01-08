//
//  DragView.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/12/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "DragView.h"
#import "ObstacleImageView.h"
#import "DecorationImageView.h"

@implementation DragView{
    BOOL isRegisteredForDraggedTypes;
    GameScene* relevantScene;
}

-(instancetype)initWithFrame:(NSRect)frameRect forScene:(GameScene*)scene{
    if (self = [super initWithFrame:frameRect]){
       // NSLog(@"set scene instance var");
        relevantScene = scene;

    }
    return self;
};

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    //NSLog(@"draw rect for dragview");
    if (!isRegisteredForDraggedTypes) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, NSPasteboardTypeTIFF, nil]];
    }
    // Drawing code here.
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
   // NSLog(@"dragging entered");
    return NSDragOperationCopy;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    //NSLog(@"name: %@", [[sender draggingPasteboard] stringForType:NSPasteboardTypeString]);

    
    if([sender draggedImage]) {
        NSImage *newImage = [sender draggedImage];
       // NSLog(@"newImage.size: %f, %f", newImage.size.width, newImage.size.height);
        NSString *name = [[sender draggingPasteboard] stringForType:NSPasteboardTypeString];
        //NSLog(@"name : %@", name );
        
       // NSPasteboard *pboard = [sender draggingPasteboard];
       // NSString *plist = [pboard stringForType:NSTIFFPboardType];
        //NSLog(@"plist: %@", plist);
        
        CGPoint imageLoc = [sender draggedImageLocation];
        CGPoint dragLoc = [sender draggingLocation];
        CGPoint imageCenter = CGPointMake(imageLoc.x + (newImage.size.width / 2), imageLoc.y + (newImage.size.height / 2));
        CGVector imageOffset = CGVectorMake(imageCenter.x - dragLoc.x, imageCenter.y - dragLoc.y);
        CGPoint currentPos = CGPointMake(dragLoc.x + imageOffset.dx, dragLoc.y + imageOffset.dy);
        if ([[sender draggingSource] isKindOfClass:[ObstacleImageView class]]) {
            [relevantScene addObstacleSignifierForImage:newImage fromPointInView:currentPos withName: name];
        }
        else if ([[sender draggingSource] isKindOfClass:[DecorationImageView class]]) {
            [relevantScene addDecorationSignifierForImage:newImage fromPointInView:currentPos withName: name];
        }
    }
    
    return YES;
}


@end
