//
//  AppDelegate.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate{
    NSWindowController* helpController;
}

- (IBAction)newDocument:(id)sender
{
    if (myWindowController == nil)
    {
        myWindowController = [[MyWindowController alloc] initWithWindowNibName:@"EditorWindow"];
        helpController = [[NSWindowController alloc] initWithWindowNibName:@"HelpWindow"];

    }
    [myWindowController showWindow:self];

}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [self newDocument:self];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)saveLevel:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"save level" object:nil];
}

- (IBAction)loadLevel:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"load level" object:[[theDoc lastPathComponent] stringByDeletingPathExtension]];
        }
        
    }];
}

- (IBAction)openHelpPopup:(id)sender {
    [myWindowController showWindow:helpController.window];
}


@end
