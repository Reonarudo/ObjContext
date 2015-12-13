//
//  BehaviorMethod.m
//  CtxFramework
//
//  Created by Leonardo Marques on 11.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import "BehaviorMethod.h"


@interface BehaviorMethod (){
    Class classy;
    IMP impl;
    Method behavior;
}

@end

@implementation BehaviorMethod


-(id)getBehavior{
    //method_setImplementation(behavior, impl);
    return [NSValue valueWithPointer:behavior];
}

-(void)setImplementation:(IMP)i{
    impl=i;
}

-(void)setBehavior:(id)b{
    behavior=((NSValue*)b).pointerValue;
}

-(void)setClass:(Class)c{
    classy=c;
}


-(Class)getClass{
    return classy;
}

@end
