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

//-(void)setClassInLayerModulesFolder:(NSString *)folder{
//    classInLayerModulesFolder=folder;
//}
//-(void) setCtx2AdptMapFolder:(NSString*)folder{
//    ctx2AdptMapFolder=folder;
//}
//
//-(NSString*)CILFolder{
//    return classInLayerModulesFolder;
//}
//
//- (id)init {
//    adaptations=[NSMutableDictionary new];
//    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//    classInLayerModulesFolder = [resourcePath stringByAppendingPathComponent:@"CILBundles"];
//    ctx2AdptMapFolder = [resourcePath stringByAppendingPathComponent:@"C2AMap"];
//    if (self = [super init]) {
//        adaptationKeys=[[NSMutableArray alloc] init];
//        loadedAdaptations=[[NSMutableArray alloc] init];
//        [AdaptationManager initializeFolders];
//        [AdaptationManager readMappingFile];
//
//
//
//    }
//    return self;
//}
//
//+(void)initializeFolders{
//    NSString * cilPath = classInLayerModulesFolder;
//    NSString * c2aPath = ctx2AdptMapFolder;
//    NSError * error;
//    //Create C2A path if not exists
//    if (![[NSFileManager defaultManager] fileExistsAtPath:c2aPath])
//    {
//        if (![[NSFileManager defaultManager] createDirectoryAtPath:c2aPath
//                                       withIntermediateDirectories:NO
//                                                        attributes:nil
//                                                             error:&error])
//        {
//            NSLog(@"\n\nCreate directory error: %@\n\n", error);
//        }else{
//            //Create c2afile
//            NSData *file;
//            NSString* data=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict></dict></plist>";
//            file =[data dataUsingEncoding:NSUTF8StringEncoding];
//            NSString* filePath=[c2aPath stringByAppendingPathComponent:kModelFileName];
//            [[NSFileManager defaultManager] createFileAtPath:filePath
//                                                    contents:file
//                                                  attributes:nil];
//            NSLog(@"Created File at:\n%@",filePath);
//        }
//    }
//    //--
//    //Create CIL path if not exists
//    if (![[NSFileManager defaultManager] fileExistsAtPath:cilPath])
//    {
//        if (![[NSFileManager defaultManager] createDirectoryAtPath:cilPath
//                                       withIntermediateDirectories:NO
//                                                        attributes:nil
//                                                             error:&error])
//        {
//            NSLog(@"\n\nCreate directory error: %@\n\n", error);
//        }else{
//        }
//    }
//    //--
//}
//
//
//
//-(NSArray*)getCILAdaptations{
//    NSMutableArray* adpts=[NSMutableArray new];
//    for (NSString* adptK in adaptations.allKeys) {
//        Adaptation* adpt=adaptations[adptK];
//        if (adpt.bhvrLocal[@"BundleFile"]) {
//            [adpts addObject:adpt];
//        }
//    }
//    return adpts;
//}
//
//-(NSArray*)getLICAdaptations{
//    NSMutableArray* adpts=[NSMutableArray new];
//    for (NSString* adptK in adaptations.allKeys) {
//        Adaptation* adpt=adaptations[adptK];
//        if (!adpt.bhvrLocal[@"BundleFile"]) {
//            [adpts addObject:adpt];
//        }
//    }
//    return adpts;
//}
//
//-(IMP)getCILMethodImplementationFromBundle:(NSString*)b inClass:(NSString*)c inMethod:(NSString*)m{
//    //NSString* bundleName=b;
//    NSString *fullPath=[classInLayerModulesFolder stringByAppendingPathComponent:b];
//    NSBundle *bundle;
//    bundle = [NSBundle bundleWithPath:fullPath];
//    [bundle load];
//    //Loading class
//    Class bundledClass;
//    id instance;
//    bundledClass = [bundle principalClass];
//    instance = [[bundledClass alloc] init];
//    Method met=class_getInstanceMethod(bundledClass, NSSelectorFromString(m));
//    return method_getImplementation(met);
//}
//
//
//
//
////------------------------------------------------------------------------------
//
//+(void)readMappingFile{
//    NSString* c2aMapPath=[ctx2AdptMapFolder stringByAppendingPathComponent:kModelFileName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:c2aMapPath])
//    {
//        NSLog(@"Did not find Ctx 2 Adpt Map file");
//    }else{
//        rawC2AMap = [NSDictionary dictionaryWithContentsOfFile:c2aMapPath];
//        NSLog(@"Loading C2AMap...");
//        //NSMutableDictionary* adaptationsInFile=[[NSMutableDictionary alloc] init];
//        Adaptation* a;
//        c2AMap=[NSDictionary new];
//        for (NSString* adptKey in rawC2AMap.allKeys) {
//            //Adaptation json:
//            NSDictionary* rawAdpt=rawC2AMap[adptKey];
//            a=[Adaptation adaptationFromJSONData:rawAdpt];
//            [[AdaptationManager manager] addAdaptation:a];
//        }
//        NSLog(@"Finished loading C2AMap.");
//    }
//}
//
//-(void)addAdaptation:(Adaptation *)a{
//    [loadedAdaptations addObject:a];
//    [adaptationKeys addObject:[a adptId]];
//}
//
//
//-(NSArray*)activeAdaptationsOn:(LMContext*)ctx{
//    NSMutableArray* adaptations=[[NSMutableArray alloc] init];
//    for (Adaptation*a in activeAdaptations.allValues) {
//        if ([a isTrigeredBy:ctx]) {
//            [adaptations addObject:a];
//        }
//    }
//    return adaptations;
//}
//
//
//- (void)dealloc {
//}
@end
