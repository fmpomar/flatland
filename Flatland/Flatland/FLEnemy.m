//
//  FLEnemy.m
//  Flatland
//
//  Created by vmware on 11/26/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLEnemy.h"


@implementation FLEnemy
{
    FLPathFinding* _pathFinding;
    FLPath* _path;
    FLPhysicsBody* _player;
    CGPoint _headingPosition;
    BOOL _moving;
}

-(id) initWithPlayer: (FLPhysicsBody*) player pathFinding: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position {
    self = [super initWithSpace:space Position:position R:15.0f M:0.5f I:INFINITY color:ccc4f(0.8f, 0.0f, 0.0f, 1.0f) andDrawDirection:YES];
    _pathFinding = pathFinding;
    _player = player;
    _path = [_pathFinding pathFrom:self.position To:_player.position];
    if (_path)
        _headingPosition = _path.next;
    _moving = YES;
    [self scheduleUpdate];
    return self;
}

-(void) update:(ccTime)delta {
    [self resetForces];
    if (_moving) {
        // Moving to a determined position
        if (ccpDistance(self.position, _headingPosition) > 16.0) {
            [self applyForce:ccpMult(ccpSub(_headingPosition, self.position),1) at:CGPointZero];
        } else if (_path) {
            if (_path.hasNext) {
                _headingPosition = _path.next;
            } else {
                _moving = false;
                _path = nil;
            }
        }
    } else {
        // Wandering. or stopped. by now        
    }
    
}

@end
