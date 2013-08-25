//
//  AppDelegate.h
//  RSDeskDict
//
//  Created by Michael Chinen on 13/08/22.
//  Copyright (c) 2013年 RS. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *inputField;
@property (assign) IBOutlet NSTextView *defField;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
- (IBAction)onInput:(id)sender;
@end
