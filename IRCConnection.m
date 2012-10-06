//
//  IRCConnection.m
//  Pesterchum
//
//  Created by Michael Colvin on 9/15/12.
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
            chatBox.text = @"Logging in...........";
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
                        NSLog(@"Received data--------------------%@", output);
                        
                        
                        if( !loggedIn )
                        {
                            NSString *chumString = [output substringToIndex:[output rangeOfString:@" "].location];
                            NSString *chumhandle = [[[chumString componentsSeparatedByString:@"!"] objectAtIndex:0] substringFromIndex:1];
                            
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
                                    chatBox.text = @"Logged in to Pesterchum.\n\n\n";
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
                                    NSString *chumhandle = @"";
                                    
                                    if( [chumString rangeOfString:@"!"].location != NSNotFound )
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
                                                if( [[[line substringFromIndex:[line rangeOfString:[parts objectAtIndex:4]].location] substringFromIndex:1] rangeOfString:myHandle].location != NSNotFound )
                                                    [self sendMsg:@"MOOD >0" to:@"#pesterchum"];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if( parts.count > 3 )
                                        {
                                            NSString *message = [parts objectAtIndex:3];
                                            
                                            if( [ircCommand isEqualToString: @"PRIVMSG"] && ![message hasPrefix:@":PESTERCHUM"] )
                                            {
                                                display = [NSString stringWithFormat:@"<%@>%@",chumhandle,[[line substringFromIndex:[line rangeOfString:[parts objectAtIndex:3]].location] substringFromIndex:1]];
                                            }
                                        }
                                        
                                        if( [ircCommand isEqualToString: @"QUIT"] )
                                        {
                                            display = [NSString stringWithFormat:@"%@ has logged off!", chumhandle];
                                            
                                            PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                            int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                            
                                            if( chumIndex != NSNotFound )
                                            {
                                                UITableViewCell *cell = [appDelegate.chumroll.chumTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:chumIndex inSection:0]];
                                                cell.textLabel.textColor = [UIColor darkGrayColor];
                                            }
                                        }
                                        
                                        if( [ircCommand isEqualToString: @"PART"] )
                                        {
                                            display = [NSString stringWithFormat:@"%@ has logged off!", chumhandle];
                                        }
                                        else if( [ircCommand isEqualToString: @"JOIN"] )
                                        {
                                            PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
                                            int chumIndex = [appDelegate.chumroll.chums indexOfObject:chumhandle];
                                            
                                            if( chumIndex != NSNotFound )
                                            {
                                                [self sendMsg:@"MOOD >0" to:@"#pesterchum"];
                                            }
                                            display = [NSString stringWithFormat:@"%@ has logged on!", chumhandle];
                                        }
                                        
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
        
        if( chatBox )
            [self printToChat:[NSString stringWithFormat:@"%@\n", msg]];
    }
}

- (void) printToChat:(NSString*)msg
{
    chatBox.text = [chatBox.text stringByAppendingString: msg];
    NSRange range = NSMakeRange(chatBox.text.length - 1, 1);
    [chatBox scrollRangeToVisible:range];
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

+ (NSString*) getInitials:(NSString*) name
{
    NSMutableString *out = [[[NSString stringWithFormat:@"%c", [name characterAtIndex:0]] uppercaseString] mutableCopy];
    int index = 1;
    
    while (index < name.length)
    {
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[name characterAtIndex:index]])
        {
            [out appendString:[NSString stringWithFormat:@"%c",[name characterAtIndex:index]]];
            break;
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
