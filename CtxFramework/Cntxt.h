//
//  Context.h
//  CtxFramework
//
//  Created by Leonardo Marques on 11.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectReadFromJSON.h"
#import "Adaptation.h"
#import "Behavior.h"
//#import "ContextManager.h"

@interface Cntxt : ObjectReadFromJSON

@property NSString* contextKey;

//0 Environmental context
//1 Application context
@property NSNumber* contextType;
//0 class
//1 class method
//2 instance method
//3 instance method
@property NSNumber* contextScopeType;
//Observed context activator location
@property NSString* contextScopeActivatorLocation;
@property IMP originalActivatorBehavior;

//Observed context deactivator location
@property NSString* contextScopeDeactivatorLocation;
@property IMP originalDeactivatorBehavior;

//+(ContextManager*)manager;

+(Cntxt*)contextFromJSONData:(NSDictionary*)rawContext;

-(void)add:(NSString*)aK;

//Util
-(NSInteger)ContextScopeActivatorDepth;

-(NSInteger)ContextScopeDeactivatorDepth;

@end
