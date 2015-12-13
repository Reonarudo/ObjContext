    //
//  Adaptation.m
//
//
//  Created by Leonardo Marques on 02.09.15.
//
//

#import "Adaptation.h"

#import "BehaviorClass.h"
#import "BehaviorMethod.h"
#import "AdaptationManager.h"
#import <objc/runtime.h>
#import "TM.h"

@interface Adaptation (){
    //    NSNumber* activationTime;
    //
    NSMutableArray* contexts;

    NSNumber* nActiveContexts;
    //
    //    CodeLocation* adaptationPoint;
    //
    IMP __originalMethod_Imp;
    //
    //    NSNumber* delimitationConfinement;
    //
    //    CodeLocation* instanceGetterLocation;
    //
    //    NSNumber* behaviorBindingTime;
    //
    //    NSNumber* delimitationOdContextActivation;
    //
    //    NSNumber* adaptationModularity;
    //
    //    NSNumber* adaptationComposition;
}

@end

@implementation Adaptation

-(instancetype)init{
    if (self=[super init]) {
        nActiveContexts=@0;
    }
    return self;
}

+ (AdaptationManager*)manager {
    static AdaptationManager *sharedMyManager = nil;


    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+(void)setClassInLayerModulesFolder:(NSString *)folder{
    //    [[AdaptationManager manager] setClassInLayerModulesFolder:folder];
}
+ (void) setCtx2AdptMapFolder:(NSString*)folder{
    //    [[AdaptationManager manager] setCtx2AdptMapFolder:folder];
}

+(Adaptation*)adaptationFromJSONData:(NSDictionary*)data{
    Adaptation* adpt=[[Adaptation alloc] init];
    [adpt setRawData:data];
    NSDictionary* rawAdaptation=data;
    //[adpt setContextKey:rawAdaptation[@"ContextKey"][@"Value"]];
    [adpt setDelimitationScopeType:rawAdaptation[@"DelimitationScope"][@"Type"]];
    assert([adpt delimitationScopeType]!=nil);
    switch ([adpt delimitationScopeType].intValue) {
        case 0:{
            NSString* path=rawAdaptation[@"DelimitationScope"][@"Target"];
            NSString* className=[path pathComponents][0];
            assert(className!=nil);
            Class c=NSClassFromString(className);
            BehaviorClass* b=[[BehaviorClass alloc] init];
            [b setBehavior:c];
            [adpt setDelimitationScope:b];
        }break;
        case 2:{
            NSString* target=rawAdaptation[@"DelimitationScope"][@"Target"];
            NSString* className=[target pathComponents][0];
            assert(className!=nil);
            Class c=NSClassFromString(className);
            assert(c!=nil);
            NSString* methodName=[target pathComponents][1];
            assert(methodName!=nil);
            SEL s=NSSelectorFromString(methodName);
            Method m=class_getInstanceMethod(c, s);
            IMP imp= method_getImplementation(m);
            assert(imp!=nil);
            assert(m!=nil);
            BehaviorMethod* b=[[BehaviorMethod alloc] init];
            [b setBehavior:[NSValue valueWithPointer:m]];
            [b setClass:c];
            [adpt setDelimitationScope:b];
        }break;
            //TODO: case 2 & 3
        default:
            break;
    }

    [adpt setAdaptationModularityType:rawAdaptation[@"Modularity"][@"Type"]];
    if ([adpt adaptationModularityType].intValue==0) {
        [adpt setBehaviorContainer:rawAdaptation[@"Modularity"][@"BehaviorContainer"]];
        //From Bundle
        NSString* path=rawAdaptation[@"Modularity"][@"BehaviorLocation"];
        NSInteger depth=[[path pathComponents] count];
        assert(depth>=1);
        switch (depth) {
            case 1:
            {
                //Load class from bundle
                //-(IMP)getCILMethodImplementationFromBundle:(NSString*)b inClass:(NSString*)c inMethod:(NSString*)m{
                NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
                NSString * classInLayerModulesFolder = [resourcePath stringByAppendingPathComponent:@"CILBundles"];
                NSString* bundleName=[adpt behaviorContainer];
                NSString *fullPath=[classInLayerModulesFolder stringByAppendingPathComponent:bundleName];
                NSBundle *bundle;
                bundle = [NSBundle bundleWithPath:fullPath];
                [bundle load];
                //Loading class
                Class bundledClass;
                //id instance;
                bundledClass = [bundle principalClass];
                assert(bundledClass!=nil);
                BehaviorClass* b=[[BehaviorClass alloc] init];
                [b setBehavior:bundledClass];
                [adpt setNBehavior:b];


            }
                break;
            case 2:
            {
                //Load method from bundle
                NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
                NSString * classInLayerModulesFolder = resourcePath;//[resourcePath stringByAppendingPathComponent:@"CILBundles"];
                NSString* bundleName=[adpt behaviorContainer];
                NSString *fullPath=[classInLayerModulesFolder stringByAppendingPathComponent:bundleName];
                NSBundle *bundle;
                bundle = [NSBundle bundleWithPath:fullPath];
                NSError* error;
                [bundle loadAndReturnError:&error];
                //Loading class
                Class bundledClass;
                id instance;
                bundledClass = [bundle principalClass];
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                assert(bundledClass!=nil);
                instance = [[bundledClass alloc] init];
                Method met=class_getInstanceMethod(bundledClass, NSSelectorFromString([path pathComponents][1]));
                assert(met!=nil);
                BehaviorMethod* b=[[BehaviorMethod alloc] init];
                [b setBehavior:[NSValue valueWithPointer:met]];
                [adpt setNBehavior:b];
            }
                break;
            default:
                break;
        }
    }else{
        //TODO: from existing Class
        NSString* path=rawAdaptation[@"Modularity"][@"BehaviorLocation"];
        NSInteger depth=[[path pathComponents] count];
        assert(depth>=1);
        switch (depth) {
            case 1:
            {
                //Loading class
                Class existingClass;
                //id instance;
                existingClass = NSClassFromString([path pathComponents][0]);
                assert(existingClass!=nil);
                BehaviorClass* b=[[BehaviorClass alloc] init];
                [b setBehavior:existingClass];
                [adpt setNBehavior:b];
            }
                break;
            case 2:
            {
                //Loading class
                Class existingClass;
                id instance;
                existingClass = NSClassFromString([path pathComponents][0]);
                assert(existingClass!=nil);
                instance = [[existingClass alloc] init];
                Method met=class_getInstanceMethod(existingClass, NSSelectorFromString([path pathComponents][1]));
                assert(met!=nil);
                BehaviorMethod* b=[[BehaviorMethod alloc] init];
                [b setBehavior:[NSValue valueWithPointer:met]];
                [adpt setNBehavior:b];
            }
                break;
            default:
                break;
        }
    }

    [adpt setAdaptationDefinitionType:rawAdaptation[@"Definition"][@"Type"]];
    [adpt setAdaptationActivationCount:rawAdaptation[@"Definition"][@"ActCount"]];
    [adpt setDelimitationOfContextActivation:rawAdaptation[@"ContextActivationDelimitation"][@"Type"]];
    if ([adpt delimitationOfContextActivation].intValue!=0 && [adpt delimitationOfContextActivation].intValue!=3) {
        [adpt setDelimitationOfContextActivationDetail:rawAdaptation[@"ContextActivationDelimitation"][@"Detail"]];
    }
    [adpt setBehaviorBindingTime:rawAdaptation[@"BehaviorBindingTime"]];
    [adpt setAdaptationComposition:rawAdaptation[@"Composition"]];

    [adpt setPriority:rawAdaptation[@"Priority"]];


    assert(adpt!=nil);
    return adpt;
}


-(void)add:(NSString *)cK{
    [contexts addObject:cK];
}

-(BOOL)preload{
    BOOL shouldPreload = NO;
    if ([self delimitationOfContextActivation].intValue==0) {
        if ([self adaptationActivationCount].intValue>0) {
            shouldPreload = YES;
        }
    }
    return shouldPreload;
}

- (NSComparisonResult)adaptationPriorityCompareWith:(Adaptation *)a2{
    return
    self.priority.intValue<a2.priority.intValue?
    NSOrderedAscending
    :
    self.priority.intValue==a2.priority.intValue?
    self.adaptationActivationTime.intValue<a2.adaptationActivationTime.intValue?
    NSOrderedAscending
    :
    self.adaptationActivationTime.intValue==a2.adaptationActivationTime.intValue?
    NSOrderedSame
    :
    NSOrderedDescending
    :
    NSOrderedDescending;
}

-(void)activate{
    //NSLog(@"Started %@ behavior injection",self);
    if (nActiveContexts.integerValue==0) {
        //Activate
        switch ([self delimitationScopeType].intValue) {
            case 2:{
                BehaviorMethod* b=[self delimitationScope];
                Class c=[b getClass];
                Method m=((NSValue*)[b getBehavior]).pointerValue;
                [self adaptInstanceMethodImplementation:method_getName(m) fromClass:c at:[self adaptationComposition]];
            }break;
                
            default:
                break;
        }
    }
    nActiveContexts=@([nActiveContexts integerValue]+1);
    [self setAdaptationActivationCount:@([self adaptationActivationCount].integerValue+1)];
    //NSLog(@"Finished %@ behavior injection",self);
}

-(void)deactivate{
    //TODO:
    if (nActiveContexts.integerValue>0) {
        nActiveContexts=@([nActiveContexts integerValue]-1);

    }else{
        //should not be able to deactivate more times than it activated
    }
    if (nActiveContexts==0) {
        //restore original behavior
        BehaviorMethod* b=[self delimitationScope];
        Class c=[b getClass];
        Method m=((NSValue*)[b getBehavior]).pointerValue;
        Method mm=class_getInstanceMethod(c, method_getName(m));
        method_setImplementation(mm, __originalMethod_Imp);
    }

}

-(void)adaptClassImplementation:(Class) c{
    //TODO:
    //get class methods list
    //adapt all
    //get instance methods list
    //adapt all
}



-(void)adaptInstanceMethodImplementation:(SEL)s fromClass:(Class)c at:(NSNumber*)adaptComp{
    //Method m=class_getInstanceMethod(c, s);
    //NSLog(@"Adapting :%s", sel_getName(s));
    Method nm=[((NSValue*)[[self nBehavior] getBehavior]) pointerValue];
    Method m=class_getInstanceMethod(c, s);
    IMP newImpl;
    switch (adaptComp.intValue) {
        case 0:{
            //NSLog(@"By replacing its implementation");
            //NSLog(@"With :%s",sel_getName(method_getName(nm)));
            newImpl=(IMP)_replace_Method_behavior;
            __originalMethod_Imp=method_setImplementation(m, newImpl);
        }break;
        case 1:{
            //NSLog(@"By starting its implementation");
            //NSLog(@"With :%s",sel_getName(method_getName(nm)));
            newImpl=(IMP)_add_Method_behavior_beginning;
            __originalMethod_Imp=method_setImplementation(m, newImpl);
        }break;
        case 2:{
            //NSLog(@"By finishing its implementation");
            //NSLog(@"With :%s",sel_getName(method_getName(nm)));
            newImpl=(IMP)_add_Method_behavior_end;
            class_swizzleMethodAndStore(c, s, newImpl, &__originalMethod_Imp);
            //__originalMethod_Imp=method_setImplementation(m, newImpl);
        }break;
        default:
            break;
    }
    //originalBehavior=__original_Method_Imp;
}


-(IMP)originalBehavior{
    return __originalMethod_Imp;
}

typedef IMP *IMPPointer;

BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) { *store = imp; }
    return (imp != NULL);
}

NSInteger _add_Method_behavior_beginning(id self, SEL _cmd){
    CFTimeInterval startT=[TM time];
    NSArray* adpts=[[AdaptationManager manager] getAdaptationsForPath:[NSString stringWithFormat:@"%@/%s",[self class], sel_getName(_cmd)]];
    NSInteger returnValue;
    for (NSInteger i=[adpts count];i>-1;i--) {
        Method m=[((NSValue*)[[adpts[i] nBehavior] getBehavior]) pointerValue];
        returnValue=((NSInteger(*)(id,SEL))method_getImplementation(m))(self,_cmd);
    }
    Adaptation* a0=adpts[0];
    returnValue=((NSInteger(*)(id,SEL))a0.originalBehavior)(self,_cmd);
    //NSLog(@"Executed adapted method in %@",@([TM time]-startT));
    return returnValue;
}

- (id)invocationBlock
{
    return [^void (void * arg1, ...){
        [self setRetainsArguments:YES];
        va_list args;
        va_start(args, arg1);
        void * arg = arg1;
        NSUInteger numArguments = [blockSignature numberOfArguments];
        for( NSUInteger idx = 1; idx < numArguments; idx++ ){
            
            [self setArgument:&arg atIndex:idx];
            
            arg = va_arg(args, void *);
        }
        va_end(args);
        
        [self invoke];
        
    } copy];
}


NSInteger _add_Method_behavior_end(id selff, SEL _cmd){
//    va_list args, arguments;
//    va_start(args, _cmd);
//    
//    va_copy(args, arguments);
//    CFTimeInterval startT=[TM time];
    
    NSArray* adpts=[[AdaptationManager manager] getAdaptationsForPath:[NSString stringWithFormat:@"%@/%s",[selff class], sel_getName(_cmd)]];
    NSInteger returnValue;
    Adaptation* a0=adpts[0];
    returnValue=((NSInteger(*)(id,SEL, ...))a0.originalBehavior)(selff, _cmd);
//    for (Adaptation* a in adpts) {
//        Method m=[((NSValue*)[[a nBehavior] getBehavior]) pointerValue];
//        returnValue=((NSInteger(*)(id,SEL, ...))method_getImplementation(m))(selff,_cmd,arguments);
//    }
    //va_end(args);
    //NSLog(@"Executed adapted method in %@",@([TM time]-startT));
    return returnValue;
}

NSInteger _replace_Method_behavior(id self, SEL _cmd){
    CFTimeInterval startT=[TM time];
    NSString* path=[NSString stringWithFormat:@"%@/%s",[self class], sel_getName(_cmd)];
    NSArray* adpts=[[AdaptationManager manager] getAdaptationsForPath:path];
    Adaptation* a=adpts[[adpts count]-1];
    Method m=[((NSValue*)[[a nBehavior] getBehavior]) pointerValue];
    NSInteger returnValue=((NSInteger(*)(id,SEL))method_getImplementation(m))(self,_cmd);
    //NSLog(@"Executed adapted method in %@",@([TM time]-startT));
    return returnValue;
}

NSInteger _restore_Method_behavior(id self, SEL _cmd){
    NSString* path=[NSString stringWithFormat:@"%@/%s",[self class], sel_getName(_cmd)];
    NSArray* adpts=[[AdaptationManager manager] getAdaptationsForPath:path];
    Adaptation* a=adpts[[adpts count]-1];
    NSInteger returnValue=((NSInteger(*)(id,SEL))[a originalBehavior])(self,_cmd);
    return returnValue;
}


-(NSString*)description{
    return [self adaptationKey];
}

@end
