//
//  ContextManager.h
//  CtxFramework
//
//  Created by Leonardo Marques on 09.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cntxt.h"
#import "ContextMonitor.h"

static NSString* const kModelFileName = @"c2amm.plist";

@interface ContextManager : NSObject

@property NSString* fileName;

+ (ContextManager*)manager;
+ (ContextManager*)managerWithFile:(NSString*)filename;
//+ (ContextMonitor*)monitor;
+ (NSNotificationCenter*)sharedNotificationCenter;

- (void)reload;
- (void)loadContextToAdaptaionFile;
- (void)buildContextModel;
- (void)applyPreActiveAdaptations;
- (void)activated:(Cntxt*)c;
- (void)deactivated:(Cntxt*)c;
- (void)add:(Cntxt*)c;
- (Cntxt*)context4Key:(NSString*)cK;
-( NSArray*)loadedContexts;
//-(NSArray*)applicationContexts;
//-(NSArray*)environmentContexts;

@end
