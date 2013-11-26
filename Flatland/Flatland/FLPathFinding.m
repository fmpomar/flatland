//
//  FLPathFinding.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPathFinding.h"

@implementation FLPathFindingNode
{
    CGPoint _position;
    NSMutableArray* _edges;
    BOOL _visited;
    FLPathFindingNode* _parent;
    float _accumCost;
}

-(id) initWithPosition:(CGPoint)position {
    _position = position;
    _edges = [NSMutableArray array];
    
    return self;
}

-(void) addNeighbour:(FLPathFindingNode *)neighbour withCost: (float) cost {
    if (neighbour)
        [_edges addObject:[[FLPathFindingEdge alloc] initWithTarget:neighbour andCost:cost]];
}

-(void) reset {
    _visited = NO;
    _parent = nil;
    _accumCost = INFINITY;
}

-(NSMutableArray*) getEdges {
    return _edges;
}

-(float) getAccumCost {
    return _accumCost;
}

-(void) setAccumCost: (float) cost {
    _accumCost = cost;
}

-(CGPoint) getPosition {
    return _position;
}

-(void) setParent:(FLPathFindingNode *)parent {
    _parent = parent;
}

-(FLPathFindingNode*) getParent {
    return _parent;
}

-(BOOL) isVisited {
    return _visited;
}

-(void) setVisited {
    _visited = YES;
}

@end

@implementation FLPathFindingEdge
{
    float _cost;
    FLPathFindingNode* _target;
}

-(id) initWithTarget: (FLPathFindingNode*) target andCost: (float) cost {
    _cost = cost;
    _target = target;
    return self;
}

-(float) getCost {
    return _cost;
}

-(FLPathFindingNode*) getTarget {
    return _target;
}

@end

@implementation FLPath
{
    NSMutableArray* _nodes;
    NSEnumerator* _enum;
}

-(id) initWithDestination:(FLPathFindingNode *)destNode {
    FLPathFindingNode* current = destNode;
    _nodes = [NSMutableArray array];
    while (current) {
        [_nodes addObject: current];
        current = [current getParent];
    }
    _enum = [_nodes reverseObjectEnumerator];
    return self;
}

-(CGPoint) next {
    return [[_enum nextObject] getPosition];
}

@end

static FLPathFindingNode* getLowestNode(NSMutableOrderedSet* set) {
    FLPathFindingNode* lowest = nil;
    float lowestAccumCost = INFINITY;
    for (FLPathFindingNode* node in set) {
        if (!lowest || lowestAccumCost > [node getAccumCost]) {
            lowest = node;
            lowestAccumCost = [node getAccumCost];
        }
    }
    return lowest;
}

@implementation FLPathFinding
{
    FLPathFindingNode** _nodes;
    int _nodesSize;
    FLTiledMap* _map;
    CGSize _dims;
}

-(FLPathFindingNode*) getNode: (CGPoint) position  {
    if ([_map tileInBounds: position])
        return _nodes[(int)(position.x+position.y*_dims.width)];
    else
        return nil;
}

-(void) setNode: (FLPathFindingNode*) node at: (CGPoint) position {
    if ([_map tileInBounds: position])
        _nodes[(int)(position.x+position.y*_dims.width)] = node;
}

-(void) reset {
    for (int i = 0; i < _nodesSize; i++) {
        if (_nodes[i])
            [_nodes[i] reset];
    }
}

-(float) tileDistanceFrom: (CGPoint) from To: (CGPoint) to {
    return hypotf(to.x-from.x, to.y-from.y);
}

-(FLPath*) pathFrom: (cpVect) origin To: (cpVect) destination {
    NSMutableOrderedSet* openSet = [NSMutableOrderedSet orderedSet];
    FLPathFindingNode* originNode = [self getNode: [_map worldToMapCoords:origin]];
    FLPathFindingNode* destNode = [self getNode: [_map worldToMapCoords:destination]];
    
    if (!originNode || !destNode) return nil; //No path
    
    [self reset];
    
    [originNode setAccumCost:[self tileDistanceFrom:[originNode getPosition] To:[destNode getPosition]]];
    
    [openSet addObject: originNode];
    
    while ([openSet count] > 0) {
        FLPathFindingNode* lowest = getLowestNode(openSet);
        
        [lowest setVisited];
        [openSet removeObject:lowest];
        
        if (lowest == destNode) break;
        
        for (FLPathFindingEdge*edge in [lowest getEdges]) {
            FLPathFindingNode* neighbour = [edge getTarget];
            if (![neighbour isVisited]) {
                float cost = [edge getCost];
                float newAccumCost = cost+[lowest getAccumCost]+[self tileDistanceFrom:[neighbour getPosition] To:[destNode getPosition]];
                
                if (![openSet containsObject:neighbour]) {
                    [neighbour setParent: lowest];
                    [neighbour setAccumCost: newAccumCost];
                    [openSet addObject:neighbour];
                } else if (newAccumCost < [neighbour getAccumCost]) {
                    [neighbour setParent: lowest];
                    [neighbour setAccumCost: newAccumCost];
                }
            }
        }
    }
    
    if ([destNode getParent])
        return [[FLPath alloc] initWithDestination: destNode];
    else
        return nil; // Path not found.
    
    
}

-(id) initWithMap:(FLTiledMap *)map {
    int x, y;
    _nodesSize = map.mapSize.height*map.mapSize.width;
    _nodes = malloc(sizeof(FLPathFindingNode*)*_nodesSize);
    _map = map;
    _dims = map.mapSize;
    
    // Create nodes
    for (y = 0; y < _dims.height; y++) {
        for (x = 0; x < _dims.width; x++) {
            if ([_map tileBlocked:ccp(x,y)])
                [self setNode:nil at:ccp(x,y)];
            else
                [self setNode:[[FLPathFindingNode alloc] initWithPosition:ccp(x,y)] at:ccp(x,y)];
        }
    }

    // Establish node connections
    for (y = 0; y < _dims.height; y++) {
        for (x = 0; x < _dims.width; x++) {
            FLPathFindingNode* node = [self getNode:ccp(x,y)];
            if (node) {
                // Orthogonally adjacent nodes
                [node addNeighbour:[self getNode:ccp(x-1,y)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x,y-1)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x+1,y)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x,y+1)] withCost:1.0f];
                
                // Diagonally adjacent nodes
                if ([self getNode:ccp(x-1,y)] && [self getNode:ccp(x,y-1)])
                    [node addNeighbour:[self getNode:ccp(x-1,y-1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x-1,y)] && [self getNode:ccp(x,y+1)])
                    [node addNeighbour:[self getNode:ccp(x-1,y+1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x+1,y)] && [self getNode:ccp(x,y+1)])
                    [node addNeighbour:[self getNode:ccp(x+1,y+1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x+1,y)] && [self getNode:ccp(x,y-1)])
                    [node addNeighbour:[self getNode:ccp(x+1,y-1)] withCost:M_SQRT2];
            }
        }
    }
    
    
    
    return self;
}
@end
