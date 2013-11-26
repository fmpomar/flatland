//
//  FLPathFinding.h
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLTiledMap.h"

@interface FLPathFindingNode : NSObject

@property (nonatomic,assign) float accumCost;
@property (nonatomic,strong) FLPathFindingNode* parent;
@property (nonatomic,assign,readonly) BOOL visited;
@property (nonatomic,strong,readonly) NSMutableArray* edges;
@property (nonatomic,assign,readonly) CGPoint position;

-(id) initWithPosition: (CGPoint) position;
-(void) addNeighbour:(FLPathFindingNode *)neighbour withCost: (float) cost;

-(void) reset;
-(void) setVisited;

@end

@interface FLPathFindingEdge : NSObject

@property (nonatomic,readonly,assign) float cost;
@property (nonatomic,readonly,strong) FLPathFindingNode* target;

-(id) initWithTarget: (FLPathFindingNode*) target andCost: (float) cost;

@end

@interface FLPath : NSObject
-(id) initWithDestination: (FLPathFindingNode*) destNode andMap: (FLTiledMap*) map;
-(CGPoint) next;
-(BOOL) hasNext;
@end

@interface FLPathFinding : NSObject

@property (nonatomic,strong,readonly) FLTiledMap* map;

-(id) initWithMap: (FLTiledMap*) map;
-(FLPath*) pathFrom: (cpVect) origin To: (cpVect) destination;
@end
