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

#import "GameLayer.h"
#import "types.h"
#import "GameController.h"
#import "SettingsController.h"
#import "nt_b2dsprite.h"
#import "nt_block.h"
#import "config.h"

#define OBJECT_DISTANCE_THRESHOLD 64
#define POOF_TAG 2312

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 300.0f;

const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;

const int32 MAXIMUM_NUMBER_OF_STEPS = 2; //was 25

const CGSize cliffSize = CGSizeMake(131, 238);

//pan/zoom scroll layer or move/rotate object?
//this needs to be global because of multiple calls
//in touches moved
static BOOL sendSuper = YES;

@interface GameLayer (Private)

- (void)step:(ccTime)dt;
- (void)updateAfterStep;

- (void)afterStart;
- (void)finish;

- (void)initPhysics;
- (void)createBoundingBodies;

- (CGPoint)convertTouchPointToWorldPoint:(CGPoint)aPoint;
- (b2Vec2)convertTouchPointToPhysicsPoint:(CGPoint)aPoint;
- (float)angleOnObjectTouch:(GameObjTouch *)aObj atPoint:(CGPoint)aPoint;
- (float)distanceFromObjectTouch:(GameObjTouch *)aObj atPoint:(CGPoint)aPoint;

@end


@implementation GameLayer
@synthesize gameDelegate = _gameDelegate;
@synthesize isEditing, isEditingPosition, snaps;
@synthesize editMode = m_editMode;

- (id)initWithLength:(float)aLength fans:(NSArray *)aFans blocks:(NSArray *)aBlocks coins:(NSArray *)aCoins
{
  self = [super init];
  if (self)
  { 
    sharedGC = [GameController sharedGameController];
    sharedSC = [SettingsController sharedSettingsController];
    
    [self setBounds:CGSizeMake(aLength, self.screenSize.height)];
    
    // init physics
    [self initPhysics];
    
    m_objects = [[NSMutableArray alloc] init];
    
    [m_objects addObjectsFromArray:aCoins];
    [m_objects addObjectsFromArray:aBlocks];
    [m_objects addObjectsFromArray:aFans];
    
    m_prevScale = 1.0f;
    m_prevPos = CGPointMake(0, 0);
    m_nCoins = 0;
    
    m_touchedObjects = [[NSMutableArray alloc] init];
    m_selectedObjects = [[NSMutableArray alloc] init];
    
    for (nt_object * o in m_objects)
    {
      [o setWorld:m_world];
      [self addChild:o];
    }
    
    m_player = [[nt_player alloc] initWithWorld:m_world atPosition:CGPointMake(cliffSize.width/2.0f, cliffSize.height)];
    m_player.tag = kTagPlayer;
    [self addChild:m_player z:5];
    
    [m_player setBallSize:sharedGC.ballSize];
    
    m_claw = [[nt_claw alloc] initWithPlayer:m_player];
    [self addChild:m_claw];
    
    self.isEditingPosition = NO;
    self.isEditing = NO;
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = YES;
    self.sticksToBottom = (self.highestPoint.y < self.screenSize.height);
    self.scrollY = !self.sticksToBottom;
    self.zooms = YES;
    m_editMode = kEditModeSingleSelection;
    //self.bounces = YES;
    
    //determine the minimum and maximum scale
    self.minimumScale = max(self.screenSize.width/self.bounds.width, 0.5);
    self.maximumScale = 1.0f;
    
    [self checkBounds];
    
    if (!self.isEditing)
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self zoomToScale:self.maximumScale/2.0f inTime:0.0f];
//    [self scrollToEndInTime:0.0f];
  }
  return self;
}


- (id)initWithLevel:(nt_level *)aLevel
{
  return [self initWithLength:aLevel.length fans:aLevel.fans blocks:aLevel.blocks coins:aLevel.coins];
}


- (void)dealloc
{
  delete m_world;
	m_world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
  
  delete m_contactListener;
  m_contactListener = nil;
  
  [m_player release];
  [m_claw release];
  [m_objects release];
  [m_touchedObjects release];
  [m_selectedObjects release];
	
	[super dealloc];
}


- (void)onEnter
{
  [super onEnter];
  [sharedGC edit];
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
//  if (sharedGC.state != kGameStatePaused)
//    [self scrollToStartInTime:1.5f];
}


- (void)onExit
{
  [super onExit];
  
}


- (b2World *)world
{
  return m_world;
}


- (nt_level *)level
{
  return [nt_level levelWithLength:m_bounds.width fans:self.fans blocks:self.blocks coins:self.coins];
}


- (NSMutableArray *)objects
{
  return m_objects;
}


- (NSMutableArray *)fans
{
  NSMutableArray * res = [NSMutableArray array];
  
  for (id o in m_objects)
    if ([o isKindOfClass:[nt_fan class]])
      [res addObject:(nt_fan *)o];
  
  return res;
}


- (NSMutableArray *)blocks
{
  NSMutableArray * res = [NSMutableArray array];
  
  for (id o in m_objects)
    if ([o isKindOfClass:[nt_block class]])
      [res addObject:(nt_block *)o];
  
  return res;
}


- (NSMutableArray *)coins
{
  NSMutableArray * res = [NSMutableArray array];
  
  for (id o in m_objects)
    if ([o isKindOfClass:[nt_coin class]])
      [res addObject:(nt_coin *)o];
  
  return res;
}


- (NSMutableArray *)collectedCoins
{
  NSMutableArray * res = [NSMutableArray array];
  
  for (nt_coin * c in self.coins)
    if (c.isEaten)
    {
      [res addObject:c];
    }
  
  return res;
}


- (CGPoint)highestPoint
{
  CGPoint res = CGPointMake(0, 0);
  
  for (nt_object * o in m_objects)
  {
    if (o.position.y > res.y)
    {
      res = o.position;
    }
  }
  
  return res;
}


- (CGPoint)farthestPoint
{
  CGPoint res = CGPointMake(0, 0);
  
  for (nt_object * o in m_objects)
  {
    if (o.position.x > res.x)
    {
      res = o.position;
    }
  }
  
  return res;
}


- (CGPoint)playerPoint
{
  return m_player.position;
}


- (CGPoint)goalPoint
{
  return m_finish.position;
}


- (uint)starsEarned
{
  return 3 - m_player.hurtLevel;
}


- (uint)coinsCollected
{
  return self.collectedCoins.count;
}


- (uint)score
{
  return 1000 * self.distanceRatio;
}


- (void)start
{
  if ([m_player isReset])
  {
    m_prevScale = self.scale;
    m_prevPos = self.position;
    m_animating = YES;
    m_distanceTraveled = CGPointMake(0, 0);
    m_prevDistanceTraveled = m_player.position;
    
    if (self.position.x != 0)
    {
      [self performSelector:@selector(afterStart) withObject:nil afterDelay:0.5];
      [self scrollToPosition:CGPointMake(0, 0) inTime:0.4f];
    }
    else
    {
      [self afterStart];
    }
    
    for (nt_fan * f in self.fans)
      [f setAnimating:YES];
    
    [m_player setShieldLevel:sharedGC.ballShield];
    [m_player activateShield];
    
    //[self zoomToNormalAnimated:YES];
    
    if ([self.gameDelegate respondsToSelector:@selector(gameLayerDidStart:)])
      [self.gameDelegate gameLayerDidStart:self];
  }
}


- (void)reset
{
  [sharedGC reset];
  [m_player reset];
  [m_claw hold];
  
  m_velocity = CGPointMake(0, 0);
  m_nCoins = 0;
  m_distanceTraveled = CGPointMake(0, 0);
  m_prevDistanceTraveled = m_player.position;
  m_animating = NO;
  
//  for (nt_object * o in m_objects)
//    [o resetMovement];
  
  for (nt_fan * f in self.fans)
    [f setAnimating:NO];
  
  for (nt_coin * a in self.coins)
    [a reset];
  
  [self zoomToScale:m_prevScale inTime:0.4f];
  [self scrollToPosition:m_prevPos inTime:0.4f];
  
  if ([self.gameDelegate respondsToSelector:@selector(gameLayerDidReset:)])
    [self.gameDelegate gameLayerDidReset:self];
}


- (void)killPlayer
{
  if (m_player.visible && m_player.finished != YES)
  {
    [self addPoofAtPoint:m_player.position];
    m_player.visible = NO;
    m_player.body->SetLinearVelocity(b2Vec2_zero);
    [self performSelector:@selector(reset) withObject:nil afterDelay:0.4];
    
    if ([self.gameDelegate respondsToSelector:@selector(gameLayerDidDie:)])
      [self.gameDelegate gameLayerDidDie:self];
  }
}


- (nt_block *)blockForBody:(b2Body *)aBody
{
  for (nt_block * b in self.blocks)
    if (b.body == aBody)
      return b;
  return nil;
}


- (nt_fan *)fanForBody:(b2Body *)aBody
{
  for (nt_fan * f in self.fans)
    if (f.body == aBody)
      return f;
  return nil;
}


- (nt_coin *)coinForBody:(b2Body *)aBody
{
  for (nt_coin * a in self.coins)
    if (a.body == aBody)
      return a;
  return nil;
}


- (void)addObject:(nt_object *)anObject
{
  [anObject setWorld:m_world];
  [self addChild:anObject];
  [m_objects addObject:anObject];
}


- (nt_object *)addObject:(nt_object *)anObject atTouch:(UITouch *)aTouch
{
  [self addObject:anObject];
  
  [m_touchedObjects removeAllObjects];
  
  GameObjTouch * objtouch = [[GameObjTouch alloc] init];
  objtouch.touch = aTouch;
  objtouch.object = [m_objects lastObject];
  [m_touchedObjects addObject:objtouch];
  [objtouch release];
  
  [m_selectedObjects removeAllObjects];
  
  [self addSelectedObject:[m_objects lastObject]];
  
  m_grabbed = YES;
  
  return [m_objects lastObject];
}


- (void)removeObject:(nt_object *)anObject
{
  if (anObject != NULL)
  {
    [self addPoofAtPoint:anObject.position];
    [anObject destroyBody];
    if (anObject.parent)
      [anObject removeFromParentAndCleanup:YES];
    [m_objects removeObject:anObject];
  }
}


- (void)removeAllObjects
{
  while (m_objects.count)
  {
    [self removeObject:[m_objects lastObject]];
  }
}


- (NSMutableArray *)touchedObjects
{
  return m_touchedObjects;
}


- (NSMutableArray *)selectedObjects
{
  return m_selectedObjects;
}


- (void)addSelectedObject:(nt_object *)anObject
{
  if (  anObject != nil &&
        [m_objects containsObject:anObject] &&
      ! [m_selectedObjects containsObject:anObject]
     )
  {
    [m_selectedObjects addObject:anObject];
  }
}


- (void)removeSelectedObject:(nt_object *)anObject
{
  if (  anObject != nil &&
      [m_objects containsObject:anObject] &&
      [m_selectedObjects containsObject:anObject]
     )
  {
    [m_selectedObjects removeObject:anObject];
  }
}


- (nt_object *)lastTouchedObject
{
  return m_lastTouchedObject;
}


- (nt_object *)objectClosestToPoint:(CGPoint)aPoint inArray:(NSArray *)aArray
{
  nt_object * res = nil;
  float prevDist = 100000;
  float d = 100000;
  CGPoint objPoint = CGPointZero;
  
  for (nt_object * o in aArray)
  {
    objPoint = o.position;
    
    if ([o isKindOfClass:[nt_fan class]] && !self.isEditing)
    {
      //place the object point at the tip of the fan's arrow
      objPoint = [self convertToNodeSpace:[(nt_fan *)o tip]];
    }
    
    d = sqrtf(powf(objPoint.x - aPoint.x, 2) + powf(objPoint.y - aPoint.y, 2));
    
    if (d < OBJECT_DISTANCE_THRESHOLD && (d < prevDist || m_selectedObjects.count > 0))
    {
      prevDist = d;
      o.isEditingPosition = (d < OBJECT_DISTANCE_THRESHOLD/2);
      res = o;
      
      //take the already selected object over others
      if (res != nil && [self isObjectSelected:res])
        return res;
    }
  }
  
  return res;
}


- (nt_object *)objectClosestToPoint:(CGPoint)aPoint
{
  return [self objectClosestToPoint:aPoint inArray:self.objects];
}


- (nt_fan *)fanClosestToPoint:(CGPoint)aPoint
{
  return (nt_fan *)[self objectClosestToPoint:aPoint inArray:self.fans];
}


- (nt_block *)blockClosestToPoint:(CGPoint)aPoint
{
  return (nt_block *)[self objectClosestToPoint:aPoint inArray:self.blocks];
}


- (nt_coin *)coinClosestToPoint:(CGPoint)aPoint
{
  return (nt_coin *)[self objectClosestToPoint:aPoint inArray:self.coins];
}


- (BOOL)isTouchingPlayerAtPoint:(CGPoint)aPoint
{
  return (CGRectContainsPoint(m_player.boundingBox, aPoint));
}


- (BOOL)isObjectSelected:(nt_object *)anObject
{
  if (anObject == nil)
    return NO;
  return [m_selectedObjects containsObject:anObject];
}


- (void)collectCoins:(NSArray *)aCoins
{
  for (NSValue * v in aCoins)
  {
    CGPoint p = [v CGPointValue];
    for (nt_coin * c in self.coins)
    {
      if (CGPointEqualToPoint(p, c.originalPosition))
      {
        [c eatMe];
      }
    }
  }
}


- (void)addPoofAtPoint:(CGPoint)aPoint
{
  CCParticleSystemQuad * p = [[CCParticleSystemQuad alloc] initWithFile:@"confetti.plist"];
  p.position = aPoint;
  p.tag = POOF_TAG;
  [self addChild:p z:5];
  p.autoRemoveOnFinish = YES;
  [p release];
}


- (void)addFireWorks:(NSNumber *)aCount
{
  int width = self.screenSize.width;
  int height = self.screenSize.height;
  NSNumber * nextNum = [NSNumber numberWithInt:aCount.intValue-1];
  
  [self addPoofAtPoint:CGPointMake(rand() % width, rand() % height)];
  
  if (nextNum.intValue > 0)
  {
    [self performSelector:@selector(addFireWorks:) withObject:nextNum afterDelay:1.0f];
  }
}


- (void)addBounds:(CGSize)aBounds
{
  CGSize newBounds = CGSizeMake(m_bounds.width + aBounds.width, m_bounds.height + aBounds.height);
  
  if (newBounds.width >= STANDARD_SCREEN_WIDTH)
  {
    [self setBounds:newBounds];
    
    m_finish.position = CGPointMake(m_finish.position.x + aBounds.width, m_finish.position.y + aBounds.height);
    m_wall->SetTransform(b2Vec2(m_wall->GetPosition().x + aBounds.width, m_wall->GetPosition().y + aBounds.height), 0);
  }
}


- (void)checkBounds
{
  if (self.farthestPoint.x > self.bounds.width)
  {
    while (self.farthestPoint.x > self.bounds.width)
    {
      [self addBounds:CGSizeMake(self.screenSize.width/2, 0)];
    }
  }
  else if (self.farthestPoint.x < self.bounds.width - STANDARD_SCREEN_WIDTH)
  {
    while (self.farthestPoint.x < self.bounds.width - STANDARD_SCREEN_WIDTH)
    {
      [self addBounds:CGSizeMake(-self.screenSize.width/2, 0)];
    }
  }
  
  //set the new bounds height based on the derived minimum scale
  [self setBounds:CGSizeMake(self.bounds.width, self.screenSize.height*(1/max(self.screenSize.width/self.bounds.width, 0.5)))];
  
  //if a location of an object in the game is higher than the bounds
  //adjust the bounds to enclose the highest object
  if (self.highestPoint.y > self.bounds.height)
  {
    [self setBounds:CGSizeMake(self.bounds.width, self.highestPoint.y + m_player.contentSize.height)];
  }
}


- (void)setPreviousScale:(float)aPreviousScale
{
  m_prevScale = aPreviousScale;
}


- (void)setPreviousPos:(CGPoint)aPreviousPos
{
  m_prevPos = aPreviousPos;
}


- (void)update:(ccTime)dt
{
  if (sharedGC.state == kGameStatePaused)
    return;
  
  //follow the player before checking bounds
  if (sharedGC.state == kGameStateRunning)
  {
    CGPoint position = CGPointMake(m_player.body->GetPosition().x*PTM_RATIO, m_player.body->GetPosition().y*PTM_RATIO);
    CGPoint pos = self.position;
    
    if (position.x > self.screenSize.width / 2.0f || position.y > self.screenSize.height / 2.0f)
    {
      pos.x = -MIN(m_bounds.width - self.screenSize.width, position.x - self.screenSize.width / 2.0f);
      pos.y = -MIN(m_bounds.height - self.screenSize.height, position.y - self.screenSize.height / 2.0f);
      pos = ccpMult(pos, self.scale);
      m_velocity = CGPointMake(pos.x - self.position.x, 0);
      self.position = pos;
    }
    
    CGPoint delta = CGPointMake(fabsf(m_player.position.x - m_prevDistanceTraveled.x), fabsf(m_player.position.y - m_prevDistanceTraveled.y));
    m_distanceTraveled = ccpAdd(m_distanceTraveled, delta);
    m_prevDistanceTraveled = m_player.position;
    
    if (m_distanceTraveled.y != 0)
    {
      self.distanceRatio = m_distanceTraveled.x/m_distanceTraveled.y;
    }
  }
  
  [super update:dt];
  
  [self step:dt];
}


- (void)draw
{
	[super draw];

	if (sharedSC.debugging)
  {
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
    kmGLPushMatrix();
    
    m_world->DrawDebugData();
    
    kmGLPopMatrix();
  }
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (m_animating)
    return;
  
  [super ccTouchesBegan:touches withEvent:event];
  
  m_lastTouchedObject = nil;
  
  for (UITouch * touch in touches.allObjects)
  {
    CGPoint adjLoc = [self convertTouchPointToWorldPoint:[touch locationInView:touch.view]];
    BOOL taken = FALSE;
    nt_object * obj;
    
    if (self.isEditing)
      obj = [self objectClosestToPoint:adjLoc];
    else
      obj = [self fanClosestToPoint:adjLoc];
    
    m_grabbed = [self isObjectSelected:obj];
    
    for (GameObjTouch * ot in m_touchedObjects)
      if (ot.object == obj)
      {
        ot.touch = touch;
        taken = TRUE;
      }
    
    if (obj != nil && !taken)
    {
      GameObjTouch * objtouch = [[GameObjTouch alloc] init];
      objtouch.touch = touch;
      objtouch.object = obj;
      m_lastTouchedObject = obj;
      [m_touchedObjects addObject:objtouch];
      [objtouch release];
    }
  }
  
  sendSuper = YES;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (m_animating)
    return;
  
  if (touches.count > 2 && self.isEditing)
    sendSuper = NO;
  
  for (UITouch * touch in touches.allObjects)
  {
    GameObjTouch * objtouch = nil;
    
    for (GameObjTouch * ot in m_touchedObjects)
      if (ot.touch == touch)
        objtouch = ot;
    
    if (objtouch != nil)
    {
      if (sharedGC.state == kGameStateEditing)
      {
        if (objtouch.object != nil)
        {
          if (objtouch.object.body)
          {
            CGPoint location =      [touch locationInView:touch.view];
            CGPoint prevLocation =  [touch previousLocationInView:touch.view];
            CGPoint adjLoc =        [self convertTouchPointToWorldPoint:location];
            CGPoint prevAdjLoc =    [self convertTouchPointToWorldPoint:prevLocation];
            
            float distance = [self distanceFromObjectTouch:objtouch atPoint:location];
            float prevDistance = [self distanceFromObjectTouch:objtouch atPoint:prevLocation];
            
            float angleInDegrees =      [self angleOnObjectTouch:objtouch atPoint:location];
            float prevAngleInDegrees =  [self angleOnObjectTouch:objtouch atPoint:prevLocation];
            float changeInAngle =       angleInDegrees - prevAngleInDegrees;
            
            if (self.isEditing)
            { 
              if (m_selectedObjects.count > 0 && m_grabbed)
              {
                for (nt_object * o in m_selectedObjects)
                {
                  if (o.isEditingPosition || m_selectedObjects.count > 1)
                  {
                    CGPoint deltaPos = CGPointMake(adjLoc.x - prevAdjLoc.x, adjLoc.y - prevAdjLoc.y);
                    [o setPosition:ccpAdd(o.position, deltaPos)];
                  }
                  else
                  {
                    [o setAngle:o.angle + changeInAngle];
                  }
                  sendSuper = NO;
                }
              }
            }
            else
            {
              if ([objtouch.object isKindOfClass:[nt_fan class]])
              {
                if ([(nt_fan *)objtouch.object power] > 1.0f)
                {
                  //usually small adjustments
                  [objtouch.object setAngle:objtouch.object.angle + changeInAngle];
                }
                else
                {
                  //usually first adjustment. Turn fan completely.
                  [objtouch.object setAngle:angleInDegrees];
                }
                
                if (distance < [(nt_fan *)objtouch.object maxPower])
                {
                  [(nt_fan *)objtouch.object setPower:[(nt_fan *)objtouch.object power] + (distance - prevDistance)];
                }
                else
                {
                  [(nt_fan *)objtouch.object setPower:distance];
                }
                
                sendSuper = NO;
              }
            }
          }
        }
      }
    }
  }
  
  if (sendSuper)
  {
    [super ccTouchesMoved:touches withEvent:event];
  }
  
  m_dragged = YES; //hack since super isn't always called
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super ccTouchesEnded:touches withEvent:event];
  
  UITouch * touch = [touches anyObject];
  CGPoint adjLoc = [self convertTouchPointToWorldPoint:[touch locationInView:touch.view]];
  
  if (!self.isEditing && !m_dragged)
  {
    if ([self isTouchingPlayerAtPoint:adjLoc])
    {
      if (sharedGC.state == kGameStateRunning)
      {
        [self reset];
      }
      else
      {
        [self start];
      }
    }
  }
  
  if (m_animating)
    return;
  
  if (!m_dragged)
  {
    if (m_editMode == kEditModeSingleSelection || m_editMode == kEditModeMultipleSelection)
    {
      if (m_editMode == kEditModeSingleSelection)
        [m_selectedObjects removeAllObjects];
      
      nt_object * close = [self objectClosestToPoint:adjLoc];
      
      if (close != nil)
      {
        if (m_selectedObjects.count > 0)
        {
          BOOL found = NO;
          
          for (nt_object * o in m_selectedObjects)
          {
            if (o == close)
            {
              found = YES;
            }
          }
          
          if (found)
          {
            [self removeSelectedObject:close];
          }
          else
          {
            [self addSelectedObject:close];
          }
        }
        else
        {
          [self addSelectedObject:close];
        }
      }
      else
      {
        [m_selectedObjects removeAllObjects];
      }
    }
    else if (m_editMode == kEditModeSingleDeletion)
    {
      [self removeObject:[self objectClosestToPoint:adjLoc]];
    }
  }
  
  for (nt_object * o in m_selectedObjects)
  {
    if (self.snaps)
      [o checkSnap];
  }
  
  NSMutableArray * deletedObjects = [[NSMutableArray alloc] init];
  
  for (UITouch * touch in touches.allObjects)
    for (GameObjTouch * t in m_touchedObjects)
      if (t.touch == touch)
      {
        m_lastTouchedObject = t.object;
        [deletedObjects addObject:t];
      }
  
  for (GameObjTouch * t in deletedObjects)
    [m_touchedObjects removeObject:t];
  
  [deletedObjects release];
  
  if (sharedGC.state == kGameStateEditing)
  {
    if (self.isEditing)
    {
      if (!m_dragged && CGRectContainsPoint(CGRectMake(m_bounds.width - 100, 0, 100, m_bounds.height/2), adjLoc))
        [self addBounds:CGSizeMake(self.screenSize.width/2, 0)];
      if (!m_dragged && CGRectContainsPoint(CGRectMake(0, 0, 100, m_bounds.height/2), adjLoc))
        [self addBounds:CGSizeMake(-self.screenSize.width/2, 0)];
    }
  }
}


- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesCancelled:touches withEvent:event];
  
  NSMutableArray * deletedObjects = [[NSMutableArray alloc] init];
  
  for (UITouch * touch in touches.allObjects)
    for (GameObjTouch * t in m_touchedObjects)
      if (t.touch == touch)
        [deletedObjects addObject:t];
  
  for (GameObjTouch * t in deletedObjects)
    [m_touchedObjects removeObject:t];
  
  [deletedObjects release];
}


- (void)step:(ccTime)dt
{
  float32 frameTime = dt;
  int stepsPerformed = 0;
  while ((frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS))
  {
    float32 deltaTime = std::min(frameTime, FIXED_TIMESTEP);
    frameTime -= deltaTime;
    if (frameTime < MINIMUM_TIMESTEP)
    {
      deltaTime += frameTime;
      frameTime = 0.0f;
    }
    m_world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
    stepsPerformed++;
    [self updateAfterStep];
  }
  m_world->ClearForces();
}


- (void)updateAfterStep
{
  if (sharedGC.state != kGameStateRunning)
    return;
  
  //collisions
  std::vector<MyContact>::iterator cont;
  for(cont = m_contactListener->_contacts.begin(); cont != m_contactListener->_contacts.end(); ++cont)
  {
    MyContact contact = *cont;
    
    b2Body *bodyB = contact.fixtureB->GetBody();
    b2Body *bodyA = contact.fixtureA->GetBody();
    
    if (bodyA != NULL && bodyB != NULL)
    {
      if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
      {
        CCNode * uA = (CCNode *)bodyA->GetUserData();
        CCNode * uB = (CCNode *)bodyB->GetUserData();
        
//        if (uA.tag == kTagFan && uB.tag == kTagPlayer)
//        {
//          nt_fan * f = [self fanForBody:bodyA];
//          if (f != nil)
//            [f updateOnBody:bodyB];
//        }
//        else if (uB.tag == kTagFan && uA.tag == kTagPlayer)
//        {
//          nt_fan * f = [self fanForBody:bodyB];
//          if (f != nil)
//            [f updateOnBody:bodyA];
//        }
        
        if (uA.tag == kTagFan && uB.tag == kTagPlayer)
        {
          b2Fixture * fix = contact.fixtureA;
          nt_fan * fan = [self fanForBody:bodyA];
          if (fan != nil)
          {
            if ([fan fixtureIsWind:fix])
            {
              [fan updateOnBody:bodyB];
            }
            else if ([fan fixtureIsFan:fix])
            {
              [self killPlayer];
            }
          }
        }
        else if (uB.tag == kTagFan && uA.tag == kTagPlayer)
        {
          b2Fixture * fix = contact.fixtureB;
          nt_fan * fan = [self fanForBody:bodyB];
          if (fan != nil)
          {
            if ([fan fixtureIsWind:fix])
            {
              [fan updateOnBody:bodyA];
            }
            else if ([fan fixtureIsFan:fix])
            {
              [self killPlayer];
            }
          }
        }
        
        if ((uA.tag == kTagFinish && uB.tag == kTagPlayer) || (uB.tag == kTagFinish && uA.tag == kTagPlayer))
        {
          static int finishCount = 0;
          
          if (finishCount > 5 && m_player.finished == NO)
          {
            m_player.finished = YES;
            finishCount = 0;
            
            //[self performSelector:@selector(addFireWorks:) withObject:[NSNumber numberWithInt:10] afterDelay:2.0f];
            
            [self scheduleOnce:@selector(finish) delay:2.0f];
          }
          
          finishCount++;
        }
        
        if ((uA.tag == kTagBlock && uB.tag == kTagPlayer) || (uB.tag == kTagBlock && uA.tag == kTagPlayer))
        {
          [m_player getHurt];
          
          if ([self.gameDelegate respondsToSelector:@selector(gameLayer:didKnockOnWood:)])
            [self.gameDelegate gameLayer:self didKnockOnWood:m_player.hurtLevel];
          
          if (m_player.isDead && sharedGC.state == kGameStateRunning)
          {
            [self killPlayer];
          }
        }
        
        if (uA.tag == kTagCoin && uB.tag == kTagPlayer)
        {
          nt_coin * a = [self coinForBody:bodyA];
          if (a != nil)
          {
            if ([a eatMe])
            {
              m_nCoins++;
              if ([self.gameDelegate respondsToSelector:@selector(gameLayer:didEatCoin:)])
                [self.gameDelegate gameLayer:self didEatCoin:m_nCoins];
            }
          }
        }
        else if (uB.tag == kTagCoin && uA.tag == kTagPlayer)
        {
          nt_coin * a = [self coinForBody:bodyA];
          if (a != nil)
          {
            if ([a eatMe])
            {
              m_nCoins++;
              if ([self.gameDelegate respondsToSelector:@selector(gameLayer:didEatCoin:)])
                [self.gameDelegate gameLayer:self didEatCoin:m_nCoins];
            }
          }
        }
        
        if ((uA.tag == kTagGround && uB.tag == kTagPlayer) || (uB.tag == kTagGround && uA.tag == kTagPlayer))
        {
          if (sharedGC.state == kGameStateRunning)
          {
            [self killPlayer];
          }
        }
      }
    }
  }
}


- (void)afterStart
{
  [sharedGC start];
  [m_player launch];
  [m_claw drop];
  m_animating = YES;
}


- (void)finish
{
  if ([self.gameDelegate respondsToSelector:@selector(gameLayerDidFinish:)])
    [self.gameDelegate gameLayerDidFinish:self];
  
  for (nt_fan * f in self.fans)
    [f setAnimating:NO];
}


- (void)setBounds:(CGSize)aBounds
{
  [super setBounds:aBounds];
  [self createBoundingBodies];
}


- (void)initPhysics
{
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	m_world = new b2World(gravity);
	
	m_world->SetAllowSleeping(true);
	
	m_world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	m_world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
  
  m_contactListener = new MyContactListener();
  m_world->SetContactListener(m_contactListener);
  
  [self createBoundingBodies];
  
  b2BodyDef bDef;
  b2FixtureDef bFix;
  b2PolygonShape bShape;
  b2Body * bBody;
  
  //cliffs
  bDef.type = b2_staticBody;
  bDef.allowSleep = true;
  
  bFix.shape = &bShape;
  bFix.density = 1.0f;
  bFix.friction = 1.0f;
  
  CCSprite * temp = [[CCSprite alloc] initWithFile:@"goal.png"];
  
  bShape.SetAsBox((temp.contentSize.width/16)/PTM_RATIO, temp.contentSize.height/(2*PTM_RATIO));
  bDef.position.Set((m_bounds.width - temp.contentSize.width + temp.contentSize.width/16 - 1)/(PTM_RATIO), temp.contentSize.height/(2*PTM_RATIO));
  
  [temp release];
  
  m_wall = m_world->CreateBody(&bDef);
  m_wall->CreateFixture(&bFix);
  
  //bottom sensor
  CCNode * ground = [CCNode node];
  [self addChild:ground];
  ground.tag = kTagGround;
  bDef.position.Set(0, 0);
  bDef.type = b2_staticBody;
  bDef.allowSleep = true;
  
  bShape.SetAsBox(m_bounds.width/PTM_RATIO, 30/PTM_RATIO);
  
  bFix.shape = &bShape;
  bFix.density = 1.0f;
  bFix.friction = 1.0f;
  bFix.isSensor = true;
  
  bBody = m_world->CreateBody(&bDef);
  bBody->CreateFixture(&bFix);
  
  bBody->SetUserData(ground);
  
  //finish sensor
  m_finish = [[nt_object alloc] initWithFile:@"goal.png"];
  [self addChild:m_finish z:10 tag:kTagFinish];
  bDef.position.Set((m_bounds.width - m_finish.contentSize.width/2)/PTM_RATIO, (m_finish.contentSize.height/2.0f)/PTM_RATIO);
  bDef.type = b2_staticBody;
  bDef.allowSleep = true;
  
  bShape.SetAsBox(m_finish.contentSize.width/(2*PTM_RATIO), m_finish.contentSize.height/(2*PTM_RATIO));
  
  bFix.shape = &bShape;
  bFix.density = 1.0f;
  bFix.friction = 1.0f;
  bFix.isSensor = true;
  
  bBody = m_world->CreateBody(&bDef);
  bBody->CreateFixture(&bFix);
  
  [m_finish setBody:bBody];
}


- (void)createBoundingBodies
{
  if (!m_world)
    return;
  
  if (m_groundBody != NULL)
  {
    m_world->DestroyBody(m_groundBody);
    m_groundBody = NULL;
  }
  
  // Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
  CGSize s = m_bounds;
  
  m_groundBody = m_world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(0, 0), b2Vec2(s.width/PTM_RATIO, 0));
	m_groundBody->CreateFixture(&groundBox,0);
	
	// top
  //	groundBox.Set(b2Vec2(0, s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO, s.height/PTM_RATIO));
  //	m_groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0, s.height*4/PTM_RATIO), b2Vec2(0, 0));
	m_groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO, s.height*4/PTM_RATIO), b2Vec2(s.width/PTM_RATIO, 0));
	m_groundBody->CreateFixture(&groundBox,0);
}


- (CGPoint)convertTouchPointToWorldPoint:(CGPoint)aPoint
{
  aPoint = [[CCDirector sharedDirector] convertToGL:aPoint];
  
  return [self convertToNodeSpace:aPoint];
}


- (b2Vec2)convertTouchPointToPhysicsPoint:(CGPoint)aPoint
{
  CGPoint adjLoc = [self convertTouchPointToWorldPoint:aPoint];
  
  return b2Vec2(adjLoc.x/PTM_RATIO, adjLoc.y/PTM_RATIO);
}


- (float)angleOnObjectTouch:(GameObjTouch *)aObj atPoint:(CGPoint)aPoint
{
  b2Vec2 objPoint = aObj.object.body->GetWorldCenter();
  
  b2Vec2 touchPoint = [self convertTouchPointToPhysicsPoint:aPoint];
  
  CGPoint dt = CGPointMake(objPoint.x - touchPoint.x, objPoint.y - touchPoint.y);
  
  return atan2(dt.y, dt.x) * 180 / b2_pi + 90;
}


- (float)distanceFromObjectTouch:(GameObjTouch *)aObj atPoint:(CGPoint)aPoint
{
  b2Vec2 objPoint = aObj.object.body->GetWorldCenter();
  
  b2Vec2 touchPoint = [self convertTouchPointToPhysicsPoint:aPoint];
  
  return sqrtf(powf(objPoint.x - touchPoint.x, 2) + powf(objPoint.y - touchPoint.y, 2));
}


@end
