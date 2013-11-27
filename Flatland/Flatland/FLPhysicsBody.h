//
//  FLPhysicsBody.h
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "CCDrawNode.h"
#import "cocos2d.h"

@interface FLPhysicsBody : CCDrawNode
@property (readonly,assign) cpSpace* space;
@property (readonly,assign) cpBody* body;

+(void) setupSpaceForCollisions: (cpSpace*) space;

-(id) initWithSpace: (cpSpace*) space position: (CGPoint) position M: (float) mass I: (float) momentOfInertia;

-(void) resetForces;
-(void) applyForce: (cpVect) force at: (cpVect) offset;
-(void) applyImpulse: (cpVect) impulse at: (cpVect) offset;
-(cpVect) resultant;

-(void)forceTowards:(CGPoint)position;

-(cpVect) rotationVector;


-(void) collisionBegin: (FLPhysicsBody*) otherBody;
-(void) collisionSeparate: (FLPhysicsBody*) otherBody;

@end
