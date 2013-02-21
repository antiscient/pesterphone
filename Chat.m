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
@synthesize name, HTMLlog, chatMoodList, chatTimeList, chatColor, isOpen, isMemo, controller;

-(id) initWithName:(NSString*) newName
{
    self = [super init];
    chatMoodList = [NSMutableDictionary dictionary];
    chatTimeList = [NSMutableDictionary dictionary];
    name = newName;
    HTMLlog = [@"<html><head></head> <body style=\"font-family:'Monaco', Monaco, monospace; font-weight:900; font-size:15px; line-height:95%\"></body></html>" mutableCopy];
    chatColor = @"0,0,0";
    
    isOpen = false;
    isMemo = false;
    return self;
}

-(void) addChum:(NSString *)chum withMood:(int)mood
{
    [self setMood:mood forChum:chum];
    [self setTime:@"0000" forChum:chum];
}

- (void) removeChum:(NSString *)chum
{
    [chatMoodList removeObjectForKey:chum];
    [chatTimeList removeObjectForKey:chum];
}

- (Boolean) hasChum:(NSString *)chum
{
    return ([chatMoodList valueForKey:chum] != nil || [chatTimeList valueForKey:chum] != nil);
}

- (void) setMood:(int)mood forChum:(NSString *)chum
{
    [chatMoodList setValue:[NSNumber numberWithInt:mood] forKey:chum];
}

- (void) setTime:(NSString*)chumTime forChum:(NSString *)chum
{
    [chatTimeList setValue:chumTime forKey:chum];
}

- (void) printToChat:(NSString*)msg fromChum:(NSString*)sender
{
    msg = [msg stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
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
    
    if( isMemo && sender && [sender length] > 1 && [self hasChum:sender] )
    {
        NSNumber *outTime = [NSNumber numberWithInt:[(NSString*)[chatTimeList valueForKey:sender] intValue]];
        NSLog( @"\n\n\n\nPrinting with time: %@(%@) and Sender: %@\n\n\n\n", outTime, [chatTimeList valueForKey:sender], sender );
        
        NSRange initials = [msg rangeOfString:[NSString stringWithFormat:@"%@: ", [IRCConnection getInitials:sender withTime:nil]]];
        if( initials.location != NSNotFound )
            msg = [msg stringByReplacingCharactersInRange:initials withString:[NSString stringWithFormat:@"%@: ", [IRCConnection getInitials:sender withTime:outTime]]];
    }
    
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
