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
@property (readonly) cpSpace* space;
@property (readonly) cpBody* body;

-(id) initWithSpace: (cpSpace*) space position: (CGPoint) position M: (float) mass I: (float) momentOfInertia;

-(void) resetForces;
-(void) applyForce: (cpVect) force at: (cpVect) offset;
-(cpVect) resultant;

@end
