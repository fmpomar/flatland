//
//  FLEnemy.m
//  Flatland
//
//  Created by vmware on 11/26/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLEnemy.h"
#import "FLPathFinding.h"

@implementation FLEnemy
{
    FLPathFinding* _pathFinding;
    FLPhysicsBody* _player;
}

-(id) initWithPlayer: (FLPhysicsBody*) player map: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position {
    self = [super initWithSpace:space Position:position R:10.0f M:0.5f I:INFINITY color:ccc4f(0.8f, 0.0f, 0.0f, 1.0f) andDrawDirection:YES];
    return self;
}

@end
