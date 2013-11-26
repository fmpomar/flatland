//
//  FLEnemy.m
//  Flatland
//
//  Created by vmware on 11/26/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLEnemy.h"

#define SPEED_MULTIPLIER 5.0f
#define WANDER_SPEED_MULTIPLIER 1.0f
#define WANDER_DISTANCE 80.0f
#define DETECTION_DISTANCE 160.0f
#define CLOSE_ENOUGH_DISTANCE 16.0f

@interface FLEnemy()

@property (strong, nonatomic) FLPathFinding* pathFinding;
@property (strong, nonatomic) FLPath* path;
@property (strong, nonatomic) FLPhysicsBody* player;
@property (nonatomic, assign) CGPoint headingPosition;
@property (nonatomic, assign) CGPoint lastPlayerPos;
@property (nonatomic, assign) BOOL moving;

@end

@implementation FLEnemy

-(id) initWithPlayer: (FLPhysicsBody*) player pathFinding: (FLPathFinding*) pathFinding space: (cpSpace*) space andPosition: (CGPoint) position {
    self = [super initWithSpace:space Position:position R:15.0f M:0.5f I:INFINITY color:ccc4f(0.8f, 0.0f, 0.0f, 1.0f) andDrawDirection:YES];
    self.pathFinding = pathFinding;
    self.player = player;
    self.path = nil;
    self.moving = YES;
    [self scheduleUpdate];
    [self schedule:@selector(wanderTimer) interval:1.0f];
    return self;
}

-(void) calculatePathToPlayer {
    self.path = [_pathFinding pathFrom:self.position To:_player.position];
    if (_path && _path.hasNext) {
        [_path next]; // Tiramos el primer tile
        if (_path.hasNext)
            _headingPosition = _path.next;
    }
        
}

-(void) updatePlayerPosition {
    if (ccpDistance(_lastPlayerPos, _player.position) > CLOSE_ENOUGH_DISTANCE) {
        if (ccpDistance(self.position, _player.position) < DETECTION_DISTANCE)
            [self calculatePathToPlayer];
        _lastPlayerPos = _player.position;
    }
}

-(void) update:(ccTime)delta {
    if (!_moving) return;
    
    [self updatePlayerPosition];
    [self resetForces];
    
    if (_path) {
        // Moving to a determined position
        if (ccpDistance(self.position, _headingPosition) > CLOSE_ENOUGH_DISTANCE) {
            CGPoint diff = ccpSub(_headingPosition, self.position);
            [self applyForce:ccpMult(diff, SPEED_MULTIPLIER) at:CGPointZero];
            self.rotation = atan2f(diff.x, -diff.y) - M_PI_2;
        } else {
            if (_path.hasNext) {
                _headingPosition = _path.next;
            } else {
                _path = nil;
            }
        }
    }
    
}

-(void) wanderTimer {
    if (_path || (arc4random()%2) == 0) return;
    CGPoint wanderPoint = ccpRotateByAngle(ccp(self.position.x+WANDER_DISTANCE, self.position.y), self.position, arc4random());
    CGPoint diff = ccpSub(wanderPoint, self.position);
    self.rotation = atan2f(diff.x, -diff.y) - M_PI_2;
    [self applyImpulse:ccpMult(diff, WANDER_SPEED_MULTIPLIER) at: CGPointZero];
}

@end
