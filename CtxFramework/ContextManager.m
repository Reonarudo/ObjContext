//
//  ContextManager.m
//  CtxFramework
//
//  Created by Leonardo Marques on 09.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import "ContextManager.h"

#import "TM.h"


//#import <objc/runtime.h>
//#import <objc/message.h>
//#import "LMContext.h"
#import "AdaptationManager.h"
//#import "Adaptation.h"
//#import "AdaptationPoint.h"

@interface ContextManager (){
    NSMutableDictionary* loadedContexts;
    NSMutableDictionary* c2AMapping;
    
}

@end


@implementation ContextManager

static NSMutableDictionary* cilAdptPoints;
static NSMutableDictionary* licAdptPoints;

static NSMutableDictionary* reverseSearchCILAdptPoints;
static NSMutableDictionary* reverseSearchLICAdptPoints;

static NSMutableDictionary* activeAppCtx;


//+ (ContextManager*)manager{
//    @synchronized(self) {
//        if (sharedMyManager == nil){
//            sharedMyManager = [[self alloc] init];
//            [sharedMyManager loadContextToAdaptaionFile];
//            [sharedMyManager applyPreActiveAdaptations];
//            [[ContextManager monitor] start];
//        }
//    }
//    return sharedMyManager;
//}

static ContextManager *sharedCManager;

+ (ContextManager*)managerWithFile:(NSString*)filename {
    
    @synchronized(self) {
        if (sharedCManager == nil){
            sharedCManager = [[self alloc] init];
            
                [sharedCManager setFileName:filename];
            
            [sharedCManager loadContextToAdaptaionFile];
            [sharedCManager applyPreActiveAdaptations];
            [[ContextMonitor sharedInstance] start];
        }else if(filename && ![filename isEqualToString:[sharedCManager fileName]]){
            [sharedCManager setFileName:filename];
            [sharedCManager reload];
        }
    }
    
    return sharedCManager;
}

+(ContextManager *)manager{
    return sharedCManager;
}


+ (NSNotificationCenter*)sharedNotificationCenter{
    return [[ContextMonitor sharedInstance] sharedNotificationCenter];
}


-(NSArray*)loadedContexts{
    return [loadedContexts allValues];
}

-(instancetype)init{
    if (self=[super init]) {
        loadedContexts=[[NSMutableDictionary alloc] init];
        c2AMapping=[[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)reload{
    loadedContexts=[[NSMutableDictionary alloc] init];
    c2AMapping=[[NSMutableDictionary alloc] init];
    [[AdaptationManager manager] reload];
    [self loadContextToAdaptaionFile];
    [self applyPreActiveAdaptations];
    [[ContextMonitor sharedInstance] start];
    
}

-(Cntxt*)context4Key:(NSString*)cK{
    return loadedContexts[cK];
}

- (void)loadContextToAdaptaionFile{
    NSDictionary* fileContent;
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* c2aMapPath=[resourcePath stringByAppendingPathComponent:[self fileName]?[self fileName]:kModelFileName];
    //assert([self fileName]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:c2aMapPath])
    {
        NSLog(@"Did not find Contex to Adaptation Map file at %@",c2aMapPath);
    }else{
        //NSLog(@"Loading %@", [self fileName]);
        fileContent = [NSDictionary dictionaryWithContentsOfFile:c2aMapPath];
        NSDictionary* rawContexts=fileContent[@"Contexts"];
        assert(rawContexts!=nil);
        NSDictionary* rawAdaptations=fileContent[@"Adaptations"];
        assert(rawAdaptations!=nil);
        //NSDictionary* rawMapping=fileContent[@"Mapping"];
        //assert(rawMapping!=nil);
        //NSLog(@"Loading Contex to Adaptation Map file...");
        Adaptation* a;
        for (NSString* adptKey in rawAdaptations.allKeys) {
            a=[Adaptation adaptationFromJSONData:rawAdaptations[adptKey]];
            [a setAdaptationKey:adptKey];
            [[AdaptationManager manager] add:a];
        }

        Cntxt* c;
        for (NSString* ctxKey in rawContexts.allKeys) {
            c=[Cntxt contextFromJSONData:rawContexts[ctxKey]];
            [c setContextKey:ctxKey];
            [self add:c];
            NSArray* adptKs=rawContexts[ctxKey][@"Adaptations"];
            [c2AMapping setValue:adptKs forKey:ctxKey];
        }

        [self buildContextModel];
        //NSLog(@"Finished loading Contex to Adaptation Map file.");
    }
}

- (void)buildContextModel{
    for (NSString* cK in c2AMapping.allKeys) {
        NSArray* adaptKs=c2AMapping[cK];
        for (NSString* aK in adaptKs) {
            [((Cntxt*)[loadedContexts objectForKey:cK]) add:aK];
            Adaptation* a=[[AdaptationManager manager] getAdaptationForKey:aK];
            [a add:cK];
        }
    }
}

- (void)applyPreActiveAdaptations{
    [[AdaptationManager manager] activatePreActivatedAdaptations];
}

- (void)activated:(Cntxt*)c{
    //TODO: check for parameters and if they correspond to true context activation
    CFTimeInterval tS=[TM time];
    for (NSString* aK in c2AMapping[c.contextKey]) {
        [[AdaptationManager manager] activate:aK];
    }
    CFTimeInterval tE=[TM time];
    if ([c2AMapping[c.contextKey] count]>1) {
        NSLog(@"Activated %@ adapataions in %@",@([c2AMapping[c.contextKey] count]), @(tE-tS));
    }
    
}
- (void)deactivated:(Cntxt*)c{
    //TODO: check for parameters and if they correspond to true context deactivation
    for (NSString* aK in c2AMapping[c.contextKey]) {
        [[AdaptationManager manager] contextDeactivatedForAdaptation:aK];
    }
}

- (void)add:(Cntxt *)c{
    if ([loadedContexts objectForKey:[c contextKey]]==nil) {
        [loadedContexts setObject:c forKey:c.contextKey];
    }else{
        NSLog(@"Warning: Already existing context %@", c.contextKey);
    }

}
/*
 - (id)init {

 cilAdptPoints=[NSMutableDictionary new];
 licAdptPoints=[NSMutableDictionary new];
 reverseSearchCILAdptPoints=[NSMutableDictionary new];
 reverseSearchLICAdptPoints=[NSMutableDictionary new];


 activeAppCtx=[NSMutableDictionary new];

 if (self = [super init]) {
 [Adaptation manager];

 NSArray* cilAdpts=[[Adaptation manager] getCILAdaptations];
 NSArray* licAdpts=[[Adaptation manager] getLICAdaptations];

 //Adaptation points initialization
 [self initializeAdaptationPoints:cilAdpts licAdpts:licAdpts];

 //Get and prepare relevant context states
 for (Adaptation* adpt in cilAdpts) {
 for (NSDictionary* appCtxType in adpt.appActvCtxStt) {
 if (appCtxType[@"MethodCall"]) {
 SEL originalSelector;
 Class originalClass=NSClassFromString(appCtxType[@"MethodCall"][@"Class"][@"Name"]);
 Method origM;
 BOOL instance=appCtxType[@"MethodCall"][@"Class"][@"InstanceMethod"];
 if (instance) {
 originalSelector = NSSelectorFromString(appCtxType[@"MethodCall"][@"Class"][@"InstanceMethod"]);
 origM=class_getInstanceMethod(originalClass, originalSelector);
 [self injectInstanceMethodListenerIn:originalSelector from:originalClass];
 }else{
 originalSelector = NSSelectorFromString(appCtxType[@"MethodCall"][@"Class"][@"ClassMethod"]);
 origM=class_getClassMethod(originalClass, originalSelector);
 [self injectClassMethodListenerIn:originalSelector from:originalClass];
 }
 LMContext* ctx=[[LMContext alloc] init];
 [ctx setComponents:@[NSStringFromSelector(originalSelector), NSStringFromClass(originalClass)]];

 [[LMContext monitor] addDependency:adpt toContextChange:ctx];


 }
 }
 }


 }
 return self;
 }

 -(instancetype)initWithC2AModelPath:(NSString*)path1 andAdaptationModulesPath:(NSString*)path2{
 //TODO: add implementation for this placeholder
 return self;
 }

 - (void)initializeAdaptationPoints:(NSArray *)cilAdpts licAdpts:(NSArray *)licAdpts {
 //CIL adaptation points initialization
 for (Adaptation* adpt in cilAdpts) {
 SEL originalSelector;
 Class originalClass;
 if (adpt.adptPoint[@"Class"][@"InstanceMethod"] || adpt.adptPoint[@"Class"][@"ClassMethod"]) {
 //adapt Point Method
 [self initializeReverseAdaptationPointsSearch:adpt];
 }else if(adpt.adptPoint[@"Class"]){
 //adapt Point Class
 //TODO: cil class adaptation points
 }
 }

 //LIC adaptation points initialization
 for (Adaptation* adpt in licAdpts) {
 SEL originalSelector;
 Class originalClass;
 if (adpt.adptPoint[@"Class"][@"InstanceMethod"] || adpt.adptPoint[@"Class"][@"ClassMethod"]) {
 //adapt Point Method
 [self initializeReverseAdaptationPointsSearch:adpt];
 }else if(adpt.adptPoint[@"Class"]){
 //adapt Point Class
 //TODO: lic class adaptation points
 }
 }
 }

 //initializes reverse search list betweeen Adaptations and Adaptation points
 - (void)initializeReverseAdaptationPointsSearch:(Adaptation *)adpt {
 SEL originalSelector;
 Class originalClass;
 Method origM;
 BOOL instance=adpt.adptPoint[@"Class"][@"InstanceMethod"];
 originalClass = NSClassFromString(adpt.adptPoint[@"Class"][@"Name"]);
 AdaptationPoint* adptPt=[AdaptationPoint new];
 if (instance) {
 originalSelector = NSSelectorFromString(adpt.adptPoint[@"Class"][@"InstanceMethod"]);
 origM=class_getInstanceMethod(originalClass, originalSelector);
 }else{
 originalSelector = NSSelectorFromString(adpt.adptPoint[@"Class"][@"ClassMethod"]);
 origM=class_getClassMethod(originalClass, originalSelector);
 }
 [adptPt setOriginalBehavior:method_getImplementation(origM)];
 [cilAdptPoints setObject:adptPt forKey:adpt.adptPoint];
 //TODO: check if Dictionaries are comparable
 if (adpt.bhvrLocal[@"BundleFile"]) {
 if ([reverseSearchCILAdptPoints objectForKey:adpt.adptPoint]) {
 NSMutableArray* adpts=[reverseSearchCILAdptPoints objectForKey:adpt.adptPoint];
 [adpts addObject:adpt];
 }else{
 [reverseSearchCILAdptPoints setObject:[[NSMutableArray alloc] initWithObjects:adpt, nil] forKey:adpt.adptPoint];
 }
 }else{
 if ([reverseSearchLICAdptPoints objectForKey:adpt.adptPoint]) {
 NSMutableArray* adpts=[reverseSearchLICAdptPoints objectForKey:adpt.adptPoint];
 [adpts addObject:adpt];
 [reverseSearchLICAdptPoints setObject:adpts forKey:adpt.adptPoint];
 }else{
 [reverseSearchLICAdptPoints setObject:[[NSMutableArray alloc] initWithObjects:adpt, nil] forKey:adpt.adptPoint];
 }
 }
 }

 -(void)methodCalledCallback:(SEL)calledMethod from:(Class)c{
 //TODO: update application context
 LMContext* ctx=[[LMContext alloc] initWithComponents:@[NSStringFromSelector(calledMethod),NSStringFromClass(c)]];
 if ([[LMContext monitor] isMonitoringAppCtx:ctx]) {
 for (Adaptation* adpt in [[LMContext monitor] adaptationsForContext:ctx]) {
 //TODO: check if context is valid
 NSDictionary* aB=adpt.bhvrLocal;
 IMP impl=[[AdaptationManager manager] getCILMethodImplementationFromBundle:aB[@"BundleFile"] inClass:aB[@"Class"][@"Name"] inMethod:aB[@"Class"][@"InstanceMethod"]];
 if (!impl) {
 NSLog(@"Warning no implementation was loaded for: %@/%@", aB[@"BundleFile" ], aB[@"Class"][@"Name"]);
 }
 Method m=class_getInstanceMethod(c, calledMethod);
 method_setImplementation(m, impl);
 }
 }

 }

 -(void)methodFinishedCallback:(SEL)calledMethod from:(Class)c{
 //TODO: check if adaptation is needed before calling the method
 }



 - (void) setClassInLayerModulesFolder:(NSString*)folder{
 [AdaptationManager setClassInLayerModulesFolder:folder];
 }

 - (void) setCtx2AdptMapFolder:(NSString*)folder{
 [AdaptationManager setCtx2AdptMapFolder:folder];
 }


 -(void)activateContext:(NSString *)ctxId{

 }

 -(void)deactivateContext:(NSString *)ctxId{
 }


 - (void)dealloc {
 }
 */
@end
