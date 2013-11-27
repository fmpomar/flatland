//
//  FLPlayer.m
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPlayer.h"

@interface FLPlayer()
@property (nonatomic, strong) id<FLGame> game;
@end

@implementation FLPlayer

+(id) playerWithGame:(id<FLGame>)game space:(cpSpace *)space andPosition:(CGPoint)position {
    return [[[self alloc] initWithGame:game space:space andPosition:position] autorelease];
    
}

-(id) initWithGame:(id<FLGame>)game space:(cpSpace *)space andPosition:(CGPoint)position {
    self = [super initWithSpace:space Position:position R:16.0f M:0.5f I:INFINITY color:ccc4f(0.1f, 0.0f, 0.9f, 1.0f) andDrawDirection:YES];
    self.game = game;
    return self;
}

-(FLProjectile*) fireProjectile {
    FLProjectile* projectile = [[FLProjectile alloc] initWithGame:_game space:self.space andPosition:ccpAdd(self.position,ccpMult(self.rotationVector, self.circleRadius))];
    
    return nil;
}

-(void) collisionBegin:(FLPhysicsBody *)otherBody {
    NSLog(@"Game Lost!");
    [_game endGame];
}

-(void)dealloc {
    self.game = nil;
    [super dealloc];
}

@end
