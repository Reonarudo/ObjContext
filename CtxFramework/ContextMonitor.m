//
//  ContextMonitor.m
//  CtxFramework
//
//  Created by Leonardo Marques on 09.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import "ContextMonitor.h"
#import "ContextManager.h"
#import "BehaviorClass.h"
#import "BehaviorMethod.h"

@interface ContextMonitor (){
    NSNotificationCenter* notCen;
    NSMutableDictionary* reverseActivation2Context;
    NSMutableDictionary* reverseDeactivation2Context;
}

@end

@implementation ContextMonitor
//@synthesize monitoredClassInstances, monitoredAppCtx, monitoredEnvCtx, ns;



-(instancetype)init{
    if (self=[super init]) {
//        ns=[[NSNotificationCenter alloc] init];
//        monitoredAppCtx=[NSMutableDictionary new];
//        monitoredEnvCtx=[NSMutableDictionary new];
        //monitoredAdpCtx=[NSMutableDictionary new];
        notCen=[NSNotificationCenter defaultCenter];

        reverseActivation2Context=[[NSMutableDictionary alloc] init];
        reverseDeactivation2Context=[[NSMutableDictionary alloc] init];
        
        [self insertContextObservers];
    }
    return self;
}

static ContextMonitor *sharedMyManager = nil;

+ (ContextMonitor*)sharedInstance {

    @synchronized(self) {
        sharedMyManager = [[self alloc] init];
    }
    
    
    return sharedMyManager;
}

-(NSNotificationCenter*)sharedNotificationCenter{
    return notCen;
}

-(void)start{
    //TODO:
    [notCen addObserver:self selector:@selector(contextEvent:) name:nil object:nil];
}

-(void)stop{
    [notCen removeObserver:self name:nil object:nil];
}

-(void)contextEvent:(NSNotification*)not{
    //NSLog(@"testetetetete > %@", not);
    NSArray* cmp=[[not name] componentsSeparatedByString:@"|"];
    if ([cmp[0] isEqualToString:@"A"]) {
        //Activated Context cmp[1]
        NSArray* sCmp=[cmp[1] componentsSeparatedByString:@"§"];
        NSDictionary* k=@{@"class":sCmp[0],@"method":sCmp[1]};
        if (reverseActivation2Context[k]) {
            for (NSString* cK in reverseActivation2Context[k]) {
                Cntxt* c=[[ContextManager managerWithFile:nil] context4Key:cK];
                [[ContextManager managerWithFile:nil] activated:c];
            }
        }
    }else if ([cmp[0] isEqualToString:@"D"]){
        //Deactivated Context cmp[1]
        NSArray* sCmp=[cmp[1] componentsSeparatedByString:@"§"];
        NSDictionary* k=@{@"class":sCmp[0],@"method":sCmp[1]};
        if (reverseDeactivation2Context[k]) {
            for (NSString* cK in reverseDeactivation2Context[k]) {
                Cntxt* c=[[ContextManager managerWithFile:nil] context4Key:cK];
                [[ContextManager managerWithFile:nil] deactivated:c];
            }
        }
    }else{
        //ERROR
    }
}

-(NSArray*)contextsForActivator:(NSString*)activator{
    NSArray* cmp=[activator componentsSeparatedByString:@"|"];
        //Activated Context cmp[1]
        NSArray* sCmp=[cmp[1] componentsSeparatedByString:@"§"];
        NSDictionary* k=@{@"class":sCmp[0],@"method":sCmp[1]};
        if (reverseActivation2Context[k]) {
            return reverseActivation2Context[k];
        }else{
            return nil;
        }

}

-(NSArray*)contextsForDeactivator:(NSString*)deactivator{
    NSArray* cmp=[deactivator componentsSeparatedByString:@"|"];
    //Activated Context cmp[1]
    NSArray* sCmp=[cmp[1] componentsSeparatedByString:@"§"];
    NSDictionary* k=@{@"class":sCmp[0],@"method":sCmp[1]};
    if (reverseDeactivation2Context[k]) {
        return reverseDeactivation2Context[k];
    }else{
        return nil;
    }
}

-(void)insertContextObservers{
    [self insertApplicationContextObservers];
    [self insertEnvironmentContextObservers];
}

-(void)insertApplicationContextObservers{
    //TODO:
    NSArray* appCtxts=[[ContextManager managerWithFile:[ContextManager manager].fileName] loadedContexts];
    for (Cntxt* c in appCtxts) {
        NSString* contextActLoc=[c contextScopeActivatorLocation];
        NSString* contextDeaLoc=[c contextScopeDeactivatorLocation];
        NSString* actClass=[contextActLoc pathComponents][0];
        NSString* actMeth;
        if ([[contextActLoc pathComponents] count]>1) {
            actMeth=[contextActLoc pathComponents][1];
        }
        NSString* deactClass=[contextDeaLoc pathComponents][0];
        NSString* deactMeth;
        if ([[contextDeaLoc pathComponents] count]>1) {
            deactMeth=[contextDeaLoc pathComponents][1];
        }
        //Build reverse search
        NSDictionary* k=@{@"class":actClass,@"method":actMeth};
        if (reverseActivation2Context[k]) {
            [reverseActivation2Context[k] addObject:c.contextKey];
        }else{
            NSMutableArray* tmpA=[[NSMutableArray alloc] init];
            [tmpA addObject:c.contextKey];
            [reverseActivation2Context setObject:tmpA forKey:k];
            //If observer hasn't been inserted yet then it doest exist on the reverse search
            NSInteger depth=[c ContextScopeActivatorDepth];
            assert(depth>0);
            switch (depth) {
                case 1://Class depth
                {
                    //inserts class observer
//                    [self injectInstanceMethodActivationNotifierIn:NSSelectorFromString(@"init") from:NSClassFromString(actClass)];
//                    [self injectInstanceMethodDeactivationNotifierIn:NSSelectorFromString(@"dealloc") from:NSClassFromString(actClass)];
//
                }
                    break;
                case 2://Method depth
                case 3://Param depth
                {
                    //Method m=class_getInstanceMethod(NSClassFromString(actClass), NSSelectorFromString(actMeth));


                    IMP originalImp;
                    if ([contextActLoc isEqual:contextDeaLoc]) {

                        originalImp=[self injectInstanceMethodActAndDeactivationNotifierIn:NSSelectorFromString(actMeth) from:NSClassFromString(actClass)];
                    }else{
                            originalImp=[self injectInstanceMethodActivationNotifierIn:NSSelectorFromString(actMeth) from:NSClassFromString(actClass)];
                        
                        
                    }
                    if (![c originalActivatorBehavior]) {
                        [c setOriginalActivatorBehavior:originalImp];
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }
        if (reverseDeactivation2Context[contextDeaLoc]) {
            NSDictionary* k=@{@"class":deactClass,@"method":deactMeth};
            [reverseDeactivation2Context[k] addObject:c.contextKey];
        }else{
            NSDictionary* k=@{@"class":deactClass,@"method":deactMeth};
            NSMutableArray* tmpA=[[NSMutableArray alloc] init];
            [tmpA addObject:c.contextKey];
            [reverseDeactivation2Context setObject:tmpA forKey:k];

            //If observer hasn't been inserted yet then it doest exist on the reverse search
            NSInteger depth=[c ContextScopeDeactivatorDepth];
            assert(depth>0);
            switch (depth) {
                case 1://Class depth
                {
                    //inserts class observer
                    //already in from activator
                }
                    break;
                case 2://Method depth
                case 3://Param depth
                {
                    if (![contextActLoc isEqual:contextDeaLoc]) {

                       IMP originalImp=[self injectInstanceMethodDeactivationNotifierIn:NSSelectorFromString(deactMeth) from:NSClassFromString(deactClass)];
                        //assert(originalImp==method_getImplementation(m));
                        if (![c originalDeactivatorBehavior]) {
                            [c setOriginalDeactivatorBehavior:originalImp];
                        }
                        
                    }
                }
                    break;
                default:
                    break;
            }



        }


    }
}

-(void)insertEnvironmentContextObservers{
    //TODO:
}



//Actual method to be used
-(IMP)injectInstanceMethodActivationNotifierIn:(SEL) s from:(Class) c{
    Method m=class_getInstanceMethod(c, s);
    IMP originalMethodImp=method_setImplementation(m, (IMP)_add_Method_activation_notifier);
    return originalMethodImp;
}

-(IMP)injectClassMethodActivationNotifierIn:(SEL) s from:(Class) c{
    Method m=class_getClassMethod(c, s);
    IMP originalMethodImp=method_setImplementation(m, (IMP)_add_Method_activation_notifier);
    return originalMethodImp;
}

-(IMP)injectInstanceMethodDeactivationNotifierIn:(SEL) s from:(Class) c{
    Method m=class_getInstanceMethod(c, s);
    IMP originalMethodImp=method_setImplementation(m, (IMP)_add_Method_deactivation_notifier);
    return originalMethodImp;
}

-(IMP)injectClassMethodDeactivationNotifierIn:(SEL) s from:(Class) c{
    Method m=class_getClassMethod(c, s);
    IMP originalMethodImp=method_setImplementation(m, (IMP)_add_Method_deactivation_notifier);
    return originalMethodImp;
}

-(IMP)injectInstanceMethodActAndDeactivationNotifierIn:(SEL) s from:(Class) c{
    Method m=class_getInstanceMethod(c, s);
    IMP originalMethodImp=method_setImplementation(m, (IMP)_add_Method_act_and_deact_notifier);
    return originalMethodImp;
}

//Acessory functions to build new method's implementation
NSInteger _add_Method_activation_notifier(id self, SEL _cmd){
    //NSLog(@"Activated Contexts With Class: %@ Method: %@", [self class], NSStringFromSelector(_cmd));
    NSString* activator=[NSString stringWithFormat:@"A|%@§%@", [self class], NSStringFromSelector(_cmd)];
    [[ContextManager sharedNotificationCenter] postNotificationName:activator object:self];
    NSString* cK=[[ContextMonitor sharedInstance] contextsForActivator:activator][0];
    //NSLog(@"Contexts: %@", [[ContextMonitor sharedInstance] contextsForActivator:activator]);
    Cntxt* c=[[ContextManager managerWithFile:nil] context4Key:cK];
    NSInteger returnValue=((NSInteger(*)(id,SEL))[c originalActivatorBehavior])(self,_cmd);
    return returnValue;
}
NSInteger _add_Method_deactivation_notifier(id self, SEL _cmd){
    //NSLog(@"Deactivated Contexts With Class: %@ Method: %@", [self class], NSStringFromSelector(_cmd));
    NSString* deactivator=[NSString stringWithFormat:@"D|%@§%@", [self class], NSStringFromSelector(_cmd)];
    [[ContextManager sharedNotificationCenter] postNotificationName:deactivator object:self];
    NSString* cK=[[ContextMonitor sharedInstance] contextsForDeactivator:deactivator][0];
    Cntxt* c=[[ContextManager managerWithFile:nil] context4Key:cK];
    NSInteger returnValue=((NSInteger(*)(id,SEL))[c originalDeactivatorBehavior])(self,_cmd);
    return returnValue;
}

NSInteger _add_Method_act_and_deact_notifier(id self, SEL _cmd){
//    NSLog(@"Activated Contexts With Class: %@ Method: %s", [self class], sel_getName(_cmd));
//    [[ContextManager sharedNotificationCenter] postNotificationName:[NSString stringWithFormat:@"A|%@§%@", [self class], NSStringFromSelector(_cmd)] object:self];
//
//    NSInteger returnValue=((NSInteger(*)(id,SEL))__original_Method_Imp)(self,_cmd);
//    NSLog(@"Deactivated Contexts With Class: %@ Method: %s", [self class], sel_getName(_cmd));
//    [[ContextManager sharedNotificationCenter] postNotificationName:[NSString stringWithFormat:@"D|%@§%@", [self class], NSStringFromSelector(_cmd)] object:self];
//
//    return returnValue;
    return -1;
}


////////////
//
////Observer Injection
//NSInteger _replacement_Method(id self, SEL _cmd){
//    //va_list argumentList;
//    //[[[LMContext monitor] ns] postNotificationName:[NSString stringWithFormat:@"A:%@§%@", [self class], NSStringFromSelector(_cmd)] object:self];
//    NSInteger returnValue=((NSInteger(*)(id,SEL))__original_Method_Imp)(self,_cmd);
//    //[[[LMContext monitor] ns] postNotificationName:[NSString stringWithFormat:@"D:%@§%@", [self class], NSStringFromSelector(_cmd)] object:self];
//    return returnValue;
//}
//
//-(void)injectInstanceMethodIn:(SEL) s from:(Class) c{
//    Method m=class_getInstanceMethod(c, s);
//    __original_Method_Imp=method_setImplementation(m, (IMP)_replacement_Method);
//}
//-(void)injectClassMethodIn:(SEL) s from:(Class) c{
//    Method m=class_getClassMethod(c, s);
//    __original_Method_Imp=method_setImplementation(m, (IMP)_replacement_Method);
//}
//
//static IMP __original_Method_Imp;
//NSInteger _add_to_begining_Method(id self, SEL _cmd){
//
//    NSInteger returnValue=((NSInteger(*)(id,SEL))__original_Method_Imp)(self,_cmd);
//    return returnValue;
//}

//-(BOOL)isMonitoringAppCtx:(LMContext*)ctx{
//    return [monitoredAppCtx objectForKey:ctx.components]?YES:NO;
//}
//
//-(void)addDependency:(Adaptation*)adpt toContextChange:(LMContext*)ctx{
//
//    if ([[LMContext monitor] isMonitoringAppCtx:ctx]) {
//        NSMutableArray* adpts=[[NSMutableArray alloc] initWithArray:[monitoredAppCtx objectForKey:ctx.components]];
//        NSInteger nEl=[adpts count];
//        [adpts addObject:adpt];
//        [monitoredAppCtx setObject:adpts forKey:ctx.components];
//        assert([adpts count]>nEl);
//    }else{
//        NSInteger nEl=[monitoredAppCtx count];
//        [monitoredAppCtx setObject:@[adpt] forKey:ctx.components];
//        assert([monitoredAppCtx count]>nEl);
//    }
//
//}
//
//-(NSArray*)adaptationsForContext:(LMContext*)ctx{
//    return [monitoredAppCtx objectForKey:ctx.components];
//}



@end
