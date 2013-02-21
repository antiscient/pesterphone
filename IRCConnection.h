//
//  IRCConnection.h
//  Pesterchum
//
//  Created by Antiscient on 9/15/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatViewController;
@interface IRCConnection : NSObject <NSStreamDelegate>
{
    NSInputStream * inputStream;
    NSOutputStream * outputStream;
    
    Boolean loggedIn;
    Boolean loggingIn;
    
    NSString *myHandle;
    NSString *myInitials;
}

- (void) startWithURL:(NSString*) urlStr;
- (void) dataSending:(NSString*)data;
- (void) sendMsg:(NSString*)msg to:(NSString*)target;
- (void) setHandle:(NSString*)name;
- (NSString*) handle;
- (NSString*) initials;

+ (NSString*) getInitials:(NSString*)name withTime:(NSNumber*)time;

@end
