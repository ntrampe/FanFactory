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

#import "LevelEditingScene.h"
#import "nt_button.h"
#import "GameScene.h"
#import "GameController.h"
#import "CCSprite+StretchableImage.h"
#import "nt_attribute.h"
#import "config.h"

@interface LevelEditingScene (Private)

- (void)addObjectForTag:(int)aTag atTouch:(UITouch *)aTouch;
- (void)handleLongPress;

- (void)checkGuides;
- (void)enableGuides:(BOOL)shouldEnable;

- (void)drawDashedLineFromOrigin:(CGPoint)aOrigin toDestination:(CGPoint)aDestination;

@end

static BOOL edit = YES;

@implementation LevelEditingScene

+ (CCScene *)sceneWithLevelDocument:(LevelDocument *)aLevel
{
  CCScene *scene = [CCScene node];
	
	LevelEditingScene * layer = [[LevelEditingScene alloc] initWithLevelDocument:aLevel];
  
  [scene addChild:layer];
  
  [layer release];
	
	return scene;
}

- (id)initWithLevelDocument:(LevelDocument *)aLevel
{
  self = [super initWithLevel:aLevel.level];
  
  if (self) 
  {
    m_document = [aLevel retain];
    
    float scale = self.screenSize.width / STANDARD_SCREEN_WIDTH;
    
    sharedGC = [GameController sharedGameController];
    
    m_game.isEditing = YES;
    m_game.minimumScale = 0.5f;
    m_game.maximumScale = 2.0f;
    m_game.scrollX = m_game.scrollY = YES;
    m_game.snaps = YES;
    m_game.sticksToBottom = NO;
    m_game.drawBounds = YES;
    
    m_game.isBounded = YES;
    m_game.scale = max(self.screenSize.width/m_game.bounds.width, 0.5);
    [m_game update:0.03];
    m_game.isBounded = NO;
    
    [self enableGuides:NO];
    
    m_trashcan = [CCSprite spriteWithFile:@"trashcan.png"];
    m_trashcan.tag = kTagTrashCan;
    m_trashcan.scale = scale;
    m_trashcan.position = CGPointMake(m_trashcan.contentSize.width*m_trashcan.scale/2, self.screenSize.height - m_trashcan.contentSize.height*m_trashcan.scale/2);
    [self addChild:m_trashcan z:-4];
    
    m_white = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 50) width:self.screenSize.width height:m_trashcan.contentSize.height*m_trashcan.scale];
    m_white.position = CGPointMake(0, self.screenSize.height - m_white.contentSize.height);
    [self addChild:m_white z:-5];
    
    m_palleteObjects = [[NSMutableArray alloc] init];
    
    NSArray * names = [NSArray arrayWithObjects:@"block_long_small.png", @"block_long_large.png", @"block_square_small.png", @"block_square_large.png", @"block_triangle_hole.png", @"block_triangle_whole.png", @"block_circle.png", @"fan_1.png", @"coin.png", nil];
    
    float offset = m_trashcan.contentSize.width*scale + 30;
    
    for (int x = 0; x < names.count; x++)
    {
      CCSprite * s;
      if (x == 8)
        s = [CCSprite spriteWithFile:[names objectAtIndex:x]];
      else
        s = [CCSprite spriteWithSpriteFrameName:[names objectAtIndex:x]];
      s.tag = x;
      s.scale = scale;
      s.position = CGPointMake(offset, self.screenSize.height - 50*scale);
      offset += 100*scale;
      [self addChild:s z:-5];
      [m_palleteObjects addObject:s];
    }
    
    m_defaultObject = [[nt_object alloc] initWithPosition:CGPointZero angle:0];
    m_palleteShowing = NO;
    m_white.opacity = 0.0f;
    
    m_rectSelection = NO;
    m_selectionRect = CGRectZero;
  }
  return self;
}


- (void)dealloc
{
  [m_document release];
  [m_palleteObjects release];
  [m_defaultObject release];
  //[m_title release];
  [super dealloc];
}


- (void)onEnter
{
  [super onEnter];
  
  [self showPallete];
}


- (void)onExit
{
  [super onExit];
  [m_document setLevel:m_game.level];
  [m_document updateChangeCount:UIDocumentChangeDone];
  [m_document closeWithCompletionHandler:nil];
}


- (void)visit
{
  [super visit];
  
  if (m_rectSelection)
  {
    glLineWidth(4.0f);
    
    CGPoint destination = ccpAdd(m_selectionRect.origin, CGPointMake(m_selectionRect.size.width, m_selectionRect.size.height));
    CGPoint origin = m_selectionRect.origin;
    
    CGPoint org1 = CGPointMake(origin.x, origin.y);
    CGPoint org2 = CGPointMake(destination.x, origin.y);
    CGPoint org3 = CGPointMake(destination.x, destination.y);
    CGPoint org4 = CGPointMake(origin.x, destination.y);
    CGPoint dest1 = CGPointMake(destination.x, origin.y);
    CGPoint dest2 = CGPointMake(destination.x, destination.y);
    CGPoint dest3 = CGPointMake(origin.x, destination.y);
    CGPoint dest4 = CGPointMake(origin.x, origin.y);
    
    [self drawDashedLineFromOrigin:org1  toDestination:dest1];
    [self drawDashedLineFromOrigin:org2  toDestination:dest2];
    [self drawDashedLineFromOrigin:org3  toDestination:dest3];
    [self drawDashedLineFromOrigin:org4  toDestination:dest4];
    
    //for loop for filled circles
    for (int i = 0; i < 6; i++)
    {
      ccDrawCircle(org1, i, 0, 10, NO);
      ccDrawCircle(org2, i, 0, 10, NO);
      ccDrawCircle(org3, i, 0, 10, NO);
      ccDrawCircle(org4, i, 0, 10, NO);
    }
  }
}


- (void)hidePallete
{
  if (m_palleteShowing)
  {
    for (CCNode * child in self.children)
    {
      if ([child isKindOfClass:[CCSprite class]] && child.tag != BG_TAG && child.tag != kTagTrashCan)
      {
        CCSprite * s = (CCSprite *)child;
        [s runAction:[CCFadeOut actionWithDuration:0.2f]];
      }
    }
    [m_white runAction:[CCFadeTo actionWithDuration:0.2f opacity:0.0f]];
    m_palleteShowing = NO;
  }
}


- (void)showPallete
{
  if (!m_palleteShowing)
  {
    for (CCNode * child in self.children)
    {
      if ([child isKindOfClass:[CCSprite class]] && child.tag != BG_TAG && child.tag != kTagTrashCan)
      {
        CCSprite * s = (CCSprite *)child;
        [s runAction:[CCFadeIn actionWithDuration:0.2f]];
      }
    }
    [m_white runAction:[CCFadeTo actionWithDuration:0.4f opacity:50]];
    m_palleteShowing = YES;
  }
}


- (void)testLevel
{
  sharedGC.testing = YES;
  [self goToScene:[GameScene sceneWithLevel:m_game.level]];
}


- (void)emailLevel
{
  if ([MFMailComposeViewController canSendMail])
  {
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:@"New Fan Factory Level!"];
    [mailController setMessageBody:@"I made a new level check it out!" isHTML:NO];
    
    NSData * attachment = m_level.data;
    NSString * attachmentName = m_document.name;
    
    [mailController addAttachmentData:attachment mimeType:@"dat" fileName:attachmentName];
    [mailController setMailComposeDelegate:self];
    [self presentViewController:mailController animated:YES];
    [mailController release];
  }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self.rootViewController.modalViewController dismissModalViewControllerAnimated:YES];
}


- (void)addObjectForTag:(int)aTag atTouch:(UITouch *)aTouch
{ 
  //nt_attribute * attribute = [nt_attribute attributeWithMovement:move time:animTime distance:50.0f invert:invert];
  CGPoint location = [aTouch locationInView:aTouch.view];
  location = [[CCDirector sharedDirector] convertToGL:location];
  CGPoint adjLoc = [m_game convertToNodeSpace:location];
  
  if (aTag == 7)
  {
    nt_fan * f = [[nt_fan alloc] initWithPosition:adjLoc angle:0.0f attributes:m_defaultObject.attributes];
    [f setPower:1.0f];
    [f enableGuide:edit];
    [m_game addObject:f atTouch:aTouch];
    [f release];
  }
  else if (aTag == 8)
  {
    nt_coin * a = [[nt_coin alloc] initWithPosition:adjLoc angle:0.0f attributes:m_defaultObject.attributes];
    [a enableGuide:edit];
    [m_game addObject:a atTouch:aTouch];
    [a release];
  }
  else
  {
    nt_block * b = [[nt_block alloc] initWithPosition:adjLoc angle:0.0f attributes:m_defaultObject.attributes];
    [b setType:(kBlockType)aTag];
    [b enableGuide:edit];
    [m_game addObject:b atTouch:aTouch];
    [b release];
  }
  
  if (edit)
  {
    [self checkGuides];
  }
}


- (void)handleLongPress
{
  if (m_game.selectedObjects.count > 0)
  {
    UINavigationController * n;
    if (m_game.selectedObjects.count > 1)
    {
      MultipleObjectsViewController * v = [[MultipleObjectsViewController alloc] initWithObjects:m_game.selectedObjects];
      v.modalPresentationStyle = UIModalPresentationCurrentContext;
      v.delegate = self;
      
      n = [[UINavigationController alloc] initWithRootViewController:v];
      [v release];
    }
    else
    {
      ObjectAttributesViewController * v = [[ObjectAttributesViewController alloc] initWithObjects:m_game.selectedObjects];
      v.modalPresentationStyle = UIModalPresentationCurrentContext;
      v.delegate = self;
      
      n = [[UINavigationController alloc] initWithRootViewController:v];
      [v release];
    }
    
    
    n.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:n animated:YES];
    [n release];
  }
}


- (void)checkGuides
{
  for (nt_object * o in m_game.objects)
  {
    [o enableGuide:[m_game isObjectSelected:o]];
  }
}


- (void)enableGuides:(BOOL)shouldEnable
{
  for (nt_object * o in m_game.objects)
  {
    [o enableGuide:shouldEnable];
  }
}


- (void)drawDashedLineFromOrigin:(CGPoint)aOrigin toDestination:(CGPoint)aDestination
{
  float dashLength = 3.0f;
  
  CGPoint delta = ccpSub(aDestination, aOrigin);
  float dist = ccpDistance(aOrigin, aDestination);
  float x = delta.x / dist * dashLength;
  float y = delta.y / dist * dashLength;
  float linePercentage = 0.5f;
  
  CGPoint p1 = aOrigin;
  for(float i = 0; i <= dist / dashLength * linePercentage; i++)
  {
    CGPoint p2 = CGPointMake(p1.x + x, p1.y + y);
    ccDrawLine(p1, p2);
    p1 = CGPointMake(p1.x + x / linePercentage, p1.y + y / linePercentage);
  }
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch * touch = [touches anyObject];
  CGPoint location = [touch locationInView:touch.view];
  location = [[CCDirector sharedDirector] convertToGL:location];
  
  for (CCNode * child in self.children)
  {
    if ([child isKindOfClass:[CCSprite class]])
    {
      //make the sprites easier to grab
      CGRect newBounds = CGRectMake(child.boundingBox.origin.x, self.screenSize.height - m_trashcan.contentSize.height*m_trashcan.scaleY, child.boundingBox.size.width, m_trashcan.contentSize.height);
      
      if (CGRectContainsPoint(newBounds, location))
      {
        int tag = child.tag;
        if (tag != 999 && tag != kTagTrashCan) //background and trash can tag
        {
          [self addObjectForTag:tag atTouch:touch];
          //[self hidePallete];
        }
      }
    }
  }
  
  [self scheduleOnce:@selector(handleLongPress) delay:0.4f];
  
  CGPoint avgLoc = CGPointMake(0, 0);
  
  for (UITouch * touch in touches.allObjects)
  {
    CGPoint loc = [touch locationInView:touch.view];
    loc = [[CCDirector sharedDirector] convertToGL:loc];
    
    avgLoc = ccpAdd(avgLoc, loc);
  }
  
  avgLoc.x /= touches.count;
  avgLoc.y /= touches.count;
  
  m_rectSelection = (touches.count == 3 && m_game.editMode != kEditModeSingleDeletion);
  m_selectionRect.origin = avgLoc;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self unschedule:@selector(handleLongPress)];
  
  if (touches.count == 3 && m_game.editMode != kEditModeSingleDeletion)
  {
    CGPoint avgLoc = CGPointMake(0, 0);
    
    for (UITouch * touch in touches.allObjects)
    {
      CGPoint loc = [touch locationInView:touch.view];
      loc = [[CCDirector sharedDirector] convertToGL:loc];
      
      avgLoc = ccpAdd(avgLoc, loc);
    }
    
    avgLoc.x /= touches.count;
    avgLoc.y /= touches.count;
    
    if (!m_rectSelection)
    {
      m_rectSelection = YES;
      m_selectionRect.origin = avgLoc;
    }
    
    m_selectionRect.size = CGSizeMake(avgLoc.x - m_selectionRect.origin.x, avgLoc.y - m_selectionRect.origin.y);
  }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
  CGPoint location = [touch locationInView:touch.view];
  location = [[CCDirector sharedDirector] convertToGL:location];
  
  if (CGRectContainsPoint(m_trashcan.boundingBox, location))
  {
    if (touch.tapCount > 1)
    {
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to clear your level?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
      [alert show];
      [alert release];
    }
    
    if ([m_game isObjectSelected:[m_game objectClosestToPoint:[m_game convertToNodeSpace:location]]])
    {
      for (nt_object * o in m_game.selectedObjects)
        [m_game removeObject:o];
      
      [m_game.selectedObjects removeAllObjects];
    }
  }
  
  if (m_rectSelection)
  {
    CGRect newRect = m_selectionRect;
    
    newRect.origin = [m_game convertToNodeSpace:newRect.origin];
    
    newRect.size = CGSizeMake(newRect.size.width*(1.0f/m_game.scaleX), newRect.size.height*(1.0f/m_game.scaleY));
    
    for (nt_object * o in m_game.objects)
    {
      if (CGRectContainsPoint(newRect, o.position))
      {
        [m_game addSelectedObject:o];
      }
    }
  }
  
  m_rectSelection = NO;
  m_selectionRect = CGRectZero;
  
  if (edit)
  {
    [self checkGuides];
  }
  
  for (nt_object * o in m_game.selectedObjects)
    [m_game reorderChild:o z:10];
  
  [self unschedule:@selector(handleLongPress)];
  [m_game checkBounds];
  
  [m_document setLevel:m_game.level];
  [m_document updateChangeCount:UIDocumentChangeDone];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    [m_game removeAllObjects];
  }
}


- (void)ntalertViewWillShow:(nt_alertview *)sender
{
  
}


- (void)ntalertViewDidHide:(nt_alertview *)sender
{
  
}


- (void)createMenu
{
  float scale = self.screenSize.width / STANDARD_SCREEN_WIDTH;
  
  nt_buttonitem * pause = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"pause_button.png"] block:^(id sender)
                           {
                             nt_pausePopUp * p = [[nt_pausePopUp alloc] initWithDelegate:self];
                             
                             CCMenuItemFont * play = [CCMenuItemFont itemWithString:@"Test Level" target:self selector:@selector(testLevel)];
                             
                             CCMenuItemFont * set = [CCMenuItemFont itemWithString:@"Settings" block:^(id sender)
                                                      {
                                                        OverallSettingsViewController * v = [[OverallSettingsViewController alloc] init];
                                                        v.delegate = self;
                                                        v.modalPresentationStyle = UIModalPresentationFormSheet;
                                                        v.snaps = m_game.snaps;
                                                        v.guides = edit;
                                                        v.editMode = m_game.editMode;
                                                        v.defaultObject = m_defaultObject;
                                                        [self presentViewController:v animated:YES];
                                                        [v release];
                                                      }];
                             CCMenuItemFont * share = [CCMenuItemFont itemWithString:@"Share" target:self selector:@selector(emailLevel)];
                             
                             CCMenu * subMenu = [CCMenu menuWithItems:play, set, share, nil];
                             [subMenu alignItemsVertically];
                             [p addMenu:subMenu atPosition:CGPointMake(p.container.contentSize.width/2 + 50, p.container.contentSize.height/2)];
                             [p show];
                             [p release];
                           }];
  
  pause.scale = scale;
  
  CCMenu * menu = [CCMenu menuWithItems:pause, nil];
  menu.position = CGPointMake(pause.contentSize.width*scale/2 + 10, self.screenSize.height - (pause.contentSize.height*scale/2.0f) - 100*scale - 10); //100 = trashcan size
  [self addChild:menu];
}


- (void)objectAttributesViewController:(ObjectAttributesViewController *)sender didFinishWithAttributes:(NSArray *)attributes
{
  
}


- (void)multipleObjectsViewControllerDidDuplicate:(MultipleObjectsViewController *)sender
{
  [m_game.selectedObjects removeAllObjects];
  
  for (nt_object * o in sender.objects)
  {
    nt_object * oCopy = [o copy];
    
    [m_game addObject:oCopy];
    [m_game addSelectedObject:[m_game.objects lastObject]];
    
    [oCopy release];
  }
  
  [self checkGuides];
}


- (void)multipleObjectsViewControllerDidFinish:(MultipleObjectsViewController *)sender
{
  if (sender.duplicated)
    return;
  
  [m_game.selectedObjects removeAllObjects];
  
  for (nt_object * o in sender.objects)
  {
    [m_game addSelectedObject:o];
  }
  
  [self checkGuides];
}


- (void)overallSettingsViewControllerDidFinish:(OverallSettingsViewController *)sender
{
  m_game.snaps = sender.snaps;
  edit = sender.guides;
  m_game.editMode = (kEditMode)sender.editMode;
  
  if (m_game.editMode == kEditModeSingleSelection || m_game.editMode == kEditModeMultipleSelection)
  {
    [self showPallete];
  }
  else if (m_game.editMode == kEditModeSingleDeletion)
  {
    [self hidePallete];
    [m_game.selectedObjects removeAllObjects];
    [self enableGuides:NO];
  }
}


@end
