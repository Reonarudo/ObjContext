//
//  ContextMonitor.h
//  CtxFramework
//
//  Created by Leonardo Marques on 09.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adaptation.h"
//#import "ContextManager.h"
//#import "LMContext.h"

@interface ContextMonitor:NSObject{
//    NSMutableDictionary* monitoredClassInstances;
//    NSMutableDictionary* monitoredAppCtx;
//    NSMutableDictionary* monitoredEnvCtx;
    //NSMutableDictionary* monitoredAdpCtx;

//    NSNotificationCenter* ns;
}
//@property NSMutableDictionary* monitoredClassInstances;
//@property NSMutableDictionary* monitoredAppCtx;
//@property NSMutableDictionary* monitoredEnvCtx;
//@property NSMutableDictionary* monitoredAdpCtx;

//@property NSNotificationCenter* ns;

//-(void) initWithManager:(ContextManager*)cmngr;
//-(BOOL)isMonitoringAppCtx:(Context*)ctx;
//-(void)addDependency:(Adaptation*)adpt toContextChange:(Context*)ctx;
//-(NSArray*)adaptationsForContext:(Context*)ctx;




//------------------------------------------------------------------------------
//-(void)activatedContext:(Context*)ctx;
//-(void)deactivatedContext:(Context*)ctx;

+ (ContextMonitor*)sharedInstance;
-(NSNotificationCenter*)sharedNotificationCenter;
-(void)start;
-(NSArray*)contextsForActivator:(NSString*)activator;
-(NSArray*)contextsForDeactivator:(NSString*)deactivator;

@end
