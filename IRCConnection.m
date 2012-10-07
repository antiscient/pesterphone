//
//  IRCConnection.m
//  Pesterchum
//
//  Created by Antiscient on 9/15/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "IRCConnection.h"
#import "PesterphoneAppDelegate.h"

@implementation IRCConnection
@synthesize chatBox;

-(id) init
{
    self = [super init];
    return self;
}

-(void) startWithURL:(NSString*) urlStr
{
    if (![urlStr isEqualToString:@""])
    {
        NSURL *website = [NSURL URLWithString:urlStr];
        if (!website)
        {
            NSLog(@"%@ is not a valid URL", urlStr);
            return;
        }
        
        if(chatBox)
            [self printToChat:@"Logging in..........."];
        loggedIn = false;
        loggingIn = false;
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[website host], 6667, &readStream, &writeStream);
        
        inputStream = (__bridge NSInputStream *)readStream;
        outputStream = (__bridge NSOutputStream *)writeStream;
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
    }
    
}

-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSString *event;
    switch (streamEvent)
    {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted:
            if( theStream == inputStream )
                event = @"NSStreamEventOpenCompleted– input";
            else if( theStream == outputStream )
                event = @"NSStreamEventOpenCompleted– output";
            break;
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            if (theStream == inputStream)
            {
                uint8_t buffer[4096];
                int len;
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:4096];
                    if (len > 0)
                    {
                        NSMutableString *output = [[NSMutableString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        NSLog(@"-------- ---- ------------------- %@", output);
                        
                        
                        if( !loggedIn )
                        {
                            NSString *chumString = [output substringToIndex:[output rangeOfString:@" "].location];
                            NSString *chumhandle = @"NOHANDLE";
                            
                            if( [chumString rangeOfString:@"!"].location != NSNotFound && [[[chumString componentsSeparatedByString:@"!"] objectAtIndex:0] length] > 1 )
                                chumhandle = [[[chumString componentsSeparatedByString:@"!"] objectAtIndex:0] substringFromIndex:1];
                            
                            if( [output rangeOfString:@"433"].location != NSNotFound )
                            {
                                NSLog(@"Nickname is already in use!");
                                return;
                            }
                            if( [output rangeOfString:@"004"].location != NSNotFound )
                            {
                                NSLog(@"Logged in.\n");
                                loggedIn = true;
                                loggingIn = false;
                                if( chatBox )
                                    [self printToChat:@"Logged in to Pesterchum.\n\n\n"];
                                [self dataSending:@"JOIN #Pesterchum\n"];
                                [self sendMsg:@"MOOD >0" to:@"#pesterchum"];
                                
                                PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                
                                if( appDelegate.chumroll )
                                {
                                    NSMutableString *chums = [@"" mutableCopy];
                                    
                                    for( NSString *chum in appDelegate.chumroll.chums )
                                    {
                                        [chums appendString:chum];
                                    }
                                    
                                    if( chums.length > 0 )
                                        [self sendMsg:[NSString stringWithFormat:@"GETMOOD %@", chums] to:@"#pesterchum"];
                                }
                                
                                // [self dataSending:[NSString stringWithFormat:@"JOIN %@\n", @"#General_Chat"]];
                            }
                            
                            if( [output rangeOfString:@"PING"].location != NSNotFound )
                            {
                                NSLog(@"Ponging!");
                                [self dataSending:[NSString stringWithFormat:@"PONG %@",[output substringFromIndex:5]]];
                            }
                            
                            if( [output rangeOfString:@"\x01"].location != NSNotFound )
                            {
                                if( [output rangeOfString:@"VERSION"].location != NSNotFound )
                                {
                                    NSLog(@"Responding to VERSION request");
                                    [self dataSending:[NSString stringWithFormat:@"NOTICE %@ \x01VERSION Pesterchum 3.41\x01", chumString]];
                                }
                            }
                            
                        }
                        else
                        {
                            NSArray *lines = [output componentsSeparatedByString:@"\n"];
                            
                            for( NSString* line in lines )
                            {
                                NSString * display = @"";
                                
                                if( [line rangeOfString:@"PING"].location != NSNotFound )
                                {
                                    NSLog(@"Ponging!");
                                    [self dataSending:[NSString stringWithFormat:@"PONG %@",[line substringFromIndex:5]]];
                                    display = @"";
                                }
                                
                                NSArray *parts = [line componentsSeparatedByString:@" "];
                                
                                if( parts.count > 2 )
                                {
                                    NSString *chumString = [parts objectAtIndex:0];
                                    NSString *chumhandle = @"NOHANDLE";
                                    
                                    if( [chumString rangeOfString:@"!"].location != NSNotFound && [[[chumString componentsSeparatedByString:@"!"] objectAtIndex:0] length] > 1 )
                                        chumhandle = [[[chumString componentsSeparatedByString:@"!"] objectAtIndex:0] substringFromIndex:1];
                                    
                                    NSString *ircCommand = [parts objectAtIndex:1];
                                    NSString *target = [parts objectAtIndex:2];
                                    
                                    if( [target isEqualToString: @"#pesterchum"] )
                                    {
                                        if( parts.count > 3 )
                                        {
                                            NSString *message = [parts objectAtIndex:3];
                                            
                                            if( [message hasPrefix:@":MOOD"] )
                                            {
                                                PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                                int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                                
                                                if( chumIndex != NSNotFound )
                                                {
                                                    UITableViewCell *cell = [appDelegate.chumroll.chumTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:chumIndex inSection:0]];
                                                    cell.textLabel.textColor = [UIColor whiteColor];
                                                }
                                            }
                                            else if( [message hasPrefix:@":GETMOOD"] )
                                            {
                                                NSString *searchLine = [line substringFromIndex:[line rangeOfString:[parts objectAtIndex:4]].location];
                                                NSLog( @"\n\n\n#######  SEARCHING FOR HANDLE ######     in string: %@\n\n\n", searchLine );
                                                if( [searchLine rangeOfString:myHandle].location != NSNotFound )
                                                    [self sendMsg:@"MOOD >0" to:@"#pesterchum"];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if( parts.count > 3 )
                                        {
                                            NSString *message = [parts objectAtIndex:3];
                                            
                                            if( [ircCommand isEqualToString: @"PRIVMSG"] )
                                            {
                                                if( [message hasPrefix:@":PESTERCHUM:"] )
                                                {
                                                    if( [message hasPrefix:@":PESTERCHUM:CEASE"] )
                                                    {
                                                        // get current date/time
                                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                        // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                                        [dateFormatter setDateFormat:@"H:mm"];
                                                        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                                        
                                                        display = [NSString stringWithFormat:@"-- %@ [%@] ceased pestering %@ [%@] at %@ --", chumhandle, [IRCConnection getInitials:chumhandle], myHandle, myInitials, currentTime ];
                                                    }
                                                }
                                                else if( [message hasPrefix:@":COLOR >"] )
                                                {
                                                    //
                                                    //  Insert text color change here.
                                                    //
                                                }
                                                else
                                                {
                                                    // get current date/time
                                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                                    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                                                    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                                    currentTime = [currentTime substringToIndex:[currentTime length] - 3];
                                                    
                                                    display = [NSString stringWithFormat:@"[%@] %@: %@", currentTime, [IRCConnection getInitials:chumhandle],[[line substringFromIndex:[line rangeOfString:[parts objectAtIndex:3]].location] substringFromIndex:1]];
                                                }
                                            }
                                        }
                                        
                                        if( [ircCommand isEqualToString: @"QUIT"] )
                                        {
                                            //display = [NSString stringWithFormat:@"%@ has logged off!", chumhandle];
                                            
                                            PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                            int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                            
                                            if( chumIndex != NSNotFound )
                                            {
                                                UITableViewCell *cell = [appDelegate.chumroll.chumTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:chumIndex inSection:0]];
                                                cell.textLabel.textColor = [UIColor darkGrayColor];
                                            }
                                        }
                                        
                                        if( ![target isEqualToString:@"#pesterchum"] && [ircCommand isEqualToString: @"PART"] )
                                        {
                                            display = [NSString stringWithFormat:@"%@ has logged off!", chumhandle];
                                        }
                                        /*else if( [ircCommand isEqualToString: @"JOIN"] )
                                        {
                                            PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                            int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                            
                                            if( chumIndex != NSNotFound )
                                            {
                                                [self sendMsg:[NSString stringWithFormat:@"GETMOOD %@", chumhandle] to:@"#pesterchum"];
                                            }
                                            display = [NSString stringWithFormat:@"%@ has logged on!", chumhandle];
                                        }*/
                                        
                                        if( [line rangeOfString:@"\x01"].location != NSNotFound )
                                        {
                                            if( [line rangeOfString:@"VERSION"].location != NSNotFound )
                                            {
                                                NSLog(@"Responding to VERSION request");
                                                [self dataSending:[NSString stringWithFormat:@"NOTICE %@ :\x01VERSION Pesterchum 3.41\x01", [parts objectAtIndex:0] ]];
                                                display = @"";
                                            }
                                        }
                                        else if( display != @"" && chatBox )
                                        {
                                            [self printToChat:display];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            if( theStream == outputStream && !loggedIn && !loggingIn )
            {
                NSLog(@"Nick will be \"%@\"", myHandle);
                NSLog( @"Attempting login........" );
                [self dataSending:[NSString stringWithFormat:@"NICK %@\n", myHandle]];
                [self dataSending:[NSString stringWithFormat:@"USER %@ 0 * :test bot\n", myHandle]];
                loggingIn = true;
            }
            break;
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            [self close];
            break;
        case NSStreamEventEndEncountered:
            break; default:
            event = @"NSStreamEventEndEncountered";
            [self close];
            event = @"Unknown"; break;
    }
    //NSLog(@"event------%@",event);
}

- (void)dataSending:(NSString*)data
{
    if(outputStream)
    {
        if(![outputStream hasSpaceAvailable])
            return;
        NSData *_data=[data dataUsingEncoding:NSUTF8StringEncoding];
        int data_len = [_data length];
        uint8_t *readBytes = (uint8_t *)[_data bytes];
        int byteIndex=0;
        int len=0;
        while (TRUE)
        {
            len = ((data_len - byteIndex >= 4096) ? 4096 : (data_len-byteIndex));
            if(len==0)
                break;
            uint8_t buf[len];
            (void)memcpy(buf, readBytes, len);
            len = [outputStream write:(const uint8_t *)buf maxLength:len];
            
            if( len == -1 )
            {
                NSLog( @"Write error -1" );
                break;
            }
            
            byteIndex += len;
            readBytes += len;
        }
    }
}

- (void) sendMsg:(NSString*)msg to:(NSString*)target
{
    NSArray *lines = [msg componentsSeparatedByString:@"\n"];
    
    for(NSString* line in lines)
    {
        NSString *out = [NSString stringWithFormat:@"PRIVMSG %@ :%@\n",target, line];
        [self dataSending:out];
        NSLog(@"Sending-----------\"%@\"", out);
        
        if( chatBox && ![msg hasPrefix:@"PESTERCHUM:"] && ![msg hasPrefix:@"MOOD >"] && ![msg hasPrefix:@"COLOR >"] )
        {
            // get current date/time
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
            currentTime = [currentTime substringToIndex:[currentTime length] - 3];
            
            [self printToChat:[NSString stringWithFormat:@"[%@] %@: %@", currentTime, myInitials, msg]];
        }
    }
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
    
    NSString* javascript = [NSString stringWithFormat:@"document.body.innerHTML += \"%@\"", msg];
    //+= '%@<br/>';", msg];
    [chatBox stringByEvaluatingJavaScriptFromString:javascript];
    
    NSInteger height = [[chatBox stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
    [chatBox stringByEvaluatingJavaScriptFromString:javascript];
}

- (void) setHandle:(NSString *)name
{
    myHandle = name;
    myInitials = [IRCConnection getInitials:name];
}

- (NSString*) initials
{
    return myInitials;
}

- (NSString*) handle
{
    return myHandle;
}

+ (NSString*) getInitials:(NSString*) name
{
    NSMutableString *out = [[[NSString stringWithFormat:@"%c", [name characterAtIndex:0]] uppercaseString] mutableCopy];
    int index = 1;
    
    while (index < name.length)
    {
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[name characterAtIndex:index]])
        {
            [out appendString:[NSString stringWithFormat:@"%c",[name characterAtIndex:index]]];
        }
        index++;
    }
    
    return [NSString stringWithString:out];
}

- (void)close
{
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    inputStream = nil;
    outputStream = nil;
}

@end
