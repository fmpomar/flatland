#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#import "FLPlayer.h"

// MainLayer
@interface MainLayer : CCLayer <FLGame>

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end