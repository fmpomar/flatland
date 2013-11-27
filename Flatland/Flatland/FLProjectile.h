//
//  FLProjectile.h
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsCircle.h"
#import "FLGame.h"

@interface FLProjectile : FLPhysicsCircle

+(id) projectileWithGame: (id<FLGame>) game space: (cpSpace*) space andPosition: (CGPoint) position;
-(id) initWithGame: (id<FLGame>) game space: (cpSpace*) space andPosition: (CGPoint) position;

@end
