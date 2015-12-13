//
//  AdaptationModuleManager.h
//  CtxFramework
//
//  Created by Leonardo Marques on 02.09.15.
//  Copyright (c) 2015 Leonardo Marques. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adaptation.h"
//#import "LMContext.h"

//static NSString* const kModelFileName = @"c2amm.plist";

@interface AdaptationManager : NSObject{
//    NSString* c2ammFilePath;
//    NSString* cILFolderPath;
}
//@property (nonatomic) NSMutableDictionary* activeAdaptations;
//@property (nonatomic) NSString* c2ammFilePath;
//@property (nonatomic) NSString* cILFolderPath;

//+(void)readMappingFile;
//-(void)addAdaptation:(Adaptation*)a;

+(AdaptationManager*)manager;
-(void)activate:(NSString*)aK;
-(void)deactivate:(NSString*)aK;
-(void)add:(Adaptation*)a;
-(Adaptation*)getAdaptationForKey:(NSString*)aK;
-(NSArray*)getAdaptationsForPath:(NSString*)path;
-(void)activatePreActivatedAdaptations;
-(void)contextDeactivatedForAdaptation:(NSString*)aK;
-(void)reload;
@end
