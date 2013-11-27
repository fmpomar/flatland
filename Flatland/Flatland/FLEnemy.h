//
//  FLEnemy.h
//  Flatland
//
//  Created by vmware on 11/26/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsCircle.h"
#import "FLPathFinding.h"
#import "FLPlayer.h"
#import "FLGame.h"


@interface FLEnemy : FLPhysicsCircle

+(id) enemyWithGame: (id<FLGame>) game pathFinding: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position;
-(id) initWithGame: (id<FLGame>) game pathFinding: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position;

@end
