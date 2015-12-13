//
//  Context.m
//  CtxFramework
//
//  Created by Leonardo Marques on 11.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import "Cntxt.h"
#import "ContextManager.h"

@interface Cntxt (){
    NSMutableArray* adaptations;
}

@end

@implementation Cntxt

#pragma mark Class methods

+ (ContextManager*)manager {
    static ContextManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+(Cntxt*)contextFromJSONData:(NSDictionary*)data{
    Cntxt *ctx=[[Cntxt alloc] init];
    [ctx setRawData:data];

    NSDictionary* rawContext=data;

    [ctx setContextType:rawContext[@"Type"]];
    assert([ctx contextType]!=nil);
    [ctx setContextScopeType:rawContext[@"ContextScope"][@"Type"]];
    assert([ctx contextScopeType]!=nil);
    [ctx setContextScopeActivatorLocation:rawContext[@"ContextScope"][@"Activator"]];
    assert([ctx contextScopeActivatorLocation]!=nil);
    [ctx setContextScopeDeactivatorLocation:rawContext[@"ContextScope"][@"Deactivator"]];
    assert([ctx contextScopeDeactivatorLocation]!=nil);

    assert(ctx!=nil);
    return ctx;
}

#pragma mark instance methods

-(instancetype)init{
    if (self=[super init]) {
        adaptations=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)add:(NSString*)aK{
    //TODO: check inserted adaptations compatability
    [adaptations addObject:aK];
}

-(NSInteger)ContextScopeActivatorDepth{
    return [self pathDepth:[self contextScopeActivatorLocation]];
}

-(NSInteger)ContextScopeDeactivatorDepth{
    return [self pathDepth:[self contextScopeDeactivatorLocation]];
}

-(NSInteger)pathDepth:(NSString*)p{
    NSString* path=p;
    if([[path pathComponents] count]==1){
        return 1;
    }else if([path pathComponents][0]){
        if ([[path pathComponents] count]>2) {
            return 3;
        }else{
            return 2;
        }
    }else{
        return -1;//ERROR
    }
}

@end
