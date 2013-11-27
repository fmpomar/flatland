//
//  FLProjectile.m
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLProjectile.h"

@interface FLProjectile()

@property (nonatomic, strong) id<FLGame> game;

@end

@implementation FLProjectile

+(id) projectileWithGame:(id<FLGame>)game space:(cpSpace *)space andPosition:(CGPoint)position {
    return [[[self alloc] initWithGame:game space:space andPosition:position] autorelease];
}

-(id) initWithGame:(id<FLGame>)game space:(cpSpace *)space andPosition:(CGPoint)position {
    self = [super initWithSpace:space Position:position R:2.0f M:0.1f I:INFINITY color:ccc4f(0.0f, 0.0f, 0.0f, 1.0f) andDrawDirection:NO];
    self.game = game;
    [self schedule:@selector(scheduledExpiration) interval:2.0f];
    return self;
}

-(void)collisionBegin:(FLPhysicsBody *)otherBody {
    [_game projectileExpired:self];
}

-(void) scheduledExpiration {
    [_game projectileExpired:self];
}

-(void)dealloc {
    self.game = nil;
    [super dealloc];
}

@end
