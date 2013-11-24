#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface HudLayer : CCLayer
- (void)numCollectedChanged:(int)numCollected;
@end

// MainLayer
@interface MainLayer : CCLayer
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end