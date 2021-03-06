//
//  IRCConnection.m
//  Pesterchum
//
//  Created by Antiscient on 9/15/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "IRCConnection.h"
#import "PesterphoneAppDelegate.h"
#import "ChatViewController.h"


@implementation IRCConnection

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
#ifdef DEBUG
                        NSLog(@"-------- ---- ------------------- %@", output);
#endif
                        
                        
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
                                    
                                    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                    
                                    if( [ircCommand isEqualToString:@"321"] ) //    IRC RPL_LISTSTART
                                    {
                                        appDelegate.memoList = [NSMutableArray array];
                                    }
                                    else if( [ircCommand isEqualToString:@"323"] ) //    IRC RPL_LISTEND
                                    {
                                        if( appDelegate.memoView )
                                            [appDelegate.memoView reloadTable];
                                    }
                                    else if( [target isEqualToString: @"#pesterchum"] )
                                    {
                                        if( parts.count > 3 )
                                        {
                                            NSString *message = [parts objectAtIndex:3];
                                            
                                            if( [message hasPrefix:@":MOOD"] )
                                            {
                                                int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                                
                                                if( chumIndex != NSNotFound )
                                                {
                                                    [appDelegate.chumroll.chumMoods setValue:[NSNumber numberWithInt:1] forKey:chumhandle];
                                                    [appDelegate.chumroll reloadTable];
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
                                        Chat *theChat = [appDelegate.chatList valueForKey:chumhandle];
                                        
                                        
                                        if( parts.count > 3 )
                                        {
                                            NSString *message = [parts objectAtIndex:3];
                                            
                                            if( [ircCommand isEqualToString:@"322"] ) //    IRC RPL_LIST
                                            {
                                                [appDelegate.memoList addObject:[message substringFromIndex:1]];
                                            }
                                            else if( [ircCommand isEqualToString:@"353"] ) //      MEMO USERLIST BEGIN
                                            {
                                                // Example: :irc6.mindfang.org 353 iosBot = #iOS_TestArena :iosBot @volatileSchematic
                                                
                                                if( parts.count > 5 )
                                                {
                                                    Chat *memo = [appDelegate.chatList valueForKey:[parts objectAtIndex:4]];
                                                    if( memo )
                                                    {
                                                        NSString *nameLine = [line substringFromIndex:[line rangeOfString:[parts objectAtIndex:5]].location];
                                                        NSArray *names = [nameLine componentsSeparatedByString:@" "];
                                                        for( NSString *name in names )
                                                        {
                                                            NSString *newName = name;
                                                            if( [name length] > 1 )
                                                            {
                                                                if( [name hasPrefix:@":"] || [name hasPrefix:@"@"] )
                                                                    newName = [name substringFromIndex:1];
                                                                [memo addChum:newName withMood:0];
                                                                NSLog( @"\n\n\n\n\n\n\n\t\tGot here!!! (%@)\n\n\n\n\n\n\n", newName );
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            else if( [ircCommand isEqualToString: @"PRIVMSG"] )
                                            {
                                                if( [message hasPrefix:@":PESTERCHUM:"] )
                                                {
                                                    if( theChat && [message hasPrefix:@":PESTERCHUM:CEASE"] )
                                                    {
                                                        // get current date/time
                                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                        // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                                        [dateFormatter setDateFormat:@"H:mm"];
                                                        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                                        
                                                        display = [NSString stringWithFormat:@"<c=100,100,100>-- %@ <c=%@>[%@]</c> ceased pestering %@ <c=%@>[%@]</c> at %@ --</c>", chumhandle, theChat.chatColor, [IRCConnection getInitials:chumhandle withTime:nil],
                                                                   myHandle, appDelegate.myColor, myInitials, currentTime ];
                                                        theChat.isOpen = false;
                                                        [theChat removeChum:chumhandle];
                                                    }
                                                    if( [message hasPrefix:@":PESTERCHUM:BEGIN"] )
                                                    {
                                                        // get current date/time
                                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                        // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                                        [dateFormatter setDateFormat:@"H:mm"];
                                                        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                                        
                                                        display = [NSString stringWithFormat:@"<c=100,100,100>-- %@ <c=%@>[%@]</c> began pestering %@ <c=%@>[%@]</c> at %@ --</c>", chumhandle, theChat.chatColor, [IRCConnection getInitials:chumhandle withTime:nil],
                                                                   myHandle, appDelegate.myColor, myInitials, currentTime ];
                                                        
                                                        if( !theChat )
                                                        {
                                                            [appDelegate.chatList setValue:[[Chat alloc] initWithName:chumhandle] forKey:chumhandle];
                                                            theChat = [appDelegate.chatList valueForKey:chumhandle];
                                                        }
                                                        
                                                        theChat.isOpen = true;
                                                        [self sendMsg:[NSString stringWithFormat:@"COLOR >%@", appDelegate.myColor] to:chumhandle];
                                                    }
                                                    else if( [message hasPrefix:@":PESTERCHUM:TIME>"] )
                                                    {
                                                        if( ![target isEqualToString:myHandle] )
                                                            theChat = [appDelegate.chatList valueForKey:target];
                                                        if( theChat )
                                                        {
                                                            NSLog( @"\n\n\n!!!!!!!!!!!!\n Time adjusted! \n!!!!!!!!!!!!!\n\n\n" );
                                                            if( [message isEqualToString:@":PESTERCHUM:TIME>i\n"] )
                                                                [theChat setTime:@"0000" forChum:chumhandle];
                                                            else
                                                            {
                                                                NSString *timeString = [[message substringFromIndex:[message rangeOfString:@">"].location+1] stringByReplacingOccurrencesOfString:@":" withString:@""];
                                                                NSString *chumTime = [[timeString substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                                NSLog( @"\n\nTimeString: %@ - Time: %@\n\n   Replacing: %@", timeString, chumTime, [theChat.chatTimeList valueForKey:chumhandle] );
                                                                if( [timeString characterAtIndex:0] == 'P' )
                                                                    chumTime = [@"-" stringByAppendingString:chumTime];
                                                                [theChat setTime:chumTime forChum:chumhandle];
                                                                NSLog( @"\n\nTime for %@ is now: %@\n\n", chumhandle, [theChat.chatTimeList valueForKey:chumhandle] );
                                                            }
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if( ![target isEqualToString:myHandle] )
                                                        theChat = [appDelegate.chatList valueForKey:target];
                                                    
                                                    if( theChat )
                                                    {
                                                        if( [message hasPrefix:@":COLOR"] && parts.count > 4 && [[parts objectAtIndex:4] hasPrefix:@">"] )
                                                        {
                                                            theChat.chatColor = [[parts objectAtIndex:4] substringFromIndex:1];
                                                        }
                                                        else
                                                        {
                                                            if( !theChat.isMemo )
                                                            {
                                                                // get current date/time
                                                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                                // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                                                [dateFormatter setDateFormat:@"hh:mm"];
                                                                NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                                                
                                                                NSString *prefix = [NSString stringWithFormat:@"<c=%@>%@: ", theChat.chatColor, [IRCConnection getInitials:chumhandle withTime:nil]];
                                                                NSString *suffix = @"</c>";
                                                                display = [NSString stringWithFormat:@"[%@] %@%@%@", currentTime, prefix,[[line substringFromIndex:[line rangeOfString:[parts objectAtIndex:3]].location] substringFromIndex:1], suffix];
                                                            }
                                                            else
                                                            {
                                                                display = [[line substringFromIndex:[line rangeOfString:[parts objectAtIndex:3]].location] substringFromIndex:1];
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if( [ircCommand isEqualToString: @"QUIT"] || [ircCommand isEqualToString:@"NICK"] )
                                        {
                                            //display = [NSString stringWithFormat:@"%@ has logged off!", chumhandle];
                                            
                                            // get current date/time
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                                            [dateFormatter setDateFormat:@"H:mm"];
                                            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
                                            
                                            for( NSString *key in [appDelegate.chatList allKeys] )
                                            {
                                                Chat *currentChat = (Chat *)[appDelegate.chatList valueForKey:key];
                                                if( [currentChat hasChum:chumhandle] )
                                                {
                                                    [currentChat removeChum:chumhandle];
                                                    if( currentChat.isMemo )
                                                    {
                                                        NSString *initials = [IRCConnection getInitials:chumhandle withTime:[NSNumber numberWithInt:[[currentChat.chatTimeList valueForKey:chumhandle] integerValue]]];
                                                        NSString *when;
                                                        switch ([initials characterAtIndex:0])
                                                        {
                                                            case 'P':
                                                                when = @"PAST";
                                                                break;
                                                            case 'C':
                                                                when = @"CURRENT";
                                                                break;
                                                            case 'F':
                                                                when = @"FUTURE";
                                                                break;
                                                        }
                                                        [currentChat printToChat:[NSString stringWithFormat:@"<c=100,100,100>-- %@ %@ [%@] ceased responding to memo at %@ --</c>", when, chumhandle, initials, currentTime] fromChum:chumhandle];
                                                    }
                                                    else
                                                        [currentChat printToChat:[NSString stringWithFormat:@"<c=100,100,100>-- %@ <c=%@>[%@]</c> set their mood to OFFLINE --</c>", chumhandle, currentChat.chatColor,
                                                                                  [IRCConnection getInitials:chumhandle withTime:nil]] fromChum:chumhandle];
                                                }
                                            }
                                            
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
                                        else if( display != @"" && theChat )
                                        {
                                            [theChat printToChat:display fromChum:chumhandle];
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
                [self dataSending:@"PASS PesterphoneAlpha\n"];
                [self dataSending:[NSString stringWithFormat:@"NICK %@\n", myHandle]];
                [self dataSending:[NSString stringWithFormat:@"USER %@ host Pesterphone :Pesterclient99\n", myHandle]];
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
        PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
        Chat *theChat = [appDelegate.chatList valueForKey:target];
        NSString *out = line;
        
        if( ![line hasPrefix:@"PESTERCHUM:"] && ![line hasPrefix:@"MOOD >"] && ![line hasPrefix:@"COLOR >"] && ![line hasPrefix:@"GETMOOD"] )
        {
            // get current date/time
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
            
            if( theChat.isMemo )
            {
                out = [NSString stringWithFormat:@"<c=%@>%@: %@</c>", appDelegate.myColor, myInitials, out];
                [theChat printToChat:out fromChum:myHandle];
            }
            else
            {
                out = [NSString stringWithFormat:@"<c=%@>%@</c>", appDelegate.myColor, out];
                [theChat printToChat:[NSString stringWithFormat:@"[%@] <c=%@>%@: %@</c>", currentTime, appDelegate.myColor, myInitials, out] fromChum:myHandle];
            }
            
        }
        
        out = [NSString stringWithFormat:@"PRIVMSG %@ :%@\n",target, out];
        [self dataSending:out];
        
#ifdef DEBUG
        NSLog(@"Sending-----------\"%@\"", out);
#endif
    }
}

- (void) setHandle:(NSString *)name
{
    myHandle = name;
    myInitials = [IRCConnection getInitials:name withTime:nil];
}

- (NSString*) initials
{
    return myInitials;
}

- (NSString*) handle
{
    return myHandle;
}

+ (NSString*) getInitials:(NSString*) name withTime:(NSNumber*)chumTime
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
    
    if( chumTime != nil )
    {
        int outTime = [chumTime intValue];
        
        if( outTime == 0 )
            return [@"C" stringByAppendingString:out];
        if( outTime < 0 )
            return [@"P" stringByAppendingString:out];
        if( outTime > 0 )
            return [@"F" stringByAppendingString:out];
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
