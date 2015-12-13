//
//  BehaviorClass.m
//  CtxFramework
//
//  Created by Leonardo Marques on 11.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import "BehaviorClass.h"
#import <objc/runtime.h>

@interface BehaviorClass (){
    Class behavior;
}

@end

@implementation BehaviorClass


-(id)getBehavior{
    return behavior;
}

-(void)setBehavior:(id)b{
    behavior=b;
}

@end
