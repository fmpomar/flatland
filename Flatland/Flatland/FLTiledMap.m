//
//  FLTiledMap.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLTiledMap.h"

@implementation FLTiledMap
{
    cpSpace* _space;
    CCTMXLayer* _metaLayer;
}

+(id) tiledMapWithTMXFile:(NSString *)tmxFile andSpace:(cpSpace*)space {
    return [[self alloc] initWithTMXFile:tmxFile andSpace:space];
}

-(id) initWithTMXFile:(NSString *)tmxFile andSpace:(cpSpace*)space {
    self = [super initWithTMXFile:tmxFile];
    _space = space;
    _metaLayer = [self layerNamed:@"Meta"];
    _metaLayer.visible = NO;
    [self initWalls];
    return self;
}

-(CGPoint) playerSpawnPoint {
    CCTMXObjectGroup *objectGroup = [self objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
    return ccp([spawnPoint[@"x"] integerValue],[spawnPoint[@"y"] integerValue]);
}

-(Boolean) tileInBounds: (CGPoint) tileCoord {
    return (tileCoord.x >= 0 && tileCoord.y >= 0 && tileCoord.x < self.mapSize.width && tileCoord.y < self.mapSize.height);
}

-(Boolean) tileBlocked: (CGPoint)tileCoord {
    int tileGid = [_metaLayer tileGIDAt: tileCoord];
    if (tileGid) {
        NSDictionary *properties = [self propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = properties[@"Collidable"];
            return (collision && [collision isEqualToString:@"True"]);
        }
    }
    return (![self tileInBounds:tileCoord]);
}

-(void) createWallAtTile: (CGPoint) tileCoord {
    if ([self tileBlocked:tileCoord]) {
        cpShape * wallShape;
        cpVect verts[] = {
            cpv(0,0),
            cpv(0, self.tileSize.height),
            cpv( self.tileSize.width, self.tileSize.height),
            cpv( self.tileSize.width,0),
        };
        cpVect offset = cpv(tileCoord.x*self.tileSize.width,(self.tileSize.height*(self.mapSize.height-1))-tileCoord.y*self.tileSize.height);
        wallShape = cpPolyShapeNew(_space->staticBody, 4, verts, offset);
        cpShapeSetElasticity(wallShape, 1.0f);
        cpShapeSetFriction(wallShape, 1.0f);
        cpSpaceAddStaticShape(_space, wallShape);
    }
}

-(void) initWalls {
    int x,y;
    CGSize mapSize = [self mapSize];
    
    for (x=0; x<mapSize.width; x++)
        for (y=0; y<mapSize.height; y++)
            [self createWallAtTile:ccp(x,y)];
}

@end
