//
//  FlPhysicsCircle.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsCircle.h"

#define DEFAULT_CIRCLE_ELASTICITY 0.5f
#define DEFAULT_CIRCLE_FRICTION 0.5f

@interface FLPhysicsCircle()

@property (nonatomic, assign) cpShape* shape;
@property (nonatomic, assign) ccColor4F color;
@property (nonatomic, assign) BOOL drawDirection;

@end

@implementation FLPhysicsCircle

-(id) initWithSpace: (cpSpace*) space Position: (cpVect) position R: (float) radius M: (float) mass I: (float) momentOfInertia color: (ccColor4F) color andDrawDirection: (BOOL) drawDirection {
	
    self = [super initWithSpace:space position:position M: mass I:momentOfInertia];
    
    self.shape = cpCircleShapeNew(self.body, radius, CGPointZero);
    self.color = color;
    self.drawDirection = drawDirection;
    
    cpShapeSetElasticity(_shape, DEFAULT_CIRCLE_ELASTICITY);
	cpShapeSetFriction(_shape, DEFAULT_CIRCLE_FRICTION);
    cpSpaceAddShape(self.space, _shape);
    
    return self;
    
}

-(void) draw {
    cpVect center = ((cpCircleShape*)_shape)->tc; //cpCircleShapeGetOffset(_shape);
    cpFloat radius = cpCircleShapeGetRadius(_shape);
    [self drawDot:center radius:cpfmax(radius, 1.0) color:ccc4f(0.0f, 0.0f, 0.0f, 1.0f)];
    [self drawDot:center radius:cpfmax(radius*0.9f, 1.0) color:_color];
    if (_drawDirection)
        [self drawSegmentFrom:center to:cpvadd(center, cpvmult(cpBodyGetRot(self.body), radius)) radius:1.0 color:ccc4f(0.0f, 0.0f, 0.0f, 1.0f)];
    [super draw];
	[super clear];
}

@end
