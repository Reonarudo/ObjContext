//
//  Adaptation.h
//
//
//  Created by Leonardo Marques on 02.09.15.
//
//

#import <Foundation/Foundation.h>
#import "ObjectReadFromJSON.h"
#import "Cntxt.h"
//#import "CtxTypes.h"
#import "Behavior.h"
#import "ContextMonitor.h"
//#import "AdaptationPoint.h"
//#import "AdaptationManager.h"
@interface Adaptation : ObjectReadFromJSON{

}

@property(nonatomic) NSString* adaptationKey;
@property(nonatomic) NSString* contextKey;

//0 class
//1 class method
//2 instance method
//3 instance method
@property NSNumber* delimitationScopeType;
//Adaptation target
@property id<Behavior> delimitationScope;
//0 layer adaptation (no state should be kept)
//1 context adaptation (keep activation state)
@property NSNumber* adaptationDefinitionType;
//If context adaptation, activation count is kept here
@property NSNumber* adaptationActivationCount;
//Last activation time is kept here
@property NSNumber* adaptationActivationTime;
//0 permanent activation
//1 active # times
//2 active t time
//3 as long as the context is active
@property NSNumber* delimitationOfContextActivation;
//# of activations if delimitationOfContextActivation==1
//time if delimitationOfContextActivation==2
@property NSNumber* delimitationOfContextActivationDetail;
//0 replace current behavior
//1 add to begining of current behavior
//2 add to end of current behavior
@property NSNumber* adaptationComposition;
//TODO: analyse this property as an overall system property os adaptation fine
//grained property
//0 on context activation
//1 on method dispatch
@property NSNumber* behaviorBindingTime;
//0 priority is defined by activation time
//# priority is defined by 1 is higher priority than 2 and any activation time
//priority is higher than a priority 1 adaptation
@property NSNumber* priority;
//"$BundleName$" Context-In-Layer (CIL)
//"" Layer-In-Context (LIC)
@property NSNumber* adaptationModularityType;
//Behaviour to be injected
@property id<Behavior> nBehavior;
//If the behavior is inside an external container
@property NSString* behaviorContainer;

//+ (AdaptationManager*)manager;

+(Adaptation*)adaptationFromJSONData:(NSDictionary*)rawAdaptation;

//+ (id)manager;
//+ (void) setClassInLayerModulesFolder:(NSString*)folder;
//+ (void) setCtx2AdptMapFolder:(NSString*)folder;
//
//------------------------------------------------------------------------------
//-(BOOL)isTrigeredBy:(LMContext*)ctx;
//-(LMContext*)trigger;

//-(void)contextChange:(NSNotification*)notif;

-(void)activate;
-(void)deactivate;

-(void)add:(NSString*)cK;

-(BOOL)preload;

- (NSComparisonResult)adaptationPriorityCompareWith:(Adaptation *)a2;

-(IMP)originalBehavior;

@end
