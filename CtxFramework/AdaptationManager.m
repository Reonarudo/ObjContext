//
//  AdaptationModuleManager.m
//  CtxFramework
//
//  Created by Leonardo Marques on 02.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "AdaptationManager.h"


@interface AdaptationManager (){
    NSMutableDictionary* loadedAdaptations;
    NSMutableDictionary* adaptationKeyForPath;
    NSMutableArray* startUpAdapts;
}

@end

@implementation AdaptationManager
//@synthesize activeAdaptations;
//
//
//static NSString* classInLayerModulesFolder;
//static NSString* ctx2AdptMapFolder;
//static NSDictionary* rawC2AMap;
//static NSDictionary* c2AMap;

//static NSMutableDictionary* adaptations;

static AdaptationManager *sharedMyManager = nil;

+ (AdaptationManager*)manager {


    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(instancetype)init{
    if (self=[super init]) {
        loadedAdaptations=[[NSMutableDictionary alloc] init];
        adaptationKeyForPath=[[NSMutableDictionary alloc] init];
        startUpAdapts=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)reload{
    loadedAdaptations=[[NSMutableDictionary alloc] init];
    adaptationKeyForPath=[[NSMutableDictionary alloc] init];
    startUpAdapts=[[NSMutableArray alloc] init];
}

-(void)activate:(NSString*)aK{
    Adaptation* adpt=loadedAdaptations[aK];
    assert(adpt);
    //check activation limite for number of adaptations activation delimited adaptations
    if ([adpt delimitationOfContextActivation].intValue==1) {
        NSNumber* limit=[adpt delimitationOfContextActivationDetail];
        if (limit.integerValue>[adpt adaptationActivationCount].integerValue) {
            return;
        }
    }
    //set up timer for time delimited adaptations
    if ([adpt delimitationOfContextActivation].intValue==2) {
        NSNumber* time=[adpt delimitationOfContextActivationDetail];
//TODO: check if this is an acceptable implementation of independent timers
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, time.integerValue, NSEC_PER_USEC);
        dispatch_source_set_event_handler(timer, ^{
            [self deactivate:aK];
            dispatch_source_cancel(timer);
        });

        // Start the timer
        dispatch_resume(timer);
    }

    NSInteger i=[adpt adaptationActivationCount].integerValue;

    [adpt activate];
    NSInteger ii=[adpt adaptationActivationCount].integerValue;
    assert(ii==i+1);
}

-(void)deactivate:(NSString*)aK{
}

-(void)add:(Adaptation*)a{
    NSString* aK=[a adaptationKey];
    NSString* path=[a rawData][@"DelimitationScope"][@"Target"];
    if ([loadedAdaptations objectForKey:aK]==nil) {
        [loadedAdaptations setObject:a forKey:aK];
        [self addAdaptationKey:aK ForPath:path];
    }else{
        NSLog(@"Warning: Already loaded adaptation %@", aK);
        [self addAdaptationKey:aK ForPath:path];
    }

}

-(void)addAdaptationKey:(NSString*) aK ForPath:(NSString*)path{
    if ([adaptationKeyForPath objectForKey:path]) {
        NSMutableArray* arr=[NSMutableArray arrayWithArray:[adaptationKeyForPath objectForKey:path]];
        [arr addObject:aK];
        [adaptationKeyForPath setObject:arr forKey:path];
    }else{
        [adaptationKeyForPath setObject:@[aK] forKey:path];
    }
}

-(void)activatePreActivatedAdaptations{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //To assure they are activated respecting their priority
        NSArray *sortedAdpts = [[loadedAdaptations allValues] sortedArrayUsingSelector:@selector(adaptationPriorityCompareWith:)];
        for (Adaptation*a in sortedAdpts) {
            if ([a preload]) {
                [self activate:a.adaptationKey];
            }
        }
    });
}



-(Adaptation*)getAdaptationForKey:(NSString*)aK{
    return [loadedAdaptations objectForKey:aK];
}

-(NSArray*)getAdaptationsForPath:(NSString*)path{
    NSMutableArray*adapts=[[NSMutableArray alloc] init];
    for (NSString* aK in [adaptationKeyForPath objectForKey:path]) {
        [adapts addObject:[loadedAdaptations objectForKey:aK]];
    }
    return adapts;
}

-(void)contextDeactivatedForAdaptation:(NSString*)aK{
    if ([[loadedAdaptations objectForKey:aK] delimitationOfContextActivation].intValue==3) {
        [self deactivate:aK];
    }
}


@end
