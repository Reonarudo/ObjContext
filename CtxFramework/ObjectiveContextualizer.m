//
//  ObjectiveContextualizer.m
//  CtxFramework
//
//  Created by Leonardo Marques on 20.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import "ObjectiveContextualizer.h"
#import "ContextManager.h"
#import "AdaptationManager.h"

@interface ObjectiveContextualizer (){

    ContextManager* manager;
    AdaptationManager* adptManager;
}



@end

@implementation ObjectiveContextualizer

static ObjectiveContextualizer *sharedMyManager = nil;

+ (ObjectiveContextualizer*)contextualize {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (ObjectiveContextualizer*)contextualizeWithFile:(NSString*)fileName{
    @synchronized(self) {
        if (sharedMyManager==nil) {
            sharedMyManager = [[self alloc] initWithFile:fileName];
        }else{
            [sharedMyManager reloadWithFile:fileName];
        }
        
    }
    return sharedMyManager;
}

-(void)reloadWithFile:(NSString*)fN{
    manager=[ContextManager managerWithFile:fN];
}

-(instancetype)initWithFile:(NSString*)fN{
    if (self=[super init]) {
        if (![manager.fileName isEqualToString:fN] && !manager.fileName) {
            manager=[ContextManager managerWithFile:fN];
            adptManager=[AdaptationManager manager];
        }
        
        
    }
    return self;
}

-(instancetype)init{
    if (self=[super init]) {
        manager=[ContextManager managerWithFile:nil];
        adptManager=[AdaptationManager manager];
        [manager reload];
    }
    return self;
}

-(void)apply:(NSString*)adaptationKey{
    [adptManager activate:adaptationKey];
}

-(void)remove:(NSString*)adaptationKey{
    [adptManager deactivate:adaptationKey];
}

@end
