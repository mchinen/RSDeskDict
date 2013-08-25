//
//  AppDelegate.m
//  RSDeskDict
//
//  Created by Michael Chinen on 13/08/22.
//  Copyright (c) 2013年 RS. All rights reserved.
//

#import <CoreServices/CoreServices.h>

#import "AppDelegate.h"

//@synthesize inputField, defField;

@implementation AppDelegate
@synthesize managedObjectContext;

static NSArray* s_dicts;
static NSDictionary* s_names;

// unexposed but exported.
CFArrayRef DCSCopyAvailableDictionaries();
CFStringRef DCSDictionaryGetShortName(DCSDictionaryRef);
DCSDictionaryRef DCSDictionaryCreate(CFURLRef url);
CFArrayRef DCSCopyRecordsForSearchString(DCSDictionaryRef dictionary, CFStringRef string, void *u1, void *u2);
CFStringRef DCSRecordCopyData(CFTypeRef record);
CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictionary);
CFStringRef DCSRecordGetRawHeadword(CFTypeRef record);
CFStringRef DCSRecordGetString(CFTypeRef record);

CFStringRef DCSRecordGetAssociatedObj(CFTypeRef record);
CFStringRef DCSRecordCopyDataURL(CFTypeRef record);
CFStringRef DCSRecordGetAnchor(CFTypeRef record);
CFStringRef DCSRecordGetSubDictionary(CFTypeRef record);
CFStringRef DCSRecordGetTitle(CFTypeRef record);
CFDictionaryRef DCSCopyDefinitionMarkup (
                                         DCSDictionaryRef dictionary,
                                         CFStringRef record
                                         );

extern CFStringRef DCSRecordGetHeadword(CFTypeRef);
extern CFStringRef DCSRecordGetBody(CFTypeRef);
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   // gather dicts
   s_dicts = (__bridge_transfer NSArray*)DCSCopyAvailableDictionaries();
   s_names = [NSMutableDictionary dictionaryWithCapacity:[s_dicts count]];

   for (NSObject *d in s_dicts) {
      NSString *sn = (__bridge NSString*)DCSDictionaryGetShortName((__bridge DCSDictionaryRef)d);
      NSLog(@"%@", sn);

      [s_names setValue:sn forKey:[NSString stringWithFormat:@"%p",d]];
   }
}

- (IBAction)onInput:(id)sender
{
   NSString* inputStr = [self.inputField stringValue];
   // send to dict look up
   NSString* defStr = @"";
   for (NSObject *d in s_dicts) {
      CFRange substringRange = DCSGetTermRangeInString((__bridge DCSDictionaryRef)d, (__bridge CFStringRef)inputStr, 0);
      if (substringRange.location == kCFNotFound) {
         continue;
      }
      NSString* subStr = [inputStr substringWithRange:NSMakeRange(substringRange.location, substringRange.length)];
      
      NSArray* records = (__bridge_transfer NSArray*)DCSCopyRecordsForSearchString((__bridge DCSDictionaryRef)d, (__bridge CFStringRef)subStr, 0, 0);
      if (records) {
         
         defStr = [defStr stringByAppendingString:
                   [NSString stringWithFormat:@"[%@]\n", [s_names objectForKey:[NSString stringWithFormat:@"%p",d]]]];
         for (NSObject* r in records) {
            // DCSRecordCopyData doesn't play with with the big boy dicts
            CFStringRef data = DCSRecordGetTitle((__bridge CFTypeRef) r);
            //CFStringRef data = DCSRecordGetRawHeadword((__bridge CFTypeRef) r);
            //CFStringRef data = DCSRecordGetHeadword((__bridge CFTypeRef) r);
            if (data) {
               NSString* recordDef = (__bridge_transfer NSString*)DCSCopyTextDefinition((__bridge DCSDictionaryRef)d,
                                                                                        data,
                                                                                        CFRangeMake(0,CFStringGetLength(data)));
               defStr = [defStr stringByAppendingString:[NSString stringWithFormat:@"%@\n\n", recordDef]];
               
               NSLog(@"printed %@", r);
            } else {
               NSLog(@"skipping %@", r);
            }
         }
      }
   }

   [self.defField setString:defStr];
   //[[self.defField textStorage] setAttributedString:defStr];
}
@end
