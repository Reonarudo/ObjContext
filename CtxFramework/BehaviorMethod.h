//
//  BehaviorMethod.h
//  CtxFramework
//
//  Created by Leonardo Marques on 11.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import "Behavior.h"
#import <objc/runtime.h>

@interface BehaviorMethod : NSObject<Behavior>
-(void)setClass:(Class)c;
-(Class)getClass;
-(void)setImplementation:(IMP)i;
@end
