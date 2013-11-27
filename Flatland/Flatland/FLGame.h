//
//  FLGame.h
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLProjectile;
@class FLEnemy;
@class FLPlayer;

@protocol FLGame <NSObject>

-(void) endGame;
-(void) enemyExpired: (FLEnemy*) enemy;
-(void) projectileExpired: (FLProjectile*) projectile;
-(FLPlayer*) getPlayer;

@end
