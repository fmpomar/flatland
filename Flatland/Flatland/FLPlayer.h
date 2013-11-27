//
//  FLPlayer.h
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsCircle.h"
#import "FLGame.h"
#import "FLProjectile.h"

@protocol FLPlayerHost;

@interface FLPlayer : FLPhysicsCircle
+(id) playerWithGame:(id<FLGame>)game space:(cpSpace *)space andPosition:(CGPoint)position;
-(id) initWithGame: (id<FLGame>) game space: (cpSpace*) space andPosition: (CGPoint) position;

-(FLProjectile*) fireProjectile;
@end
