/*
 * Copyright (c) 2014 Nicholas Trampe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "ParallaxScrollLayer.h"

#import "ntt_config.h"
#import "nt_level.h"
#import "nt_fan.h"
#import "nt_block.h"
#import "nt_coin.h"
#import "nt_player.h"
#import "nt_claw.h"
#import "MyContactListener.h"
#import "GameObjTouch.h"

typedef enum
{
  kEditModeSingleSelection = 0,
  kEditModeMultipleSelection = 1,
  kEditModeSingleDeletion = 2
}kEditMode;

@class GameController;
@class SettingsController;
@class GameLayer;

@protocol GameLayerDelegate

@optional
- (void)gameLayerDidStart:(GameLayer *)gameLayer;
- (void)gameLayerDidFinish:(GameLayer *)gameLayer;
- (void)gameLayerDidDie:(GameLayer *)gameLayer;
- (void)gameLayerDidReset:(GameLayer *)gameLayer;
- (void)gameLayer:(GameLayer *)gameLayer didKnockOnWood:(uint)aNumberOfTimes;
- (void)gameLayer:(GameLayer *)gameLayer didSmashBlock:(nt_block *)aBlock;
- (void)gameLayer:(GameLayer *)gameLayer didEatCoin:(uint)aNumberOfTimes;

@end

@interface GameLayer : ParallaxScrollLayer
{
  GameController * sharedGC;
  SettingsController * sharedSC;
  
  b2World * m_world;					// strong ref
	GLESDebugDraw * m_debugDraw;		// strong ref
  b2Body * m_groundBody;
  
  MyContactListener * m_contactListener;
  
  NSMutableArray * m_objects;
  NSMutableArray * m_touchedObjects;
  NSMutableArray * m_selectedObjects;
  
  nt_player * m_player;
  nt_object * m_lastTouchedObject; //weak
  nt_claw   * m_claw;
  
  b2Body * m_wall;
  nt_object * m_finish;
  
  BOOL m_started;
  
  kEditMode m_editMode;
  BOOL      m_grabbed;
  
  uint m_nCoins;
  float m_prevScale;
  CGPoint m_prevPos;
  
  CGPoint m_distanceTraveled, m_prevDistanceTraveled;
}
@property (readwrite, assign) NSObject <GameLayerDelegate> * gameDelegate;
@property (nonatomic, assign) BOOL isEditing, isEditingPosition, snaps;
@property (nonatomic, assign) float distanceRatio;
@property (nonatomic, assign) kEditMode editMode;

- (id)initWithLength:(float)aLength fans:(NSArray *)aFans blocks:(NSArray *)aBlocks coins:(NSArray *)aCoins;
- (id)initWithLevel:(nt_level *)aLevel;

- (b2World *)world;
- (nt_level *)level;
- (NSMutableArray *)objects;
- (NSMutableArray *)fans;
- (NSMutableArray *)blocks;
- (NSMutableArray *)coins;
- (NSMutableArray *)collectedCoins;
- (CGPoint)highestPoint;
- (CGPoint)farthestPoint;
- (CGPoint)playerPoint;
- (CGPoint)goalPoint;
- (uint)starsEarned;
- (uint)coinsCollected;
- (uint)score;

- (void)start;
- (void)reset;
- (void)killPlayer;

- (nt_block *)blockForBody:(b2Body *)aBody;
- (nt_fan *)fanForBody:(b2Body *)aBody;
- (nt_coin *)coinForBody:(b2Body *)aBody;

- (void)addObject:(nt_object *)anObject;
- (nt_object *)addObject:(nt_object *)anObject atTouch:(UITouch *)aTouch;
- (void)removeObject:(nt_object *)anObject;
- (void)removeAllObjects;
- (NSMutableArray *)touchedObjects;
- (NSMutableArray *)selectedObjects;
- (void)addSelectedObject:(nt_object *)anObject;
- (void)removeSelectedObject:(nt_object *)anObject;
- (nt_object *)lastTouchedObject;
- (nt_object *)objectClosestToPoint:(CGPoint)aPoint inArray:(NSArray *)aArray;
- (nt_object *)objectClosestToPoint:(CGPoint)aPoint;
- (nt_fan *)fanClosestToPoint:(CGPoint)aPoint;
- (nt_block *)blockClosestToPoint:(CGPoint)aPoint;
- (nt_coin *)coinClosestToPoint:(CGPoint)aPoint;
- (BOOL)isTouchingPlayerAtPoint:(CGPoint)aPoint;
- (BOOL)isObjectSelected:(nt_object *)anObject;

- (void)collectCoins:(NSArray *)aCoins;

- (void)addPoofAtPoint:(CGPoint)aPoint;
- (void)addFireWorks:(NSNumber *)aCount;

- (void)addBounds:(CGSize)aBounds;
- (void)checkBounds;
- (void)setPreviousScale:(float)aPreviousScale;
- (void)setPreviousPos:(CGPoint)aPreviousPos;

@end
