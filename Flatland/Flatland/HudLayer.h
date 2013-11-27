//
//  HudLayer.h
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
@interface HudLayer : CCLayer

-(void) displayMessage: (NSString*) message;
-(void) displayMessage:(NSString *)message withColor: (ccColor3B) color;

@end
