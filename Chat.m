//
//  Chat.m
//  Pesterchum
//
//  Created by Hanzilla on 10/7/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "Chat.h"
#import "ChatViewController.h"

@implementation Chat
@synthesize name, HTMLlog, chatMoodList, chatColor, isOpen, isMemo, controller;

-(id) initWithName:(NSString*) newName
{
    self = [super init];
    chatMoodList = [NSMutableDictionary dictionary];
    name = newName;
    HTMLlog = [@"<html><head></head> <body style=\"font-family:'Monaco', Monaco, monospace; font-weight:900; font-size:15px; line-height:95%\"></body></html>" mutableCopy];
    chatColor = @"0,0,0";
    [chatMoodList setValue:@"0" forKey:name];
    isOpen = false;
    isMemo = false;
    return self;
}

-(void) addChum:(NSString *)chum withMood:(NSString *)mood
{
    [chatMoodList setValue:mood forKey:chum];
}

- (void) printToChat:(NSString*)msg
{
    msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    msg = [msg stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    msg = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    msg = [msg stringByAppendingString:@"<br/>"];
    msg = [msg stringByReplacingOccurrencesOfString:@"<c=" withString:@"<span style=\\\"color:rgb("];
    // Terrible hack.
    msg = [msg stringByReplacingOccurrencesOfString:@"0>" withString:@"0)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"1>" withString:@"1)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"2>" withString:@"2)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"3>" withString:@"3)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"4>" withString:@"4)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"5>" withString:@"5)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"6>" withString:@"6)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"7>" withString:@"7)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"8>" withString:@"8)\\\">"];
    msg = [msg stringByReplacingOccurrencesOfString:@"9>" withString:@"9)\\\">"];
    
    msg = [msg stringByReplacingOccurrencesOfString:@"</c>" withString:@"</span>"];
    
    NSLog( @"\n\n\n\n$$$$$    Message = %@    $$$$$\n\n\n\n", msg );
    
    if( controller )
    {
        NSString* javascript = [NSString stringWithFormat:@"document.body.innerHTML += \"%@\"", msg];
        //+= '%@<br/>';", msg];
        [controller.chatTextView stringByEvaluatingJavaScriptFromString:javascript];
        
        NSInteger height = [[controller.chatTextView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
        javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
        [controller.chatTextView stringByEvaluatingJavaScriptFromString:javascript];
    }
    
    [self.HTMLlog appendString:msg];
}


@end
