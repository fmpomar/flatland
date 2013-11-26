//
//  FLEnemy.h
//  Flatland
//
//  Created by vmware on 11/26/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsCircle.h"
#import "FLPathFinding.h"

@interface FLEnemy : FLPhysicsCircle

-(id) initWithPlayer: (FLPhysicsBody*) player pathFinding: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position;

@end
