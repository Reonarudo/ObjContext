//
//  ObjectiveContextualizer.h
//  CtxFramework
//
//  Created by Leonardo Marques on 20.11.15.
//  Copyright © 2015 Leonardo Marques. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectiveContextualizer : NSObject
+ (ObjectiveContextualizer*)contextualize;
+ (ObjectiveContextualizer*)contextualizeWithFile:(NSString*)fileName;
-(void)apply:(NSString*)adaptationKey;
-(void)remove:(NSString*)adaptationKey;
@end
